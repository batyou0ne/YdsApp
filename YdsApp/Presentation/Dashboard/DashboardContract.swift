import Foundation

/// Uygulama içi ana sekme hedefleri
public enum AppMainTab: String, CaseIterable, Equatable, Sendable {
    case dashboard = "DASHBOARD"
    case sentenceXRay = "SENTENCE_XRAY"
    case vocab3D = "VOCAB_3D"
    case microSprint = "MICRO_SPRINT"
    case mistakeVault = "MISTAKE_VAULT"

    public var titleTr: String {
        switch self {
        case .dashboard: return "Reçete & Karne"
        case .sentenceXRay: return "Cümle Röntgeni"
        case .vocab3D: return "3B Kelime"
        case .microSprint: return "Mikro-Sprint"
        case .mistakeVault: return "Hata Kumbarası"
        }
    }

    public var iconSystemName: String {
        switch self {
        case .dashboard: return "gauge.with.dots.needle.67percent"
        case .sentenceXRay: return "waveform.path.ecg.rectangle.fill"
        case .vocab3D: return "cube.transparent.fill"
        case .microSprint: return "bolt.badge.clock.fill"
        case .mistakeVault: return "tray.full.fill"
        }
    }
}

/// Dashboard Ekran Durumu (Immutable ViewState - SwiftUI <-> Jetpack Compose 1:1)
public struct DashboardViewState: Equatable, Sendable {
    public let profile: UserStudyProfile
    public let reportCard: ScoreReportCard
    public let dailyPrescription: DailyPrescription
    public let isPaywallPresented: Bool
    public let paywallTriggerReasonTr: String
    public let workoutCompletionBannerTr: String?
    public let requestedNavigationTab: AppMainTab?

    public init(
        profile: UserStudyProfile = UserStudyProfile(hasCompletedOnboarding: true),
        reportCard: ScoreReportCard = ScoreReportCard(
            estimatedTotalScore: 53.75,
            initialBaselineScore: 46.25,
            targetScore: 70.00,
            neededScore: 16.25,
            todayEarnedDelta: 0.40,
            categoryRecords: MistakeVaultSeedData.defaultCategoryMasteries,
            topWeakCategories: [.conjunction, .preposition]
        ),
        dailyPrescription: DailyPrescription = DailyPrescription(dateString: "Bugün", track: .healthSciences, steps: []),
        isPaywallPresented: Bool = false,
        paywallTriggerReasonTr: String = "Günlük reçetenin tamamını (%100 - 14 adım) ve sınırsız Cümle Röntgenini açmak için Pro'ya geç.",
        workoutCompletionBannerTr: String? = nil,
        requestedNavigationTab: AppMainTab? = nil
    ) {
        self.profile = profile
        self.reportCard = reportCard
        self.dailyPrescription = dailyPrescription
        self.isPaywallPresented = isPaywallPresented
        self.paywallTriggerReasonTr = paywallTriggerReasonTr
        self.workoutCompletionBannerTr = workoutCompletionBannerTr
        self.requestedNavigationTab = requestedNavigationTab
    }

    public var formattedCurrentScore: String {
        String(format: "%.2f", profile.currentEstimatedScore)
    }

    public var formattedInitialScore: String {
        String(format: "%.2f", profile.initialEstimatedScore)
    }

    public var formattedTargetScore: String {
        String(format: "%.2f", profile.targetScore)
    }

    public var formattedNeededScore: String {
        String(format: "+%.2f Puan Kaldı", profile.neededScore)
    }

    public var formattedTodayDelta: String {
        String(format: "+%.2f puan", profile.todayEarnedScoreDelta)
    }

    public var scoreTrajectorySummaryTr: String {
        String(format: "%.2f -> %.2f", profile.initialEstimatedScore, profile.currentEstimatedScore)
    }

    public var gaugeProgressFraction: Double {
        min(max(profile.currentEstimatedScore / 100.0, 0.05), 1.0)
    }

    public var targetMarkerFraction: Double {
        min(max(profile.targetScore / 100.0, 0.10), 1.0)
    }

    public var prescriptionButtonTitleTr: String {
        let completed = dailyPrescription.completedStepsCount
        let total = max(14, dailyPrescription.totalStepsCount)
        if completed == 0 {
            return "Günün 15 Dakikalık Antrenmanını Başlat (14 Adım)"
        } else if completed < total {
            return "Günün Antrenmanına Devam Et (\(completed)/\(total) Adım)"
        } else {
            return "Günün Antrenmanı Tamamlandı (+0.55 Puan Eklendi!)"
        }
    }

    public var freeTierGatingSubtitleTr: String {
        if profile.subscriptionTier.isPro {
            return "Pro Aktif • 14 Adımlık Tam Reçete ve Alan Filtreleri Açık"
        } else {
            return "Ücretsiz Plan • İlk 7 Adım (%50) Açık • 8. Adımda Pro Kilidi"
        }
    }
}

/// Dashboard Kullanıcı Niyetleri (UDF UiEvent)
public enum DashboardUiEvent: Sendable {
    case onAppear
    case startNextPrescriptionStep
    case tapPrescriptionStep(DailyPrescriptionStep)
    case selectAcademicTrackFilter(AcademicTrack)
    case openPaywall(reasonTr: String)
    case dismissPaywall
    case upgradeSubscription(SubscriptionTier)
    case clearNavigationRequest
    case restartOnboardingDiagnostic
}
