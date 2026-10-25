import Foundation

/// Hata Kumbarası (Mistake Vault) Ekran Durumu (Immutable ViewState - SwiftUI <-> Jetpack Compose 1:1)
public struct MistakeVaultViewState: Equatable, Sendable {
    public let profile: UserStudyProfile
    public let allMistakes: [MistakeVaultItem]
    public let selectedCategoryFilter: QuestionCategory?
    public let showOnlyUnresolved: Bool
    public let activePracticeQuestion: SprintQuestion?
    public let selectedPracticeOptionId: String?
    public let practiceFeedbackBannerTr: String?
    public let isDistractorBlurred: Bool
    public let isPaywallPresented: Bool

    public init(
        profile: UserStudyProfile = UserStudyProfile(hasCompletedOnboarding: true),
        allMistakes: [MistakeVaultItem] = MistakeVaultSeedData.initialMistakes,
        selectedCategoryFilter: QuestionCategory? = nil,
        showOnlyUnresolved: Bool = false,
        activePracticeQuestion: SprintQuestion? = nil,
        selectedPracticeOptionId: String? = nil,
        practiceFeedbackBannerTr: String? = nil,
        isDistractorBlurred: Bool = true,
        isPaywallPresented: Bool = false
    ) {
        self.profile = profile
        self.allMistakes = allMistakes
        self.selectedCategoryFilter = selectedCategoryFilter
        self.showOnlyUnresolved = showOnlyUnresolved
        self.activePracticeQuestion = activePracticeQuestion
        self.selectedPracticeOptionId = selectedPracticeOptionId
        self.practiceFeedbackBannerTr = practiceFeedbackBannerTr
        self.isDistractorBlurred = isDistractorBlurred
        self.isPaywallPresented = isPaywallPresented
    }

    // MARK: - Hesaplanmış Özellikler (Computed Properties)

    public var filteredMistakes: [MistakeVaultItem] {
        allMistakes.filter { item in
            let matchesCategory = (selectedCategoryFilter == nil) || (item.category == selectedCategoryFilter)
            let matchesResolved = !showOnlyUnresolved || !item.isResolved
            return matchesCategory && matchesResolved
        }
    }

    public var unresolvedCount: Int {
        allMistakes.filter { !$0.isResolved }.count
    }

    public var resolvedCount: Int {
        allMistakes.filter(\.isResolved).count
    }

    public var totalRecoverablePoints: Double {
        allMistakes.reduce(0.0) { $0 + $1.estimatedScoreRecoveryPoints }
    }

    public var recoverableScorePointsText: String {
        if unresolvedCount == 0 {
            return "Tebrikler! Kumbaradaki tüm sınav tuzaklarını çözdün ve puanlarını geri kazandın!"
        }
        return String(
            format: "Kumbaradaki %d Hatayı Kapatarak +%.2f Puan Geri Kazanabilirsin!",
            unresolvedCount,
            totalRecoverablePoints
        )
    }

    public var formattedCurrentScore: String {
        String(format: "%.2f", profile.currentEstimatedScore)
    }

    public var formattedTargetScore: String {
        String(format: "%.2f", profile.targetScore)
    }

    public var isPracticeAnsweredCorrectly: Bool {
        guard let selectedPracticeOptionId, let activePracticeQuestion else { return false }
        return selectedPracticeOptionId == activePracticeQuestion.correctOptionId
    }

    public var activeSelectedPracticeOption: QuestionOption? {
        guard let selectedPracticeOptionId, let activePracticeQuestion else { return nil }
        return activePracticeQuestion.options.first { $0.id == selectedPracticeOptionId }
    }
}

/// Hata Kumbarası Kullanıcı Niyetleri (UDF UiEvent)
public enum MistakeVaultUiEvent: Sendable {
    case onAppear
    case selectCategoryFilter(QuestionCategory?)
    case toggleUnresolvedFilter
    case startMistakeReviewQuestion(MistakeVaultItem)
    case submitPracticeOption(String)
    case closePracticeModal
    case openPaywall
    case dismissPaywall
    case upgradeSubscription(SubscriptionTier)
}
