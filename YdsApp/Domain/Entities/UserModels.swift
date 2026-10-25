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

    // Canlı Puan Motoru & Borsa Kalibrasyon Alanları
    public let scoreConfidenceMargin: Double?
    public let todayLossScoreDelta: Double
    public let totalQuestionsSolvedCount: Int
    public let consecutiveCorrectByCategory: [String: Int]
    public let declaredBaselineScore: Double?
    public let hasScoreDiscrepancy: Bool
    public let daysActiveCount: Int
    public let lastCheckInDate: Date?
    public let lastCheckInScore: Double?

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
        weakestCategories: [QuestionCategory] = [.conjunction, .preposition],
        scoreConfidenceMargin: Double? = 5.0,
        todayLossScoreDelta: Double = 0.0,
        totalQuestionsSolvedCount: Int = 0,
        consecutiveCorrectByCategory: [String: Int] = [:],
        declaredBaselineScore: Double? = nil,
        hasScoreDiscrepancy: Bool = false,
        daysActiveCount: Int = 1,
        lastCheckInDate: Date? = nil,
        lastCheckInScore: Double? = nil
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
        self.scoreConfidenceMargin = scoreConfidenceMargin
        self.todayLossScoreDelta = todayLossScoreDelta
        self.totalQuestionsSolvedCount = totalQuestionsSolvedCount
        self.consecutiveCorrectByCategory = consecutiveCorrectByCategory
        self.declaredBaselineScore = declaredBaselineScore
        self.hasScoreDiscrepancy = hasScoreDiscrepancy
        self.daysActiveCount = daysActiveCount
        self.lastCheckInDate = lastCheckInDate
        self.lastCheckInScore = lastCheckInScore
    }

    private enum CodingKeys: String, CodingKey {
        case hasCompletedOnboarding
        case targetExam
        case academicTrack
        case initialEstimatedScore
        case currentEstimatedScore
        case targetScore
        case daysRemainingUntilExam
        case streakDays
        case todayEarnedScoreDelta
        case subscriptionTier
        case dailyFreeXRayUsedCount
        case completedPrescriptionStepsToday
        case weakestCategories
        case scoreConfidenceMargin
        case todayLossScoreDelta
        case totalQuestionsSolvedCount
        case consecutiveCorrectByCategory
        case declaredBaselineScore
        case hasScoreDiscrepancy
        case daysActiveCount
        case lastCheckInDate
        case lastCheckInScore
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.hasCompletedOnboarding = try c.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
        self.targetExam = try c.decodeIfPresent(ExamType.self, forKey: .targetExam) ?? .yokdil
        self.academicTrack = try c.decodeIfPresent(AcademicTrack.self, forKey: .academicTrack) ?? .healthSciences
        self.initialEstimatedScore = try c.decodeIfPresent(Double.self, forKey: .initialEstimatedScore) ?? 46.25
        self.currentEstimatedScore = try c.decodeIfPresent(Double.self, forKey: .currentEstimatedScore) ?? 53.75
        self.targetScore = try c.decodeIfPresent(Double.self, forKey: .targetScore) ?? 70.00
        self.daysRemainingUntilExam = try c.decodeIfPresent(Int.self, forKey: .daysRemainingUntilExam) ?? 90
        self.streakDays = try c.decodeIfPresent(Int.self, forKey: .streakDays) ?? 4
        self.todayEarnedScoreDelta = try c.decodeIfPresent(Double.self, forKey: .todayEarnedScoreDelta) ?? 0.40
        self.subscriptionTier = try c.decodeIfPresent(SubscriptionTier.self, forKey: .subscriptionTier) ?? .free
        self.dailyFreeXRayUsedCount = try c.decodeIfPresent(Int.self, forKey: .dailyFreeXRayUsedCount) ?? 0
        self.completedPrescriptionStepsToday = try c.decodeIfPresent(Int.self, forKey: .completedPrescriptionStepsToday) ?? 0
        self.weakestCategories = try c.decodeIfPresent([QuestionCategory].self, forKey: .weakestCategories) ?? [.conjunction, .preposition]
        self.scoreConfidenceMargin = try c.decodeIfPresent(Double.self, forKey: .scoreConfidenceMargin) ?? 5.0
        self.todayLossScoreDelta = try c.decodeIfPresent(Double.self, forKey: .todayLossScoreDelta) ?? 0.0
        self.totalQuestionsSolvedCount = try c.decodeIfPresent(Int.self, forKey: .totalQuestionsSolvedCount) ?? 0
        self.consecutiveCorrectByCategory = try c.decodeIfPresent([String: Int].self, forKey: .consecutiveCorrectByCategory) ?? [:]
        self.declaredBaselineScore = try c.decodeIfPresent(Double.self, forKey: .declaredBaselineScore)
        self.hasScoreDiscrepancy = try c.decodeIfPresent(Bool.self, forKey: .hasScoreDiscrepancy) ?? false
        self.daysActiveCount = try c.decodeIfPresent(Int.self, forKey: .daysActiveCount) ?? 1
        self.lastCheckInDate = try c.decodeIfPresent(Date.self, forKey: .lastCheckInDate)
        self.lastCheckInScore = try c.decodeIfPresent(Double.self, forKey: .lastCheckInScore)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(hasCompletedOnboarding, forKey: .hasCompletedOnboarding)
        try c.encode(targetExam, forKey: .targetExam)
        try c.encode(academicTrack, forKey: .academicTrack)
        try c.encode(initialEstimatedScore, forKey: .initialEstimatedScore)
        try c.encode(currentEstimatedScore, forKey: .currentEstimatedScore)
        try c.encode(targetScore, forKey: .targetScore)
        try c.encode(daysRemainingUntilExam, forKey: .daysRemainingUntilExam)
        try c.encode(streakDays, forKey: .streakDays)
        try c.encode(todayEarnedScoreDelta, forKey: .todayEarnedScoreDelta)
        try c.encode(subscriptionTier, forKey: .subscriptionTier)
        try c.encode(dailyFreeXRayUsedCount, forKey: .dailyFreeXRayUsedCount)
        try c.encode(completedPrescriptionStepsToday, forKey: .completedPrescriptionStepsToday)
        try c.encode(weakestCategories, forKey: .weakestCategories)
        try c.encodeIfPresent(scoreConfidenceMargin, forKey: .scoreConfidenceMargin)
        try c.encode(todayLossScoreDelta, forKey: .todayLossScoreDelta)
        try c.encode(totalQuestionsSolvedCount, forKey: .totalQuestionsSolvedCount)
        try c.encode(consecutiveCorrectByCategory, forKey: .consecutiveCorrectByCategory)
        try c.encodeIfPresent(declaredBaselineScore, forKey: .declaredBaselineScore)
        try c.encode(hasScoreDiscrepancy, forKey: .hasScoreDiscrepancy)
        try c.encode(daysActiveCount, forKey: .daysActiveCount)
        try c.encodeIfPresent(lastCheckInDate, forKey: .lastCheckInDate)
        try c.encodeIfPresent(lastCheckInScore, forKey: .lastCheckInScore)
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

    /// Güven aralığı metni (örn: "±1.50 puan")
    public var formattedConfidenceMarginTr: String {
        String(format: "±%.2f puan", scoreConfidenceMargin ?? 5.0)
    }

    /// Güven aralığı alt sınırı (0.00'dan küçük olamaz)
    public var confidenceLowerBound: Double {
        max(0.0, currentEstimatedScore - (scoreConfidenceMargin ?? 5.0))
    }

    /// Güven aralığı üst sınırı (100.00'den büyük olamaz)
    public var confidenceUpperBound: Double {
        min(100.0, currentEstimatedScore + (scoreConfidenceMargin ?? 5.0))
    }

    /// Profilin immutability'sini bozmadan tek bir alanı güncelleyip yeni kopya dönen yardımcı metot
    public func copying(
        hasCompletedOnboarding: Bool? = nil,
        targetExam: ExamType? = nil,
        academicTrack: AcademicTrack? = nil,
        initialEstimatedScore: Double? = nil,
        currentEstimatedScore: Double? = nil,
        targetScore: Double? = nil,
        daysRemainingUntilExam: Int? = nil,
        streakDays: Int? = nil,
        todayEarnedScoreDelta: Double? = nil,
        subscriptionTier: SubscriptionTier? = nil,
        dailyFreeXRayUsedCount: Int? = nil,
        completedPrescriptionStepsToday: Int? = nil,
        weakestCategories: [QuestionCategory]? = nil,
        scoreConfidenceMargin: Double? = nil,
        todayLossScoreDelta: Double? = nil,
        totalQuestionsSolvedCount: Int? = nil,
        consecutiveCorrectByCategory: [String: Int]? = nil,
        declaredBaselineScore: Double? = nil,
        hasScoreDiscrepancy: Bool? = nil,
        daysActiveCount: Int? = nil,
        lastCheckInDate: Date?? = nil,
        lastCheckInScore: Double?? = nil
    ) -> UserStudyProfile {
        UserStudyProfile(
            hasCompletedOnboarding: hasCompletedOnboarding ?? self.hasCompletedOnboarding,
            targetExam: targetExam ?? self.targetExam,
            academicTrack: academicTrack ?? self.academicTrack,
            initialEstimatedScore: initialEstimatedScore ?? self.initialEstimatedScore,
            currentEstimatedScore: currentEstimatedScore ?? self.currentEstimatedScore,
            targetScore: targetScore ?? self.targetScore,
            daysRemainingUntilExam: daysRemainingUntilExam ?? self.daysRemainingUntilExam,
            streakDays: streakDays ?? self.streakDays,
            todayEarnedScoreDelta: todayEarnedScoreDelta ?? self.todayEarnedScoreDelta,
            subscriptionTier: subscriptionTier ?? self.subscriptionTier,
            dailyFreeXRayUsedCount: dailyFreeXRayUsedCount ?? self.dailyFreeXRayUsedCount,
            completedPrescriptionStepsToday: completedPrescriptionStepsToday ?? self.completedPrescriptionStepsToday,
            weakestCategories: weakestCategories ?? self.weakestCategories,
            scoreConfidenceMargin: scoreConfidenceMargin ?? self.scoreConfidenceMargin,
            todayLossScoreDelta: todayLossScoreDelta ?? self.todayLossScoreDelta,
            totalQuestionsSolvedCount: totalQuestionsSolvedCount ?? self.totalQuestionsSolvedCount,
            consecutiveCorrectByCategory: consecutiveCorrectByCategory ?? self.consecutiveCorrectByCategory,
            declaredBaselineScore: declaredBaselineScore ?? self.declaredBaselineScore,
            hasScoreDiscrepancy: hasScoreDiscrepancy ?? self.hasScoreDiscrepancy,
            daysActiveCount: daysActiveCount ?? self.daysActiveCount,
            lastCheckInDate: lastCheckInDate != nil ? lastCheckInDate! : self.lastCheckInDate,
            lastCheckInScore: lastCheckInScore != nil ? lastCheckInScore! : self.lastCheckInScore
        )
    }
}
