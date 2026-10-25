import Foundation

// MARK: - Randomness (DI)

/// Deterministik test edilebilirlik için enjekte edilen rastgelelik kaynağı.
/// Durumsuzdur (stateless): aynı (`upperBound`, `step`) çifti aynı sonucu verir.
public protocol RandomnessProvider: Sendable {
    /// `0..<upperBound` aralığında bir indeks döndürür. `upperBound <= 1` ise 0 döner.
    func nextIndex(upperBound: Int, step: Int) -> Int
}

/// Tohumlu (seed'li) SplitMix64 tabanlı sağlayıcı: aynı seed -> aynı soru dizisi.
public struct SeededRandomnessProvider: RandomnessProvider, Equatable {
    public let seed: UInt64

    public init(seed: UInt64) {
        self.seed = seed
    }

    public func nextIndex(upperBound: Int, step: Int) -> Int {
        guard upperBound > 1 else { return 0 }
        var z = seed &+ (UInt64(truncatingIfNeeded: step) &+ 1) &* 0x9E3779B97F4A7C15
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        z = z ^ (z >> 31)
        return Int(z % UInt64(upperBound))
    }
}

/// Üretim ortamı için sistem rastgeleliği (soru çeşitliliği). Testlerde KULLANILMAZ.
public struct SystemRandomnessProvider: RandomnessProvider {
    public init() {}

    public func nextIndex(upperBound: Int, step: Int) -> Int {
        guard upperBound > 1 else { return 0 }
        var generator = SystemRandomNumberGenerator()
        return Int.random(in: 0..<upperBound, using: &generator)
    }
}

// MARK: - Models

/// Teşhis yolu: beyanlı (Yol A: 2 teyit sorusu) veya tam ölçüm (6 soru).
public enum AdaptiveDiagnosticPath: String, Codable, Equatable, Sendable {
    case declaredConfirmation = "DECLARED_CONFIRMATION"
    case fullMeasurement = "FULL_MEASUREMENT"
}

/// Ölçüm güven seviyesi.
public enum DiagnosticConfidenceLevel: String, Codable, CaseIterable, Equatable, Sendable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"

    public var titleTr: String {
        switch self {
        case .low: return "Düşük güven"
        case .medium: return "Orta güven"
        case .high: return "Yüksek güven"
        }
    }
}

/// Tek bir cevabın düz (platformdan bağımsız) kaydı.
public struct AdaptiveDiagnosticAnswer: Codable, Equatable, Sendable {
    public let questionId: String
    public let category: QuestionCategory
    public let band: QuestionDifficultyBand
    public let irtDifficulty: Double
    /// `nil` = süre doldu / boş bırakıldı
    public let selectedOptionId: String?
    public let isCorrect: Bool
    public let responseSeconds: Double
    public let timeLimitSeconds: Int
    public let timedOut: Bool
    /// Süre limitinin yarısından hızlı doğru cevap
    public let isFastCorrect: Bool

    public init(
        questionId: String,
        category: QuestionCategory,
        band: QuestionDifficultyBand,
        irtDifficulty: Double,
        selectedOptionId: String?,
        correctOptionId: String,
        responseSeconds: Double,
        timeLimitSeconds: Int
    ) {
        self.questionId = questionId
        self.category = category
        self.band = band
        self.irtDifficulty = irtDifficulty
        self.selectedOptionId = selectedOptionId
        self.responseSeconds = max(0, responseSeconds)
        self.timeLimitSeconds = timeLimitSeconds
        // Süre dolan = yanlış
        let expired = selectedOptionId == nil || (timeLimitSeconds > 0 && responseSeconds > Double(timeLimitSeconds))
        self.timedOut = expired
        self.isCorrect = !expired && selectedOptionId == correctOptionId
        self.isFastCorrect = self.isCorrect && timeLimitSeconds > 0 && responseSeconds < Double(timeLimitSeconds) / 2.0
    }

    public init(question: SprintQuestion, selectedOptionId: String?, responseSeconds: Double) {
        self.init(
            questionId: question.id,
            category: question.category,
            band: question.difficultyBand,
            irtDifficulty: question.irtDifficulty,
            selectedOptionId: selectedOptionId,
            correctOptionId: question.correctOptionId,
            responseSeconds: responseSeconds,
            timeLimitSeconds: question.timeLimitSeconds
        )
    }
}

/// Adaptif teşhis oturumu (değer tipi, değişmez güncelleme: her `submit` yeni kopya döner).
public struct AdaptiveDiagnosticSession: Codable, Equatable, Sendable {
    public let path: AdaptiveDiagnosticPath
    public let maxQuestions: Int
    public let askedQuestionIds: [String]
    public let answers: [AdaptiveDiagnosticAnswer]
    public let currentBand: QuestionDifficultyBand
    /// Tahmini Sınav Puanı ölçeğinde (0.00–100.00) yetenek tahmini
    public let abilityEstimate: Double
    /// Puan ölçeğinde standart hata
    public let standardError: Double
    public let remainingCategories: [QuestionCategory]

    public init(
        path: AdaptiveDiagnosticPath,
        maxQuestions: Int,
        askedQuestionIds: [String] = [],
        answers: [AdaptiveDiagnosticAnswer] = [],
        currentBand: QuestionDifficultyBand = .medium,
        abilityEstimate: Double,
        standardError: Double,
        remainingCategories: [QuestionCategory] = AdaptiveDiagnosticEngine.diagnosticCategories
    ) {
        self.path = path
        self.maxQuestions = maxQuestions
        self.askedQuestionIds = askedQuestionIds
        self.answers = answers
        self.currentBand = currentBand
        self.abilityEstimate = abilityEstimate
        self.standardError = standardError
        self.remainingCategories = remainingCategories
    }

    /// Yeni oturum. `declaredBaseline` verilirse Yol A (2 teyit sorusu), yoksa tam ölçüm (6 soru).
    public static func start(declaredBaseline: Double? = nil) -> AdaptiveDiagnosticSession {
        if let declared = declaredBaseline {
            return AdaptiveDiagnosticSession(
                path: .declaredConfirmation,
                maxQuestions: AdaptiveDiagnosticEngine.confirmationQuestionCount,
                abilityEstimate: AdaptiveDiagnosticEngine.clampScore(declared),
                standardError: AdaptiveDiagnosticEngine.declaredInitialStandardError
            )
        }
        return AdaptiveDiagnosticSession(
            path: .fullMeasurement,
            maxQuestions: AdaptiveDiagnosticEngine.fullQuestionCount,
            abilityEstimate: AdaptiveDiagnosticEngine.neutralStartScore,
            standardError: AdaptiveDiagnosticEngine.initialStandardError
        )
    }

    public var isComplete: Bool { answers.count >= maxQuestions }
}

/// Teşhis sonucu.
public struct AdaptiveDiagnosticOutcome: Equatable, Sendable {
    public let estimatedScore: Double
    public let confidenceLowerBound: Double
    public let confidenceUpperBound: Double
    public let categoryRecords: [CategoryMasteryRecord]
    public let weakestTwoCategories: [QuestionCategory]
    public let confidenceLevel: DiagnosticConfidenceLevel
    public let correctCount: Int
    public let totalCount: Int
    /// Beyan ile ölçüm arasında > 12 puan fark varsa Türkçe bilgi notu
    public let declaredScoreMismatchNoteTr: String?

    public init(
        estimatedScore: Double,
        confidenceLowerBound: Double,
        confidenceUpperBound: Double,
        categoryRecords: [CategoryMasteryRecord],
        weakestTwoCategories: [QuestionCategory],
        confidenceLevel: DiagnosticConfidenceLevel,
        correctCount: Int,
        totalCount: Int,
        declaredScoreMismatchNoteTr: String?
    ) {
        self.estimatedScore = estimatedScore
        self.confidenceLowerBound = confidenceLowerBound
        self.confidenceUpperBound = confidenceUpperBound
        self.categoryRecords = categoryRecords
        self.weakestTwoCategories = weakestTwoCategories
        self.confidenceLevel = confidenceLevel
        self.correctCount = correctCount
        self.totalCount = totalCount
        self.declaredScoreMismatchNoteTr = declaredScoreMismatchNoteTr
    }
}

// MARK: - Engine

/// 6 soruluk adaptif teşhis motoru (saf Domain, deterministik).
/// Mevcut `EvaluateDiagnosticTestUseCase` yanında durur; yuvarlama için ortak
/// `CalculateEstimatedScoreUseCase.roundToQuarterPoint` kullanılır.
public struct AdaptiveDiagnosticEngine: Sendable {
    // Sabitler
    public static let minScore = 25.0
    public static let maxScore = 92.5
    public static let fullQuestionCount = 6
    public static let confirmationQuestionCount = 2
    /// Yol C (beyan yok, ölçüm yok) sabit baz puanı
    public static let fallbackBaselineScore = 35.0
    public static let neutralStartScore = 57.5
    public static let initialStandardError = 10.0
    public static let declaredInitialStandardError = 7.0
    /// Her cevapta standart hatanın çarpanı (SE sürekli küçülür)
    public static let standardErrorDecay = 0.80
    /// Beyan - ölçüm farkı bu eşiği aşarsa uyarı notu üretilir
    public static let mismatchThreshold = 12.0
    /// Puan ölçeği <-> logit dönüşümü (1 logit = 12 puan)
    static let pointsPerLogit = 12.0
    static let baseK = 1.6
    static let kDecayPerAnswer = 0.25
    static let fastCorrectBonus = 0.1

    public static let diagnosticCategories: [QuestionCategory] = [
        .academicVocab, .conjunction, .preposition,
        .reductionAndTense, .sentenceCompletion, .dialogueAndRestatement
    ]

    private let scoreCalculator: CalculateEstimatedScoreUseCase
    private let randomness: RandomnessProvider

    /// Varsayılan sağlayıcı sabit seed'lidir (deterministik); çeşitlilik için kompozisyon
    /// kökünde `SystemRandomnessProvider()` enjekte edilir.
    public init(
        randomness: RandomnessProvider = SeededRandomnessProvider(seed: 0),
        scoreCalculator: CalculateEstimatedScoreUseCase = CalculateEstimatedScoreUseCase()
    ) {
        self.randomness = randomness
        self.scoreCalculator = scoreCalculator
    }

    public static func clampScore(_ value: Double) -> Double {
        min(max(value, minScore), maxScore)
    }

    // MARK: Next question

    /// Sıradaki soruyu seçer; oturum bittiyse veya uygun soru yoksa `nil`.
    /// Sıralama: (1) hedef banda yakınlık, (2) tanı sorusu olması, (3) kullanıcının track'i
    /// (tam eşleşme > genel akademik > diğer). Track'i banttan sonra koymamızın nedeni:
    /// yanlış bantta soru sormak ölçümü bozar; aynı bant içinde track önceliklidir.
    public func nextQuestion(
        session: AdaptiveDiagnosticSession,
        pool: [SprintQuestion],
        track: AcademicTrack
    ) -> SprintQuestion? {
        guard !session.isComplete else { return nil }

        let asked = Set(session.askedQuestionIds)
        let targetBand: QuestionDifficultyBand = session.answers.isEmpty ? .medium : session.currentBand
        let step = session.answers.count

        let available = pool.filter { !asked.contains($0.id) }
        let categoriesWithCandidates = session.remainingCategories.filter { category in
            available.contains { $0.category == category }
        }
        guard !categoriesWithCandidates.isEmpty else { return nil }

        let category = categoriesWithCandidates[randomness.nextIndex(upperBound: categoriesWithCandidates.count, step: step)]
        let candidates = available.filter { $0.category == category }

        func key(_ q: SprintQuestion) -> [Int] {
            let bandDistance = abs(Self.bandRank(q.difficultyBand) - Self.bandRank(targetBand))
            let diagnosticRank = q.isDiagnosticOnboarding ? 0 : 1
            let trackRank = q.track == track ? 0 : (q.track == .generalAcademic ? 1 : 2)
            return [bandDistance, diagnosticRank, trackRank]
        }
        func lessThan(_ a: [Int], _ b: [Int]) -> Bool {
            for (x, y) in zip(a, b) where x != y { return x < y }
            return false
        }

        var bestKey = key(candidates[0])
        for q in candidates.dropFirst() {
            let k = key(q)
            if lessThan(k, bestKey) { bestKey = k }
        }
        // Sıralı (id'ye göre) eşit adaylar arasından seed'li seçim -> platformlar arası kararlı
        let tied = candidates.filter { key($0) == bestKey }.sorted { $0.id < $1.id }
        return tied[randomness.nextIndex(upperBound: tied.count, step: step &+ 100)]
    }

    // MARK: Submit

    /// Cevabı işler: Elo/1-PL benzeri yetenek güncellemesi (azalan K), SE küçültme, band geçişi.
    public func submit(answer: AdaptiveDiagnosticAnswer, session: AdaptiveDiagnosticSession) -> AdaptiveDiagnosticSession {
        let n = session.answers.count
        let theta = (session.abilityEstimate - Self.neutralStartScore) / Self.pointsPerLogit
        let probability = 1.0 / (1.0 + exp(-(theta - answer.irtDifficulty)))
        var outcome = answer.isCorrect ? 1.0 : 0.0
        if answer.isFastCorrect { outcome += Self.fastCorrectBonus }
        let k = Self.baseK / (1.0 + Self.kDecayPerAnswer * Double(n))
        let newTheta = theta + k * (outcome - probability)
        let newAbility = Self.clampScore(Self.neutralStartScore + newTheta * Self.pointsPerLogit)

        let newBand: QuestionDifficultyBand = answer.isCorrect
            ? Self.band(above: answer.band)
            : Self.band(below: answer.band)

        return AdaptiveDiagnosticSession(
            path: session.path,
            maxQuestions: session.maxQuestions,
            askedQuestionIds: session.askedQuestionIds + [answer.questionId],
            answers: session.answers + [answer],
            currentBand: newBand,
            abilityEstimate: newAbility,
            standardError: session.standardError * Self.standardErrorDecay,
            remainingCategories: session.remainingCategories.filter { $0 != answer.category }
        )
    }

    // MARK: Finalize

    public func finalize(session: AdaptiveDiagnosticSession, declaredBaseline: Double?) -> AdaptiveDiagnosticOutcome {
        let hasAnswers = !session.answers.isEmpty
        let rawScore: Double
        let standardError: Double
        if hasAnswers {
            rawScore = session.abilityEstimate
            standardError = session.standardError
        } else if let declared = declaredBaseline {
            rawScore = declared
            standardError = Self.initialStandardError
        } else {
            // Yol C: sabit baz, düşük güven
            rawScore = Self.fallbackBaselineScore
            standardError = Self.initialStandardError
        }

        let score = scoreCalculator.roundToQuarterPoint(Self.clampScore(rawScore))
        let halfWidth = 1.96 * standardError
        let lower = scoreCalculator.roundToQuarterPoint(Self.clampScore(score - halfWidth))
        let upper = scoreCalculator.roundToQuarterPoint(Self.clampScore(score + halfWidth))

        let level: DiagnosticConfidenceLevel
        if !hasAnswers {
            level = .low
        } else if standardError <= 3.0 {
            level = .high
        } else if standardError <= 5.5 {
            level = .medium
        } else {
            level = .low
        }

        let records = buildRecords(answers: session.answers, score: score)
        let weakest = weakestTwo(records: records, answers: session.answers)

        var note: String? = nil
        if hasAnswers, let declared = declaredBaseline {
            let declaredRounded = scoreCalculator.roundToQuarterPoint(Self.clampScore(declared))
            if abs(declaredRounded - score) > Self.mismatchThreshold {
                note = "Beyan ettiğin \(Self.format(declaredRounded)) ile ölçülen \(Self.format(score)) arasında fark var; ölçümle başlıyoruz"
            }
        }

        return AdaptiveDiagnosticOutcome(
            estimatedScore: score,
            confidenceLowerBound: lower,
            confidenceUpperBound: upper,
            categoryRecords: records,
            weakestTwoCategories: weakest,
            confidenceLevel: level,
            correctCount: session.answers.filter(\.isCorrect).count,
            totalCount: session.answers.count,
            declaredScoreMismatchNoteTr: note
        )
    }

    // MARK: Helpers

    private func buildRecords(answers: [AdaptiveDiagnosticAnswer], score: Double) -> [CategoryMasteryRecord] {
        let baseRatio = min(max(score / 100.0, 0.25), 0.85)
        let targetRatio = min(max((score + 10.0) / 100.0, baseRatio + 0.15), 0.95)
        return QuestionCategory.allCases.map { category in
            let items = answers.filter { $0.category == category }
            let ratio: Double
            if let item = items.first {
                // Zor soruyu doğru bilmek daha çok, kolay soruyu yanlış yapmak daha çok etki eder
                ratio = item.isCorrect
                    ? min(0.90, baseRatio + 0.12 + 0.04 * item.irtDifficulty)
                    : max(0.24, baseRatio - 0.14 + 0.04 * item.irtDifficulty)
            } else {
                ratio = baseRatio
            }
            return CategoryMasteryRecord(
                category: category,
                currentMasteryRatio: ratio,
                targetMasteryRatio: targetRatio,
                questionsSolvedCount: items.count,
                correctAnswersCount: items.filter(\.isCorrect).count
            )
        }
    }

    private func weakestTwo(records: [CategoryMasteryRecord], answers: [AdaptiveDiagnosticAnswer]) -> [QuestionCategory] {
        let order = Self.diagnosticCategories
        let sorted = records
            .filter { order.contains($0.category) }
            .sorted { lhs, rhs in
                if abs(lhs.currentMasteryRatio - rhs.currentMasteryRatio) > 0.0001 {
                    return lhs.currentMasteryRatio < rhs.currentMasteryRatio
                }
                return (order.firstIndex(of: lhs.category) ?? 0) < (order.firstIndex(of: rhs.category) ?? 0)
            }
        return Array(sorted.prefix(2).map(\.category))
    }

    static func bandRank(_ band: QuestionDifficultyBand) -> Int {
        switch band {
        case .easy: return 0
        case .medium: return 1
        case .hard: return 2
        }
    }

    static func band(above band: QuestionDifficultyBand) -> QuestionDifficultyBand {
        switch band {
        case .easy: return .medium
        case .medium, .hard: return .hard
        }
    }

    static func band(below band: QuestionDifficultyBand) -> QuestionDifficultyBand {
        switch band {
        case .hard: return .medium
        case .medium, .easy: return .easy
        }
    }

    /// `62.50` biçimi (Türkçe metinlerde yerel ayardan bağımsız, nokta ayraçlı)
    static func format(_ value: Double) -> String {
        String(format: "%.2f", locale: Locale(identifier: "en_US_POSIX"), value)
    }
}
