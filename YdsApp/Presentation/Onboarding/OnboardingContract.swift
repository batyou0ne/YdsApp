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
            return "Adım 3/5 • Seviyeni Belirle"
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

/// Adım 3 "Nasıl Başlamak İstersin?" yol seçenekleri.
public enum OnboardingStartPath: String, CaseIterable, Equatable, Sendable {
    /// Yol A: Beyan puanı (Adım 2) + 2 teyit sorusu
    case declaredScore = "DECLARED_SCORE"
    /// Yol B: 6 adaptif soru (önerilen, varsayılan)
    case quickDiagnostic = "QUICK_DIAGNOSTIC"
    /// Yol C: Soru yok, sabit baz puan (35.00)
    case freshStart = "FRESH_START"

    public var titleTr: String {
        switch self {
        case .declaredScore: return "Son Sınav Puanım Var"
        case .quickDiagnostic: return "3 Dakikalık Hızlı Teşhis"
        case .freshStart: return "Sıfırdan Başlıyorum"
        }
    }

    public var subtitleTr: String {
        switch self {
        case .declaredScore: return "Adım 2'de girdiğin puanı 2 kısa soruyla birlikte teyit ederiz."
        case .quickDiagnostic: return "6 kısa soru: sana göre kolaylaşır ya da zorlaşır. En net sonuç bu yoldan çıkar."
        case .freshStart: return "Soru yok. 35.00 puandan başlarız; birkaç gün çalışınca puanını netleştiririz."
        }
    }

    public var iconSystemName: String {
        switch self {
        case .declaredScore: return "doc.text.magnifyingglass"
        case .quickDiagnostic: return "bolt.heart.fill"
        case .freshStart: return "leaf.fill"
        }
    }

    public var isRecommended: Bool { self == .quickDiagnostic }
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

    // Adım 3 Yol Ayrımı ve Adaptif Teşhis Durumu
    /// `false` ise eski 5 soruluk akış çalışır (feature flag `useAdaptiveDiagnostic`)
    public let useAdaptiveDiagnostic: Bool
    public let selectedStartPath: OnboardingStartPath
    public let adaptiveSession: AdaptiveDiagnosticSession?
    public let isPathChooserVisible: Bool
    /// Son cevabın doğruluğu (anlık mikro geri bildirim); cevap verilmediyse `nil`
    public let lastAnswerWasCorrect: Bool?
    /// Her cevaptan sonra güncellenen canlı Tahmini Sınav Puanı ipucu (0.00–100.00)
    public let estimatedLiveScoreHint: Double?
    /// Son cevabın canlı puana etkisi (örn. `+0.50`)
    public let liveScoreDeltaHint: Double?
    /// Mevcut sorunun kalan süresi (sn)
    public let remainingSeconds: Int
    public let didCurrentQuestionTimeOut: Bool
    public let diagnosticOutcome: AdaptiveDiagnosticOutcome?

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
        useAdaptiveDiagnostic: Bool = true,
        selectedStartPath: OnboardingStartPath = .quickDiagnostic,
        adaptiveSession: AdaptiveDiagnosticSession? = nil,
        isPathChooserVisible: Bool = false,
        lastAnswerWasCorrect: Bool? = nil,
        estimatedLiveScoreHint: Double? = nil,
        liveScoreDeltaHint: Double? = nil,
        remainingSeconds: Int = 0,
        didCurrentQuestionTimeOut: Bool = false,
        diagnosticOutcome: AdaptiveDiagnosticOutcome? = nil,
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
        self.useAdaptiveDiagnostic = useAdaptiveDiagnostic
        self.selectedStartPath = selectedStartPath
        self.adaptiveSession = adaptiveSession
        self.isPathChooserVisible = isPathChooserVisible
        self.lastAnswerWasCorrect = lastAnswerWasCorrect
        self.estimatedLiveScoreHint = estimatedLiveScoreHint
        self.liveScoreDeltaHint = liveScoreDeltaHint
        self.remainingSeconds = remainingSeconds
        self.didCurrentQuestionTimeOut = didCurrentQuestionTimeOut
        self.diagnosticOutcome = diagnosticOutcome
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
        if let session = adaptiveSession {
            return "Soru \(currentQuestionIndex + 1) / \(max(1, session.maxQuestions))"
        }
        return "Soru \(currentQuestionIndex + 1) / \(max(1, diagnosticQuestions.count))"
    }

    /// Cevap sonrası gösterilecek koç geri bildirimi: seçilen şık; süre dolduysa doğru şık.
    public var feedbackOption: QuestionOption? {
        if let selected = currentSelectedOption { return selected }
        guard didCurrentQuestionTimeOut, let question = currentDiagnosticQuestion else { return nil }
        return question.options.first { $0.id == question.correctOptionId }
    }

    /// Mevcut sorunun cevaplanıp kilitlenip kilitlenmediği (adaptif akışta cevap geri açılmaz)
    public var isCurrentQuestionAnswered: Bool {
        isShowingInstantCoachFeedback
    }

    /// "Seviye: Orta"
    public var levelIndicatorText: String {
        "Seviye: \((adaptiveSession?.currentBand ?? .medium).titleTr)"
    }

    /// Kalan süre halkası için 0.0–1.0
    public var remainingTimeFraction: Double {
        guard let limit = currentDiagnosticQuestion?.timeLimitSeconds, limit > 0 else { return 0 }
        return min(1.0, max(0.0, Double(remainingSeconds) / Double(limit)))
    }

    /// Soru ilerleme çubuğu için 0.0–1.0 (cevaplanan / toplam)
    public var diagnosticProgressFraction: Double {
        guard let session = adaptiveSession, session.maxQuestions > 0 else { return 0 }
        return Double(session.answers.count) / Double(session.maxQuestions)
    }

    /// "+0.50 puan" / "-0.25 puan"; yalnızca fark varsa
    public var liveScoreHintText: String? {
        guard let hint = estimatedLiveScoreHint else { return nil }
        let base = String(format: "Tahmini puan: %.2f", locale: Locale(identifier: "en_US_POSIX"), hint)
        guard let delta = liveScoreDeltaHint, abs(delta) > 0.0001 else { return base }
        return base + String(format: " (%+.2f puan)", locale: Locale(identifier: "en_US_POSIX"), delta)
    }

    /// "51.25 (±5)"
    public var formattedOutcomeScoreWithRange: String? {
        guard let outcome = diagnosticOutcome else { return nil }
        let half = Int(((outcome.confidenceUpperBound - outcome.confidenceLowerBound) / 2.0).rounded())
        return String(format: "%.2f (±%d)", locale: Locale(identifier: "en_US_POSIX"), outcome.estimatedScore, half)
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
    case selectStartPath(OnboardingStartPath)
    case confirmStartPath
    case skipDiagnosticWithFreshStart
    /// Saniyelik zamanlayıcı vuruşu (View'dan gelir; süre mantığı ViewModel'de)
    case tickTimer
    case selectSubscriptionPlan(SubscriptionTier)
    case completeOnboardingWithSelectedTier(SubscriptionTier)
}
