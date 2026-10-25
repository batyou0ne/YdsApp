import Foundation

public enum LessonDifficulty: String, Codable, CaseIterable, Equatable, Sendable {
    case easy = "EASY"
    case medium = "MEDIUM"
    case hard = "HARD"

    public var titleTr: String {
        switch self {
        case .easy:
            return "Kolay"
        case .medium:
            return "Orta"
        case .hard:
            return "Zor"
        }
    }
}

public enum LessonCategoryType: String, Codable, CaseIterable, Equatable, Sendable {
    case grammar = "GRAMMAR"
    case vocabulary = "VOCABULARY"
    case reading = "READING"
    case translation = "TRANSLATION"
    case clozeTest = "CLOZE_TEST"
    case dialogue = "DIALOGUE"

    public var titleTr: String {
        switch self {
        case .grammar:
            return "Gramer"
        case .vocabulary:
            return "Kelime"
        case .reading:
            return "Okuma"
        case .translation:
            return "Çeviri"
        case .clozeTest:
            return "Cloze Test"
        case .dialogue:
            return "Diyalog"
        }
    }

    public var iconSystemName: String {
        switch self {
        case .grammar:
            return "text.book.closed.fill"
        case .vocabulary:
            return "character.book.closed.fill"
        case .reading:
            return "doc.text.magnifyingglass"
        case .translation:
            return "arrow.left.arrow.right.circle.fill"
        case .clozeTest:
            return "square.and.pencil"
        case .dialogue:
            return "bubble.left.and.bubble.right.fill"
        }
    }
}

public struct LessonItem: Codable, Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let category: LessonCategoryType
    public let level: String
    public let difficulty: LessonDifficulty
    public let durationMinutes: Int
    public let questionCount: Int
    public let instructorName: String
    public let instructorSubtitle: String
    public let isFollowingInstructor: Bool
    public let summaryTr: String
    public let examTipsTr: [String]
    public let artworkType: String
    public var isBookmarked: Bool

    public init(
        id: String,
        title: String,
        category: LessonCategoryType,
        level: String,
        difficulty: LessonDifficulty = .medium,
        durationMinutes: Int = 25,
        questionCount: Int = 20,
        instructorName: String = "Akademik Sınav Enstitüsü",
        instructorSubtitle: String = "Resmî İçerik • ÖSYM Müfredatı",
        isFollowingInstructor: Bool = true,
        summaryTr: String,
        examTipsTr: [String],
        artworkType: String,
        isBookmarked: Bool = false
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.level = level
        self.difficulty = difficulty
        self.durationMinutes = durationMinutes
        self.questionCount = questionCount
        self.instructorName = instructorName
        self.instructorSubtitle = instructorSubtitle
        self.isFollowingInstructor = isFollowingInstructor
        self.summaryTr = summaryTr
        self.examTipsTr = examTipsTr
        self.artworkType = artworkType
        self.isBookmarked = isBookmarked
    }
}
