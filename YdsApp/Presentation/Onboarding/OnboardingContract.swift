import Foundation

/// 5 Adımlı Kişiselleştirme ve Seviye Tespiti Adımları
public enum OnboardingStep: Int, CaseIterable, Equatable, Sendable {
    case step1ExamAndTrack = 1
    case step2ScoreAndTimeGoal = 2
    case step3DiagnosticTest = 3
    case step4DiagnosisAndPrescription = 4
    case step5StrategicPaywall = 5

    public var stepTitleTr: String {
        switch self {
        case .step1ExamAndTrack:
            return "Adım 1/5 • Hedef Sınav ve Akademik Alan"
        case .step2ScoreAndTimeGoal:
            return "Adım 2/5 • Puan ve Zaman Hedefi"
        case .step3DiagnosticTest:
            return "Adım 3/5 • 5 Soruluk Stratejik Seviye Tespiti"
        case .step4DiagnosisAndPrescription:
            return "Adım 4/5 • Teşhis Raporu ve Günlük Reçeten"
        case .step5StrategicPaywall:
            return "Adım 5/5 • Pro Antrenman Kilidi"
        }
    }

    public var progressFraction: Double {
        Double(rawValue) / 5.0
    }
}

/// Onboarding Ekran Durumu (Immutable ViewState - SwiftUI <-> Jetpack Compose 1:1)
public struct OnboardingViewState: Equatable, Sendable {
    public let currentStep: OnboardingStep
    public let selectedExam: ExamType
    public let selectedTrack: AcademicTrack
    public let declaredBaselineScore: Double
    public let targetScore: Double
    public let daysRemaining: Int

    // 5 Soruluk Teşhis Testi Durumu
    public let diagnosticQuestions: [SprintQuestion]
    public let currentQuestionIndex: Int
    public let selectedOptionIdForCurrentQuestion: String?
    public let isShowingInstantCoachFeedback: Bool
    public let recordedAnswers: [EvaluateDiagnosticTestUseCase.DiagnosticAnswerInput]

    // Adım 4 Teşhis ve Reçete Sonucu
    public let diagnosticResult: EvaluateDiagnosticTestUseCase.DiagnosticEvaluationResult?
    public let previewPrescription: DailyPrescription?

    // Adım 5 Paywall Seçimi
    public let selectedSubscriptionTier: SubscriptionTier
    public let isCompleted: Bool

    public init(
        currentStep: OnboardingStep = .step1ExamAndTrack,
        selectedExam: ExamType = .yokdil,
        selectedTrack: AcademicTrack = .healthSciences,
        declaredBaselineScore: Double = 45.0,
        targetScore: Double = 70.0,
        daysRemaining: Int = 90,
        diagnosticQuestions: [SprintQuestion] = [],
        currentQuestionIndex: Int = 0,
        selectedOptionIdForCurrentQuestion: String? = nil,
        isShowingInstantCoachFeedback: Bool = false,
        recordedAnswers: [EvaluateDiagnosticTestUseCase.DiagnosticAnswerInput] = [],
        diagnosticResult: EvaluateDiagnosticTestUseCase.DiagnosticEvaluationResult? = nil,
        previewPrescription: DailyPrescription? = nil,
        selectedSubscriptionTier: SubscriptionTier = .proAnnual,
        isCompleted: Bool = false
    ) {
        self.currentStep = currentStep
        self.selectedExam = selectedExam
        self.selectedTrack = selectedTrack
        self.declaredBaselineScore = declaredBaselineScore
        self.targetScore = targetScore
        self.daysRemaining = daysRemaining
        self.diagnosticQuestions = diagnosticQuestions
        self.currentQuestionIndex = currentQuestionIndex
        self.selectedOptionIdForCurrentQuestion = selectedOptionIdForCurrentQuestion
        self.isShowingInstantCoachFeedback = isShowingInstantCoachFeedback
        self.recordedAnswers = recordedAnswers
        self.diagnosticResult = diagnosticResult
        self.previewPrescription = previewPrescription
        self.selectedSubscriptionTier = selectedSubscriptionTier
        self.isCompleted = isCompleted
    }

    public var currentDiagnosticQuestion: SprintQuestion? {
        guard diagnosticQuestions.indices.contains(currentQuestionIndex) else { return nil }
        return diagnosticQuestions[currentQuestionIndex]
    }

    public var currentSelectedOption: QuestionOption? {
        guard let optionId = selectedOptionIdForCurrentQuestion,
              let question = currentDiagnosticQuestion else { return nil }
        return question.options.first { $0.id == optionId }
    }

    public var diagnosticProgressText: String {
        "Soru \(currentQuestionIndex + 1) / \(max(1, diagnosticQuestions.count))"
    }

    public var formattedDeclaredScore: String {
        String(format: "%.2f", declaredBaselineScore)
    }

    public var formattedTargetScore: String {
        String(format: "%.2f", targetScore)
    }

    public var formattedProjectedGain: String {
        String(format: "+%.2f Puan Hedefi", max(0.0, targetScore - declaredBaselineScore))
    }
}

/// Onboarding Kullanıcı Niyetleri (UDF UiEvent)
public enum OnboardingUiEvent: Sendable {
    case onAppear
    case selectExam(ExamType)
    case selectTrack(AcademicTrack)
    case updateDeclaredBaselineScore(Double)
    case updateTargetScore(Double)
    case updateDaysRemaining(Int)
    case proceedToNextStep
    case goBackStep
    case selectDiagnosticOption(String)
    case submitCurrentDiagnosticQuestion
    case selectSubscriptionPlan(SubscriptionTier)
    case completeOnboardingWithSelectedTier(SubscriptionTier)
}
