import Foundation

/// 3 Boyutlu Kelime modülü etkileşim modları
public enum Vocab3DInteractionMode: String, CaseIterable, Equatable, Sendable {
    case explore3DCard = "EXPLORE_3D_CARD"
    case dimensionQuiz = "DIMENSION_QUIZ"

    public var titleTr: String {
        switch self {
        case .explore3DCard:
            return "3B Öğrenme Kartı"
        case .dimensionQuiz:
            return "3 Boyutlu Ustalık Testi"
        }
    }

    public var iconSystemName: String {
        switch self {
        case .explore3DCard:
            return "cube.transparent.fill"
        case .dimensionQuiz:
            return "checkmark.shield.fill"
        }
    }
}

/// 3 Boyutlu Kelime Ustalık Testi (Anlam / Zorunlu Edat / YDS İkizi) soru durumu
public struct Vocab3DQuizQuestionState: Equatable, Sendable {
    public let dimension: VocabQuizDimension
    public let promptTitleTr: String
    public let promptStem: String
    public let options: [String]
    public let correctOption: String
    public let selectedOption: String?
    public let isAnswered: Bool
    public let isCorrect: Bool?

    public init(
        dimension: VocabQuizDimension,
        promptTitleTr: String,
        promptStem: String,
        options: [String],
        correctOption: String,
        selectedOption: String? = nil,
        isAnswered: Bool = false,
        isCorrect: Bool? = nil
    ) {
        self.dimension = dimension
        self.promptTitleTr = promptTitleTr
        self.promptStem = promptStem
        self.options = options
        self.correctOption = correctOption
        self.selectedOption = selectedOption
        self.isAnswered = isAnswered
        self.isCorrect = isCorrect
    }
}

/// 3 Boyutlu Kelime, Zorunlu Edat ve YDS İkizleri Ekran Durumu (Immutable ViewState - SwiftUI <-> Jetpack Compose 1:1)
public struct Vocab3DViewState: Equatable, Sendable {
    public let profile: UserStudyProfile
    public let selectedTrack: AcademicTrack
    public let interactionMode: Vocab3DInteractionMode
    public let cards: [Vocab3DCard]
    public let currentIndex: Int
    public let activeDimensionTab: VocabQuizDimension
    public let currentQuizState: Vocab3DQuizQuestionState?
    public let lastEvaluationFeedbackTr: String?
    public let lastEarnedScoreDeltaText: String?
    public let isPaywallPresented: Bool
    public let paywallReasonTr: String

    public init(
        profile: UserStudyProfile = UserStudyProfile(hasCompletedOnboarding: true),
        selectedTrack: AcademicTrack = .healthSciences,
        interactionMode: Vocab3DInteractionMode = .explore3DCard,
        cards: [Vocab3DCard] = Vocab3DSeedData.healthCards,
        currentIndex: Int = 0,
        activeDimensionTab: VocabQuizDimension = .meaning,
        currentQuizState: Vocab3DQuizQuestionState? = nil,
        lastEvaluationFeedbackTr: String? = nil,
        lastEarnedScoreDeltaText: String? = nil,
        isPaywallPresented: Bool = false,
        paywallReasonTr: String = "YÖKDİL Sağlık, Fen ve Sosyal Bilimler 3 boyutlu kelime paketleri arasında sınırsız geçiş için YDS Pro'ya yükselt."
    ) {
        self.profile = profile
        self.selectedTrack = selectedTrack
        self.interactionMode = interactionMode
        self.cards = cards
        self.currentIndex = currentIndex
        self.activeDimensionTab = activeDimensionTab
        self.currentQuizState = currentQuizState
        self.lastEvaluationFeedbackTr = lastEvaluationFeedbackTr
        self.lastEarnedScoreDeltaText = lastEarnedScoreDeltaText
        self.isPaywallPresented = isPaywallPresented
        self.paywallReasonTr = paywallReasonTr
    }

    // MARK: - Computed Properties

    public var currentCard: Vocab3DCard? {
        guard cards.indices.contains(currentIndex) else { return cards.first }
        return cards[currentIndex]
    }

    public var fullyLearnedCount: Int {
        cards.filter(\.isFullyLearned).count
    }

    public var masterySummaryBannerTr: String {
        String(
            format: "Tam Öğrenilen (3/3 Boyut): %d/%d Kelime • Tahmini Puan: %.2f",
            fullyLearnedCount,
            cards.count,
            profile.currentEstimatedScore
        )
    }

    public var progressPositionText: String {
        let total = max(1, cards.count)
        let current = cards.isEmpty ? 0 : (currentIndex + 1)
        return "Kelime \(current) / \(total) • \(selectedTrack.titleTr)"
    }

    public var canGoPrevious: Bool {
        currentIndex > 0
    }

    public var canGoNext: Bool {
        currentIndex + 1 < cards.count
    }

    public var formattedCurrentScore: String {
        String(format: "%.2f", profile.currentEstimatedScore)
    }

    public var formattedTargetScore: String {
        String(format: "%.2f", profile.targetScore)
    }
}

/// 3 Boyutlu Kelime Kullanıcı Niyetleri (UDF UiEvent)
public enum Vocab3DUiEvent: Sendable {
    case onAppear
    case selectTrack(AcademicTrack)
    case switchInteractionMode(Vocab3DInteractionMode)
    case selectDimensionTab(VocabQuizDimension)
    case selectQuizOption(String)
    case advanceToNextQuizOrCard
    case nextCard
    case previousCard
    case dismissPaywall
    case upgradeSubscription(SubscriptionTier)
}
