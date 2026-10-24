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

    public init(
        id: String,
        category: QuestionCategory,
        sprintMode: MicroSprintMode,
        track: AcademicTrack,
        isDiagnosticOnboarding: Bool = false,
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
    }

    public var correctOption: QuestionOption? {
        options.first { $0.id == correctOptionId }
    }
}
