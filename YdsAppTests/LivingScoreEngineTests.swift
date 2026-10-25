import XCTest
@testable import YdsCore

final class LivingScoreEngineTests: XCTestCase {
    private var engine: CalculateEstimatedScoreUseCase!
    private var initialRecords: [CategoryMasteryRecord]!

    override func setUp() {
        super.setUp()
        engine = CalculateEstimatedScoreUseCase()
        initialRecords = MistakeVaultSeedData.defaultCategoryMasteries
    }

    // MARK: - 1. Zorluk Ağırlıkları (easy 0.10, medium 0.15, hard 0.25)
    func testDifficultyBandWeights() {
        let baseProfile = UserStudyProfile(
            currentEstimatedScore: 50.00,
            todayEarnedScoreDelta: 0.00
        )

        // Easy: +0.10
        let easyOutcome = engine.recordQuestionOutcome(
            category: .conjunction,
            difficultyBand: .easy,
            isCorrect: true,
            currentProfile: baseProfile,
            currentRecords: initialRecords
        )
        XCTAssertEqual(easyOutcome.earnedDelta, 0.10, accuracy: 0.001)
        XCTAssertEqual(easyOutcome.updatedProfile.currentEstimatedScore, 50.10, accuracy: 0.001)

        // Medium: +0.15
        let mediumOutcome = engine.recordQuestionOutcome(
            category: .conjunction,
            difficultyBand: .medium,
            isCorrect: true,
            currentProfile: baseProfile,
            currentRecords: initialRecords
        )
        XCTAssertEqual(mediumOutcome.earnedDelta, 0.15, accuracy: 0.001)
        XCTAssertEqual(mediumOutcome.updatedProfile.currentEstimatedScore, 50.15, accuracy: 0.001)

        // Hard: +0.25
        let hardOutcome = engine.recordQuestionOutcome(
            category: .conjunction,
            difficultyBand: .hard,
            isCorrect: true,
            currentProfile: baseProfile,
            currentRecords: initialRecords
        )
        XCTAssertEqual(hardOutcome.earnedDelta, 0.25, accuracy: 0.001)
        XCTAssertEqual(hardOutcome.updatedProfile.currentEstimatedScore, 50.25, accuracy: 0.001)
    }

    // MARK: - 2. Günlük Kazanç Tavanı (+1.50)
    func testDailyGainCeiling() {
        let profileNearCap = UserStudyProfile(
            currentEstimatedScore: 50.00,
            todayEarnedScoreDelta: 1.40
        )

        // Kalan hak: 1.50 - 1.40 = 0.10. Hard soru (+0.25) tavan nedeniyle +0.10 verir.
        let outcomeNearCap = engine.recordQuestionOutcome(
            category: .conjunction,
            difficultyBand: .hard,
            isCorrect: true,
            currentProfile: profileNearCap,
            currentRecords: initialRecords
        )
        XCTAssertEqual(outcomeNearCap.earnedDelta, 0.10, accuracy: 0.001)
        XCTAssertEqual(outcomeNearCap.updatedProfile.todayEarnedScoreDelta, 1.50, accuracy: 0.001)
        XCTAssertEqual(outcomeNearCap.updatedProfile.currentEstimatedScore, 50.10, accuracy: 0.001)

        // Tavan tam doluyken ek doğru çözüldüğünde artış 0.00 olmalı
        let profileAtCap = outcomeNearCap.updatedProfile
        let outcomeAtCap = engine.recordQuestionOutcome(
            category: .conjunction,
            difficultyBand: .hard,
            isCorrect: true,
            currentProfile: profileAtCap,
            currentRecords: initialRecords
        )
        XCTAssertEqual(outcomeAtCap.earnedDelta, 0.00, accuracy: 0.001)
        XCTAssertEqual(outcomeAtCap.updatedProfile.todayEarnedScoreDelta, 1.50, accuracy: 0.001)
        XCTAssertEqual(outcomeAtCap.updatedProfile.currentEstimatedScore, 50.10, accuracy: 0.001)
        XCTAssertTrue(outcomeAtCap.explanation.headlineTr.contains("Tavan"))
    }

    // MARK: - 3. Yanlış Cevap: Puan Sert Düşmez & Günde En Fazla -0.25 Düşüş
    func testWrongAnswerDailyLossFloor() {
        var profile = UserStudyProfile(
            currentEstimatedScore: 50.00,
            todayEarnedScoreDelta: 0.00,
            todayLossScoreDelta: 0.00
        )

        // 1. Yanlış: -0.05 düşüş
        let outcome1 = engine.recordQuestionOutcome(
            category: .conjunction,
            difficultyBand: .medium,
            isCorrect: false,
            currentProfile: profile,
            currentRecords: initialRecords
        )
        XCTAssertEqual(outcome1.earnedDelta, -0.05, accuracy: 0.001)
        XCTAssertEqual(outcome1.updatedProfile.currentEstimatedScore, 49.95, accuracy: 0.001)
        XCTAssertEqual(outcome1.updatedProfile.todayLossScoreDelta, 0.05, accuracy: 0.001)
        XCTAssertTrue(outcome1.explanation.headlineTr.contains("Açığı"))
        XCTAssertTrue(outcome1.explanation.nextActionTr.contains("reçetene eklendi"))

        profile = outcome1.updatedProfile

        // 4 yanlış daha çözelim (toplam 5 yanlış = -0.25)
        for _ in 0..<4 {
            let out = engine.recordQuestionOutcome(
                category: .conjunction,
                difficultyBand: .medium,
                isCorrect: false,
                currentProfile: profile,
                currentRecords: initialRecords
            )
            profile = out.updatedProfile
        }

        XCTAssertEqual(profile.todayLossScoreDelta, 0.25, accuracy: 0.001)
        XCTAssertEqual(profile.currentEstimatedScore, 49.75, accuracy: 0.001)

        // 6. Yanlış: Günlük -0.25 tabanına ulaşıldığı için artık puan düşmez (0.00 delta)
        let outcome6 = engine.recordQuestionOutcome(
            category: .conjunction,
            difficultyBand: .medium,
            isCorrect: false,
            currentProfile: profile,
            currentRecords: initialRecords
        )
        XCTAssertEqual(outcome6.earnedDelta, 0.00, accuracy: 0.001)
        XCTAssertEqual(outcome6.updatedProfile.currentEstimatedScore, 49.75, accuracy: 0.001)
        XCTAssertEqual(outcome6.updatedProfile.todayLossScoreDelta, 0.25, accuracy: 0.001)
    }

    // MARK: - 4. Azalan Getiri (Aynı Kategoride 10+ Doğruda Yarıya İnme)
    func testDiminishingReturnsOnConsecutiveCorrect() {
        var profile = UserStudyProfile(
            currentEstimatedScore: 50.00,
            todayEarnedScoreDelta: 0.00
        )

        // İlk 10 doğru: her biri tam getiri (+0.10 easy)
        for i in 1...10 {
            let out = engine.recordQuestionOutcome(
                category: .academicVocab,
                difficultyBand: .easy,
                isCorrect: true,
                currentProfile: profile,
                currentRecords: initialRecords
            )
            XCTAssertEqual(out.earnedDelta, 0.10, accuracy: 0.001, "Soru \(i) tam getiri olmalı")
            profile = out.updatedProfile
        }

        XCTAssertEqual(profile.consecutiveCorrectByCategory[QuestionCategory.academicVocab.rawValue], 10)

        // 11. Doğru: 10+ ardışık olduğu için artış yarıya iner (0.10 * 0.5 = 0.05)
        let out11 = engine.recordQuestionOutcome(
            category: .academicVocab,
            difficultyBand: .easy,
            isCorrect: true,
            currentProfile: profile,
            currentRecords: initialRecords
        )
        XCTAssertEqual(out11.earnedDelta, 0.05, accuracy: 0.001)
        XCTAssertTrue(out11.explanation.headlineTr.contains("Azalan Getiri"))
        profile = out11.updatedProfile

        // Yanlış cevap geldiğinde ardışık sayaç sıfırlanır
        let wrongOut = engine.recordQuestionOutcome(
            category: .academicVocab,
            difficultyBand: .easy,
            isCorrect: false,
            currentProfile: profile,
            currentRecords: initialRecords
        )
        XCTAssertEqual(wrongOut.updatedProfile.consecutiveCorrectByCategory[QuestionCategory.academicVocab.rawValue], 0)
        profile = wrongOut.updatedProfile

        // Yanlıştan sonraki ilk doğru tekrar tam getiri verir (+0.10)
        let recoveryOut = engine.recordQuestionOutcome(
            category: .academicVocab,
            difficultyBand: .easy,
            isCorrect: true,
            currentProfile: profile,
            currentRecords: initialRecords
        )
        XCTAssertEqual(recoveryOut.earnedDelta, 0.10, accuracy: 0.001)
    }

    // MARK: - 5. Güven Marjı Daralması (±5.0 -> min ±1.5)
    func testScoreConfidenceMarginNarrowing() {
        var profile = UserStudyProfile(
            currentEstimatedScore: 50.00,
            scoreConfidenceMargin: 5.0
        )
        XCTAssertEqual(profile.scoreConfidenceMargin, 5.0)

        // 1 soru çözüldüğünde marj 0.05 daralır (4.95)
        let out1 = engine.recordQuestionOutcome(
            category: .preposition,
            difficultyBand: .medium,
            isCorrect: true,
            currentProfile: profile,
            currentRecords: initialRecords
        )
        XCTAssertEqual(out1.updatedProfile.scoreConfidenceMargin ?? 0.0, 4.95, accuracy: 0.001)
        profile = out1.updatedProfile

        // 80 soru daha çözelim -> 1.5 tabanına ulaşıp orada kalmalı
        for _ in 0..<80 {
            let out = engine.recordQuestionOutcome(
                category: .preposition,
                difficultyBand: .medium,
                isCorrect: true,
                currentProfile: profile,
                currentRecords: initialRecords
            )
            profile = out.updatedProfile
        }

        XCTAssertEqual(profile.scoreConfidenceMargin ?? 0.0, 1.5, accuracy: 0.001)
        XCTAssertEqual(profile.formattedConfidenceMarginTr, "±1.50 puan")
        XCTAssertEqual(profile.confidenceLowerBound, profile.currentEstimatedScore - 1.5, accuracy: 0.001)
        XCTAssertEqual(profile.confidenceUpperBound, profile.currentEstimatedScore + 1.5, accuracy: 0.001)
    }

    // MARK: - 6. Haftalık Check-In Kalibrasyonu (%60 Ölçülene Çekme & Marj Daralma)
    func testWeeklyCheckInCalibration() {
        let profile = UserStudyProfile(
            currentEstimatedScore: 50.00,
            todayEarnedScoreDelta: 0.20,
            scoreConfidenceMargin: 4.5
        )

        // Ölçülen check-in skoru: 70.00
        // Formül: 50.00 * 0.40 + 70.00 * 0.60 = 20.00 + 42.00 = 62.00
        let outcome = engine.applyCheckInCalibration(
            measuredScore: 70.00,
            profile: profile,
            records: initialRecords
        )

        XCTAssertEqual(outcome.updatedProfile.currentEstimatedScore, 62.00, accuracy: 0.001)
        XCTAssertEqual(outcome.earnedDelta, 12.00, accuracy: 0.001)
        XCTAssertEqual(outcome.scoreEvent.source, .checkIn)
        XCTAssertLessThanOrEqual(outcome.updatedProfile.scoreConfidenceMargin ?? 5.0, 2.0)
        XCTAssertTrue(outcome.explanation.headlineTr.contains("Check-In"))
    }

    // MARK: - 7. Yuvarlama (Çeyrek & Yirmide Bir)
    func testQuarterAndTwentiethPointRounding() {
        // Quarter point (0.25 basamakları)
        XCTAssertEqual(engine.roundToQuarterPoint(53.12), 53.00, accuracy: 0.001)
        XCTAssertEqual(engine.roundToQuarterPoint(53.13), 53.25, accuracy: 0.001)
        XCTAssertEqual(engine.roundToQuarterPoint(53.37), 53.25, accuracy: 0.001)
        XCTAssertEqual(engine.roundToQuarterPoint(53.38), 53.50, accuracy: 0.001)
        XCTAssertEqual(engine.roundToQuarterPoint(53.63), 53.75, accuracy: 0.001)
        XCTAssertEqual(engine.roundToQuarterPoint(53.88), 54.00, accuracy: 0.001)

        // Twentieth point (0.05 basamakları)
        XCTAssertEqual(engine.roundToTwentieth(53.02), 53.00, accuracy: 0.001)
        XCTAssertEqual(engine.roundToTwentieth(53.03), 53.05, accuracy: 0.001)
        XCTAssertEqual(engine.roundToTwentieth(53.07), 53.05, accuracy: 0.001)
        XCTAssertEqual(engine.roundToTwentieth(53.08), 53.10, accuracy: 0.001)
    }

    // MARK: - 8. 0.00 – 100.00 Clamp Sınırları
    func testClampBetweenZeroAndOneHundred() {
        // 100.00 Tavanı
        let nearMaxProfile = UserStudyProfile(
            currentEstimatedScore: 99.90,
            todayEarnedScoreDelta: 0.00
        )
        let maxOutcome = engine.recordQuestionOutcome(
            category: .conjunction,
            difficultyBand: .hard,
            isCorrect: true,
            currentProfile: nearMaxProfile,
            currentRecords: initialRecords
        )
        XCTAssertEqual(maxOutcome.updatedProfile.currentEstimatedScore, 100.00, accuracy: 0.001)
        XCTAssertEqual(maxOutcome.earnedDelta, 0.10, accuracy: 0.001)

        // 0.00 Tabanı
        let nearMinProfile = UserStudyProfile(
            currentEstimatedScore: 0.02,
            todayEarnedScoreDelta: 0.00,
            todayLossScoreDelta: 0.00
        )
        let minOutcome = engine.recordQuestionOutcome(
            category: .conjunction,
            difficultyBand: .easy,
            isCorrect: false,
            currentProfile: nearMinProfile,
            currentRecords: initialRecords
        )
        XCTAssertEqual(minOutcome.updatedProfile.currentEstimatedScore, 0.00, accuracy: 0.001)
        XCTAssertGreaterThanOrEqual(minOutcome.updatedProfile.currentEstimatedScore, 0.00)
    }

    // MARK: - 9. Beyan ile Ölçüm Uyuşmazlığı (İlk 3 Gün Ölçülen Puan Baz Alınır)
    func testDeclaredScoreMismatchBehavior() {
        let profileWithMismatch = UserStudyProfile(
            initialEstimatedScore: 45.00,
            currentEstimatedScore: 45.00,
            declaredBaselineScore: 65.00,
            hasScoreDiscrepancy: true,
            daysActiveCount: 2
        )

        // İlk 3 günde karne hesabı ölçülen puanı (45.00) baz alır
        let reportCardDay2 = engine.execute(
            profile: profileWithMismatch,
            categoryRecords: initialRecords
        )
        XCTAssertEqual(reportCardDay2.estimatedTotalScore, 45.00, accuracy: 0.001)

        // 4. günden sonra uyuşmazlık kilidi kalkar ve ağırlıklı puan devreye girer
        let profileDay4 = profileWithMismatch.copying(daysActiveCount: 4)
        let reportCardDay4 = engine.execute(
            profile: profileDay4,
            categoryRecords: initialRecords
        )
        XCTAssertGreaterThanOrEqual(reportCardDay4.estimatedTotalScore, 45.00)
    }

    // MARK: - 10. Format Gösterimi "48.75 ➔ 49.15 (+0.40 puan)"
    func testScoreTransitionDisplayFormat() {
        let formatted = CalculateEstimatedScoreUseCase.formatScoreTransition(
            before: 48.75,
            after: 49.15
        )
        XCTAssertEqual(formatted, "48.75 ➔ 49.15 (+0.40 puan)")

        let event = ScoreEvent(
            source: .sprint,
            delta: 0.40,
            scoreBefore: 48.75,
            scoreAfter: 49.15
        )
        XCTAssertEqual(event.transitionDisplayTr, "48.75 ➔ 49.15 (+0.40 puan)")
    }

    // MARK: - 11. Geriye Uyumlu JSON Decode
    func testLegacyJSONDecodingBackwardCompatibility() throws {
        let legacyJSON = """
        {
            "hasCompletedOnboarding": true,
            "targetExam": "YÖKDİL",
            "academicTrack": "HEALTH_SCIENCES",
            "initialEstimatedScore": 46.25,
            "currentEstimatedScore": 53.75,
            "targetScore": 70.0,
            "daysRemainingUntilExam": 90,
            "streakDays": 4,
            "todayEarnedScoreDelta": 0.4,
            "subscriptionTier": "FREE",
            "dailyFreeXRayUsedCount": 0,
            "completedPrescriptionStepsToday": 0,
            "weakestCategories": ["CONJUNCTION", "PREPOSITION"]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(UserStudyProfile.self, from: legacyJSON)
        XCTAssertEqual(decoded.currentEstimatedScore, 53.75)
        XCTAssertEqual(decoded.scoreConfidenceMargin, 5.0)
        XCTAssertEqual(decoded.todayLossScoreDelta, 0.0)
        XCTAssertEqual(decoded.totalQuestionsSolvedCount, 0)
        XCTAssertFalse(decoded.hasScoreDiscrepancy)
        XCTAssertEqual(decoded.daysActiveCount, 1)
    }

    // MARK: - 12. ScoreEvent Repository Persistence
    func testScoreEventRepositoryPersistence() async {
        let repository = DefaultUserStudyRepository()

        let event1 = ScoreEvent(
            source: .sprint,
            delta: 0.15,
            scoreBefore: 50.00,
            scoreAfter: 50.15
        )
        let event2 = ScoreEvent(
            source: .vocab,
            delta: 0.10,
            scoreBefore: 50.15,
            scoreAfter: 50.25
        )

        await repository.appendScoreEvent(event1)
        await repository.appendScoreEvent(event2)

        let allEvents = await repository.getScoreEvents(since: nil)
        XCTAssertEqual(allEvents.count, 2)
        XCTAssertEqual(allEvents.first?.source, .sprint)
        XCTAssertEqual(allEvents.last?.source, .vocab)
        XCTAssertEqual(allEvents.last?.scoreAfter, 50.25)
    }
}
