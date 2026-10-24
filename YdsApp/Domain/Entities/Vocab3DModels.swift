import Foundation

/// 3 Boyutlu Kelime Kartı tekrar sınav boyutları
public enum VocabQuizDimension: String, Codable, CaseIterable, Equatable, Sendable {
    case meaning = "MEANING"
    case preposition = "PREPOSITION"
    case synonym = "SYNONYM"

    public var titleTr: String {
        switch self {
        case .meaning:
            return "1. Boyut: Akademik Anlam"
        case .preposition:
            return "2. Boyut: Zorunlu Edat"
        case .synonym:
            return "3. Boyut: YDS İkizi (Eş Anlam)"
        }
    }

    public var badgeTr: String {
        switch self {
        case .meaning:
            return "ANLAM"
        case .preposition:
            return "EDAT"
        case .synonym:
            return "YDS İKİZİ"
        }
    }
}

/// 3 Boyutlu Kelime Ustalık Durumu
/// KURAL: `isFullyLearned` yalnızca üç boyut da (`isMeaningMastered`, `isPrepositionMastered`, `isSynonymMastered`)
/// ayrı ayrı doğru cevaplandığında `true` döner!
public struct VocabMasteryProgress: Codable, Equatable, Sendable {
    public let isMeaningMastered: Bool
    public let isPrepositionMastered: Bool
    public let isSynonymMastered: Bool
    public let nextReviewAt: Date
    public let consecutiveCorrectCount: Int

    public init(
        isMeaningMastered: Bool = false,
        isPrepositionMastered: Bool = false,
        isSynonymMastered: Bool = false,
        nextReviewAt: Date = Date(timeIntervalSince1970: 1_700_000_000),
        consecutiveCorrectCount: Int = 0
    ) {
        self.isMeaningMastered = isMeaningMastered
        self.isPrepositionMastered = isPrepositionMastered
        self.isSynonymMastered = isSynonymMastered
        self.nextReviewAt = nextReviewAt
        self.consecutiveCorrectCount = consecutiveCorrectCount
    }

    /// 3D Vocabulary Mastery Rule: Üç boyutun tamamı ustalaşılmadan kelime öğrenildi sayılmaz.
    public var isFullyLearned: Bool {
        isMeaningMastered && isPrepositionMastered && isSynonymMastered
    }

    public var masteredDimensionCount: Int {
        [isMeaningMastered, isPrepositionMastered, isSynonymMastered].filter { $0 }.count
    }

    public var nextPendingDimension: VocabQuizDimension {
        if !isMeaningMastered { return .meaning }
        if !isPrepositionMastered { return .preposition }
        if !isSynonymMastered { return .synonym }
        return .meaning
    }
}

/// 3 Boyutlu Kelime, Zorunlu Edat ve YDS İkizleri Paketi
public struct Vocab3DCard: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let headword: String
    public let partOfSpeech: String
    public let track: AcademicTrack
    public let academicMeaningTr: String
    public let mandatoryPreposition: String
    public let ydsTwins: [String]
    public let meaningDistractorsTr: [String]
    public let prepositionDistractors: [String]
    public let twinDistractors: [String]
    public let examExampleSentenceEn: String
    public let examExampleSentenceTr: String
    public let examTipTr: String
    public let masteryProgress: VocabMasteryProgress

    public init(
        id: String,
        headword: String,
        partOfSpeech: String,
        track: AcademicTrack,
        academicMeaningTr: String,
        mandatoryPreposition: String,
        ydsTwins: [String],
        meaningDistractorsTr: [String],
        prepositionDistractors: [String],
        twinDistractors: [String],
        examExampleSentenceEn: String,
        examExampleSentenceTr: String,
        examTipTr: String,
        masteryProgress: VocabMasteryProgress = VocabMasteryProgress()
    ) {
        self.id = id
        self.headword = headword
        self.partOfSpeech = partOfSpeech
        self.track = track
        self.academicMeaningTr = academicMeaningTr
        self.mandatoryPreposition = mandatoryPreposition
        self.ydsTwins = ydsTwins
        self.meaningDistractorsTr = meaningDistractorsTr
        self.prepositionDistractors = prepositionDistractors
        self.twinDistractors = twinDistractors
        self.examExampleSentenceEn = examExampleSentenceEn
        self.examExampleSentenceTr = examExampleSentenceTr
        self.examTipTr = examTipTr
        self.masteryProgress = masteryProgress
    }

    public var isFullyLearned: Bool {
        masteryProgress.isFullyLearned
    }

    public var formattedWithPreposition: String {
        "\(headword) \(mandatoryPreposition.uppercased())"
    }
}
