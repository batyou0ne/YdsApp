import Foundation

/// İnteraktif Cümle Röntgeni (Sentence X-Ray) Ekran Durumu (Immutable ViewState - SwiftUI <-> Jetpack Compose 1:1)
public struct SentenceXRayViewState: Equatable, Sendable {
    public let profile: UserStudyProfile
    public let selectedTrack: AcademicTrack
    public let items: [SentenceXRayItem]
    public let currentIndex: Int
    public let isXRayActive: Bool
    public let selectedSegmentId: String?
    public let isTranslationVisible: Bool
    public let isPaywallPresented: Bool
    public let paywallReasonTr: String
    public let scoreToastMessageTr: String?
    public let masteredItemIds: Set<String>

    public init(
        profile: UserStudyProfile = UserStudyProfile(hasCompletedOnboarding: true),
        selectedTrack: AcademicTrack = .healthSciences,
        items: [SentenceXRayItem] = SentenceXRaySeedData.healthItems,
        currentIndex: Int = 0,
        isXRayActive: Bool = false,
        selectedSegmentId: String? = nil,
        isTranslationVisible: Bool = false,
        isPaywallPresented: Bool = false,
        paywallReasonTr: String = "Ücretsiz planda günde 1 Cümle Röntgeni açabilirsin. Sınırsız Cümle Röntgeni ve alan filtreleri için YDS Pro'ya geç.",
        scoreToastMessageTr: String? = nil,
        masteredItemIds: Set<String> = []
    ) {
        self.profile = profile
        self.selectedTrack = selectedTrack
        self.items = items
        self.currentIndex = currentIndex
        self.isXRayActive = isXRayActive
        self.selectedSegmentId = selectedSegmentId
        self.isTranslationVisible = isTranslationVisible
        self.isPaywallPresented = isPaywallPresented
        self.paywallReasonTr = paywallReasonTr
        self.scoreToastMessageTr = scoreToastMessageTr
        self.masteredItemIds = masteredItemIds
    }

    // MARK: - Computed Properties

    public var currentItem: SentenceXRayItem? {
        guard items.indices.contains(currentIndex) else { return items.first }
        return items[currentIndex]
    }

    public var selectedSegment: SentenceSegment? {
        guard let item = currentItem else { return nil }
        if let selectedSegmentId,
           let match = item.segments.first(where: { $0.id == selectedSegmentId }) {
            return match
        }
        return item.segments.first(where: { $0.examLogicTipTr != nil }) ?? item.segments.first
    }

    public var progressPositionText: String {
        let total = max(1, items.count)
        let current = items.isEmpty ? 0 : (currentIndex + 1)
        return "Cümle \(current) / \(total) • \(selectedTrack.titleTr)"
    }

    public var freeXRayQuotaBadgeText: String {
        if profile.subscriptionTier.isPro {
            return "PRO • Sınırsız Röntgen"
        } else {
            return "Günlük Ücretsiz Röntgen Hakkı: \(profile.dailyFreeXRayRemaining)/1"
        }
    }

    public var isCurrentSentenceMastered: Bool {
        guard let item = currentItem else { return false }
        return masteredItemIds.contains(item.id)
    }

    public var canGoPrevious: Bool {
        currentIndex > 0
    }

    public var canGoNext: Bool {
        currentIndex + 1 < items.count
    }

    public var formattedCurrentScore: String {
        String(format: "%.2f", profile.currentEstimatedScore)
    }

    public var formattedTargetScore: String {
        String(format: "%.2f", profile.targetScore)
    }
}

/// İnteraktif Cümle Röntgeni Kullanıcı Niyetleri (UDF UiEvent)
public enum SentenceXRayUiEvent: Sendable {
    case onAppear
    case selectTrack(AcademicTrack)
    case toggleXRayMode
    case selectSegment(String)
    case toggleFullTranslation
    case nextSentence
    case previousSentence
    case markSentenceMastered
    case dismissPaywall
    case upgradeSubscription(SubscriptionTier)
}
