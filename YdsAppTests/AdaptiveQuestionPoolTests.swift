import XCTest
@testable import YdsCore

final class AdaptiveQuestionPoolTests: XCTestCase {
    private let targetCategories: [QuestionCategory] = [
        .academicVocab, .conjunction, .preposition,
        .reductionAndTense, .sentenceCompletion, .dialogueAndRestatement
    ]
    private let minPerCell = 2

    private var diagnosticPool: [SprintQuestion] {
        SprintQuestionSeedData.allQuestions.filter(\.isDiagnosticOnboarding)
    }

    func testEveryCategoryAndBandCellHasEnoughDiagnosticQuestions() {
        var total = 0
        for category in targetCategories {
            for band in QuestionDifficultyBand.allCases {
                let count = diagnosticPool.filter { $0.category == category && $0.difficultyBand == band }.count
                total += count
                XCTAssertGreaterThanOrEqual(count, minPerCell, "Hücre eksik: \(category.rawValue) × \(band.rawValue) = \(count)")
            }
        }
        XCTAssertGreaterThanOrEqual(total, 36)
    }

    func testQuestionIdsAreUnique() {
        let ids = SprintQuestionSeedData.allQuestions.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    func testCorrectOptionIdIsAmongOptionsAndOptionsAreComplete() {
        for question in SprintQuestionSeedData.allQuestions {
            XCTAssertTrue(question.options.contains { $0.id == question.correctOptionId }, "\(question.id): correctOptionId şıklarda yok")
            XCTAssertEqual(Set(question.options.map(\.id)).count, question.options.count, "\(question.id): tekrar eden şık id")
            XCTAssertEqual(question.options.count, 5, "\(question.id): 5 şık olmalı")
            for option in question.options {
                let f = option.distractorCoachFeedback
                for (name, value) in [("praiseTextTr", f.praiseTextTr), ("trapReasonTr", f.trapReasonTr),
                                      ("winningRuleTr", f.winningRuleTr), ("grammarRuleTag", f.grammarRuleTag)] {
                    XCTAssertFalse(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "\(question.id)/\(option.id): \(name) boş")
                }
            }
        }
    }

    func testIRTDifficultyWithinRangeAndBandOrdered() {
        for question in SprintQuestionSeedData.allQuestions {
            XCTAssertTrue(SprintQuestion.irtDifficultyRange.contains(question.irtDifficulty), question.id)
        }
        for category in targetCategories {
            func mean(_ band: QuestionDifficultyBand) -> Double {
                let xs = diagnosticPool.filter { $0.category == category && $0.difficultyBand == band }.map(\.irtDifficulty)
                return xs.reduce(0, +) / Double(max(xs.count, 1))
            }
            XCTAssertLessThan(mean(.easy), mean(.hard), category.rawValue)
        }
    }

    func testBandMetadata() {
        XCTAssertEqual(QuestionDifficultyBand.allCases.map(\.representativeScore), [42.5, 57.5, 75.0])
        XCTAssertEqual(QuestionDifficultyBand.hard.rawValue, "HARD")
    }

    func testLegacyJSONWithoutNewFieldsDecodesWithDefaults() throws {
        let legacy = SprintQuestionSeedData.allQuestions[0]
        let data = try JSONEncoder().encode(legacy)
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        object.removeValue(forKey: "difficultyBand")
        object.removeValue(forKey: "irtDifficulty")
        let stripped = try JSONSerialization.data(withJSONObject: object)
        let decoded = try JSONDecoder().decode(SprintQuestion.self, from: stripped)
        XCTAssertEqual(decoded.difficultyBand, .medium)
        XCTAssertEqual(decoded.irtDifficulty, 0.0)
        XCTAssertEqual(decoded.id, legacy.id)
        XCTAssertEqual(decoded.options, legacy.options)
    }

    func testEncodeDecodeRoundTripIsSymmetric() throws {
        for question in SprintQuestionSeedData.allQuestions {
            let decoded = try JSONDecoder().decode(SprintQuestion.self, from: JSONEncoder().encode(question))
            XCTAssertEqual(decoded, question)
        }
        let bundle = SeedBundleDTO(xrayItems: [], vocab3DCards: [], sprintQuestions: SprintQuestionSeedData.allQuestions, initialMistakes: [])
        let roundTrip = try JSONDecoder().decode(SeedBundleDTO.self, from: JSONEncoder().encode(bundle))
        XCTAssertEqual(roundTrip, bundle)
    }

    func testRepositoryBandQueryFiltersAndExcludes() async {
        let repo = DefaultSprintQuestionRepository()
        let all = await repo.getDiagnosticQuestions(band: .hard, category: .conjunction, track: .healthSciences, excluding: [])
        XCTAssertFalse(all.isEmpty)
        XCTAssertTrue(all.allSatisfy { $0.difficultyBand == .hard && $0.category == .conjunction && $0.isDiagnosticOnboarding })
        XCTAssertEqual(all.first?.track, .healthSciences)

        let excluded = await repo.getDiagnosticQuestions(band: .hard, category: .conjunction, track: .healthSciences, excluding: [all[0].id])
        XCTAssertFalse(excluded.contains { $0.id == all[0].id })
        XCTAssertEqual(excluded.count, all.count - 1)

        let anyCategory = await repo.getDiagnosticQuestions(band: .easy, category: nil, track: .generalAcademic, excluding: [])
        XCTAssertGreaterThanOrEqual(Set(anyCategory.map(\.category)).count, 6)
    }

    func testLegacyDiagnosticQueryStillReturnsFiveOnboardingQuestions() async {
        let legacy = await DefaultSprintQuestionRepository().getDiagnosticQuestions()
        XCTAssertEqual(legacy.count, 5)
    }
}
