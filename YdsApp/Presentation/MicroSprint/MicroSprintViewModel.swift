import Combine
import Foundation

@MainActor
public final class MicroSprintViewModel: ObservableObject {
    @Published public private(set) var state: MicroSprintViewState

    private let userStudyRepository: any UserStudyRepository
    private let sprintQuestionRepository: any SprintQuestionRepository
    private let mistakeVaultRepository: any MistakeVaultRepository
    private let calculateEstimatedScoreUseCase: CalculateEstimatedScoreUseCase
    private let checkEntitlementUseCase: CheckEntitlementUseCase

    private var countdownTask: Task<Void, Never>?

    public init(
        container: AppDependencyContainer,
        initialState: MicroSprintViewState = MicroSprintViewState()
    ) {
        self.state = initialState
        self.userStudyRepository = container.userStudyRepository
        self.sprintQuestionRepository = container.sprintQuestionRepository
        self.mistakeVaultRepository = container.mistakeVaultRepository
        self.calculateEstimatedScoreUseCase = container.calculateEstimatedScoreUseCase
        self.checkEntitlementUseCase = container.checkEntitlementUseCase
    }

    deinit {
        countdownTask?.cancel()
    }

    public func onEvent(_ event: MicroSprintUiEvent) {
        switch event {
        case .onAppear:
            Task { await loadInitialSprintSession() }

        case .selectSprintMode(let mode):
            Task { await switchSprintMode(mode) }

        case .selectTrack(let track):
            Task { await handleTrackSelection(track) }

        case .timerTick:
            handleTimerTick()

        case .toggleTranslationBlurClueMode:
            updateState(isStemBlurredExpectClues: !state.isStemBlurredExpectClues)

        case .selectLeftPolarity(let polarity):
            handlePolaritySelection(left: polarity, right: state.selectedRightPolarity)

        case .selectRightPolarity(let polarity):
            handlePolaritySelection(left: state.selectedLeftPolarity, right: polarity)

        case .selectOption(let optionId):
            handleOptionSelection(optionId)

        case .dismissDistractorCoachAndAdvance:
            advanceToNextQuestion()

        case .nextQuestion:
            advanceToNextQuestion()

        case .openPaywall(let reasonTr):
            updateState(isPaywallPresented: true, paywallReasonTr: reasonTr)

        case .dismissPaywall:
            updateState(isPaywallPresented: false)

        case .upgradeSubscription(let tier):
            Task { await applySubscriptionUpgrade(tier) }
        }
    }

    // MARK: - Private Logic

    private func loadInitialSprintSession() async {
        let profile = await userStudyRepository.getUserProfile()
        let isBlurred = checkEntitlementUseCase.shouldBlurDistractorCoachDetails(tier: profile.subscriptionTier)
        let questions = await sprintQuestionRepository.getQuestions(
            for: profile.academicTrack,
            mode: state.selectedMode,
            category: nil
        )
        let safeIndex = questions.indices.contains(state.currentIndex) ? state.currentIndex : 0
        let activeQuestion = questions.indices.contains(safeIndex) ? questions[safeIndex] : nil
        let limit = activeQuestion?.timeLimitSeconds ?? 10

        updateState(
            profile: profile,
            selectedTrack: profile.academicTrack,
            questions: questions,
            currentIndex: safeIndex,
            remainingSeconds: state.isQuestionSubmitted ? state.remainingSeconds : limit,
            totalLimitSeconds: limit,
            isStemBlurredExpectClues: state.selectedMode == .translation10SecHunt ? state.isStemBlurredExpectClues : false,
            isDistractorDetailsBlurred: isBlurred
        )

        if !state.isQuestionSubmitted {
            startCountdownTimer()
        }
    }

    private func switchSprintMode(_ mode: MicroSprintMode) async {
        countdownTask?.cancel()
        let profile = await userStudyRepository.getUserProfile()
        let isBlurred = checkEntitlementUseCase.shouldBlurDistractorCoachDetails(tier: profile.subscriptionTier)
        let questions = await sprintQuestionRepository.getQuestions(
            for: state.selectedTrack,
            mode: mode,
            category: nil
        )
        let firstLimit = questions.first?.timeLimitSeconds ?? (mode == .translation10SecHunt ? 10 : 35)

        updateState(
            profile: profile,
            selectedMode: mode,
            questions: questions,
            currentIndex: 0,
            remainingSeconds: firstLimit,
            totalLimitSeconds: firstLimit,
            isStemBlurredExpectClues: mode == .translation10SecHunt,
            selectedLeftPolarity: .some(nil),
            selectedRightPolarity: .some(nil),
            isPolarityRadarVerified: false,
            selectedOptionId: .some(nil),
            isQuestionSubmitted: false,
            activeDistractorCoachOption: .some(nil),
            isDistractorDetailsBlurred: isBlurred
        )

        startCountdownTimer()
    }

    private func handleTrackSelection(_ track: AcademicTrack) async {
        let profile = await userStudyRepository.getUserProfile()
        if track != profile.academicTrack &&
            !checkEntitlementUseCase.canSwitchAcademicTrackFilter(tier: profile.subscriptionTier) {
            updateState(
                isPaywallPresented: true,
                paywallReasonTr: "YÖKDİL Sağlık, Fen ve Sosyal Bilimler Mikro-Sprint soru havuzları arasında sınırsız filtreleme yapmak için YDS Pro'ya yükselt."
            )
            return
        }

        countdownTask?.cancel()
        let updatedProfile = UserStudyProfile(
            hasCompletedOnboarding: profile.hasCompletedOnboarding,
            targetExam: profile.targetExam,
            academicTrack: track,
            initialEstimatedScore: profile.initialEstimatedScore,
            currentEstimatedScore: profile.currentEstimatedScore,
            targetScore: profile.targetScore,
            daysRemainingUntilExam: profile.daysRemainingUntilExam,
            streakDays: profile.streakDays,
            todayEarnedScoreDelta: profile.todayEarnedScoreDelta,
            subscriptionTier: profile.subscriptionTier,
            dailyFreeXRayUsedCount: profile.dailyFreeXRayUsedCount,
            completedPrescriptionStepsToday: profile.completedPrescriptionStepsToday,
            weakestCategories: profile.weakestCategories
        )
        await userStudyRepository.saveUserProfile(updatedProfile)

        let questions = await sprintQuestionRepository.getQuestions(
            for: track,
            mode: state.selectedMode,
            category: nil
        )
        let firstLimit = questions.first?.timeLimitSeconds ?? 10

        updateState(
            profile: updatedProfile,
            selectedTrack: track,
            questions: questions,
            currentIndex: 0,
            remainingSeconds: firstLimit,
            totalLimitSeconds: firstLimit,
            isStemBlurredExpectClues: state.selectedMode == .translation10SecHunt,
            selectedLeftPolarity: .some(nil),
            selectedRightPolarity: .some(nil),
            isPolarityRadarVerified: false,
            selectedOptionId: .some(nil),
            isQuestionSubmitted: false,
            activeDistractorCoachOption: .some(nil)
        )

        startCountdownTimer()
    }

    private func startCountdownTimer() {
        countdownTask?.cancel()
        countdownTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { break }
                self?.onEvent(.timerTick)
            }
        }
    }

    private func handleTimerTick() {
        guard !state.isQuestionSubmitted else {
            countdownTask?.cancel()
            return
        }
        if state.remainingSeconds > 0 {
            let nextSeconds = state.remainingSeconds - 1
            updateState(remainingSeconds: nextSeconds)
            if nextSeconds == 0 {
                countdownTask?.cancel()
            }
        } else {
            countdownTask?.cancel()
        }
    }

    private func handlePolaritySelection(left: PolarityType?, right: PolarityType?) {
        guard let question = state.currentQuestion else { return }
        let verified: Bool
        if let expectedLeft = question.expectedLeftPolarity,
           let expectedRight = question.expectedRightPolarity,
           let left,
           let right {
            verified = (left == expectedLeft && right == expectedRight)
        } else {
            verified = (left != nil && right != nil)
        }

        updateState(
            selectedLeftPolarity: .some(left),
            selectedRightPolarity: .some(right),
            isPolarityRadarVerified: verified
        )
    }

    private func handleOptionSelection(_ optionId: String) {
        guard !state.isQuestionSubmitted,
              let question = state.currentQuestion,
              let selectedOption = question.options.first(where: { $0.id == optionId }) else {
            return
        }

        countdownTask?.cancel()

        let isCorrect = (optionId == question.correctOptionId)
        let elapsedSeconds = max(1, state.totalLimitSeconds - state.remainingSeconds)
        let shouldBlur = checkEntitlementUseCase.shouldBlurDistractorCoachDetails(tier: state.profile.subscriptionTier)

        updateState(
            selectedOptionId: .some(optionId),
            isQuestionSubmitted: true,
            activeDistractorCoachOption: .some(isCorrect ? nil : selectedOption),
            isDistractorDetailsBlurred: shouldBlur
        )

        Task {
            let currentProfile = await userStudyRepository.getUserProfile()
            let currentRecords = await userStudyRepository.getCategoryMasteries()

            let outcome = calculateEstimatedScoreUseCase.recordQuestionOutcome(
                category: question.category,
                difficultyBand: question.difficultyBand,
                isCorrect: isCorrect,
                responseTimeSeconds: elapsedSeconds,
                timeLimitSeconds: question.timeLimitSeconds,
                currentProfile: currentProfile,
                currentRecords: currentRecords
            )

            await userStudyRepository.saveUserProfile(outcome.updatedProfile)
            await userStudyRepository.saveCategoryMasteries(outcome.updatedRecords)
            await userStudyRepository.appendScoreEvent(outcome.scoreEvent)

            if !isCorrect {
                await mistakeVaultRepository.recordMistake(
                    question: question,
                    selectedOption: selectedOption,
                    date: Date()
                )
            }

            let newSessionDelta = ((state.sessionEarnedScoreDelta + outcome.earnedDelta) * 20.0).rounded() / 20.0
            let updatedBlur = checkEntitlementUseCase.shouldBlurDistractorCoachDetails(
                tier: outcome.updatedProfile.subscriptionTier
            )

            updateState(
                profile: outcome.updatedProfile,
                isDistractorDetailsBlurred: updatedBlur,
                sessionCorrectCount: state.sessionCorrectCount + (isCorrect ? 1 : 0),
                sessionSolvedCount: state.sessionSolvedCount + 1,
                sessionEarnedScoreDelta: newSessionDelta,
                latestScoreExplanation: .some(outcome.explanation),
                latestScoreTransitionText: .some(outcome.scoreEvent.transitionDisplayTr)
            )
        }
    }

    private func advanceToNextQuestion() {
        guard !state.questions.isEmpty else { return }
        countdownTask?.cancel()

        let nextIdx = (state.currentIndex + 1) % state.questions.count
        let nextQuestion = state.questions[nextIdx]
        let limit = nextQuestion.timeLimitSeconds

        updateState(
            currentIndex: nextIdx,
            remainingSeconds: limit,
            totalLimitSeconds: limit,
            isStemBlurredExpectClues: state.selectedMode == .translation10SecHunt,
            selectedLeftPolarity: .some(nil),
            selectedRightPolarity: .some(nil),
            isPolarityRadarVerified: false,
            selectedOptionId: .some(nil),
            isQuestionSubmitted: false,
            activeDistractorCoachOption: .some(nil)
        )

        startCountdownTimer()
    }

    private func applySubscriptionUpgrade(_ tier: SubscriptionTier) async {
        let current = await userStudyRepository.getUserProfile()
        let updatedProfile = UserStudyProfile(
            hasCompletedOnboarding: current.hasCompletedOnboarding,
            targetExam: current.targetExam,
            academicTrack: current.academicTrack,
            initialEstimatedScore: current.initialEstimatedScore,
            currentEstimatedScore: current.currentEstimatedScore,
            targetScore: current.targetScore,
            daysRemainingUntilExam: current.daysRemainingUntilExam,
            streakDays: current.streakDays,
            todayEarnedScoreDelta: current.todayEarnedScoreDelta,
            subscriptionTier: tier,
            dailyFreeXRayUsedCount: current.dailyFreeXRayUsedCount,
            completedPrescriptionStepsToday: current.completedPrescriptionStepsToday,
            weakestCategories: current.weakestCategories
        )
        await userStudyRepository.saveUserProfile(updatedProfile)

        let isBlurred = checkEntitlementUseCase.shouldBlurDistractorCoachDetails(tier: tier)
        updateState(
            profile: updatedProfile,
            isDistractorDetailsBlurred: isBlurred,
            isPaywallPresented: false
        )
    }

    private func updateState(
        profile: UserStudyProfile? = nil,
        selectedMode: MicroSprintMode? = nil,
        selectedTrack: AcademicTrack? = nil,
        questions: [SprintQuestion]? = nil,
        currentIndex: Int? = nil,
        remainingSeconds: Int? = nil,
        totalLimitSeconds: Int? = nil,
        isStemBlurredExpectClues: Bool? = nil,
        selectedLeftPolarity: PolarityType?? = nil,
        selectedRightPolarity: PolarityType?? = nil,
        isPolarityRadarVerified: Bool? = nil,
        selectedOptionId: String?? = nil,
        isQuestionSubmitted: Bool? = nil,
        activeDistractorCoachOption: QuestionOption?? = nil,
        isDistractorDetailsBlurred: Bool? = nil,
        sessionCorrectCount: Int? = nil,
        sessionSolvedCount: Int? = nil,
        sessionEarnedScoreDelta: Double? = nil,
        latestScoreExplanation: ScoreChangeExplanation?? = nil,
        latestScoreTransitionText: String?? = nil,
        isPaywallPresented: Bool? = nil,
        paywallReasonTr: String? = nil
    ) {
        state = MicroSprintViewState(
            profile: profile ?? state.profile,
            selectedMode: selectedMode ?? state.selectedMode,
            selectedTrack: selectedTrack ?? state.selectedTrack,
            questions: questions ?? state.questions,
            currentIndex: currentIndex ?? state.currentIndex,
            remainingSeconds: remainingSeconds ?? state.remainingSeconds,
            totalLimitSeconds: totalLimitSeconds ?? state.totalLimitSeconds,
            isStemBlurredExpectClues: isStemBlurredExpectClues ?? state.isStemBlurredExpectClues,
            selectedLeftPolarity: selectedLeftPolarity ?? state.selectedLeftPolarity,
            selectedRightPolarity: selectedRightPolarity ?? state.selectedRightPolarity,
            isPolarityRadarVerified: isPolarityRadarVerified ?? state.isPolarityRadarVerified,
            selectedOptionId: selectedOptionId ?? state.selectedOptionId,
            isQuestionSubmitted: isQuestionSubmitted ?? state.isQuestionSubmitted,
            activeDistractorCoachOption: activeDistractorCoachOption ?? state.activeDistractorCoachOption,
            isDistractorDetailsBlurred: isDistractorDetailsBlurred ?? state.isDistractorDetailsBlurred,
            sessionCorrectCount: sessionCorrectCount ?? state.sessionCorrectCount,
            sessionSolvedCount: sessionSolvedCount ?? state.sessionSolvedCount,
            sessionEarnedScoreDelta: sessionEarnedScoreDelta ?? state.sessionEarnedScoreDelta,
            latestScoreExplanation: latestScoreExplanation ?? state.latestScoreExplanation,
            latestScoreTransitionText: latestScoreTransitionText ?? state.latestScoreTransitionText,
            isPaywallPresented: isPaywallPresented ?? state.isPaywallPresented,
            paywallReasonTr: paywallReasonTr ?? state.paywallReasonTr
        )
    }
}
