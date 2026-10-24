import Foundation

/// Protokol tabanlı async/await HTTP ve Lokal Seed veri yükleyici arayüzü
public protocol SeedDataProviding: Sendable {
    func loadSeedBundle() async -> SeedBundleDTO
    func exportSeedBundleJSON() throws -> Data
}

/// Hem uygulama içi zengin Seed verisini hem de JSON serileştirmesini sağlayan servis
public struct LocalSeedDataSource: SeedDataProviding {
    public init() {}

    public func loadSeedBundle() async -> SeedBundleDTO {
        SeedBundleDTO(
            schemaVersion: 1,
            xrayItems: SentenceXRaySeedData.allItems,
            vocab3DCards: Vocab3DSeedData.allCards,
            sprintQuestions: SprintQuestionSeedData.allQuestions,
            initialMistakes: MistakeVaultSeedData.initialMistakes
        )
    }

    public func exportSeedBundleJSON() throws -> Data {
        let bundle = SeedBundleDTO(
            schemaVersion: 1,
            xrayItems: SentenceXRaySeedData.allItems,
            vocab3DCards: Vocab3DSeedData.allCards,
            sprintQuestions: SprintQuestionSeedData.allQuestions,
            initialMistakes: MistakeVaultSeedData.initialMistakes
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(bundle)
    }
}
