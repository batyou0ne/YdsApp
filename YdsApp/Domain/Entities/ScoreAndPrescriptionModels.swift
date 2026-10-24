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

/// Canlı Puan Tahmin Motoru tarafından üretilen genel karne özeti
public struct ScoreReportCard: Codable, Equatable, Sendable {
    public let estimatedTotalScore: Double
    public let initialBaselineScore: Double
    public let targetScore: Double
    public let neededScore: Double
    public let todayEarnedDelta: Double
    public let categoryRecords: [CategoryMasteryRecord]
    public let topWeakCategories: [QuestionCategory]

    public init(
        estimatedTotalScore: Double,
        initialBaselineScore: Double,
        targetScore: Double,
        neededScore: Double,
        todayEarnedDelta: Double,
        categoryRecords: [CategoryMasteryRecord],
        topWeakCategories: [QuestionCategory]
    ) {
        self.estimatedTotalScore = estimatedTotalScore
        self.initialBaselineScore = initialBaselineScore
        self.targetScore = targetScore
        self.neededScore = neededScore
        self.todayEarnedDelta = todayEarnedDelta
        self.categoryRecords = categoryRecords
        self.topWeakCategories = topWeakCategories
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
