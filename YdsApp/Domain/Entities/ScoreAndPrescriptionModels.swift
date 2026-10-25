import Foundation

/// Soru Tipi Karnesi içerisindeki tek bir kategorinin ustalık ve puan potansiyeli kaydı
public struct CategoryMasteryRecord: Identifiable, Codable, Equatable, Sendable {
    public let category: QuestionCategory
    public let currentMasteryRatio: Double
    public let targetMasteryRatio: Double
    public let questionsSolvedCount: Int
    public let correctAnswersCount: Int

    public var id: String { category.rawValue }

    public init(
        category: QuestionCategory,
        currentMasteryRatio: Double,
        targetMasteryRatio: Double = 0.85,
        questionsSolvedCount: Int = 12,
        correctAnswersCount: Int = 7
    ) {
        self.category = category
        self.currentMasteryRatio = min(max(currentMasteryRatio, 0.0), 1.0)
        self.targetMasteryRatio = min(max(targetMasteryRatio, 0.0), 1.0)
        self.questionsSolvedCount = questionsSolvedCount
        self.correctAnswersCount = correctAnswersCount
    }

    /// Bu soru tipinden şu anki tahmini puana gelen net katkı
    public var currentScoreContribution: Double {
        currentMasteryRatio * category.maxScorePoints
    }

    /// Hedef ustalık oranına ulaşıldığında kazanılacak ek sınav puanı
    /// Formül: `(targetCategoryMastery - currentCategoryMastery) * categoryMaxScorePoints`
    public var potentialScoreGain: Double {
        let rawGain = max(0.0, (targetMasteryRatio - currentMasteryRatio) * category.maxScorePoints)
        return (rawGain * 4.0).rounded() / 4.0
    }

    public var masteryPercentageInt: Int {
        Int((currentMasteryRatio * 100.0).rounded())
    }

    public var diagnosticNoteTr: String {
        let gainFormatted = String(format: "+%.2f", potentialScoreGain)
        if currentMasteryRatio >= 0.72 {
            return "\(category.shortTitleTr) sorularında ustalaşmaya yakınsın, buradan \(gainFormatted) puan cepte!"
        } else if currentMasteryRatio >= 0.50 {
            return "\(category.shortTitleTr) refleksini hızlandırarak sınav puanına \(gainFormatted) puan ekleyebilirsin."
        } else {
            return "En hızlı puan sıçraması alanı! \(category.shortTitleTr) tuzaklarını kapatmak sana \(gainFormatted) puan kazandırır."
        }
    }
}

/// Canlı Puan Değişiminin Kaynağı (iOS <-> Android 1:1 Enum)
public enum ScoreSource: String, Codable, CaseIterable, Equatable, Sendable {
    case sprint = "SPRINT"
    case xray = "XRAY"
    case vocab = "VOCAB"
    case checkIn = "CHECK_IN"

    public var titleTr: String {
        switch self {
        case .sprint: return "Mikro-Sprint"
        case .xray: return "Cümle Röntgeni"
        case .vocab: return "3B Kelime"
        case .checkIn: return "Haftalık Check-In"
        }
    }
}

/// Puan Değişim Açıklaması (Pedagojik Ceza Yerine Açık Tespiti)
public struct ScoreChangeExplanation: Codable, Equatable, Sendable {
    public let deltaPoints: Double
    public let headlineTr: String
    public let reasonTr: String
    public let nextActionTr: String

    public init(
        deltaPoints: Double,
        headlineTr: String,
        reasonTr: String,
        nextActionTr: String
    ) {
        self.deltaPoints = deltaPoints
        self.headlineTr = headlineTr
        self.reasonTr = reasonTr
        self.nextActionTr = nextActionTr
    }

    public var formattedDeltaTr: String {
        let sign = deltaPoints >= 0 ? "+" : ""
        return String(format: "%@%.2f puan", sign, deltaPoints)
    }
}

/// Borsa grafiği gibi canlı puan geçmişi kaydı (ScoreEvent)
public struct ScoreEvent: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let date: Date
    public let source: ScoreSource
    public let category: QuestionCategory?
    public let delta: Double
    public let scoreBefore: Double
    public let scoreAfter: Double
    public let explanation: ScoreChangeExplanation?

    public init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        source: ScoreSource,
        category: QuestionCategory? = nil,
        delta: Double,
        scoreBefore: Double,
        scoreAfter: Double,
        explanation: ScoreChangeExplanation? = nil
    ) {
        self.id = id
        self.date = date
        self.source = source
        self.category = category
        self.delta = delta
        self.scoreBefore = scoreBefore
        self.scoreAfter = scoreAfter
        self.explanation = explanation
    }

    /// "48.75 ➔ 49.15 (+0.40 puan)" gösterim formatı
    public var transitionDisplayTr: String {
        let sign = delta >= 0 ? "+" : ""
        return String(format: "%.2f ➔ %.2f (%@%.2f puan)", scoreBefore, scoreAfter, sign, delta)
    }
}

/// Puan motorunun işlem dönüş tipi (Puan, karne, açıklama ve olay kaydı)
public struct ScoreOutcomeResult: Codable, Equatable, Sendable {
    public let updatedProfile: UserStudyProfile
    public let updatedRecords: [CategoryMasteryRecord]
    public let earnedDelta: Double
    public let explanation: ScoreChangeExplanation
    public let scoreEvent: ScoreEvent

    public init(
        updatedProfile: UserStudyProfile,
        updatedRecords: [CategoryMasteryRecord],
        earnedDelta: Double,
        explanation: ScoreChangeExplanation,
        scoreEvent: ScoreEvent
    ) {
        self.updatedProfile = updatedProfile
        self.updatedRecords = updatedRecords
        self.earnedDelta = earnedDelta
        self.explanation = explanation
        self.scoreEvent = scoreEvent
    }
}

/// Canlı Puan Tahmin Motoru tarafından üretilen genel karne özeti
public struct ScoreReportCard: Codable, Equatable, Sendable {
    public let estimatedTotalScore: Double
    public let initialBaselineScore: Double
    public let targetScore: Double
    public let neededScore: Double
    public let todayEarnedDelta: Double
    public let categoryRecords: [CategoryMasteryRecord]
    public let topWeakCategories: [QuestionCategory]
    public let scoreConfidenceMargin: Double?

    public init(
        estimatedTotalScore: Double,
        initialBaselineScore: Double,
        targetScore: Double,
        neededScore: Double,
        todayEarnedDelta: Double,
        categoryRecords: [CategoryMasteryRecord],
        topWeakCategories: [QuestionCategory],
        scoreConfidenceMargin: Double? = 5.0
    ) {
        self.estimatedTotalScore = estimatedTotalScore
        self.initialBaselineScore = initialBaselineScore
        self.targetScore = targetScore
        self.neededScore = neededScore
        self.todayEarnedDelta = todayEarnedDelta
        self.categoryRecords = categoryRecords
        self.topWeakCategories = topWeakCategories
        self.scoreConfidenceMargin = scoreConfidenceMargin
    }

    private enum CodingKeys: String, CodingKey {
        case estimatedTotalScore
        case initialBaselineScore
        case targetScore
        case neededScore
        case todayEarnedDelta
        case categoryRecords
        case topWeakCategories
        case scoreConfidenceMargin
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.estimatedTotalScore = try c.decode(Double.self, forKey: .estimatedTotalScore)
        self.initialBaselineScore = try c.decode(Double.self, forKey: .initialBaselineScore)
        self.targetScore = try c.decode(Double.self, forKey: .targetScore)
        self.neededScore = try c.decode(Double.self, forKey: .neededScore)
        self.todayEarnedDelta = try c.decode(Double.self, forKey: .todayEarnedDelta)
        self.categoryRecords = try c.decode([CategoryMasteryRecord].self, forKey: .categoryRecords)
        self.topWeakCategories = try c.decode([QuestionCategory].self, forKey: .topWeakCategories)
        self.scoreConfidenceMargin = try c.decodeIfPresent(Double.self, forKey: .scoreConfidenceMargin) ?? 5.0
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(estimatedTotalScore, forKey: .estimatedTotalScore)
        try c.encode(initialBaselineScore, forKey: .initialBaselineScore)
        try c.encode(targetScore, forKey: .targetScore)
        try c.encode(neededScore, forKey: .neededScore)
        try c.encode(todayEarnedDelta, forKey: .todayEarnedDelta)
        try c.encode(categoryRecords, forKey: .categoryRecords)
        try c.encode(topWeakCategories, forKey: .topWeakCategories)
        try c.encodeIfPresent(scoreConfidenceMargin, forKey: .scoreConfidenceMargin)
    }

    public var formattedConfidenceMarginTr: String {
        String(format: "±%.2f puan", scoreConfidenceMargin ?? 5.0)
    }
}

/// Günlük 15 dakikalık reçetedeki adım türü
public enum PrescriptionStepType: String, Codable, Equatable, Sendable {
    case vocab3D = "VOCAB_3D"
    case sentenceXRay = "SENTENCE_XRAY"
    case microSprint = "MICRO_SPRINT"
    case mistakeVaultReview = "MISTAKE_VAULT_REVIEW"

    public var badgeTitleTr: String {
        switch self {
        case .vocab3D: return "3B KELİME & EDAT"
        case .sentenceXRay: return "CÜMLE RÖNTGENİ"
        case .microSprint: return "MİKRO-SPRİNT"
        case .mistakeVaultReview: return "HATA KUMBARASI"
        }
    }

    public var iconSystemName: String {
        switch self {
        case .vocab3D: return "cube.fill"
        case .sentenceXRay: return "waveform.path.ecg.rectangle.fill"
        case .microSprint: return "bolt.fill"
        case .mistakeVaultReview: return "arrow.triangle.2.circlepath.circle.fill"
        }
    }
}

/// Günlük 15 dakikalık reçetedeki 14 adımdan her biri
public struct DailyPrescriptionStep: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let stepIndex: Int
    public let stepType: PrescriptionStepType
    public let referenceItemId: String
    public let titleTr: String
    public let subtitleTr: String
    public let estimatedScoreImpact: Double
    public let isCompleted: Bool
    public let isLockedForFreeTier: Bool

    public init(
        id: String,
        stepIndex: Int,
        stepType: PrescriptionStepType,
        referenceItemId: String,
        titleTr: String,
        subtitleTr: String,
        estimatedScoreImpact: Double,
        isCompleted: Bool = false,
        isLockedForFreeTier: Bool = false
    ) {
        self.id = id
        self.stepIndex = stepIndex
        self.stepType = stepType
        self.referenceItemId = referenceItemId
        self.titleTr = titleTr
        self.subtitleTr = subtitleTr
        self.estimatedScoreImpact = estimatedScoreImpact
        self.isCompleted = isCompleted
        self.isLockedForFreeTier = isLockedForFreeTier
    }
}

/// Günün 15 Dakikalık Reçetesi (5x 3B Kelime + 2x Cümle Röntgeni + 5x Mikro-Sprint + 2x Hata Kumbarası = 14 Adım)
public struct DailyPrescription: Codable, Equatable, Sendable {
    public let dateString: String
    public let track: AcademicTrack
    public let totalEstimatedMinutes: Int
    public let steps: [DailyPrescriptionStep]
    public let expectedScoreDeltaRangeMin: Double
    public let expectedScoreDeltaRangeMax: Double
    public let freeTierStepLimit: Int

    public init(
        dateString: String,
        track: AcademicTrack,
        totalEstimatedMinutes: Int = 15,
        steps: [DailyPrescriptionStep],
        expectedScoreDeltaRangeMin: Double = 0.25,
        expectedScoreDeltaRangeMax: Double = 0.65,
        freeTierStepLimit: Int = 7
    ) {
        self.dateString = dateString
        self.track = track
        self.totalEstimatedMinutes = totalEstimatedMinutes
        self.steps = steps
        self.expectedScoreDeltaRangeMin = expectedScoreDeltaRangeMin
        self.expectedScoreDeltaRangeMax = expectedScoreDeltaRangeMax
        self.freeTierStepLimit = freeTierStepLimit
    }

    public var completedStepsCount: Int {
        steps.filter(\.isCompleted).count
    }

    public var totalStepsCount: Int {
        steps.count
    }

    public var progressFraction: Double {
        guard !steps.isEmpty else { return 0.0 }
        return Double(completedStepsCount) / Double(steps.count)
    }
}

/// Hata Kumbarası (Mistake Vault) kaydı
public struct MistakeVaultItem: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let questionId: String
    public let stemPreview: String
    public let selectedWrongOptionId: String
    public let selectedWrongOptionText: String
    public let correctOptionId: String
    public let correctOptionText: String
    public let category: QuestionCategory
    public let track: AcademicTrack
    public let grammarRuleTag: String
    public let grammarRuleTitleTr: String
    public let praiseTextTr: String
    public let trapReasonTr: String
    public let winningRuleTr: String
    public let failedCount: Int
    public let masteredInReviewCount: Int
    public let isResolved: Bool
    public let lastMistakeDate: Date

    public init(
        id: String,
        questionId: String,
        stemPreview: String,
        selectedWrongOptionId: String,
        selectedWrongOptionText: String,
        correctOptionId: String,
        correctOptionText: String,
        category: QuestionCategory,
        track: AcademicTrack,
        grammarRuleTag: String,
        grammarRuleTitleTr: String,
        praiseTextTr: String,
        trapReasonTr: String,
        winningRuleTr: String,
        failedCount: Int = 1,
        masteredInReviewCount: Int = 0,
        isResolved: Bool = false,
        lastMistakeDate: Date = Date(timeIntervalSince1970: 1_700_000_000)
    ) {
        self.id = id
        self.questionId = questionId
        self.stemPreview = stemPreview
        self.selectedWrongOptionId = selectedWrongOptionId
        self.selectedWrongOptionText = selectedWrongOptionText
        self.correctOptionId = correctOptionId
        self.correctOptionText = correctOptionText
        self.category = category
        self.track = track
        self.grammarRuleTag = grammarRuleTag
        self.grammarRuleTitleTr = grammarRuleTitleTr
        self.praiseTextTr = praiseTextTr
        self.trapReasonTr = trapReasonTr
        self.winningRuleTr = winningRuleTr
        self.failedCount = failedCount
        self.masteredInReviewCount = masteredInReviewCount
        self.isResolved = isResolved
        self.lastMistakeDate = lastMistakeDate
    }

    public var estimatedScoreRecoveryPoints: Double {
        isResolved ? 0.0 : 0.25
    }
}
