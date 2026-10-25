import Foundation

/// YDS / e-YDS / YÖKDİL 9 temel soru kategorisi ve gerçek sınav puan ağırlıkları (80 soru = 100.00 puan)
public enum QuestionCategory: String, Codable, CaseIterable, Equatable, Sendable {
    case conjunction = "CONJUNCTION"
    case preposition = "PREPOSITION"
    case translation = "TRANSLATION"
    case academicVocab = "ACADEMIC_VOCAB"
    case reductionAndTense = "REDUCTION_AND_TENSE"
    case sentenceCompletion = "SENTENCE_COMPLETION"
    case irrelevantSentence = "IRRELEVANT_SENTENCE"
    case clozeTest = "CLOZE_TEST"
    case dialogueAndRestatement = "DIALOGUE_AND_RESTATEMENT"

    public var titleTr: String {
        switch self {
        case .conjunction:
            return "Zıtlık & Neden-Sonuç Bağlaçları"
        case .preposition:
            return "Akademik Edatlar (Prepositions)"
        case .translation:
            return "Çeviri Eklemleri (EN-TR / TR-EN)"
        case .academicVocab:
            return "Akademik Kelime (Phrasal & Vocab)"
        case .reductionAndTense:
            return "Kısaltma (Reduction) & Tense"
        case .sentenceCompletion:
            return "Cümle Tamamlama"
        case .irrelevantSentence:
            return "Akış Bozan (Roma Rakamı)"
        case .clozeTest:
            return "Cloze Test (Boşluk Tamamlama)"
        case .dialogueAndRestatement:
            return "Paragraf, Yakın Anlam & Diyalog"
        }
    }

    public var shortTitleTr: String {
        switch self {
        case .conjunction: return "Bağlaçlar"
        case .preposition: return "Edatlar"
        case .translation: return "Çeviri"
        case .academicVocab: return "Kelime"
        case .reductionAndTense: return "Kısaltma & Tense"
        case .sentenceCompletion: return "Cümle Tamamlama"
        case .irrelevantSentence: return "Akış Bozan"
        case .clozeTest: return "Cloze Test"
        case .dialogueAndRestatement: return "Paragraf & Yakın Anlam"
        }
    }

    /// 80 soruluk gerçek YDS/YÖKDİL soru dağılımı karşılığı (Toplam = 80 soru)
    public var examQuestionCount: Int {
        switch self {
        case .academicVocab: return 6          // Kelime & Edat toplam 12 soru (%15 = 15.0 puan)
        case .preposition: return 6
        case .conjunction: return 10           // Bağlaç & Kısaltma/Dilbilgisi toplam 16 soru (%20 = 20.0 puan)
        case .reductionAndTense: return 6
        case .sentenceCompletion: return 10    // Cümle Tamamlama 10 soru (%12.5 = 12.5 puan)
        case .translation: return 8            // Çeviri 8 soru (%10 = 10.0 puan)
        case .irrelevantSentence: return 6     // Paragraf & Yakın Anlam & Diyalog & Akış Bozan & Cloze toplam 34 soru (%42.5 = 42.5 puan)
        case .clozeTest: return 10
        case .dialogueAndRestatement: return 18
        }
    }

    /// Her soru 1.25 puan (Toplam = 100.00 puan)
    public var maxScorePoints: Double {
        Double(examQuestionCount) * 1.25
    }

    public var iconName: String {
        switch self {
        case .conjunction: return "arrow.left.and.right.square.fill"
        case .preposition: return "link.circle.fill"
        case .translation: return "bolt.horizontal.fill"
        case .academicVocab: return "cube.transparent.fill"
        case .reductionAndTense: return "clock.badge.checkmark.fill"
        case .sentenceCompletion: return "puzzlepiece.extension.fill"
        case .irrelevantSentence: return "magnifyingglass.circle.fill"
        case .clozeTest: return "text.insert"
        case .dialogueAndRestatement: return "doc.text.magnifyingglass"
        }
    }
}

/// Mikro-Sprint antrenman modları
public enum MicroSprintMode: String, Codable, CaseIterable, Equatable, Sendable {
    case translation10SecHunt = "TRANSLATION_10_SEC_HUNT"
    case conjunctionPolarityRadar = "CONJUNCTION_POLARITY_RADAR"
    case irrelevantSentenceDetective = "IRRELEVANT_SENTENCE_DETECTIVE"
    case clozeAndDialogueSprint = "CLOZE_AND_DIALOGUE_SPRINT"
    case diagnosticMiniTest = "DIAGNOSTIC_MINI_TEST"

    public static var playableModes: [MicroSprintMode] {
        [
            .translation10SecHunt,
            .conjunctionPolarityRadar,
            .irrelevantSentenceDetective,
            .clozeAndDialogueSprint
        ]
    }

    public var titleTr: String {
        switch self {
        case .translation10SecHunt:
            return "10 Saniyede Çeviri Avı"
        case .conjunctionPolarityRadar:
            return "Artı / Eksi Bağlaç Radarı"
        case .irrelevantSentenceDetective:
            return "Akış Bozan Dedektifi"
        case .clozeAndDialogueSprint:
            return "Cloze & Diyalog Hız Sprinti"
        case .diagnosticMiniTest:
            return "5 Soruluk Stratejik Seviye Tespiti"
        }
    }

    public var subtitleTr: String {
        switch self {
        case .translation10SecHunt:
            return "Cümleyi baştan sona çevirme! Sadece parlayan Ana Yüklem ve Bağlaç eklemini yakala, 10 saniyede şıkkı vur."
        case .conjunctionPolarityRadar:
            return "Önce boşluk öncesi ve sonrasının kutbunu (+ / -) seç, ardından doğru bağlaç ailesini işaretle."
        case .irrelevantSentenceDetective:
            return "5 Roma rakamlı cümlede zamir takibi (this, such, they) ve özne kayması ipuçlarıyla sırıtan cümleyi bul."
        case .clozeAndDialogueSprint:
            return "Akademik metin içi boşluk tamamlama, edat, kısaltma ve yakın anlam refleks antrenmanı."
        case .diagnosticMiniTest:
            return "En çok puan kaybettiğin soru tiplerini ve başlangıç YDS/YÖKDİL puanını belirleyen 5 stratejik soru."
        }
    }

    public var badgeTextTr: String {
        switch self {
        case .translation10SecHunt: return "10 SN REFLEKS"
        case .conjunctionPolarityRadar: return "+ / - RADAR"
        case .irrelevantSentenceDetective: return "ROMA RAKAMI"
        case .clozeAndDialogueSprint: return "3 DK SERİ"
        case .diagnosticMiniTest: return "TEŞHİS"
        }
    }

    public var iconSystemName: String {
        switch self {
        case .translation10SecHunt: return "timer"
        case .conjunctionPolarityRadar: return "plus.forwardslash.minus"
        case .irrelevantSentenceDetective: return "eye.trianglebadge.exclamationmark.fill"
        case .clozeAndDialogueSprint: return "flame.fill"
        case .diagnosticMiniTest: return "stethoscope"
        }
    }
}

/// Soru kökünde parlatılan ipucu türü
public enum ClueHighlightType: String, Codable, Equatable, Sendable {
    case mainVerb = "MAIN_VERB"
    case conjunction = "CONJUNCTION"
    case pronounReference = "PRONOUN_REFERENCE"
    case topicShift = "TOPIC_SHIFT"
    case prepositionTrigger = "PREPOSITION_TRIGGER"

    public var labelTr: String {
        switch self {
        case .mainVerb: return "Ana Yüklem İpucu"
        case .conjunction: return "Bağlaç Eklemi"
        case .pronounReference: return "Zamir Takibi (Referans)"
        case .topicShift: return "Konu / Özne Kayması"
        case .prepositionTrigger: return "Edat Tetikleyicisi"
        }
    }
}

/// Soru kökü içindeki vurgulanmış ipucu parçası
public struct ClueSpan: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let matchedSubstring: String
    public let clueType: ClueHighlightType
    public let explanationTr: String

    public init(
        id: String,
        matchedSubstring: String,
        clueType: ClueHighlightType,
        explanationTr: String
    ) {
        self.id = id
        self.matchedSubstring = matchedSubstring
        self.clueType = clueType
        self.explanationTr = explanationTr
    }
}

/// "Neden Yanlış Yaptım?" Çeldirici Koçu geri bildirimi
/// PEDAGOJİK KURAL: Hiçbir zaman sadece doğru şık harfi ve ham çeviri gösterilmez!
public struct DistractorExplanation: Codable, Equatable, Sendable {
    public let praiseTextTr: String
    public let trapReasonTr: String
    public let winningRuleTr: String
    public let grammarRuleTag: String

    public init(
        praiseTextTr: String,
        trapReasonTr: String,
        winningRuleTr: String,
        grammarRuleTag: String
    ) {
        self.praiseTextTr = praiseTextTr
        self.trapReasonTr = trapReasonTr
        self.winningRuleTr = winningRuleTr
        self.grammarRuleTag = grammarRuleTag
    }
}

/// 5 şıklı (A, B, C, D, E) soru seçeneği
public struct QuestionOption: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let text: String
    public let distractorCoachFeedback: DistractorExplanation

    public init(
        id: String,
        text: String,
        distractorCoachFeedback: DistractorExplanation
    ) {
        self.id = id
        self.text = text
        self.distractorCoachFeedback = distractorCoachFeedback
    }
}

/// Adaptif teşhis için soru zorluk bandı (iOS <-> Android 1:1 Enum)
public enum QuestionDifficultyBand: String, Codable, CaseIterable, Equatable, Sendable {
    case easy = "EASY"       // A2/B1, 35-50 puan bandı
    case medium = "MEDIUM"   // B1/B2, 50-65 puan bandı
    case hard = "HARD"       // C1, 65-85 puan bandı

    public var titleTr: String {
        switch self {
        case .easy: return "Kolay"
        case .medium: return "Orta"
        case .hard: return "Zor"
        }
    }

    /// Bandı temsil eden tahmini sınav puanı (0.00 - 100.00)
    public var representativeScore: Double {
        switch self {
        case .easy: return 42.5
        case .medium: return 57.5
        case .hard: return 75.0
        }
    }

    public var cefrHintTr: String {
        switch self {
        case .easy: return "A2/B1 · 35–50 puan bandı"
        case .medium: return "B1/B2 · 50–65 puan bandı"
        case .hard: return "C1 · 65–85 puan bandı"
        }
    }

    /// `irtDifficulty` verilmediğinde banttan türetilen varsayılan zorluk parametresi (b)
    public var defaultIRTDifficulty: Double {
        switch self {
        case .easy: return -1.0
        case .medium: return 0.0
        case .hard: return 1.0
        }
    }
}

/// Mikro-Sprint ve Seviye Tespit sorusu
public struct SprintQuestion: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let category: QuestionCategory
    public let sprintMode: MicroSprintMode
    public let track: AcademicTrack
    public let isDiagnosticOnboarding: Bool
    public let timeLimitSeconds: Int
    public let stemText: String
    public let highlightedClues: [ClueSpan]
    public let expectedLeftPolarity: PolarityType?
    public let expectedRightPolarity: PolarityType?
    public let options: [QuestionOption]
    public let correctOptionId: String
    /// Adaptif teşhis zorluk bandı (JSON'da yoksa `.medium`)
    public let difficultyBand: QuestionDifficultyBand
    /// IRT zorluk parametresi (-2.0...+2.0, JSON'da yoksa 0.0)
    public let irtDifficulty: Double

    public static let irtDifficultyRange: ClosedRange<Double> = -2.0...2.0

    public init(
        id: String,
        category: QuestionCategory,
        sprintMode: MicroSprintMode,
        track: AcademicTrack,
        isDiagnosticOnboarding: Bool = false,
        difficultyBand: QuestionDifficultyBand = .medium,
        irtDifficulty: Double? = nil,
        timeLimitSeconds: Int,
        stemText: String,
        highlightedClues: [ClueSpan],
        expectedLeftPolarity: PolarityType? = nil,
        expectedRightPolarity: PolarityType? = nil,
        options: [QuestionOption],
        correctOptionId: String
    ) {
        self.id = id
        self.category = category
        self.sprintMode = sprintMode
        self.track = track
        self.isDiagnosticOnboarding = isDiagnosticOnboarding
        self.timeLimitSeconds = timeLimitSeconds
        self.stemText = stemText
        self.highlightedClues = highlightedClues
        self.expectedLeftPolarity = expectedLeftPolarity
        self.expectedRightPolarity = expectedRightPolarity
        self.options = options
        self.correctOptionId = correctOptionId
        self.difficultyBand = difficultyBand
        self.irtDifficulty = Self.clampIRT(irtDifficulty ?? difficultyBand.defaultIRTDifficulty)
    }

    private static func clampIRT(_ value: Double) -> Double {
        min(max(value, irtDifficultyRange.lowerBound), irtDifficultyRange.upperBound)
    }

    private enum CodingKeys: String, CodingKey {
        case id, category, sprintMode, track, isDiagnosticOnboarding, timeLimitSeconds
        case stemText, highlightedClues, expectedLeftPolarity, expectedRightPolarity
        case options, correctOptionId, difficultyBand, irtDifficulty
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(String.self, forKey: .id)
        self.category = try c.decode(QuestionCategory.self, forKey: .category)
        self.sprintMode = try c.decode(MicroSprintMode.self, forKey: .sprintMode)
        self.track = try c.decode(AcademicTrack.self, forKey: .track)
        self.isDiagnosticOnboarding = try c.decode(Bool.self, forKey: .isDiagnosticOnboarding)
        self.timeLimitSeconds = try c.decode(Int.self, forKey: .timeLimitSeconds)
        self.stemText = try c.decode(String.self, forKey: .stemText)
        self.highlightedClues = try c.decode([ClueSpan].self, forKey: .highlightedClues)
        self.expectedLeftPolarity = try c.decodeIfPresent(PolarityType.self, forKey: .expectedLeftPolarity)
        self.expectedRightPolarity = try c.decodeIfPresent(PolarityType.self, forKey: .expectedRightPolarity)
        self.options = try c.decode([QuestionOption].self, forKey: .options)
        self.correctOptionId = try c.decode(String.self, forKey: .correctOptionId)
        let band = try c.decodeIfPresent(QuestionDifficultyBand.self, forKey: .difficultyBand) ?? .medium
        self.difficultyBand = band
        // Alan yoksa banttan türetilir; eski JSON'da band de yoksa .medium -> 0.0
        self.irtDifficulty = Self.clampIRT(
            try c.decodeIfPresent(Double.self, forKey: .irtDifficulty) ?? band.defaultIRTDifficulty
        )
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(category, forKey: .category)
        try c.encode(sprintMode, forKey: .sprintMode)
        try c.encode(track, forKey: .track)
        try c.encode(isDiagnosticOnboarding, forKey: .isDiagnosticOnboarding)
        try c.encode(timeLimitSeconds, forKey: .timeLimitSeconds)
        try c.encode(stemText, forKey: .stemText)
        try c.encode(highlightedClues, forKey: .highlightedClues)
        try c.encodeIfPresent(expectedLeftPolarity, forKey: .expectedLeftPolarity)
        try c.encodeIfPresent(expectedRightPolarity, forKey: .expectedRightPolarity)
        try c.encode(options, forKey: .options)
        try c.encode(correctOptionId, forKey: .correctOptionId)
        try c.encode(difficultyBand, forKey: .difficultyBand)
        try c.encode(irtDifficulty, forKey: .irtDifficulty)
    }

    public var correctOption: QuestionOption? {
        options.first { $0.id == correctOptionId }
    }
}
