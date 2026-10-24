import Foundation

/// Cümle Röntgeni (Sentence X-Ray) içindeki cümle parçalarının yapısal rolü
public enum SegmentRole: String, Codable, CaseIterable, Equatable, Sendable {
    case mainSubject = "MAIN_SUBJECT"
    case mainVerb = "MAIN_VERB"
    case conjunction = "CONJUNCTION"
    case nonEssentialClause = "NON_ESSENTIAL_CLAUSE"
    case prepositionTrigger = "PREPOSITION_TRIGGER"
    case standard = "STANDARD"

    public var titleTr: String {
        switch self {
        case .mainSubject:
            return "Ana Özne"
        case .mainVerb:
            return "Ana Yüklem"
        case .conjunction:
            return "Bağlaç & Kutup"
        case .nonEssentialClause:
            return "Yan Cümlecik / İki Virgül Arası"
        case .prepositionTrigger:
            return "Zorunlu Edat Kalıbı"
        case .standard:
            return "Tamamlayıcı Öğe"
        }
    }

    public var shortTagTr: String {
        switch self {
        case .mainSubject:
            return "ÖZNE"
        case .mainVerb:
            return "YÜKLEM"
        case .conjunction:
            return "BAĞLAÇ"
        case .nonEssentialClause:
            return "[YAN CÜMLECİK]"
        case .prepositionTrigger:
            return "EDAT"
        case .standard:
            return "METİN"
        }
    }
}

/// Bağlacın cümle akış yönü (Zıtlık vs Paralellik/Neden-Sonuç)
public enum ConjunctionDirection: String, Codable, Equatable, Sendable {
    case contrast = "CONTRAST"
    case parallel = "PARALLEL"

    public var iconSymbol: String {
        switch self {
        case .contrast: return "⇄"
        case .parallel: return "⇉"
        }
    }

    public var descriptionTr: String {
        switch self {
        case .contrast: return "Zıtlık / Yön Değiştirici (⇄)"
        case .parallel: return "Paralel / Neden-Sonuç Akışı (⇉)"
        }
    }
}

/// Cümle Röntgeni içerisindeki tek bir etkileşimli cümle parçası
public struct SentenceSegment: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let text: String
    public let role: SegmentRole
    public let examLogicTipTr: String?
    public let conjunctionDirection: ConjunctionDirection?
    public let segmentPolarity: PolarityType?

    public init(
        id: String,
        text: String,
        role: SegmentRole,
        examLogicTipTr: String? = nil,
        conjunctionDirection: ConjunctionDirection? = nil,
        segmentPolarity: PolarityType? = nil
    ) {
        self.id = id
        self.text = text
        self.role = role
        self.examLogicTipTr = examLogicTipTr
        self.conjunctionDirection = conjunctionDirection
        self.segmentPolarity = segmentPolarity
    }
}

/// 4-5 satırlık akademik cümleleri görsel olarak parçalarına ayıran Cümle Röntgeni modeli
public struct SentenceXRayItem: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let track: AcademicTrack
    public let difficultyLevel: Int
    public let fullTranslationTr: String
    public let skeletonSummaryTr: String
    public let clausePolarityLeft: PolarityType
    public let clausePolarityRight: PolarityType
    public let segments: [SentenceSegment]

    public init(
        id: String,
        track: AcademicTrack,
        difficultyLevel: Int,
        fullTranslationTr: String,
        skeletonSummaryTr: String,
        clausePolarityLeft: PolarityType,
        clausePolarityRight: PolarityType,
        segments: [SentenceSegment]
    ) {
        self.id = id
        self.track = track
        self.difficultyLevel = difficultyLevel
        self.fullTranslationTr = fullTranslationTr
        self.skeletonSummaryTr = skeletonSummaryTr
        self.clausePolarityLeft = clausePolarityLeft
        self.clausePolarityRight = clausePolarityRight
        self.segments = segments
    }

    public var fullEnglishSentence: String {
        segments.map(\.text).joined(separator: " ")
    }
}
