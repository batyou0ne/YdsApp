import Foundation

/// Canlı Puan Tahmin Motoru (CalculateEstimatedScoreUseCase)
/// Kullanıcının ilerlemesini kelime sayısı veya ham XP yerine 0.00 - 100.00 arasındaki
/// "Borsa grafiği gibi yaşayan" ama adil Tahmini Sınav Puanı ile ölçer.
public struct CalculateEstimatedScoreUseCase: Sendable {

    // MARK: - Sabitler (Pedagojik ve Matematiksel Kurallar)
    public static let dailyGainCeiling: Double = 1.50
    public static let dailyLossFloor: Double = -0.25
    public static let singleWrongPenalty: Double = -0.05
    public static let consecutiveCorrectThreshold: Int = 10
    public static let initialConfidenceMargin: Double = 5.0
    public static let minimumConfidenceMargin: Double = 1.5
    public static let confidenceNarrowingStep: Double = 0.05
    public static let checkInMeasuredWeight: Double = 0.60

    public init() {}

    // MARK: - Format Gösterimi
    /// Puan değişimini sınav odaklı standart biçimde formatlar: "48.75 ➔ 49.15 (+0.40 puan)"
    public static func formatScoreTransition(before: Double, after: Double) -> String {
        let delta = after - before
        let sign = delta >= 0 ? "+" : ""
        return String(format: "%.2f ➔ %.2f (%@%.2f puan)", before, after, sign, delta)
    }

    // MARK: - Ağırlıklı Puan Hesaplama
    /// Kategori ustalık kayıtlarından ağırlıklı gerçek YDS/YÖKDİL tahmini puanını (0.00 - 100.00) hesaplar.
    public func calculateWeightedScore(from records: [CategoryMasteryRecord]) -> Double {
        guard !records.isEmpty else { return 46.25 }
        let rawSum = records.reduce(0.0) { partial, record in
            partial + (record.currentMasteryRatio * record.category.maxScorePoints)
        }
        return roundToQuarterPoint(min(max(rawSum, 0.0), 100.0))
    }

    // MARK: - Soru Tipi Karnesi
    /// Tam Soru Tipi Karnesi (`ScoreReportCard`) üretir.
    /// Beyan ile ölçüm uyuşmazlığı varsa ilk 3 gün ölçülen puan baz alınır.
    public func execute(
        profile: UserStudyProfile,
        categoryRecords: [CategoryMasteryRecord]
    ) -> ScoreReportCard {
        let weightedScore = categoryRecords.isEmpty
            ? profile.currentEstimatedScore
            : calculateWeightedScore(from: categoryRecords)

        let effectiveScore: Double
        if profile.hasScoreDiscrepancy && profile.daysActiveCount <= 3 {
            // Beyan ile ölçüm uyuşmazlığında ilk 3 gün ölçülen puanı baz al
            effectiveScore = profile.initialEstimatedScore
        } else {
            effectiveScore = max(profile.currentEstimatedScore, weightedScore)
        }

        let neededScore = max(0.0, roundToQuarterPoint(profile.targetScore - effectiveScore))

        let sortedByWeakness = categoryRecords.sorted { lhs, rhs in
            if abs(lhs.currentMasteryRatio - rhs.currentMasteryRatio) > 0.001 {
                return lhs.currentMasteryRatio < rhs.currentMasteryRatio
            }
            return lhs.potentialScoreGain > rhs.potentialScoreGain
        }

        let topWeakCategories = Array(sortedByWeakness.prefix(2).map(\.category))

        return ScoreReportCard(
            estimatedTotalScore: effectiveScore,
            initialBaselineScore: profile.initialEstimatedScore,
            targetScore: profile.targetScore,
            neededScore: neededScore,
            todayEarnedDelta: profile.todayEarnedScoreDelta,
            categoryRecords: categoryRecords,
            topWeakCategories: topWeakCategories.isEmpty ? profile.weakestCategories : topWeakCategories,
            scoreConfidenceMargin: profile.scoreConfidenceMargin ?? Self.initialConfidenceMargin
        )
    }

    // MARK: - Günlük Reçete Delta Hesaplama
    /// Günlük reçete veya Mikro-Sprint tamamlandığında doğruluk ve hız performansına göre
    /// `+0.25` ile `+0.65` arası günlük puan artışı hesaplar.
    public func calculateDailyPrescriptionScoreDelta(
        correctCount: Int,
        totalCount: Int,
        averageResponseSeconds: Double,
        targetSecondsPerItem: Double = 20.0
    ) -> Double {
        guard totalCount > 0 else { return 0.25 }
        let accuracyRatio = Double(correctCount) / Double(totalCount)
        let speedBonusRatio = max(0.0, min(1.0, (targetSecondsPerItem - averageResponseSeconds) / targetSecondsPerItem))
        let rawDelta = 0.25 + (accuracyRatio * 0.30) + (speedBonusRatio * 0.10)
        let clamped = min(max(rawDelta, 0.25), 0.65)
        return (clamped * 20.0).rounded() / 20.0
    }

    // MARK: - Mikro-Sprint / Soru Çözümü Olay Kaydı
    /// Tek bir soru çözüldüğünde yaşayan puan motorunu çalıştırır.
    ///
    /// Kurallar:
    /// 1. Doğru cevap: Zorluğa göre ağırlıklı puan artışı (easy: 0.10, medium: 0.15, hard: 0.25).
    /// 2. Azalan getiri: Aynı kategoride art arda 10+ doğruda artış yarıya iner.
    /// 3. Günlük kazanç tavanı: Günde en fazla +1.50 puan kazanılabilir.
    /// 4. Yanlış cevap: Puan sert düşmez; günde en fazla -0.25 düşülür (tek yanlışta -0.05).
    ///    Düşüş yerine pedagojik açık tespit mesajı üretilir.
    /// 5. Güven aralığı: Soru çözüldükçe daralır (5.0 -> min 1.5).
    /// 6. 0.00 - 100.00 arası kesin sınırlama ve çeyrek/yirmide birlik yuvarlama.
    public func recordQuestionOutcome(
        category: QuestionCategory,
        difficultyBand: QuestionDifficultyBand = .medium,
        isCorrect: Bool,
        responseTimeSeconds: Int = 10,
        timeLimitSeconds: Int = 10,
        currentProfile: UserStudyProfile,
        currentRecords: [CategoryMasteryRecord],
        date: Date = Date()
    ) -> ScoreOutcomeResult {
        // 1. Kategori Ustalık Güncellemesi
        let speedFactor = responseTimeSeconds <= max(5, timeLimitSeconds / 2) ? 1.15 : 1.0
        let stepGain: Double = isCorrect ? (0.035 * speedFactor) : -0.01

        let updatedRecords: [CategoryMasteryRecord] = currentRecords.map { record in
            guard record.category == category else { return record }
            let newMastery = min(max(record.currentMasteryRatio + stepGain, 0.15), 0.98)
            return CategoryMasteryRecord(
                category: record.category,
                currentMasteryRatio: newMastery,
                targetMasteryRatio: max(record.targetMasteryRatio, min(0.95, newMastery + 0.15)),
                questionsSolvedCount: record.questionsSolvedCount + 1,
                correctAnswersCount: record.correctAnswersCount + (isCorrect ? 1 : 0)
            )
        }

        // 2. Ardışık Doğru & Azalan Getiri Takibi
        var consecutiveMap = currentProfile.consecutiveCorrectByCategory
        let currentConsecutive = consecutiveMap[category.rawValue] ?? 0

        let rawDelta: Double
        let isDiminishingApplied: Bool

        if isCorrect {
            let newConsecutive = currentConsecutive + 1
            consecutiveMap[category.rawValue] = newConsecutive

            let baseDelta: Double
            switch difficultyBand {
            case .easy:
                baseDelta = 0.10
            case .medium:
                baseDelta = 0.15
            case .hard:
                baseDelta = 0.25
            }

            if currentConsecutive >= Self.consecutiveCorrectThreshold {
                isDiminishingApplied = true
                rawDelta = roundToTwentieth(baseDelta * 0.5)
            } else {
                isDiminishingApplied = false
                rawDelta = baseDelta
            }
        } else {
            isDiminishingApplied = false
            consecutiveMap[category.rawValue] = 0
            rawDelta = 0.0
        }

        // 3. Puan Delta, Günlük Tavan (+1.50) ve Günlük Taban (-0.25) Hesaplaması
        let effectiveDelta: Double
        let newTodayEarnedDelta: Double
        let newTodayLossDelta: Double

        if isCorrect {
            let remainingGainAllowance = max(0.0, Self.dailyGainCeiling - currentProfile.todayEarnedScoreDelta)
            let cappedDelta = min(rawDelta, remainingGainAllowance)
            effectiveDelta = roundToTwentieth(cappedDelta)
            newTodayEarnedDelta = roundToTwentieth(currentProfile.todayEarnedScoreDelta + effectiveDelta)
            newTodayLossDelta = currentProfile.todayLossScoreDelta
        } else {
            // Yanlış cevap: Puan SERT DÜŞMEZ. Günde en fazla -0.25 düşülür.
            let remainingLossAllowance = max(0.0, abs(Self.dailyLossFloor) - currentProfile.todayLossScoreDelta)
            let lossAttempt = min(abs(Self.singleWrongPenalty), remainingLossAllowance)
            let lossDelta = roundToTwentieth(lossAttempt)
            effectiveDelta = -lossDelta
            newTodayEarnedDelta = currentProfile.todayEarnedScoreDelta
            newTodayLossDelta = roundToTwentieth(currentProfile.todayLossScoreDelta + lossDelta)
        }

        // 4. Skor Clamp (0.00 - 100.00)
        let unconstrainedScore = currentProfile.currentEstimatedScore + effectiveDelta
        let newEstimatedScore = roundToTwentieth(min(100.0, max(0.0, unconstrainedScore)))
        let finalEarnedDelta = roundToTwentieth(newEstimatedScore - currentProfile.currentEstimatedScore)

        // 5. Güven Aralığı Daralması (5.0 -> min 1.5)
        let currentMargin = currentProfile.scoreConfidenceMargin ?? Self.initialConfidenceMargin
        let newMargin = max(Self.minimumConfidenceMargin, roundToTwentieth(currentMargin - Self.confidenceNarrowingStep))

        // 6. Pedagojik Açıklama Üretimi
        let explanation: ScoreChangeExplanation
        let transitionText = Self.formatScoreTransition(
            before: currentProfile.currentEstimatedScore,
            after: newEstimatedScore
        )

        if isCorrect {
            if finalEarnedDelta == 0.0 && currentProfile.todayEarnedScoreDelta >= Self.dailyGainCeiling {
                explanation = ScoreChangeExplanation(
                    deltaPoints: 0.0,
                    headlineTr: "Günlük Kazanç Tavanına Ulaşıldı",
                    reasonTr: String(
                        format: "Bugün maksimum +%.2f puan kazanım sınırına ulaştın. Pratiklerin kategori refleksini güçlendirmeye devam ediyor.",
                        Self.dailyGainCeiling
                    ),
                    nextActionTr: "\(category.shortTitleTr) soru tipinde reflekslerin oturuyor. Yarın yeni puanlar seni bekliyor."
                )
            } else if isDiminishingApplied {
                explanation = ScoreChangeExplanation(
                    deltaPoints: finalEarnedDelta,
                    headlineTr: "\(category.shortTitleTr) Serisi: Azalan Getiri",
                    reasonTr: "\(category.shortTitleTr) alanında üst üste 10+ soru bildiğin için puan artışı yarıya indi.",
                    nextActionTr: "Farklı soru tiplerine geçerek puan artış hızını artırabilirsin."
                )
            } else {
                explanation = ScoreChangeExplanation(
                    deltaPoints: finalEarnedDelta,
                    headlineTr: "\(category.shortTitleTr) Refleksin Güçlendi",
                    reasonTr: "\(difficultyBand.titleTr) zorluktaki soru doğru yanıtlandı.",
                    nextActionTr: "Tahmini sınav puanın güncellendi: \(transitionText)"
                )
            }
        } else {
            // Yanlış cevap pedagojisi: Sert düşüş yerine açık tespiti mesajı
            explanation = ScoreChangeExplanation(
                deltaPoints: finalEarnedDelta,
                headlineTr: "\(category.shortTitleTr) Açığı Tespit Edildi",
                reasonTr: "\(category.shortTitleTr) sorusundaki tuzak kuralı henüz tam oturmadı.",
                nextActionTr: "\(category.shortTitleTr) puan açığın var; yarınki reçetene eklendi."
            )
        }

        // 7. ScoreEvent Oluşturulması
        let scoreEvent = ScoreEvent(
            id: UUID().uuidString,
            date: date,
            source: .sprint,
            category: category,
            delta: finalEarnedDelta,
            scoreBefore: currentProfile.currentEstimatedScore,
            scoreAfter: newEstimatedScore,
            explanation: explanation
        )

        // 8. Zayıf Kategorilerin Sıralanması
        let sortedWeak = updatedRecords
            .sorted { $0.currentMasteryRatio < $1.currentMasteryRatio }
            .prefix(2)
            .map(\.category)

        let updatedProfile = currentProfile.copying(
            currentEstimatedScore: newEstimatedScore,
            todayEarnedScoreDelta: newTodayEarnedDelta,
            weakestCategories: sortedWeak.isEmpty ? currentProfile.weakestCategories : Array(sortedWeak),
            scoreConfidenceMargin: newMargin,
            todayLossScoreDelta: newTodayLossDelta,
            totalQuestionsSolvedCount: currentProfile.totalQuestionsSolvedCount + 1,
            consecutiveCorrectByCategory: consecutiveMap
        )

        return ScoreOutcomeResult(
            updatedProfile: updatedProfile,
            updatedRecords: updatedRecords,
            earnedDelta: finalEarnedDelta,
            explanation: explanation,
            scoreEvent: scoreEvent
        )
    }

    // MARK: - Haftalık Check-In Kalibrasyonu (Faz 4 Sinyali)
    /// Haftalık check-in sonucuna göre mevcut puanı ölçülene doğru %60 çeker, güven aralığını daraltır.
    public func applyCheckInCalibration(
        measuredScore: Double,
        profile: UserStudyProfile,
        records: [CategoryMasteryRecord],
        date: Date = Date()
    ) -> ScoreOutcomeResult {
        let clampedMeasured = min(100.0, max(0.0, measuredScore))
        // Mevcut puanı ölçülene doğru %60 çeker
        let blendedScore = (profile.currentEstimatedScore * (1.0 - Self.checkInMeasuredWeight)) +
            (clampedMeasured * Self.checkInMeasuredWeight)
        let calibratedScore = roundToQuarterPoint(min(100.0, max(0.0, blendedScore)))
        let delta = roundToTwentieth(calibratedScore - profile.currentEstimatedScore)

        // Güven aralığını daraltır (ör. %65'ine indir, max 2.0 ile sınırla)
        let currentMargin = profile.scoreConfidenceMargin ?? Self.initialConfidenceMargin
        let narrowedMargin = max(Self.minimumConfidenceMargin, min(roundToTwentieth(currentMargin * 0.65), 2.0))

        let explanation = ScoreChangeExplanation(
            deltaPoints: delta,
            headlineTr: "Haftalık Check-In Kalibrasyonu Tamamlandı",
            reasonTr: String(
                format: "Ölçülen check-in puanı (%.2f) ile mevcut puanın kalibre edildi.",
                clampedMeasured
            ),
            nextActionTr: "Gelişim grafiğin ve günlük reçeten yeni seviyene uyarlandı."
        )

        let event = ScoreEvent(
            id: UUID().uuidString,
            date: date,
            source: .checkIn,
            category: nil,
            delta: delta,
            scoreBefore: profile.currentEstimatedScore,
            scoreAfter: calibratedScore,
            explanation: explanation
        )

        let newTodayDelta = delta > 0
            ? roundToTwentieth(profile.todayEarnedScoreDelta + delta)
            : profile.todayEarnedScoreDelta

        let updatedProfile = profile.copying(
            currentEstimatedScore: calibratedScore,
            todayEarnedScoreDelta: newTodayDelta,
            scoreConfidenceMargin: narrowedMargin
        )

        return ScoreOutcomeResult(
            updatedProfile: updatedProfile,
            updatedRecords: records,
            earnedDelta: delta,
            explanation: explanation,
            scoreEvent: event
        )
    }

    // MARK: - 3B Kelime Puan Güncellemesi
    /// 3 Boyutlu Kelime kartında doğru yanıt verildiğinde puanı günceller.
    public func recordVocabOutcome(
        card: Vocab3DCard,
        isCorrect: Bool,
        currentProfile: UserStudyProfile,
        earnedDelta: Double = 0.10,
        date: Date = Date()
    ) -> ScoreOutcomeResult {
        let rawDelta = isCorrect ? earnedDelta : 0.0
        let remainingAllowance = max(0.0, Self.dailyGainCeiling - currentProfile.todayEarnedScoreDelta)
        let effectiveDelta = roundToTwentieth(min(rawDelta, remainingAllowance))

        let newEstimatedScore = roundToTwentieth(min(100.0, max(0.0, currentProfile.currentEstimatedScore + effectiveDelta)))
        let actualDelta = roundToTwentieth(newEstimatedScore - currentProfile.currentEstimatedScore)
        let newTodayDelta = roundToTwentieth(currentProfile.todayEarnedScoreDelta + actualDelta)

        let currentMargin = currentProfile.scoreConfidenceMargin ?? Self.initialConfidenceMargin
        let newMargin = max(Self.minimumConfidenceMargin, roundToTwentieth(currentMargin - (Self.confidenceNarrowingStep * 0.5)))

        let explanation = ScoreChangeExplanation(
            deltaPoints: actualDelta,
            headlineTr: isCorrect ? "3B Kelime Hafızaya Alındı" : "3B Kelime Tekrar Kuyruğunda",
            reasonTr: isCorrect
                ? "\(card.headword) kelimesinin boyutu başarıyla çözüldü."
                : "\(card.headword) kelimesinde tekrar gerekiyor.",
            nextActionTr: isCorrect
                ? "Tahmini sınav puanın güncellendi."
                : "Kelime aralıklı tekrar kuyruğunun önüne çekildi."
        )

        let event = ScoreEvent(
            id: UUID().uuidString,
            date: date,
            source: .vocab,
            category: nil,
            delta: actualDelta,
            scoreBefore: currentProfile.currentEstimatedScore,
            scoreAfter: newEstimatedScore,
            explanation: explanation
        )

        let updatedProfile = currentProfile.copying(
            currentEstimatedScore: newEstimatedScore,
            todayEarnedScoreDelta: newTodayDelta,
            scoreConfidenceMargin: newMargin,
            totalQuestionsSolvedCount: currentProfile.totalQuestionsSolvedCount + 1
        )

        return ScoreOutcomeResult(
            updatedProfile: updatedProfile,
            updatedRecords: [],
            earnedDelta: actualDelta,
            explanation: explanation,
            scoreEvent: event
        )
    }

    // MARK: - Cümle Röntgeni Puan Güncellemesi
    /// Cümle Röntgeni adımı çözüldüğünde puanı günceller.
    public func recordSentenceXRayOutcome(
        profile: UserStudyProfile,
        item: SentenceXRayItem,
        earnedDelta: Double = 0.10,
        date: Date = Date()
    ) -> ScoreOutcomeResult {
        let remainingAllowance = max(0.0, Self.dailyGainCeiling - profile.todayEarnedScoreDelta)
        let effectiveDelta = roundToTwentieth(min(earnedDelta, remainingAllowance))

        let newEstimatedScore = roundToTwentieth(min(100.0, max(0.0, profile.currentEstimatedScore + effectiveDelta)))
        let actualDelta = roundToTwentieth(newEstimatedScore - profile.currentEstimatedScore)
        let newTodayDelta = roundToTwentieth(profile.todayEarnedScoreDelta + actualDelta)

        let currentMargin = profile.scoreConfidenceMargin ?? Self.initialConfidenceMargin
        let newMargin = max(Self.minimumConfidenceMargin, roundToTwentieth(currentMargin - Self.confidenceNarrowingStep))

        let explanation = ScoreChangeExplanation(
            deltaPoints: actualDelta,
            headlineTr: "Cümle Röntgeni Tamamlandı",
            reasonTr: "Cümle iskeleti ve bağlaç analizi başarıyla yapıldı.",
            nextActionTr: "Tahmini sınav puanın güncellendi: \(Self.formatScoreTransition(before: profile.currentEstimatedScore, after: newEstimatedScore))"
        )

        let event = ScoreEvent(
            id: UUID().uuidString,
            date: date,
            source: .xray,
            category: nil,
            delta: actualDelta,
            scoreBefore: profile.currentEstimatedScore,
            scoreAfter: newEstimatedScore,
            explanation: explanation
        )

        let updatedProfile = profile.copying(
            currentEstimatedScore: newEstimatedScore,
            todayEarnedScoreDelta: newTodayDelta,
            scoreConfidenceMargin: newMargin,
            totalQuestionsSolvedCount: profile.totalQuestionsSolvedCount + 1
        )

        return ScoreOutcomeResult(
            updatedProfile: updatedProfile,
            updatedRecords: [],
            earnedDelta: actualDelta,
            explanation: explanation,
            scoreEvent: event
        )
    }

    // MARK: - Hata Kumbarası Kuralı Kurtarma Güncellemesi
    /// Hata Kumbarasındaki soru tekrar çözüldüğünde puan kurtarımı yapar.
    public func recordMistakeReviewOutcome(
        profile: UserStudyProfile,
        category: QuestionCategory,
        isCorrect: Bool,
        records: [CategoryMasteryRecord],
        recoveryDelta: Double = 0.25,
        date: Date = Date()
    ) -> ScoreOutcomeResult {
        let delta = isCorrect ? recoveryDelta : 0.0
        let remainingAllowance = max(0.0, Self.dailyGainCeiling - profile.todayEarnedScoreDelta)
        let effectiveDelta = roundToTwentieth(min(delta, remainingAllowance))

        let newEstimatedScore = roundToTwentieth(min(100.0, max(0.0, profile.currentEstimatedScore + effectiveDelta)))
        let actualDelta = roundToTwentieth(newEstimatedScore - profile.currentEstimatedScore)
        let newTodayDelta = roundToTwentieth(profile.todayEarnedScoreDelta + actualDelta)

        let updatedRecords: [CategoryMasteryRecord] = records.map { record in
            guard record.category == category else { return record }
            let boosted = min(0.98, record.currentMasteryRatio + (isCorrect ? 0.05 : -0.01))
            return CategoryMasteryRecord(
                category: record.category,
                currentMasteryRatio: boosted,
                targetMasteryRatio: record.targetMasteryRatio,
                questionsSolvedCount: record.questionsSolvedCount + 1,
                correctAnswersCount: record.correctAnswersCount + (isCorrect ? 1 : 0)
            )
        }

        let explanation = ScoreChangeExplanation(
            deltaPoints: actualDelta,
            headlineTr: isCorrect ? "Hata Kumbarası Kuralı Kurtarıldı" : "Tuzak Kuralı Tekrar İncelenmeli",
            reasonTr: isCorrect
                ? "\(category.shortTitleTr) alanındaki geçmiş tuzak başarıyla aşıldı."
                : "\(category.shortTitleTr) tuzak kuralı üzerinde tekrar çalışılmalı.",
            nextActionTr: isCorrect
                ? "Puanın geri eklendi: \(Self.formatScoreTransition(before: profile.currentEstimatedScore, after: newEstimatedScore))"
                : "Kural Hata Kumbarasında aktif kalmaya devam ediyor."
        )

        let event = ScoreEvent(
            id: UUID().uuidString,
            date: date,
            source: .sprint,
            category: category,
            delta: actualDelta,
            scoreBefore: profile.currentEstimatedScore,
            scoreAfter: newEstimatedScore,
            explanation: explanation
        )

        let updatedProfile = profile.copying(
            currentEstimatedScore: newEstimatedScore,
            todayEarnedScoreDelta: newTodayDelta,
            totalQuestionsSolvedCount: profile.totalQuestionsSolvedCount + 1
        )

        return ScoreOutcomeResult(
            updatedProfile: updatedProfile,
            updatedRecords: updatedRecords,
            earnedDelta: actualDelta,
            explanation: explanation,
            scoreEvent: event
        )
    }

    // MARK: - Yuvarlama Yardımcıları
    /// Çeyrek puana yuvarlar (0.25 adım: 0.00, 0.25, 0.50, 0.75)
    public func roundToQuarterPoint(_ value: Double) -> Double {
        (value * 4.0).rounded() / 4.0
    }

    /// Yirmide bir puana yuvarlar (0.05 adım: 0.00, 0.05, 0.10, ..., 0.95)
    public func roundToTwentieth(_ value: Double) -> Double {
        (value * 20.0).rounded() / 20.0
    }
}
