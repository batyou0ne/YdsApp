import Foundation

// MARK: - 1. DefaultUserStudyRepository
public actor DefaultUserStudyRepository: UserStudyRepository {
    private let profileStorageKey = "yds.app.user_study_profile.v1"
    private let masteryStorageKey = "yds.app.category_masteries.v1"

    private var cachedProfile: UserStudyProfile
    private var cachedMasteries: [CategoryMasteryRecord]

    public init() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: profileStorageKey),
           let decoded = try? JSONDecoder().decode(UserStudyProfile.self, from: data) {
            self.cachedProfile = decoded
        } else {
            self.cachedProfile = UserStudyProfile()
        }

        if let data = defaults.data(forKey: masteryStorageKey),
           let decoded = try? JSONDecoder().decode([CategoryMasteryRecord].self, from: data),
           !decoded.isEmpty {
            self.cachedMasteries = decoded
        } else {
            self.cachedMasteries = MistakeVaultSeedData.defaultCategoryMasteries
        }
    }

    public func getUserProfile() async -> UserStudyProfile {
        cachedProfile
    }

    public func saveUserProfile(_ profile: UserStudyProfile) async {
        cachedProfile = profile
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: profileStorageKey)
        }
    }

    public func getCategoryMasteries() async -> [CategoryMasteryRecord] {
        cachedMasteries
    }

    public func saveCategoryMasteries(_ records: [CategoryMasteryRecord]) async {
        cachedMasteries = records
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: masteryStorageKey)
        }
    }
}

// MARK: - 2. DefaultSentenceXRayRepository
public actor DefaultSentenceXRayRepository: SentenceXRayRepository {
    private let items: [SentenceXRayItem]

    public init(items: [SentenceXRayItem] = SentenceXRaySeedData.allItems) {
        self.items = items
    }

    public func getXRayItems(for track: AcademicTrack) async -> [SentenceXRayItem] {
        if track == .generalAcademic {
            return items
        }
        let filtered = items.filter { $0.track == track }
        return filtered.isEmpty ? items : filtered
    }

    public func getAllXRayItems() async -> [SentenceXRayItem] {
        items
    }
}

// MARK: - 3. DefaultVocabularyRepository
public actor DefaultVocabularyRepository: VocabularyRepository {
    private let vocabStorageKey = "yds.app.vocab_3d_cards.v1"
    private var cards: [Vocab3DCard]

    public init() {
        if let data = UserDefaults.standard.data(forKey: vocabStorageKey),
           let decoded = try? JSONDecoder().decode([Vocab3DCard].self, from: data),
           !decoded.isEmpty {
            self.cards = decoded
        } else {
            self.cards = Vocab3DSeedData.allCards
        }
    }

    public func getVocabCards(for track: AcademicTrack) async -> [Vocab3DCard] {
        if track == .generalAcademic {
            return cards
        }
        let filtered = cards.filter { $0.track == track }
        return filtered.isEmpty ? cards : filtered
    }

    public func getAllVocabCards() async -> [Vocab3DCard] {
        cards
    }

    public func updateVocabCardProgress(_ updatedCard: Vocab3DCard) async {
        if let index = cards.firstIndex(where: { $0.id == updatedCard.id }) {
            cards[index] = updatedCard
            if let data = try? JSONEncoder().encode(cards) {
                UserDefaults.standard.set(data, forKey: vocabStorageKey)
            }
        }
    }
}

// MARK: - 4. DefaultSprintQuestionRepository
public actor DefaultSprintQuestionRepository: SprintQuestionRepository {
    private let questions: [SprintQuestion]

    public init(questions: [SprintQuestion] = SprintQuestionSeedData.allQuestions) {
        self.questions = questions
    }

    public func getDiagnosticQuestions() async -> [SprintQuestion] {
        questions.filter {
            $0.isDiagnosticOnboarding && !$0.id.hasPrefix(SprintQuestionAdaptivePoolSeedData.idPrefix)
        }
    }

    public func getDiagnosticQuestions(
        band: QuestionDifficultyBand,
        category: QuestionCategory?,
        track: AcademicTrack,
        excluding excludedQuestionIds: Set<String>
    ) async -> [SprintQuestion] {
        let pool = questions.filter { question in
            question.isDiagnosticOnboarding
                && question.difficultyBand == band
                && !excludedQuestionIds.contains(question.id)
                && (category == nil || question.category == category)
        }
        guard track != .generalAcademic else { return pool }
        let trackMatches = pool.filter { $0.track == track }
        return trackMatches + pool.filter { $0.track != track }
    }

    public func getQuestions(
        for track: AcademicTrack,
        mode: MicroSprintMode?,
        category: QuestionCategory?
    ) async -> [SprintQuestion] {
        var result = questions.filter { !$0.isDiagnosticOnboarding }

        if let mode {
            let modeMatches = result.filter { $0.sprintMode == mode }
            if !modeMatches.isEmpty {
                result = modeMatches
            }
        }

        if let category {
            let categoryMatches = result.filter { $0.category == category }
            if !categoryMatches.isEmpty {
                result = categoryMatches
            }
        }

        if track != .generalAcademic {
            let trackMatches = result.filter { $0.track == track }
            if !trackMatches.isEmpty {
                return trackMatches + result.filter { $0.track != track }
            }
        }

        return result
    }

    public func getAllQuestions() async -> [SprintQuestion] {
        questions
    }
}

// MARK: - 5. DefaultMistakeVaultRepository
public actor DefaultMistakeVaultRepository: MistakeVaultRepository {
    private let mistakeStorageKey = "yds.app.mistake_vault.v1"
    private var mistakes: [MistakeVaultItem]

    public init() {
        if let data = UserDefaults.standard.data(forKey: mistakeStorageKey),
           let decoded = try? JSONDecoder().decode([MistakeVaultItem].self, from: data),
           !decoded.isEmpty {
            self.mistakes = decoded
        } else {
            self.mistakes = MistakeVaultSeedData.initialMistakes
        }
    }

    public func getMistakeItems() async -> [MistakeVaultItem] {
        mistakes
    }

    public func recordMistake(
        question: SprintQuestion,
        selectedOption: QuestionOption,
        date: Date = Date()
    ) async {
        let feedback = selectedOption.distractorCoachFeedback
        let correctOptionText = question.correctOption?.text ?? question.correctOptionId

        if let index = mistakes.firstIndex(where: { $0.questionId == question.id }) {
            let existing = mistakes[index]
            mistakes[index] = MistakeVaultItem(
                id: existing.id,
                questionId: question.id,
                stemPreview: String(question.stemText.prefix(135)),
                selectedWrongOptionId: selectedOption.id,
                selectedWrongOptionText: selectedOption.text,
                correctOptionId: question.correctOptionId,
                correctOptionText: correctOptionText,
                category: question.category,
                track: question.track,
                grammarRuleTag: feedback.grammarRuleTag,
                grammarRuleTitleTr: Self.ruleTitle(for: feedback.grammarRuleTag, category: question.category),
                praiseTextTr: feedback.praiseTextTr,
                trapReasonTr: feedback.trapReasonTr,
                winningRuleTr: feedback.winningRuleTr,
                failedCount: existing.failedCount + 1,
                masteredInReviewCount: 0,
                isResolved: false,
                lastMistakeDate: date
            )
        } else {
            let newItem = MistakeVaultItem(
                id: "mv-\(question.id)-\(Int(date.timeIntervalSince1970))",
                questionId: question.id,
                stemPreview: String(question.stemText.prefix(135)),
                selectedWrongOptionId: selectedOption.id,
                selectedWrongOptionText: selectedOption.text,
                correctOptionId: question.correctOptionId,
                correctOptionText: correctOptionText,
                category: question.category,
                track: question.track,
                grammarRuleTag: feedback.grammarRuleTag,
                grammarRuleTitleTr: Self.ruleTitle(for: feedback.grammarRuleTag, category: question.category),
                praiseTextTr: feedback.praiseTextTr,
                trapReasonTr: feedback.trapReasonTr,
                winningRuleTr: feedback.winningRuleTr,
                failedCount: 1,
                masteredInReviewCount: 0,
                isResolved: false,
                lastMistakeDate: date
            )
            mistakes.insert(newItem, at: 0)
        }
        persist()
    }

    public func markMistakeReviewed(mistakeId: String, answeredCorrectly: Bool) async {
        guard let index = mistakes.firstIndex(where: { $0.id == mistakeId }) else { return }
        let current = mistakes[index]
        let newMasteredCount = answeredCorrectly ? (current.masteredInReviewCount + 1) : 0
        let resolved = answeredCorrectly && newMasteredCount >= 1
        mistakes[index] = MistakeVaultItem(
            id: current.id,
            questionId: current.questionId,
            stemPreview: current.stemPreview,
            selectedWrongOptionId: current.selectedWrongOptionId,
            selectedWrongOptionText: current.selectedWrongOptionText,
            correctOptionId: current.correctOptionId,
            correctOptionText: current.correctOptionText,
            category: current.category,
            track: current.track,
            grammarRuleTag: current.grammarRuleTag,
            grammarRuleTitleTr: current.grammarRuleTitleTr,
            praiseTextTr: current.praiseTextTr,
            trapReasonTr: current.trapReasonTr,
            winningRuleTr: current.winningRuleTr,
            failedCount: answeredCorrectly ? current.failedCount : (current.failedCount + 1),
            masteredInReviewCount: newMasteredCount,
            isResolved: resolved,
            lastMistakeDate: current.lastMistakeDate
        )
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(mistakes) {
            UserDefaults.standard.set(data, forKey: mistakeStorageKey)
        }
    }

    public static func ruleTitle(for tag: String, category: QuestionCategory) -> String {
        switch tag {
        case "CONJ_CLAUSE_VS_NP", "CONJ_PARTICIPLE_NP_TRAP":
            return "Tam Cümle (Although) vs İsim Öbeği (Despite/Regardless of) Kuralı"
        case "CONJ_CAUSE_VS_CONTRAST", "CONJ_POLARITY_CONTRAST":
            return "Artı (+) / Eksi (-) Bağlaç Kutbu Uyumu"
        case "PREP_TURKISH_AGAINST_TRAP", "PREP_SUSCEPTIBLE_TO_IN":
            return "Yatkınlık Sıfatlarında 'Susceptible/Vulnerable TO' Kuralı"
        case "TRANS_MAIN_VERB_MISMATCH", "TRANS_MAIN_VERB_AND_CONJ":
            return "Çeviri Sorularında Ana Yüklem ve Bağlaç Eklemi Eşleşmesi"
        case "TRANS_SINCE_CAUSE_VS_TIME":
            return "Geniş Zamanda 'Since' (-dığı için) Çeviri Kuralı"
        case "RED_ACTIVE_VS_PASSIVE_PARTICIPLE":
            return "Cansız Özne + Edat Önünde Pasif (V3) Kısaltma Kuralı"
        case "IRRELEVANT_PRONOUN_CHAIN", "IRRELEVANT_TOPIC_SHIFT":
            return "Akış Bozan Cümlede Zamir Köprüsü (This/Such/They) Takibi"
        default:
            return "\(category.shortTitleTr) Sınav Tuzak Kuralı (\(tag))"
        }
    }
}

// MARK: - Dependency Container
public struct AppDependencyContainer: Sendable {
    public let userStudyRepository: any UserStudyRepository
    public let sentenceXRayRepository: any SentenceXRayRepository
    public let vocabularyRepository: any VocabularyRepository
    public let sprintQuestionRepository: any SprintQuestionRepository
    public let mistakeVaultRepository: any MistakeVaultRepository

    public let calculateEstimatedScoreUseCase: CalculateEstimatedScoreUseCase
    public let evaluateVocab3DMasteryUseCase: EvaluateVocab3DMasteryUseCase
    public let evaluateDiagnosticTestUseCase: EvaluateDiagnosticTestUseCase
    public let generateDailyPrescriptionUseCase: GenerateDailyPrescriptionUseCase
    public let checkEntitlementUseCase: CheckEntitlementUseCase

    public init(
        userStudyRepository: any UserStudyRepository = DefaultUserStudyRepository(),
        sentenceXRayRepository: any SentenceXRayRepository = DefaultSentenceXRayRepository(),
        vocabularyRepository: any VocabularyRepository = DefaultVocabularyRepository(),
        sprintQuestionRepository: any SprintQuestionRepository = DefaultSprintQuestionRepository(),
        mistakeVaultRepository: any MistakeVaultRepository = DefaultMistakeVaultRepository()
    ) {
        self.userStudyRepository = userStudyRepository
        self.sentenceXRayRepository = sentenceXRayRepository
        self.vocabularyRepository = vocabularyRepository
        self.sprintQuestionRepository = sprintQuestionRepository
        self.mistakeVaultRepository = mistakeVaultRepository

        self.calculateEstimatedScoreUseCase = CalculateEstimatedScoreUseCase()
        self.evaluateVocab3DMasteryUseCase = EvaluateVocab3DMasteryUseCase()
        self.evaluateDiagnosticTestUseCase = EvaluateDiagnosticTestUseCase()
        self.generateDailyPrescriptionUseCase = GenerateDailyPrescriptionUseCase()
        self.checkEntitlementUseCase = CheckEntitlementUseCase()
    }
}
