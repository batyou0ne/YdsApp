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
    private let onOnboardingFinished: (@Sendable () -> Void)?

    public init(
        container: AppDependencyContainer,
        initialState: OnboardingViewState = OnboardingViewState(),
        onOnboardingFinished: (@Sendable () -> Void)? = nil
    ) {
        self.state = initialState
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
            Task { await loadDiagnosticQuestions() }

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
            if let prev = OnboardingStep(rawValue: state.currentStep.rawValue - 1) {
                updateState(currentStep: prev)
            }

        case .selectDiagnosticOption(let optionId):
            updateState(
                selectedOptionIdForCurrentQuestion: optionId,
                isShowingInstantCoachFeedback: true
            )

        case .submitCurrentDiagnosticQuestion:
            handleDiagnosticQuestionAdvance()

        case .selectSubscriptionPlan(let tier):
            updateState(selectedSubscriptionTier: tier)

        case .completeOnboardingWithSelectedTier(let tier):
            Task { await finalizeOnboarding(with: tier) }
        }
    }

    private func loadDiagnosticQuestions() async {
        let questions = await sprintQuestionRepository.getDiagnosticQuestions()
        if state.isCompleted {
            updateState(
                currentStep: .step1ExamAndTrack,
                diagnosticQuestions: questions,
                currentQuestionIndex: 0,
                selectedOptionIdForCurrentQuestion: .some(nil),
                isShowingInstantCoachFeedback: false,
                recordedAnswers: [],
                diagnosticResult: .some(nil),
                previewPrescription: .some(nil),
                isCompleted: false
            )
        } else {
            updateState(diagnosticQuestions: questions)
        }
    }

    private func handleProceedToNextStep() {
        switch state.currentStep {
        case .step1ExamAndTrack:
            updateState(currentStep: .step2ScoreAndTimeGoal)
        case .step2ScoreAndTimeGoal:
            updateState(
                currentStep: .step3DiagnosticTest,
                currentQuestionIndex: 0,
                selectedOptionIdForCurrentQuestion: nil,
                isShowingInstantCoachFeedback: false,
                recordedAnswers: []
            )
        case .step3DiagnosticTest:
            Task { await computeDiagnosisAndMoveToStep4() }
        case .step4DiagnosisAndPrescription:
            updateState(currentStep: .step5StrategicPaywall)
        case .step5StrategicPaywall:
            Task { await finalizeOnboarding(with: state.selectedSubscriptionTier) }
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
            Task {
                await mistakeVaultRepository.recordMistake(
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
            Task { await computeDiagnosisAndMoveToStep4() }
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

        updateState(
            currentStep: .step4DiagnosisAndPrescription,
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
            diagnosticResult: diagnosticResult ?? state.diagnosticResult,
            previewPrescription: previewPrescription ?? state.previewPrescription,
            selectedSubscriptionTier: selectedSubscriptionTier ?? state.selectedSubscriptionTier,
            isCompleted: isCompleted ?? state.isCompleted
        )
    }
}
