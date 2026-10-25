import Combine
import Foundation

@MainActor
public final class OnboardingViewModel: ObservableObject {
    @Published public private(set) var state: OnboardingViewState

    private let userStudyRepository: any UserStudyRepository
    private let sprintQuestionRepository: any SprintQuestionRepository
    private let vocabularyRepository: any VocabularyRepository
    private let sentenceXRayRepository: any SentenceXRayRepository
    private let mistakeVaultRepository: any MistakeVaultRepository
    private let evaluateDiagnosticUseCase: EvaluateDiagnosticTestUseCase
    private let generatePrescriptionUseCase: GenerateDailyPrescriptionUseCase
    private let adaptiveUseCase: RunAdaptiveOnboardingDiagnosticUseCase
    private let onOnboardingFinished: (@Sendable () -> Void)?

    /// Feature flag: `false` ise eski 5 soruluk sabit teşhis akışı çalışır.
    private let useAdaptiveDiagnostic: Bool
    /// Adaptif soru havuzu (ilk ihtiyaçta repository'den yüklenir)
    private var adaptivePool: [SprintQuestion] = []
    /// Oturum sıfırlandığında artar; eski asenkron işlerin durumu ezmesini engeller
    private var flowGeneration = 0
    private var pendingTask: Task<Void, Never>?

    public init(
        container: AppDependencyContainer,
        initialState: OnboardingViewState = OnboardingViewState(),
        useAdaptiveDiagnostic: Bool = true,
        onOnboardingFinished: (@Sendable () -> Void)? = nil
    ) {
        self.useAdaptiveDiagnostic = useAdaptiveDiagnostic
        self.adaptiveUseCase = container.runAdaptiveOnboardingDiagnosticUseCase
        self.state = OnboardingViewState(
            currentStep: initialState.currentStep,
            selectedExam: initialState.selectedExam,
            selectedTrack: initialState.selectedTrack,
            declaredBaselineScore: initialState.declaredBaselineScore,
            targetScore: initialState.targetScore,
            daysRemaining: initialState.daysRemaining,
            diagnosticQuestions: initialState.diagnosticQuestions,
            currentQuestionIndex: initialState.currentQuestionIndex,
            selectedOptionIdForCurrentQuestion: initialState.selectedOptionIdForCurrentQuestion,
            isShowingInstantCoachFeedback: initialState.isShowingInstantCoachFeedback,
            recordedAnswers: initialState.recordedAnswers,
            useAdaptiveDiagnostic: useAdaptiveDiagnostic,
            selectedStartPath: initialState.selectedStartPath,
            adaptiveSession: initialState.adaptiveSession,
            isPathChooserVisible: initialState.isPathChooserVisible,
            lastAnswerWasCorrect: initialState.lastAnswerWasCorrect,
            estimatedLiveScoreHint: initialState.estimatedLiveScoreHint,
            liveScoreDeltaHint: initialState.liveScoreDeltaHint,
            remainingSeconds: initialState.remainingSeconds,
            didCurrentQuestionTimeOut: initialState.didCurrentQuestionTimeOut,
            diagnosticOutcome: initialState.diagnosticOutcome,
            diagnosticResult: initialState.diagnosticResult,
            previewPrescription: initialState.previewPrescription,
            selectedSubscriptionTier: initialState.selectedSubscriptionTier,
            isCompleted: initialState.isCompleted
        )
        self.userStudyRepository = container.userStudyRepository
        self.sprintQuestionRepository = container.sprintQuestionRepository
        self.vocabularyRepository = container.vocabularyRepository
        self.sentenceXRayRepository = container.sentenceXRayRepository
        self.mistakeVaultRepository = container.mistakeVaultRepository
        self.evaluateDiagnosticUseCase = container.evaluateDiagnosticTestUseCase
        self.generatePrescriptionUseCase = container.generateDailyPrescriptionUseCase
        self.onOnboardingFinished = onOnboardingFinished
    }

    public func onEvent(_ event: OnboardingUiEvent) {
        switch event {
        case .onAppear:
            run { await $0.loadDiagnosticQuestions() }

        case .selectExam(let exam):
            let defaultTrack: AcademicTrack = (exam == .yds || exam == .eYds) ? .generalAcademic : state.selectedTrack
            updateState(selectedExam: exam, selectedTrack: defaultTrack)

        case .selectTrack(let track):
            updateState(selectedTrack: track)

        case .updateDeclaredBaselineScore(let baseline):
            let rounded = (baseline * 4.0).rounded() / 4.0
            let adjustedTarget = max(state.targetScore, min(100.0, rounded + 10.0))
            updateState(declaredBaselineScore: rounded, targetScore: adjustedTarget)

        case .updateTargetScore(let target):
            let rounded = (target * 4.0).rounded() / 4.0
            let clamped = max(rounded, state.declaredBaselineScore + 5.0)
            updateState(targetScore: min(100.0, clamped))

        case .updateDaysRemaining(let days):
            updateState(daysRemaining: max(15, min(365, days)))

        case .proceedToNextStep:
            handleProceedToNextStep()

        case .goBackStep:
            handleGoBackStep()

        case .selectDiagnosticOption(let optionId):
            if useAdaptiveDiagnostic {
                handleAdaptiveOptionSelected(optionId)
            } else {
                updateState(
                    selectedOptionIdForCurrentQuestion: optionId,
                    isShowingInstantCoachFeedback: true
                )
            }

        case .submitCurrentDiagnosticQuestion:
            if useAdaptiveDiagnostic {
                handleAdaptiveAdvance()
            } else {
                handleDiagnosticQuestionAdvance()
            }

        case .selectStartPath(let path):
            guard useAdaptiveDiagnostic, state.currentStep == .step3DiagnosticTest, state.isPathChooserVisible else { return }
            updateState(selectedStartPath: path)

        case .confirmStartPath:
            handleConfirmStartPath()

        case .skipDiagnosticWithFreshStart:
            guard useAdaptiveDiagnostic, state.currentStep == .step3DiagnosticTest else { return }
            startFreshPath()

        case .tickTimer:
            handleTimerTick()

        case .selectSubscriptionPlan(let tier):
            updateState(selectedSubscriptionTier: tier)

        case .completeOnboardingWithSelectedTier(let tier):
            run { await $0.finalizeOnboarding(with: tier) }
        }
    }

    /// Başlatılan asenkron işin bitmesini bekler (testler ve deterministik akış için).
    public func waitForPendingWork() async {
        await pendingTask?.value
    }

    private func run(_ work: @escaping @MainActor (OnboardingViewModel) async -> Void) {
        let previous = pendingTask
        pendingTask = Task { [weak self] in
            await previous?.value
            guard let self else { return }
            await work(self)
        }
    }

    private func loadDiagnosticQuestions() async {
        // Adaptif akışta sorular yol seçildikten sonra tek tek gelir; eski liste yüklenmez.
        let questions = useAdaptiveDiagnostic ? [] : await sprintQuestionRepository.getDiagnosticQuestions()
        if state.isCompleted {
            flowGeneration += 1
            updateState(
                currentStep: .step1ExamAndTrack,
                diagnosticQuestions: questions,
                currentQuestionIndex: 0,
                selectedOptionIdForCurrentQuestion: .some(nil),
                isShowingInstantCoachFeedback: false,
                recordedAnswers: [],
                selectedStartPath: .quickDiagnostic,
                adaptiveSession: .some(nil),
                isPathChooserVisible: false,
                lastAnswerWasCorrect: .some(nil),
                estimatedLiveScoreHint: .some(nil),
                liveScoreDeltaHint: .some(nil),
                remainingSeconds: 0,
                didCurrentQuestionTimeOut: false,
                diagnosticOutcome: .some(nil),
                diagnosticResult: .some(nil),
                previewPrescription: .some(nil),
                isCompleted: false
            )
        } else if !useAdaptiveDiagnostic {
            updateState(diagnosticQuestions: questions)
        }
    }

    // MARK: - Adım 3 Yol Ayrımı (Adaptif Akış)

    /// Adaptif oturumu ve soru listesini sıfırlar; `showChooser` ile yol seçiciye döner.
    private func resetAdaptiveFlow(showChooser: Bool) {
        flowGeneration += 1
        updateState(
            diagnosticQuestions: [],
            currentQuestionIndex: 0,
            selectedOptionIdForCurrentQuestion: .some(nil),
            isShowingInstantCoachFeedback: false,
            recordedAnswers: [],
            selectedStartPath: .quickDiagnostic,
            adaptiveSession: .some(nil),
            isPathChooserVisible: showChooser,
            lastAnswerWasCorrect: .some(nil),
            estimatedLiveScoreHint: .some(nil),
            liveScoreDeltaHint: .some(nil),
            remainingSeconds: 0,
            didCurrentQuestionTimeOut: false,
            diagnosticOutcome: .some(nil)
        )
    }

    private func handleGoBackStep() {
        guard useAdaptiveDiagnostic else {
            if let prev = OnboardingStep(rawValue: state.currentStep.rawValue - 1) {
                updateState(currentStep: prev)
            }
            return
        }
        switch state.currentStep {
        case .step3DiagnosticTest:
            if state.isPathChooserVisible {
                // Yol seçiciden Adım 2'ye
                resetAdaptiveFlow(showChooser: false)
                updateState(currentStep: .step2ScoreAndTimeGoal)
            } else {
                // Soru ortasında geri: cevaplanmış soru geri açılmaz, yol seçiciye dönülür
                resetAdaptiveFlow(showChooser: true)
            }
        case .step4DiagnosisAndPrescription:
            // Teşhis sonucundan geri: oturum kapandığı için yol seçiciye dönülür
            resetAdaptiveFlow(showChooser: true)
            updateState(
                currentStep: .step3DiagnosticTest,
                diagnosticResult: .some(nil),
                previewPrescription: .some(nil)
            )
        default:
            if let prev = OnboardingStep(rawValue: state.currentStep.rawValue - 1) {
                updateState(currentStep: prev)
            }
        }
    }

    private func handleConfirmStartPath() {
        guard useAdaptiveDiagnostic,
              state.currentStep == .step3DiagnosticTest,
              state.isPathChooserVisible else { return }

        switch state.selectedStartPath {
        case .freshStart:
            startFreshPath()
        case .declaredScore:
            startAdaptiveSession(declaredBaseline: state.declaredBaselineScore)
        case .quickDiagnostic:
            startAdaptiveSession(declaredBaseline: nil)
        }
    }

    /// Yol C: soru yok, sabit baz puan; doğrudan Adım 4.
    private func startFreshPath() {
        let path = OnboardingStartPath.freshStart
        flowGeneration += 1
        let generation = flowGeneration
        updateState(
            diagnosticQuestions: [],
            currentQuestionIndex: 0,
            selectedOptionIdForCurrentQuestion: .some(nil),
            isShowingInstantCoachFeedback: false,
            selectedStartPath: path,
            adaptiveSession: .some(nil),
            isPathChooserVisible: false
        )
        run { vm in
            guard vm.flowGeneration == generation else { return }
            await vm.finishAdaptiveSession(
                session: vm.adaptiveUseCase.startSession(declaredBaseline: nil),
                declaredBaseline: nil,
                generation: generation
            )
        }
    }

    /// Yol A / B: oturumu başlatır ve ilk soruyu getirir.
    private func startAdaptiveSession(declaredBaseline: Double?) {
        let session = adaptiveUseCase.startSession(declaredBaseline: declaredBaseline)
        flowGeneration += 1
        let generation = flowGeneration
        updateState(
            diagnosticQuestions: [],
            currentQuestionIndex: 0,
            selectedOptionIdForCurrentQuestion: .some(nil),
            isShowingInstantCoachFeedback: false,
            adaptiveSession: session,
            isPathChooserVisible: false,
            lastAnswerWasCorrect: .some(nil),
            estimatedLiveScoreHint: .some(nil),
            liveScoreDeltaHint: .some(nil),
            didCurrentQuestionTimeOut: false
        )
        run { vm in
            // Yol B'de de beyan puanı yalnızca uyuşmazlık notu için kullanılır
            await vm.presentNextAdaptiveQuestion(
                session: session,
                declaredBaseline: vm.state.declaredBaselineScore,
                generation: generation
            )
        }
    }

    private func loadAdaptivePoolIfNeeded() async {
        if adaptivePool.isEmpty {
            adaptivePool = await sprintQuestionRepository.getAllQuestions()
        }
    }

    private var currentDeclaredBaselineForSession: Double? {
        state.selectedStartPath == .freshStart ? nil : state.declaredBaselineScore
    }

    private func presentNextAdaptiveQuestion(
        session: AdaptiveDiagnosticSession,
        declaredBaseline: Double?,
        generation: Int
    ) async {
        await loadAdaptivePoolIfNeeded()
        guard flowGeneration == generation else { return }

        let next = session.isComplete ? nil : adaptiveUseCase.nextQuestion(
            session: session,
            pool: adaptivePool,
            track: state.selectedTrack
        )
        guard let question = next else {
            // Oturum bitti ya da uygun soru kalmadı: eldeki cevaplarla sonuca git
            await finishAdaptiveSession(session: session, declaredBaseline: declaredBaseline, generation: generation)
            return
        }

        let questions = state.diagnosticQuestions + [question]
        updateState(
            diagnosticQuestions: questions,
            currentQuestionIndex: questions.count - 1,
            selectedOptionIdForCurrentQuestion: .some(nil),
            isShowingInstantCoachFeedback: false,
            lastAnswerWasCorrect: .some(nil),
            remainingSeconds: question.timeLimitSeconds,
            didCurrentQuestionTimeOut: false
        )
    }

    private func handleAdaptiveOptionSelected(_ optionId: String) {
        guard let session = state.adaptiveSession,
              let question = state.currentDiagnosticQuestion,
              !state.isCurrentQuestionAnswered,
              question.options.contains(where: { $0.id == optionId }) else { return }
        recordAdaptiveAnswer(question: question, selectedOptionId: optionId, session: session)
    }

    private func handleTimerTick() {
        guard useAdaptiveDiagnostic,
              state.currentStep == .step3DiagnosticTest,
              let session = state.adaptiveSession,
              let question = state.currentDiagnosticQuestion,
              !state.isCurrentQuestionAnswered,
              state.remainingSeconds > 0 else { return }

        let remaining = state.remainingSeconds - 1
        updateState(remainingSeconds: remaining)
        if remaining == 0 {
            recordAdaptiveAnswer(question: question, selectedOptionId: nil, session: session)
        }
    }

    /// Cevabı UseCase'e işler, soruyu kilitler, canlı puan ipucunu ve koç geri bildirimini açar.
    private func recordAdaptiveAnswer(
        question: SprintQuestion,
        selectedOptionId: String?,
        session: AdaptiveDiagnosticSession
    ) {
        let elapsed = Double(max(0, question.timeLimitSeconds - state.remainingSeconds))
        let record = adaptiveUseCase.recordAnswer(
            question: question,
            selectedOptionId: selectedOptionId,
            responseSeconds: elapsed,
            session: session
        )

        if let selectedOptionId,
           !record.isCorrect,
           let selectedOption = question.options.first(where: { $0.id == selectedOptionId }) {
            run { vm in
                await vm.mistakeVaultRepository.recordMistake(
                    question: question,
                    selectedOption: selectedOption,
                    date: Date()
                )
            }
        }

        updateState(
            selectedOptionIdForCurrentQuestion: .some(selectedOptionId),
            isShowingInstantCoachFeedback: true,
            adaptiveSession: .some(record.session),
            lastAnswerWasCorrect: .some(record.isCorrect),
            estimatedLiveScoreHint: .some(record.liveScore),
            liveScoreDeltaHint: .some(record.liveScoreDelta),
            didCurrentQuestionTimeOut: record.timedOut
        )
    }

    private func handleAdaptiveAdvance() {
        guard let session = state.adaptiveSession,
              state.isCurrentQuestionAnswered else { return }
        let declared = currentDeclaredBaselineForSession
        let generation = flowGeneration
        run { vm in
            await vm.presentNextAdaptiveQuestion(session: session, declaredBaseline: declared, generation: generation)
        }
    }

    private func finishAdaptiveSession(
        session: AdaptiveDiagnosticSession,
        declaredBaseline: Double?,
        generation: Int
    ) async {
        let evaluation = adaptiveUseCase.finalize(
            session: session,
            declaredBaseline: declaredBaseline,
            targetExam: state.selectedExam,
            academicTrack: state.selectedTrack,
            targetScore: state.targetScore,
            daysRemaining: state.daysRemaining
        )
        await moveToStep4(result: evaluation.result, outcome: evaluation.outcome, generation: generation)
    }

    private func handleProceedToNextStep() {
        switch state.currentStep {
        case .step1ExamAndTrack:
            updateState(currentStep: .step2ScoreAndTimeGoal)
        case .step2ScoreAndTimeGoal:
            if useAdaptiveDiagnostic {
                resetAdaptiveFlow(showChooser: true)
                updateState(currentStep: .step3DiagnosticTest)
            } else {
                updateState(
                    currentStep: .step3DiagnosticTest,
                    currentQuestionIndex: 0,
                    selectedOptionIdForCurrentQuestion: nil,
                    isShowingInstantCoachFeedback: false,
                    recordedAnswers: []
                )
            }
        case .step3DiagnosticTest:
            // Adaptif akışta ilerleme yol seçici / cevap olaylarıyla yönetilir
            guard !useAdaptiveDiagnostic else { return }
            run { await $0.computeDiagnosisAndMoveToStep4() }
        case .step4DiagnosisAndPrescription:
            updateState(currentStep: .step5StrategicPaywall)
        case .step5StrategicPaywall:
            run { await $0.finalizeOnboarding(with: $0.state.selectedSubscriptionTier) }
        }
    }

    private func handleDiagnosticQuestionAdvance() {
        guard let currentQuestion = state.currentDiagnosticQuestion,
              let selectedOptionId = state.selectedOptionIdForCurrentQuestion else {
            return
        }

        var updatedAnswers = state.recordedAnswers
        updatedAnswers.append(
            EvaluateDiagnosticTestUseCase.DiagnosticAnswerInput(
                question: currentQuestion,
                selectedOptionId: selectedOptionId
            )
        )

        if let selectedOption = currentQuestion.options.first(where: { $0.id == selectedOptionId }),
           selectedOptionId != currentQuestion.correctOptionId {
            run { vm in
                await vm.mistakeVaultRepository.recordMistake(
                    question: currentQuestion,
                    selectedOption: selectedOption,
                    date: Date()
                )
            }
        }

        let nextIndex = state.currentQuestionIndex + 1
        if nextIndex < state.diagnosticQuestions.count {
            updateState(
                currentQuestionIndex: nextIndex,
                selectedOptionIdForCurrentQuestion: nil,
                isShowingInstantCoachFeedback: false,
                recordedAnswers: updatedAnswers
            )
        } else {
            updateState(recordedAnswers: updatedAnswers)
            run { await $0.computeDiagnosisAndMoveToStep4() }
        }
    }

    private func computeDiagnosisAndMoveToStep4() async {
        let result = evaluateDiagnosticUseCase.execute(
            targetExam: state.selectedExam,
            academicTrack: state.selectedTrack,
            declaredBaselineScore: state.declaredBaselineScore,
            targetScore: state.targetScore,
            daysRemaining: state.daysRemaining,
            answers: state.recordedAnswers,
            subscriptionTier: .free
        )
        await moveToStep4(result: result, outcome: nil, generation: nil)
    }

    /// Reçeteyi üretir ve Adım 4'e geçer (eski ve adaptif akış ortak noktası).
    private func moveToStep4(
        result: EvaluateDiagnosticTestUseCase.DiagnosticEvaluationResult,
        outcome: AdaptiveDiagnosticOutcome?,
        generation: Int?
    ) async {
        let vocab = await vocabularyRepository.getAllVocabCards()
        let xrays = await sentenceXRayRepository.getAllXRayItems()
        let sprints = await sprintQuestionRepository.getAllQuestions()
        let mistakes = await mistakeVaultRepository.getMistakeItems()

        let prescription = generatePrescriptionUseCase.execute(
            profile: result.calibratedProfile,
            vocabCards: vocab,
            xrayItems: xrays,
            sprintQuestions: sprints,
            mistakeItems: mistakes
        )

        // Bekleme sırasında kullanıcı geri döndüyse eski sonucu uygulama
        if let generation, generation != flowGeneration { return }
        updateState(
            currentStep: .step4DiagnosisAndPrescription,
            adaptiveSession: .some(nil),
            isPathChooserVisible: false,
            diagnosticOutcome: .some(outcome),
            diagnosticResult: result,
            previewPrescription: prescription
        )
    }

    private func finalizeOnboarding(with tier: SubscriptionTier) async {
        let baseResult = state.diagnosticResult ?? evaluateDiagnosticUseCase.execute(
            targetExam: state.selectedExam,
            academicTrack: state.selectedTrack,
            declaredBaselineScore: state.declaredBaselineScore,
            targetScore: state.targetScore,
            daysRemaining: state.daysRemaining,
            answers: state.recordedAnswers,
            subscriptionTier: tier
        )

        let baseProfile = baseResult.calibratedProfile
        let finalProfile = UserStudyProfile(
            hasCompletedOnboarding: true,
            targetExam: baseProfile.targetExam,
            academicTrack: baseProfile.academicTrack,
            initialEstimatedScore: baseProfile.initialEstimatedScore,
            currentEstimatedScore: baseProfile.currentEstimatedScore,
            targetScore: baseProfile.targetScore,
            daysRemainingUntilExam: baseProfile.daysRemainingUntilExam,
            streakDays: baseProfile.streakDays,
            todayEarnedScoreDelta: baseProfile.todayEarnedScoreDelta,
            subscriptionTier: tier,
            dailyFreeXRayUsedCount: 0,
            completedPrescriptionStepsToday: 0,
            weakestCategories: baseProfile.weakestCategories
        )

        await userStudyRepository.saveUserProfile(finalProfile)
        await userStudyRepository.saveCategoryMasteries(baseResult.initialCategoryRecords)

        updateState(selectedSubscriptionTier: tier, isCompleted: true)
        onOnboardingFinished?()
    }

    private func updateState(
        currentStep: OnboardingStep? = nil,
        selectedExam: ExamType? = nil,
        selectedTrack: AcademicTrack? = nil,
        declaredBaselineScore: Double? = nil,
        targetScore: Double? = nil,
        daysRemaining: Int? = nil,
        diagnosticQuestions: [SprintQuestion]? = nil,
        currentQuestionIndex: Int? = nil,
        selectedOptionIdForCurrentQuestion: String?? = nil,
        isShowingInstantCoachFeedback: Bool? = nil,
        recordedAnswers: [EvaluateDiagnosticTestUseCase.DiagnosticAnswerInput]? = nil,
        selectedStartPath: OnboardingStartPath? = nil,
        adaptiveSession: AdaptiveDiagnosticSession?? = nil,
        isPathChooserVisible: Bool? = nil,
        lastAnswerWasCorrect: Bool?? = nil,
        estimatedLiveScoreHint: Double?? = nil,
        liveScoreDeltaHint: Double?? = nil,
        remainingSeconds: Int? = nil,
        didCurrentQuestionTimeOut: Bool? = nil,
        diagnosticOutcome: AdaptiveDiagnosticOutcome?? = nil,
        diagnosticResult: EvaluateDiagnosticTestUseCase.DiagnosticEvaluationResult?? = nil,
        previewPrescription: DailyPrescription?? = nil,
        selectedSubscriptionTier: SubscriptionTier? = nil,
        isCompleted: Bool? = nil
    ) {
        state = OnboardingViewState(
            currentStep: currentStep ?? state.currentStep,
            selectedExam: selectedExam ?? state.selectedExam,
            selectedTrack: selectedTrack ?? state.selectedTrack,
            declaredBaselineScore: declaredBaselineScore ?? state.declaredBaselineScore,
            targetScore: targetScore ?? state.targetScore,
            daysRemaining: daysRemaining ?? state.daysRemaining,
            diagnosticQuestions: diagnosticQuestions ?? state.diagnosticQuestions,
            currentQuestionIndex: currentQuestionIndex ?? state.currentQuestionIndex,
            selectedOptionIdForCurrentQuestion: selectedOptionIdForCurrentQuestion ?? state.selectedOptionIdForCurrentQuestion,
            isShowingInstantCoachFeedback: isShowingInstantCoachFeedback ?? state.isShowingInstantCoachFeedback,
            recordedAnswers: recordedAnswers ?? state.recordedAnswers,
            useAdaptiveDiagnostic: state.useAdaptiveDiagnostic,
            selectedStartPath: selectedStartPath ?? state.selectedStartPath,
            adaptiveSession: adaptiveSession ?? state.adaptiveSession,
            isPathChooserVisible: isPathChooserVisible ?? state.isPathChooserVisible,
            lastAnswerWasCorrect: lastAnswerWasCorrect ?? state.lastAnswerWasCorrect,
            estimatedLiveScoreHint: estimatedLiveScoreHint ?? state.estimatedLiveScoreHint,
            liveScoreDeltaHint: liveScoreDeltaHint ?? state.liveScoreDeltaHint,
            remainingSeconds: remainingSeconds ?? state.remainingSeconds,
            didCurrentQuestionTimeOut: didCurrentQuestionTimeOut ?? state.didCurrentQuestionTimeOut,
            diagnosticOutcome: diagnosticOutcome ?? state.diagnosticOutcome,
            diagnosticResult: diagnosticResult ?? state.diagnosticResult,
            previewPrescription: previewPrescription ?? state.previewPrescription,
            selectedSubscriptionTier: selectedSubscriptionTier ?? state.selectedSubscriptionTier,
            isCompleted: isCompleted ?? state.isCompleted
        )
    }
}
