import Combine
import Foundation

@MainActor
public final class WeeklyCheckInViewModel: ObservableObject {
    @Published public private(set) var state: WeeklyCheckInViewState

    private let userStudyRepository: any UserStudyRepository
    private let sprintQuestionRepository: any SprintQuestionRepository
    private let mistakeVaultRepository: any MistakeVaultRepository
    private let weeklyCheckInRepository: any WeeklyCheckInRepository

    private let buildWeeklyCheckInUseCase: BuildWeeklyCheckInUseCase
    private let evaluateWeeklyCheckInUseCase: EvaluateWeeklyCheckInUseCase
    private let checkInEligibilityUseCase: CheckInEligibilityUseCase
    private let checkEntitlementUseCase: CheckEntitlementUseCase

    private var timerCancellable: AnyCancellable?

    public init(
        container: AppDependencyContainer,
        initialState: WeeklyCheckInViewState = WeeklyCheckInViewState(),
        preloadedQuestions: [SprintQuestion]? = nil
    ) {
        self.state = initialState
        self.userStudyRepository = container.userStudyRepository
        self.sprintQuestionRepository = container.sprintQuestionRepository
        self.mistakeVaultRepository = container.mistakeVaultRepository
        self.weeklyCheckInRepository = container.weeklyCheckInRepository

        self.buildWeeklyCheckInUseCase = container.buildWeeklyCheckInUseCase
        self.evaluateWeeklyCheckInUseCase = container.evaluateWeeklyCheckInUseCase
        self.checkInEligibilityUseCase = container.checkInEligibilityUseCase
        self.checkEntitlementUseCase = container.checkEntitlementUseCase

        if let preloaded = preloadedQuestions, !preloaded.isEmpty {
            self.state = WeeklyCheckInViewState(
                phase: initialState.phase,
                questions: preloaded,
                currentQuestionIndex: 0,
                remainingTimeSeconds: initialState.remainingTimeSeconds,
                totalTimeSeconds: initialState.totalTimeSeconds,
                selectedAnswers: initialState.selectedAnswers,
                flaggedQuestionIds: initialState.flaggedQuestionIds,
                report: initialState.report,
                isPaywallBlurActive: initialState.isPaywallBlurActive
            )
        } else {
            Task { await loadInitialQuestions() }
        }
    }

    public func onEvent(_ event: WeeklyCheckInUiEvent) {
        switch event {
        case .start:
            startCheckIn()

        case .selectOption(let questionId, let optionId):
            var updated = state.selectedAnswers
            updated[questionId] = optionId
            updateState(selectedAnswers: updated)

        case .leaveBlank(let questionId):
            var updated = state.selectedAnswers
            updated.removeValue(forKey: questionId)
            updateState(selectedAnswers: updated)

        case .flagQuestion(let questionId):
            var flags = state.flaggedQuestionIds
            if flags.contains(questionId) {
                flags.remove(questionId)
            } else {
                flags.insert(questionId)
            }
            updateState(flaggedQuestionIds: flags)

        case .jumpToQuestion(let index):
            if index >= 0 && index < state.questions.count {
                updateState(currentQuestionIndex: index)
            }

        case .nextQuestion:
            if state.canGoNext {
                updateState(currentQuestionIndex: state.currentQuestionIndex + 1)
            }

        case .previousQuestion:
            if state.canGoPrevious {
                updateState(currentQuestionIndex: state.currentQuestionIndex - 1)
            }

        case .tickTimer:
            handleTimerTick()

        case .submitAll:
            Task { await finishAndEvaluateCheckIn() }

        case .openMistakeCoach(let questionId):
            openCoachForQuestion(questionId: questionId)

        case .dismissMistakeCoach:
            updateState(
                activeDistractorQuestion: .some(nil),
                activeDistractorWrongOption: .some(nil)
            )

        case .openPaywall(let reasonTr):
            updateState(isPaywallSheetPresented: true, paywallTriggerReasonTr: reasonTr)

        case .dismissPaywall:
            updateState(isPaywallSheetPresented: false)

        case .upgradeSubscription(let tier):
            Task { await applySubscriptionUpgrade(tier) }

        case .dismiss:
            stopTimer()
            updateState(isDismissed: true)
        }
    }

    // MARK: - Soru Yükleme
    public func loadInitialQuestions() async {
        let allQuestions = await sprintQuestionRepository.getAllQuestions()
        let mistakes = await mistakeVaultRepository.getMistakeItems()
        let profile = await userStudyRepository.getUserProfile()

        let selected = buildWeeklyCheckInUseCase.execute(
            availableQuestions: allQuestions,
            mistakes: mistakes,
            profile: profile
        )

        let isBlurred = checkEntitlementUseCase.shouldBlurDistractorCoachDetails(tier: profile.subscriptionTier)

        updateState(
            questions: selected,
            currentQuestionIndex: 0,
            isPaywallBlurActive: isBlurred
        )
    }

    // MARK: - Sınav Akışı
    private func startCheckIn() {
        updateState(phase: .inProgress, currentQuestionIndex: 0)
        startTimer()
    }

    private func startTimer() {
        stopTimer()
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.onEvent(.tickTimer)
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func handleTimerTick() {
        guard state.phase == .inProgress else { return }
        let nextRemaining = state.remainingTimeSeconds - 1

        if nextRemaining <= 0 {
            updateState(remainingTimeSeconds: 0)
            stopTimer()
            Task { await finishAndEvaluateCheckIn() }
        } else {
            updateState(remainingTimeSeconds: nextRemaining)
        }
    }

    // MARK: - Sınavı Bitirme ve Değerlendirme
    public func finishAndEvaluateCheckIn() async {
        stopTimer()
        let profile = await userStudyRepository.getUserProfile()
        let masteries = await userStudyRepository.getCategoryMasteries()
        let latestReport = await weeklyCheckInRepository.getLatestReport()
        let elapsed = max(1, state.totalTimeSeconds - state.remainingTimeSeconds)

        let (report, outcome) = evaluateWeeklyCheckInUseCase.execute(
            questions: state.questions,
            answers: state.selectedAnswers,
            elapsedSeconds: elapsed,
            profile: profile,
            categoryRecords: masteries,
            previousReport: latestReport
        )

        // Veri katmanına yazma
        await userStudyRepository.saveUserProfile(outcome.updatedProfile)
        await userStudyRepository.appendScoreEvent(outcome.scoreEvent)
        await weeklyCheckInRepository.saveCheckInReport(report)

        // Yanlış ve boş soruları Hata Kumbarasına (MistakeVault) kaydetme
        for q in state.questions {
            let answer = state.selectedAnswers[q.id]?.trimmingCharacters(in: .whitespacesAndNewlines)
            let isCorrect = answer != nil && answer == q.correctOptionId

            if !isCorrect {
                let wrongOption: QuestionOption
                if let ans = answer, let opt = q.options.first(where: { $0.id == ans }) {
                    wrongOption = opt
                } else {
                    // Boş bırakılmışsa ilk çeldiriciyi temel al
                    wrongOption = q.options.first(where: { $0.id != q.correctOptionId }) ?? q.options[0]
                }
                await mistakeVaultRepository.recordMistake(question: q, selectedOption: wrongOption, date: Date())
            }
        }

        updateState(
            phase: .report,
            report: report,
            isPaywallBlurActive: report.isPaywallBlurActive
        )
    }

    private func openCoachForQuestion(questionId: String) {
        guard let question = state.questions.first(where: { $0.id == questionId }) else { return }
        let selectedId = state.selectedAnswers[questionId]
        let wrongOption: QuestionOption?
        if let sel = selectedId {
            wrongOption = question.options.first { $0.id == sel }
        } else {
            wrongOption = question.options.first { $0.id != question.correctOptionId }
        }
        updateState(
            activeDistractorQuestion: question,
            activeDistractorWrongOption: wrongOption
        )
    }

    private func applySubscriptionUpgrade(_ tier: SubscriptionTier) async {
        let current = await userStudyRepository.getUserProfile()
        let updated = current.copying(subscriptionTier: tier)
        await userStudyRepository.saveUserProfile(updated)

        updateState(
            isPaywallBlurActive: false,
            isPaywallSheetPresented: false
        )
    }

    // MARK: - Immutability Koruyucu Helper
    private func updateState(
        phase: WeeklyCheckInPhase? = nil,
        questions: [SprintQuestion]? = nil,
        currentQuestionIndex: Int? = nil,
        remainingTimeSeconds: Int? = nil,
        totalTimeSeconds: Int? = nil,
        selectedAnswers: [String: String]? = nil,
        flaggedQuestionIds: Set<String>? = nil,
        report: CheckInReport?? = nil,
        isPaywallBlurActive: Bool? = nil,
        activeDistractorQuestion: SprintQuestion?? = nil,
        activeDistractorWrongOption: QuestionOption?? = nil,
        isPaywallSheetPresented: Bool? = nil,
        paywallTriggerReasonTr: String? = nil,
        isDismissed: Bool? = nil
    ) {
        state = WeeklyCheckInViewState(
            phase: phase ?? state.phase,
            questions: questions ?? state.questions,
            currentQuestionIndex: currentQuestionIndex ?? state.currentQuestionIndex,
            remainingTimeSeconds: remainingTimeSeconds ?? state.remainingTimeSeconds,
            totalTimeSeconds: totalTimeSeconds ?? state.totalTimeSeconds,
            selectedAnswers: selectedAnswers ?? state.selectedAnswers,
            flaggedQuestionIds: flaggedQuestionIds ?? state.flaggedQuestionIds,
            report: report != nil ? report! : state.report,
            isPaywallBlurActive: isPaywallBlurActive ?? state.isPaywallBlurActive,
            activeDistractorQuestion: activeDistractorQuestion != nil ? activeDistractorQuestion! : state.activeDistractorQuestion,
            activeDistractorWrongOption: activeDistractorWrongOption != nil ? activeDistractorWrongOption! : state.activeDistractorWrongOption,
            isPaywallSheetPresented: isPaywallSheetPresented ?? state.isPaywallSheetPresented,
            paywallTriggerReasonTr: paywallTriggerReasonTr ?? state.paywallTriggerReasonTr,
            isDismissed: isDismissed ?? state.isDismissed
        )
    }
}
