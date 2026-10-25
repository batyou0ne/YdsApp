import Foundation

/// Haftalık Check-In Akış Aşamaları
public enum WeeklyCheckInPhase: String, CaseIterable, Equatable, Sendable {
    case intro
    case inProgress
    case report
    case review
}

/// Haftalık Check-In Ekran Durumu (Immutable ViewState - SwiftUI <-> Jetpack Compose 1:1)
public struct WeeklyCheckInViewState: Equatable, Sendable {
    public let phase: WeeklyCheckInPhase
    public let questions: [SprintQuestion]
    public let currentQuestionIndex: Int
    public let remainingTimeSeconds: Int
    public let totalTimeSeconds: Int
    public let selectedAnswers: [String: String]
    public let flaggedQuestionIds: Set<String>
    public let report: CheckInReport?
    public let isPaywallBlurActive: Bool
    public let activeDistractorQuestion: SprintQuestion?
    public let activeDistractorWrongOption: QuestionOption?
    public let isPaywallSheetPresented: Bool
    public let paywallTriggerReasonTr: String
    public let isDismissed: Bool

    public init(
        phase: WeeklyCheckInPhase = .intro,
        questions: [SprintQuestion] = [],
        currentQuestionIndex: Int = 0,
        remainingTimeSeconds: Int = 1200, // 20 dakika
        totalTimeSeconds: Int = 1200,
        selectedAnswers: [String: String] = [:],
        flaggedQuestionIds: Set<String> = [],
        report: CheckInReport? = nil,
        isPaywallBlurActive: Bool = false,
        activeDistractorQuestion: SprintQuestion? = nil,
        activeDistractorWrongOption: QuestionOption? = nil,
        isPaywallSheetPresented: Bool = false,
        paywallTriggerReasonTr: String = "Çeldirici Koçu kural detaylarını ve soru tipi karnesi derin analizini açmak için Pro'ya geç.",
        isDismissed: Bool = false
    ) {
        self.phase = phase
        self.questions = questions
        self.currentQuestionIndex = currentQuestionIndex
        self.remainingTimeSeconds = remainingTimeSeconds
        self.totalTimeSeconds = totalTimeSeconds
        self.selectedAnswers = selectedAnswers
        self.flaggedQuestionIds = flaggedQuestionIds
        self.report = report
        self.isPaywallBlurActive = isPaywallBlurActive
        self.activeDistractorQuestion = activeDistractorQuestion
        self.activeDistractorWrongOption = activeDistractorWrongOption
        self.isPaywallSheetPresented = isPaywallSheetPresented
        self.paywallTriggerReasonTr = paywallTriggerReasonTr
        self.isDismissed = isDismissed
    }

    public var totalQuestionsCount: Int {
        questions.count
    }

    public var currentQuestion: SprintQuestion? {
        guard currentQuestionIndex >= 0 && currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    public var answeredCount: Int {
        selectedAnswers.values.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }

    public var remainingQuestionsCount: Int {
        max(0, totalQuestionsCount - answeredCount)
    }

    public var flaggedCount: Int {
        flaggedQuestionIds.count
    }

    public var formattedTimer: String {
        let m = max(0, remainingTimeSeconds) / 60
        let s = max(0, remainingTimeSeconds) % 60
        return String(format: "%02d:%02d", m, s)
    }

    public var isTimeCritical: Bool {
        remainingTimeSeconds <= 180 // Son 3 dakika
    }

    public var currentSelectedOptionId: String? {
        guard let current = currentQuestion else { return nil }
        return selectedAnswers[current.id]
    }

    public var isCurrentFlagged: Bool {
        guard let current = currentQuestion else { return false }
        return flaggedQuestionIds.contains(current.id)
    }

    public var canGoPrevious: Bool {
        currentQuestionIndex > 0
    }

    public var canGoNext: Bool {
        currentQuestionIndex < totalQuestionsCount - 1
    }

    public var progressFraction: Double {
        guard totalQuestionsCount > 0 else { return 0.0 }
        return Double(answeredCount) / Double(totalQuestionsCount)
    }
}

/// Haftalık Check-In Kullanıcı Niyetleri (UDF UiEvent)
public enum WeeklyCheckInUiEvent: Sendable {
    case start
    case selectOption(questionId: String, optionId: String)
    case leaveBlank(questionId: String)
    case flagQuestion(questionId: String)
    case jumpToQuestion(index: Int)
    case nextQuestion
    case previousQuestion
    case submitAll
    case tickTimer
    case openMistakeCoach(questionId: String)
    case dismissMistakeCoach
    case openPaywall(reasonTr: String)
    case dismissPaywall
    case upgradeSubscription(SubscriptionTier)
    case dismiss
}
