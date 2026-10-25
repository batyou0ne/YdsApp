import Foundation

/// Haftalık Check-In tek bir kategori karnesi
public struct CheckInCategoryReport: Identifiable, Codable, Equatable, Sendable {
    public let category: QuestionCategory
    public let totalQuestions: Int
    public let correctCount: Int
    public let wrongCount: Int
    public let blankCount: Int
    public let accuracyRatio: Double
    public let maxScoreContribution: Double
    public let earnedScoreContribution: Double
    public let performanceNoteTr: String

    public var id: String { category.rawValue }

    public init(
        category: QuestionCategory,
        totalQuestions: Int,
        correctCount: Int,
        wrongCount: Int,
        blankCount: Int,
        accuracyRatio: Double,
        maxScoreContribution: Double,
        earnedScoreContribution: Double,
        performanceNoteTr: String
    ) {
        self.category = category
        self.totalQuestions = totalQuestions
        self.correctCount = correctCount
        self.wrongCount = wrongCount
        self.blankCount = blankCount
        self.accuracyRatio = min(max(accuracyRatio, 0.0), 1.0)
        self.maxScoreContribution = maxScoreContribution
        self.earnedScoreContribution = earnedScoreContribution
        self.performanceNoteTr = performanceNoteTr
    }

    public var accuracyPercentageInt: Int {
        Int((accuracyRatio * 100.0).rounded())
    }

    public var formattedEarnedPointsTr: String {
        String(format: "%.2f / %.2f puan", earnedScoreContribution, maxScoreContribution)
    }
}

/// Haftalık 15 Soruluk Check-In Mini Deneme Sonuç Raporu
public struct CheckInReport: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let date: Date
    public let scoreBefore: Double
    public let scoreAfter: Double
    public let measuredScore: Double
    public let earnedDelta: Double
    public let scoreConfidenceMargin: Double
    public let confidenceLowerBound: Double
    public let confidenceUpperBound: Double
    public let totalQuestions: Int
    public let correctCount: Int
    public let wrongCount: Int
    public let blankCount: Int
    public let elapsedSeconds: Int
    public let categoryReports: [CheckInCategoryReport]
    public let topImprovedCategory: QuestionCategory?
    public let topDroppedCategory: QuestionCategory?
    public let nextWeekFocusRecommendationTr: String
    public let isPaywallBlurActive: Bool

    public init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        scoreBefore: Double,
        scoreAfter: Double,
        measuredScore: Double,
        earnedDelta: Double,
        scoreConfidenceMargin: Double = 1.5,
        confidenceLowerBound: Double? = nil,
        confidenceUpperBound: Double? = nil,
        totalQuestions: Int = 15,
        correctCount: Int,
        wrongCount: Int,
        blankCount: Int,
        elapsedSeconds: Int,
        categoryReports: [CheckInCategoryReport],
        topImprovedCategory: QuestionCategory? = nil,
        topDroppedCategory: QuestionCategory? = nil,
        nextWeekFocusRecommendationTr: String,
        isPaywallBlurActive: Bool = false
    ) {
        self.id = id
        self.date = date
        self.scoreBefore = scoreBefore
        self.scoreAfter = scoreAfter
        self.measuredScore = measuredScore
        self.earnedDelta = earnedDelta
        self.scoreConfidenceMargin = scoreConfidenceMargin
        self.confidenceLowerBound = confidenceLowerBound ?? max(0.0, scoreAfter - scoreConfidenceMargin)
        self.confidenceUpperBound = confidenceUpperBound ?? min(100.0, scoreAfter + scoreConfidenceMargin)
        self.totalQuestions = totalQuestions
        self.correctCount = correctCount
        self.wrongCount = wrongCount
        self.blankCount = blankCount
        self.elapsedSeconds = elapsedSeconds
        self.categoryReports = categoryReports
        self.topImprovedCategory = topImprovedCategory
        self.topDroppedCategory = topDroppedCategory
        self.nextWeekFocusRecommendationTr = nextWeekFocusRecommendationTr
        self.isPaywallBlurActive = isPaywallBlurActive
    }

    /// "53.75 ➔ 56.25 (+2.50 puan)" formatı
    public var scoreTransitionDisplayTr: String {
        CalculateEstimatedScoreUseCase.formatScoreTransition(before: scoreBefore, after: scoreAfter)
    }

    public var formattedMeasuredScoreTr: String {
        String(format: "%.2f", measuredScore)
    }

    public var formattedCalibratedScoreTr: String {
        String(format: "%.2f", scoreAfter)
    }

    public var formattedEarnedDeltaTr: String {
        let sign = earnedDelta >= 0 ? "+" : ""
        return String(format: "%@%.2f puan", sign, earnedDelta)
    }

    public var formattedConfidenceIntervalTr: String {
        String(format: "%.2f – %.2f (±%.2f)", confidenceLowerBound, confidenceUpperBound, scoreConfidenceMargin)
    }

    public var formattedAccuracyTr: String {
        let pct = totalQuestions > 0 ? Int((Double(correctCount) / Double(totalQuestions) * 100).rounded()) : 0
        return "%\(pct) Doğruluk"
    }

    public var timeSpentFormatted: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

/// Haftalık Check-In Uygunluk Durumu (Freemium & Zaman Kuralı)
public struct CheckInEligibility: Equatable, Sendable {
    public let isEligible: Bool
    public let daysUntilNextAvailable: Int
    public let nextAvailableDate: Date?
    public let reasonTr: String?
    public let isFreeTier: Bool
    public let lastCheckInDate: Date?
    public let lastCheckInScore: Double?

    public init(
        isEligible: Bool,
        daysUntilNextAvailable: Int = 0,
        nextAvailableDate: Date? = nil,
        reasonTr: String? = nil,
        isFreeTier: Bool = false,
        lastCheckInDate: Date? = nil,
        lastCheckInScore: Double? = nil
    ) {
        self.isEligible = isEligible
        self.daysUntilNextAvailable = max(0, daysUntilNextAvailable)
        self.nextAvailableDate = nextAvailableDate
        self.reasonTr = reasonTr
        self.isFreeTier = isFreeTier
        self.lastCheckInDate = lastCheckInDate
        self.lastCheckInScore = lastCheckInScore
    }

    public var badgeTextTr: String {
        if isEligible {
            return "HAZIR"
        } else if daysUntilNextAvailable == 1 {
            return "YARIN"
        } else {
            return "\(daysUntilNextAvailable) GÜN SONRA"
        }
    }
}

/// Check-In Hatırlatma Politikası (Saf Domain Kuralı - UNUserNotificationCenter içermez)
public struct CheckInReminderPolicy: Sendable {
    public static let targetWeekdaySunday: Int = 1 // Pazar
    public static let targetWeekdaySaturday: Int = 7 // Cumartesi
    public static let defaultPreferredHour: Int = 10 // Sabah 10:00

    public static let notificationTitleTr = "Haftalık YDS Check-In Hazır!"
    public static let notificationBodyTr = "Bu haftaki çalışmaların sınav puanını artırdı mı? 15 soruluk 20 dakikalık check-in mini denemen seni bekliyor."

    public init() {}

    /// Kullanıcının aktif saatine ve hafta sonuna göre sonraki uygun hatırlatma zamanını hesaplar
    public func nextReminderDate(from referenceDate: Date = Date(), preferredHour: Int = defaultPreferredHour) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        var components = calendar.dateComponents([.year, .month, .day, .weekday], from: referenceDate)
        let currentWeekday = components.weekday ?? 1

        // Hafta sonuna (Cumartesi veya Pazar) kalan gün sayısı
        let daysUntilWeekend: Int
        if currentWeekday == Self.targetWeekdaySunday {
            daysUntilWeekend = 0
        } else if currentWeekday == Self.targetWeekdaySaturday {
            daysUntilWeekend = 0
        } else {
            daysUntilWeekend = Self.targetWeekdaySaturday - currentWeekday
        }

        let targetDate = calendar.date(byAdding: .day, value: max(0, daysUntilWeekend), to: referenceDate) ?? referenceDate
        var targetComponents = calendar.dateComponents([.year, .month, .day], from: targetDate)
        targetComponents.hour = preferredHour
        targetComponents.minute = 0
        targetComponents.second = 0

        return calendar.date(from: targetComponents) ?? referenceDate.addingTimeInterval(86400 * 2)
    }

    /// Check-In hatırlatması planlanmalı mı kontrolü
    public func shouldScheduleReminder(profile: UserStudyProfile, eligibility: CheckInEligibility) -> Bool {
        eligibility.isEligible
    }
}
