import Foundation

/// `sprintQuestions[]` elemanları (SprintQuestion) JSON'da `difficultyBand` ("EASY" | "MEDIUM" | "HARD")
/// ve `irtDifficulty` (-2.0...2.0) alanlarını taşır; alanlar yoksa "MEDIUM" / 0.0 varsayılır (geriye dönük uyumlu).
/// iOS (Codable) <-> Android (Kotlinx.Serialization) <-> Backend REST API 1:1 JSON veri zarfı
public struct SeedBundleDTO: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let xrayItems: [SentenceXRayItem]
    public let vocab3DCards: [Vocab3DCard]
    public let sprintQuestions: [SprintQuestion]
    public let initialMistakes: [MistakeVaultItem]

    public init(
        schemaVersion: Int = 1,
        xrayItems: [SentenceXRayItem],
        vocab3DCards: [Vocab3DCard],
        sprintQuestions: [SprintQuestion],
        initialMistakes: [MistakeVaultItem]
    ) {
        self.schemaVersion = schemaVersion
        self.xrayItems = xrayItems
        self.vocab3DCards = vocab3DCards
        self.sprintQuestions = sprintQuestions
        self.initialMistakes = initialMistakes
    }
}
