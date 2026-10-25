import XCTest
@testable import YdsCore

final class AdaptiveDiagnosticEngineTests: XCTestCase {
    private let categories = AdaptiveDiagnosticEngine.diagnosticCategories

    private func makeQuestion(_ category: QuestionCategory, _ band: QuestionDifficultyBand, _ index: Int, track: AcademicTrack = .generalAcademic) -> SprintQuestion {
        let explanation = DistractorExplanation(praiseTextTr: "p", trapReasonTr: "t", winningRuleTr: "w", grammarRuleTag: "tag")
        return SprintQuestion(
            id: "\(category.rawValue)-\(band.rawValue)-\(index)",
            category: category,
            sprintMode: .diagnosticMiniTest,
            track: track,
            isDiagnosticOnboarding: true,
            difficultyBand: band,
            timeLimitSeconds: 40,
            stemText: "stem",
            highlightedClues: [],
            options: [
                QuestionOption(id: "A", text: "a", distractorCoachFeedback: explanation),
                QuestionOption(id: "B", text: "b", distractorCoachFeedback: explanation)
            ],
            correctOptionId: "A"
        )
    }

    private var pool: [SprintQuestion] {
        categories.flatMap { c in
            QuestionDifficultyBand.allCases.flatMap { b in (0..<2).map { makeQuestion(c, b, $0) } }
        }
    }

    private func engine(seed: UInt64 = 7) -> AdaptiveDiagnosticEngine {
        AdaptiveDiagnosticEngine(randomness: SeededRandomnessProvider(seed: seed))
    }

    /// Oturumu `chooser(index)` ile cevaplatır; sorulan soruları da döndürür.
    private func run(
        engine: AdaptiveDiagnosticEngine,
        session start: AdaptiveDiagnosticSession,
        pool: [SprintQuestion]? = nil,
        track: AcademicTrack = .generalAcademic,
        seconds: Double = 30,
        correct: (Int) -> Bool
    ) -> (AdaptiveDiagnosticSession, [SprintQuestion]) {
        var session = start
        var asked: [SprintQuestion] = []
        let usedPool = pool ?? self.pool
        while let q = engine.nextQuestion(session: session, pool: usedPool, track: track) {
            let selected = correct(asked.count) ? q.correctOptionId : "B"
            asked.append(q)
            session = engine.submit(answer: AdaptiveDiagnosticAnswer(question: q, selectedOptionId: selected, responseSeconds: seconds), session: session)
        }
        return (session, asked)
    }

    func testAllCorrectYieldsHighScore() {
        let e = engine()
        let (s, asked) = run(engine: e, session: .start()) { _ in true }
        let out = e.finalize(session: s, declaredBaseline: nil)
        XCTAssertEqual(asked.count, 6)
        XCTAssertGreaterThanOrEqual(out.estimatedScore, 80.0)
        XCTAssertLessThanOrEqual(out.estimatedScore, 92.5)
        XCTAssertEqual(out.correctCount, 6)
        XCTAssertEqual(out.estimatedScore.truncatingRemainder(dividingBy: 0.25), 0)
    }

    func testAllWrongYieldsLowScore() {
        let e = engine()
        let (s, _) = run(engine: e, session: .start()) { _ in false }
        let out = e.finalize(session: s, declaredBaseline: nil)
        XCTAssertLessThanOrEqual(out.estimatedScore, 35.0)
        XCTAssertGreaterThanOrEqual(out.estimatedScore, 25.0)
        XCTAssertGreaterThanOrEqual(out.confidenceLowerBound, 25.0)
    }

    func testBandTransitionsOnAlternatingAnswers() {
        let e = engine()
        // doğru, yanlış, doğru, yanlış, doğru, yanlış
        let (_, asked) = run(engine: e, session: .start()) { $0 % 2 == 0 }
        let expected: [QuestionDifficultyBand] = [.medium, .hard, .medium, .hard, .medium, .hard]
        XCTAssertEqual(asked.map(\.difficultyBand), expected)
    }

    func testFirstQuestionMediumAndEdgesStay() {
        let e = engine()
        let (_, wrongRun) = run(engine: e, session: .start()) { _ in false }
        XCTAssertEqual(wrongRun.map(\.difficultyBand), [.medium, .easy, .easy, .easy, .easy, .easy])
        let (_, rightRun) = run(engine: e, session: .start()) { _ in true }
        XCTAssertEqual(rightRun.map(\.difficultyBand), [.medium, .hard, .hard, .hard, .hard, .hard])
    }

    func testNoRepeatsAndCategoryCoverage() {
        for seed in 0..<20 as Range<UInt64> {
            let e = engine(seed: seed)
            let (s, asked) = run(engine: e, session: .start()) { $0 % 3 != 0 }
            XCTAssertEqual(asked.count, 6)
            XCTAssertEqual(Set(asked.map(\.id)).count, 6)
            XCTAssertEqual(Set(asked.map(\.category)), Set(categories))
            XCTAssertTrue(s.remainingCategories.isEmpty)
        }
    }

    func testFallsBackToNearestBandWhenEmpty() {
        // Yalnızca easy sorular: medium hedefi easy'ye düşer
        let easyOnly = pool.filter { $0.difficultyBand == .easy }
        let e = engine()
        let q = e.nextQuestion(session: .start(), pool: easyOnly, track: .generalAcademic)
        XCTAssertEqual(q?.difficultyBand, .easy)
    }

    func testReturnsNilWhenPoolExhausted() {
        let e = engine()
        XCTAssertNil(e.nextQuestion(session: .start(), pool: [], track: .generalAcademic))
    }

    func testTrackPreferredWithinSameBand() {
        var mixed = pool
        let health = makeQuestion(.academicVocab, .medium, 99, track: .healthSciences)
        mixed.append(health)
        // academicVocab kategorisine zorla: yalnızca o kategoriyi içeren oturum
        let session = AdaptiveDiagnosticSession(
            path: .fullMeasurement, maxQuestions: 6,
            abilityEstimate: 57.5, standardError: 10, remainingCategories: [.academicVocab]
        )
        let q = engine().nextQuestion(session: session, pool: mixed, track: .healthSciences)
        XCTAssertEqual(q?.id, health.id)
    }

    func testConfidenceIntervalNarrows() {
        let e = engine()
        var session = AdaptiveDiagnosticSession.start()
        var widths: [Double] = []
        var errors: [Double] = [session.standardError]
        while let q = e.nextQuestion(session: session, pool: pool, track: .generalAcademic) {
            session = e.submit(answer: AdaptiveDiagnosticAnswer(question: q, selectedOptionId: "A", responseSeconds: 30), session: session)
            errors.append(session.standardError)
            let o = e.finalize(session: session, declaredBaseline: nil)
            widths.append(o.confidenceUpperBound - o.confidenceLowerBound)
        }
        for i in 1..<errors.count { XCTAssertLessThan(errors[i], errors[i - 1]) }
        XCTAssertLessThan(widths.last!, widths.first!)
        let final = e.finalize(session: session, declaredBaseline: nil)
        XCTAssertEqual(final.confidenceLevel, .high)
        // ±~5 puan
        XCTAssertEqual((final.confidenceUpperBound - final.confidenceLowerBound) / 2.0, 5.0, accuracy: 1.5)
    }

    func testSameSeedSameResult() {
        let a = engine(seed: 42)
        let b = engine(seed: 42)
        let ra = run(engine: a, session: .start()) { $0 % 2 == 1 }
        let rb = run(engine: b, session: .start()) { $0 % 2 == 1 }
        XCTAssertEqual(ra.1.map(\.id), rb.1.map(\.id))
        XCTAssertEqual(a.finalize(session: ra.0, declaredBaseline: nil), b.finalize(session: rb.0, declaredBaseline: nil))
    }

    func testFastCorrectBonusAndTimeoutIsWrong() {
        let e = engine()
        let q = pool.first { $0.difficultyBand == .medium }!
        let fast = e.submit(answer: AdaptiveDiagnosticAnswer(question: q, selectedOptionId: "A", responseSeconds: 5), session: .start())
        let slow = e.submit(answer: AdaptiveDiagnosticAnswer(question: q, selectedOptionId: "A", responseSeconds: 35), session: .start())
        XCTAssertGreaterThan(fast.abilityEstimate, slow.abilityEstimate)

        let expired = AdaptiveDiagnosticAnswer(question: q, selectedOptionId: "A", responseSeconds: 41)
        XCTAssertTrue(expired.timedOut)
        XCTAssertFalse(expired.isCorrect)
        let none = AdaptiveDiagnosticAnswer(question: q, selectedOptionId: nil, responseSeconds: 10)
        XCTAssertFalse(none.isCorrect)
    }

    func testDeclaredPathAsksTwoQuestionsAndNotesMismatch() {
        let e = engine()
        let (s, asked) = run(engine: e, session: .start(declaredBaseline: 62.5)) { _ in false }
        XCTAssertEqual(asked.count, 2)
        let out = e.finalize(session: s, declaredBaseline: 62.5)
        XCTAssertGreaterThan(62.5 - out.estimatedScore, 12.0)
        let note = try! XCTUnwrap(out.declaredScoreMismatchNoteTr)
        XCTAssertEqual(note, "Beyan ettiğin 62.50 ile ölçülen \(String(format: "%.2f", out.estimatedScore)) arasında fark var; ölçümle başlıyoruz")
    }

    func testDeclaredConsistentHasNoNote() {
        let e = engine()
        let (s, _) = run(engine: e, session: .start(declaredBaseline: 57.5)) { $0 == 0 }
        let out = e.finalize(session: s, declaredBaseline: 57.5)
        XCTAssertNil(out.declaredScoreMismatchNoteTr)
        XCTAssertNotEqual(out.confidenceLevel, .high)
    }

    func testPathCFixedBaselineLowConfidence() {
        let e = engine()
        let out = e.finalize(session: .start(), declaredBaseline: nil)
        XCTAssertEqual(out.estimatedScore, 35.0)
        XCTAssertEqual(out.confidenceLevel, .low)
        XCTAssertNil(out.declaredScoreMismatchNoteTr)
    }

    func testScoreAlwaysClamped() {
        let e = engine()
        XCTAssertEqual(e.finalize(session: .start(), declaredBaseline: 150).estimatedScore, 92.5)
        XCTAssertEqual(AdaptiveDiagnosticSession.start(declaredBaseline: 5).abilityEstimate, 25.0)
    }

    func testWeakestTwoAreFailedCategoriesAndRecordsComplete() {
        let e = engine()
        let (s, asked) = run(engine: e, session: .start()) { $0 >= 2 } // ilk iki soru yanlış
        let out = e.finalize(session: s, declaredBaseline: nil)
        XCTAssertEqual(Set(out.weakestTwoCategories), Set(asked.prefix(2).map(\.category)))
        XCTAssertEqual(out.categoryRecords.count, QuestionCategory.allCases.count)
        XCTAssertEqual(out.weakestTwoCategories.count, 2)
    }
}
