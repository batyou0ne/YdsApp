import Foundation

/// Soru kökü (stem) içinde standart metin veya vurgulanmış ipucu parçası
public struct StemRenderFragment: Identifiable, Equatable, Sendable {
    public let id: String
    public let text: String
    public let clueType: ClueHighlightType?

    public init(id: String, text: String, clueType: ClueHighlightType?) {
        self.id = id
        self.text = text
        self.clueType = clueType
    }
}

/// Mikro-Sprint Ekran Durumu (Immutable ViewState - SwiftUI <-> Jetpack Compose 1:1)
public struct MicroSprintViewState: Equatable, Sendable {
    public let profile: UserStudyProfile
    public let selectedMode: MicroSprintMode
    public let selectedTrack: AcademicTrack
    public let questions: [SprintQuestion]
    public let currentIndex: Int
    public let remainingSeconds: Int
    public let totalLimitSeconds: Int

    // 10 Saniyede Çeviri Avı Durumu (.translation10SecHunt)
    public let isStemBlurredExpectClues: Bool

    // Artı / Eksi Bağlaç Radarı Durumu (.conjunctionPolarityRadar)
    public let selectedLeftPolarity: PolarityType?
    public let selectedRightPolarity: PolarityType?
    public let isPolarityRadarVerified: Bool

    // Soru Cevaplama & Çeldirici Koçu Durumu
    public let selectedOptionId: String?
    public let isQuestionSubmitted: Bool
    public let activeDistractorCoachOption: QuestionOption?
    public let isDistractorDetailsBlurred: Bool
    public let sessionCorrectCount: Int
    public let sessionSolvedCount: Int
    public let sessionEarnedScoreDelta: Double
    public let latestScoreExplanation: ScoreChangeExplanation?
    public let latestScoreTransitionText: String?
    public let isPaywallPresented: Bool
    public let paywallReasonTr: String

    public init(
        profile: UserStudyProfile = UserStudyProfile(hasCompletedOnboarding: true),
        selectedMode: MicroSprintMode = .translation10SecHunt,
        selectedTrack: AcademicTrack = .healthSciences,
        questions: [SprintQuestion] = SprintQuestionSeedData.translationHuntQuestions,
        currentIndex: Int = 0,
        remainingSeconds: Int = 10,
        totalLimitSeconds: Int = 10,
        isStemBlurredExpectClues: Bool = true,
        selectedLeftPolarity: PolarityType? = nil,
        selectedRightPolarity: PolarityType? = nil,
        isPolarityRadarVerified: Bool = false,
        selectedOptionId: String? = nil,
        isQuestionSubmitted: Bool = false,
        activeDistractorCoachOption: QuestionOption? = nil,
        isDistractorDetailsBlurred: Bool = true,
        sessionCorrectCount: Int = 0,
        sessionSolvedCount: Int = 0,
        sessionEarnedScoreDelta: Double = 0.0,
        latestScoreExplanation: ScoreChangeExplanation? = nil,
        latestScoreTransitionText: String? = nil,
        isPaywallPresented: Bool = false,
        paywallReasonTr: String = "Düştüğün sınav tuzağını (trapReason) ve doğru şık kısa yolunu (winningRule) bulanıklık olmadan görmek için YDS Pro'ya geç."
    ) {
        self.profile = profile
        self.selectedMode = selectedMode
        self.selectedTrack = selectedTrack
        self.questions = questions
        self.currentIndex = currentIndex
        self.remainingSeconds = remainingSeconds
        self.totalLimitSeconds = totalLimitSeconds
        self.isStemBlurredExpectClues = isStemBlurredExpectClues
        self.selectedLeftPolarity = selectedLeftPolarity
        self.selectedRightPolarity = selectedRightPolarity
        self.isPolarityRadarVerified = isPolarityRadarVerified
        self.selectedOptionId = selectedOptionId
        self.isQuestionSubmitted = isQuestionSubmitted
        self.activeDistractorCoachOption = activeDistractorCoachOption
        self.isDistractorDetailsBlurred = isDistractorDetailsBlurred
        self.sessionCorrectCount = sessionCorrectCount
        self.sessionSolvedCount = sessionSolvedCount
        self.sessionEarnedScoreDelta = sessionEarnedScoreDelta
        self.latestScoreExplanation = latestScoreExplanation
        self.latestScoreTransitionText = latestScoreTransitionText
        self.isPaywallPresented = isPaywallPresented
        self.paywallReasonTr = paywallReasonTr
    }

    // MARK: - Hesaplanmış Özellikler (Computed Properties)

    public var currentQuestion: SprintQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    public var timerProgressFraction: Double {
        min(max(Double(remainingSeconds) / Double(max(1, totalLimitSeconds)), 0.0), 1.0)
    }

    public var formattedSessionDeltaText: String {
        String(format: "Bu Sprint: +%.2f puan", sessionEarnedScoreDelta)
    }

    public var formattedCurrentScore: String {
        String(format: "%.2f", profile.currentEstimatedScore)
    }

    public var formattedTargetScore: String {
        String(format: "%.2f", profile.targetScore)
    }

    public var progressPositionText: String {
        guard !questions.isEmpty else { return "0 / 0" }
        return "Soru \(currentIndex + 1) / \(questions.count)"
    }

    public var isTimerUrgent: Bool {
        !isQuestionSubmitted && remainingSeconds <= 3
    }

    public var isCurrentAnswerCorrect: Bool {
        guard let selectedOptionId, let currentQuestion else { return false }
        return selectedOptionId == currentQuestion.correctOptionId
    }

    public var currentSelectedOption: QuestionOption? {
        guard let selectedOptionId, let currentQuestion else { return nil }
        return currentQuestion.options.first { $0.id == selectedOptionId }
    }

    public var polarityRadarStatusTextTr: String {
        guard let left = selectedLeftPolarity, let right = selectedRightPolarity else {
            return "1. Adım: Boşluk öncesi (Sol) ve boşluk sonrası (Sağ) cümlenin anlam kutbunu (+ / - / =) seç."
        }
        if isPolarityRadarVerified {
            if left != right {
                return "⇄ KUTUPLAR DOĞRULANDI (\(left.symbol) <-> \(right.symbol)): ZITLIK AİLESİ (Although / While / Despite / Notwithstanding / Nonetheless) ara!"
            } else {
                return "⇉ KUTUPLAR DOĞRULANDI (\(left.symbol) <-> \(right.symbol)): PARALEL / NEDEN-SONUÇ AİLESİ (Because / Since / Moreover / Due to) ara!"
            }
        } else {
            return "Seçtiğin kutuplar (\(left.symbol) <-> \(right.symbol)) cümledeki ipucu kelimelerle eşleşmedi. Aşağıdaki ipucu rozetlerine göre tekrar dene!"
        }
    }

    public var currentStemFragments: [StemRenderFragment] {
        guard let question = currentQuestion else { return [] }
        return Self.tokenizeStem(stemText: question.stemText, clues: question.highlightedClues)
    }

    private static func tokenizeStem(stemText: String, clues: [ClueSpan]) -> [StemRenderFragment] {
        struct MatchedRange {
            let range: Range<String.Index>
            let clueType: ClueHighlightType
        }

        var matchedRanges: [MatchedRange] = []
        for clue in clues {
            let parts = clue.matchedSubstring
                .components(separatedBy: "...")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            var searchStart = stemText.startIndex
            for part in parts {
                guard searchStart < stemText.endIndex else { break }
                if let foundRange = stemText.range(
                    of: part,
                    options: [.caseInsensitive],
                    range: searchStart..<stemText.endIndex
                ) {
                    let overlaps = matchedRanges.contains { $0.range.overlaps(foundRange) }
                    if !overlaps {
                        matchedRanges.append(MatchedRange(range: foundRange, clueType: clue.clueType))
                        searchStart = foundRange.upperBound
                    }
                }
            }
        }

        matchedRanges.sort { $0.range.lowerBound < $1.range.lowerBound }

        if matchedRanges.isEmpty {
            return [StemRenderFragment(id: "frag-0", text: stemText, clueType: nil)]
        }

        var fragments: [StemRenderFragment] = []
        var cursor = stemText.startIndex
        var indexCounter = 0

        for match in matchedRanges {
            if cursor < match.range.lowerBound {
                let plainText = String(stemText[cursor..<match.range.lowerBound])
                fragments.append(
                    StemRenderFragment(id: "frag-\(indexCounter)", text: plainText, clueType: nil)
                )
                indexCounter += 1
            }

            let highlightedText = String(stemText[match.range])
            fragments.append(
                StemRenderFragment(id: "frag-\(indexCounter)", text: highlightedText, clueType: match.clueType)
            )
            indexCounter += 1
            cursor = match.range.upperBound
        }

        if cursor < stemText.endIndex {
            let trailingText = String(stemText[cursor..<stemText.endIndex])
            fragments.append(
                StemRenderFragment(id: "frag-\(indexCounter)", text: trailingText, clueType: nil)
            )
        }

        return fragments
    }
}

/// Mikro-Sprint Kullanıcı Niyetleri (UDF UiEvent)
public enum MicroSprintUiEvent: Sendable {
    case onAppear
    case selectSprintMode(MicroSprintMode)
    case selectTrack(AcademicTrack)
    case timerTick
    case toggleTranslationBlurClueMode
    case selectLeftPolarity(PolarityType)
    case selectRightPolarity(PolarityType)
    case selectOption(String)
    case dismissDistractorCoachAndAdvance
    case nextQuestion
    case openPaywall(String)
    case dismissPaywall
    case upgradeSubscription(SubscriptionTier)
}
