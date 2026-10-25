import Foundation

/// Kullanıcı çalışma profili ve kategori bazlı ustalık karnesi erişim protokolü
public protocol UserStudyRepository: Sendable {
    func getUserProfile() async -> UserStudyProfile
    func saveUserProfile(_ profile: UserStudyProfile) async
    func getCategoryMasteries() async -> [CategoryMasteryRecord]
    func saveCategoryMasteries(_ records: [CategoryMasteryRecord]) async
}

/// Cümle Röntgeni (Sentence X-Ray) veri erişim protokolü
public protocol SentenceXRayRepository: Sendable {
    func getXRayItems(for track: AcademicTrack) async -> [SentenceXRayItem]
    func getAllXRayItems() async -> [SentenceXRayItem]
}

/// 3 Boyutlu Kelime ve Edat Kartları veri erişim protokolü
public protocol VocabularyRepository: Sendable {
    func getVocabCards(for track: AcademicTrack) async -> [Vocab3DCard]
    func getAllVocabCards() async -> [Vocab3DCard]
    func updateVocabCardProgress(_ updatedCard: Vocab3DCard) async
}

/// Seviye Tespit ve Mikro-Sprint soruları veri erişim protokolü
public protocol SprintQuestionRepository: Sendable {
    /// Legacy 5 soruluk sabit onboarding teşhisi (adaptif havuz hariç)
    func getDiagnosticQuestions() async -> [SprintQuestion]
    /// Adaptif teşhis sorgusu: bant + kategori + track'e göre, `excluding` id'leri hariç tutarak.
    /// Track eşleşenler önce gelir; havuz boşalırsa track filtresi gevşetilir.
    func getDiagnosticQuestions(
        band: QuestionDifficultyBand,
        category: QuestionCategory?,
        track: AcademicTrack,
        excluding excludedQuestionIds: Set<String>
    ) async -> [SprintQuestion]
    func getQuestions(
        for track: AcademicTrack,
        mode: MicroSprintMode?,
        category: QuestionCategory?
    ) async -> [SprintQuestion]
    func getAllQuestions() async -> [SprintQuestion]
}

/// Hata Kumbarası (Mistake Vault) veri erişim protokolü
public protocol MistakeVaultRepository: Sendable {
    func getMistakeItems() async -> [MistakeVaultItem]
    func recordMistake(question: SprintQuestion, selectedOption: QuestionOption, date: Date) async
    func markMistakeReviewed(mistakeId: String, answeredCorrectly: Bool) async
}
