import Foundation

/// Akademik dil sınavı türleri (iOS <-> Android 1:1 Enum)
public enum ExamType: String, Codable, CaseIterable, Equatable, Sendable {
    case yds = "YDS"
    case eYds = "e-YDS"
    case yokdil = "YÖKDİL"

    public var displayName: String {
        rawValue
    }

    public var subtitleTr: String {
        switch self {
        case .yds:
            return "Yabancı Dil Bilgisi Seviye Tespit Sınavı (80 Soru)"
        case .eYds:
            return "Elektronik YDS - Bilgisayar Tabanlı Hız & Strateji"
        case .yokdil:
            return "Yükseköğretim Kurumları Yabancı Dil Sınavı (Alan Odaklı)"
        }
    }

    public var totalQuestions: Int { 80 }
    public var pointsPerQuestion: Double { 1.25 }
}

/// YÖKDİL ve YDS akademik alan filtreleri
public enum AcademicTrack: String, Codable, CaseIterable, Equatable, Sendable {
    case healthSciences = "HEALTH_SCIENCES"
    case naturalSciences = "NATURAL_SCIENCES"
    case socialSciences = "SOCIAL_SCIENCES"
    case generalAcademic = "GENERAL_ACADEMIC"

    public var titleTr: String {
        switch self {
        case .healthSciences:
            return "Sağlık Bilimleri"
        case .naturalSciences:
            return "Fen Bilimleri"
        case .socialSciences:
            return "Sosyal Bilimler"
        case .generalAcademic:
            return "Genel Akademik (YDS Karma)"
        }
    }

    public var shortTitleTr: String {
        switch self {
        case .healthSciences:
            return "Sağlık"
        case .naturalSciences:
            return "Fen"
        case .socialSciences:
            return "Sosyal"
        case .generalAcademic:
            return "Genel YDS"
        }
    }

    public var descriptionTr: String {
        switch self {
        case .healthSciences:
            return "Tıp, klinik araştırmalar, epidemiyoloji, nöroloji ve farmakoloji metinleri"
        case .naturalSciences:
            return "Mühendislik, astrofizik, iklim değişikliği, biyoteknoloji ve yapay zeka metinleri"
        case .socialSciences:
            return "Tarih, sosyoloji, arkeoloji, dilbilim, ekonomi ve felsefe metinleri"
        case .generalAcademic:
            return "YDS ve e-YDS formatında disiplinlerarası yüksek yoğunluklu akademik metinler"
        }
    }

    public var iconSystemName: String {
        switch self {
        case .healthSciences:
            return "cross.case.fill"
        case .naturalSciences:
            return "atom"
        case .socialSciences:
            return "building.columns.fill"
        case .generalAcademic:
            return "graduationcap.fill"
        }
    }
}

/// Abonelik kademesi (Freemium vs Pro)
public enum SubscriptionTier: String, Codable, CaseIterable, Equatable, Sendable {
    case free = "FREE"
    case proMonthly = "PRO_MONTHLY"
    case proAnnual = "PRO_ANNUAL"

    public var isPro: Bool {
        self != .free
    }

    public var displayNameTr: String {
        switch self {
        case .free:
            return "Ücretsiz Plan"
        case .proMonthly:
            return "YDS Pro (Aylık)"
        case .proAnnual:
            return "YDS Pro (Yıllık Avantaj)"
        }
    }
}

/// Cümle içi veya boşluk öncesi/sonrası anlam kutbu (+ / - / =)
public enum PolarityType: String, Codable, CaseIterable, Equatable, Sendable {
    case positive = "POSITIVE"
    case negative = "NEGATIVE"
    case neutral = "NEUTRAL"

    public var symbol: String {
        switch self {
        case .positive: return "+"
        case .negative: return "-"
        case .neutral: return "="
        }
    }

    public var badgeTitleTr: String {
        switch self {
        case .positive: return "Olumlu (+)"
        case .negative: return "Olumsuz (-)"
        case .neutral: return "Nötr (=)"
        }
    }
}

/// Kullanıcının çalışma profili ve tahmini sınav puanı durumu
public struct UserStudyProfile: Codable, Equatable, Sendable {
    public let hasCompletedOnboarding: Bool
    public let targetExam: ExamType
    public let academicTrack: AcademicTrack
    public let initialEstimatedScore: Double
    public let currentEstimatedScore: Double
    public let targetScore: Double
    public let daysRemainingUntilExam: Int
    public let streakDays: Int
    public let todayEarnedScoreDelta: Double
    public let subscriptionTier: SubscriptionTier
    public let dailyFreeXRayUsedCount: Int
    public let completedPrescriptionStepsToday: Int
    public let weakestCategories: [QuestionCategory]

    public init(
        hasCompletedOnboarding: Bool = false,
        targetExam: ExamType = .yokdil,
        academicTrack: AcademicTrack = .healthSciences,
        initialEstimatedScore: Double = 46.25,
        currentEstimatedScore: Double = 53.75,
        targetScore: Double = 70.00,
        daysRemainingUntilExam: Int = 90,
        streakDays: Int = 4,
        todayEarnedScoreDelta: Double = 0.40,
        subscriptionTier: SubscriptionTier = .free,
        dailyFreeXRayUsedCount: Int = 0,
        completedPrescriptionStepsToday: Int = 0,
        weakestCategories: [QuestionCategory] = [.conjunction, .preposition]
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.targetExam = targetExam
        self.academicTrack = academicTrack
        self.initialEstimatedScore = initialEstimatedScore
        self.currentEstimatedScore = currentEstimatedScore
        self.targetScore = targetScore
        self.daysRemainingUntilExam = daysRemainingUntilExam
        self.streakDays = streakDays
        self.todayEarnedScoreDelta = todayEarnedScoreDelta
        self.subscriptionTier = subscriptionTier
        self.dailyFreeXRayUsedCount = dailyFreeXRayUsedCount
        self.completedPrescriptionStepsToday = completedPrescriptionStepsToday
        self.weakestCategories = weakestCategories
    }

    public var neededScore: Double {
        max(0.0, targetScore - currentEstimatedScore)
    }

    public var totalScoreGainSoFar: Double {
        max(0.0, currentEstimatedScore - initialEstimatedScore)
    }

    public var dailyFreeXRayRemaining: Int {
        subscriptionTier.isPro ? 999 : max(0, 1 - dailyFreeXRayUsedCount)
    }

    public var estimatedCorrectAnswersOutOf80: Int {
        Int((currentEstimatedScore / 1.25).rounded())
    }
}
