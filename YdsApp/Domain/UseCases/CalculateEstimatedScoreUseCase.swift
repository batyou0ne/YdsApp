import Foundation

/// Canlı Puan Tahmin Motoru (CalculateEstimatedScoreUseCase)
/// Kullanıcının ilerlemesini kelime sayısı yerine 0.00 - 100.00 arasındaki Tahmini Sınav Puanı ile ölçer.
public struct CalculateEstimatedScoreUseCase: Sendable {
    public init() {}

    /// Kategori ustalık kayıtlarından ağırlıklı gerçek YDS/YÖKDİL tahmini puanını (0.00 - 100.00) hesaplar.
    public func calculateWeightedScore(from records: [CategoryMasteryRecord]) -> Double {
        guard !records.isEmpty else { return 46.25 }
        let rawSum = records.reduce(0.0) { partial, record in
            partial + (record.currentMasteryRatio * record.category.maxScorePoints)
        }
        return roundToQuarterPoint(min(max(rawSum, 0.0), 100.0))
    }

    /// Tam Soru Tipi Karnesi (`ScoreReportCard`) üretir.
    public func execute(
        profile: UserStudyProfile,
        categoryRecords: [CategoryMasteryRecord]
    ) -> ScoreReportCard {
        let weightedScore = categoryRecords.isEmpty
            ? profile.currentEstimatedScore
            : calculateWeightedScore(from: categoryRecords)

        let effectiveScore = max(profile.currentEstimatedScore, weightedScore)
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
            topWeakCategories: topWeakCategories.isEmpty ? profile.weakestCategories : topWeakCategories
        )
    }

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

    /// Tek bir soru veya kelime adımı doğru cevaplandığında kategori ustalık oranını ve profil puanını günceller.
    public func recordQuestionOutcome(
        category: QuestionCategory,
        isCorrect: Bool,
        responseTimeSeconds: Int,
        timeLimitSeconds: Int,
        currentProfile: UserStudyProfile,
        currentRecords: [CategoryMasteryRecord]
    ) -> (updatedProfile: UserStudyProfile, updatedRecords: [CategoryMasteryRecord], earnedDelta: Double) {
        let speedFactor = responseTimeSeconds <= max(5, timeLimitSeconds / 2) ? 1.15 : 1.0
        let stepGain: Double = isCorrect ? (0.035 * speedFactor) : -0.015

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

        let scoreDelta: Double = isCorrect ? 0.15 : 0.0
        let newEstimatedScore = min(100.0, roundToTwentieth(currentProfile.currentEstimatedScore + scoreDelta))
        let newTodayDelta = roundToTwentieth(currentProfile.todayEarnedScoreDelta + scoreDelta)

        let sortedWeak = updatedRecords
            .sorted { $0.currentMasteryRatio < $1.currentMasteryRatio }
            .prefix(2)
            .map(\.category)

        let updatedProfile = UserStudyProfile(
            hasCompletedOnboarding: currentProfile.hasCompletedOnboarding,
            targetExam: currentProfile.targetExam,
            academicTrack: currentProfile.academicTrack,
            initialEstimatedScore: currentProfile.initialEstimatedScore,
            currentEstimatedScore: newEstimatedScore,
            targetScore: currentProfile.targetScore,
            daysRemainingUntilExam: currentProfile.daysRemainingUntilExam,
            streakDays: currentProfile.streakDays,
            todayEarnedScoreDelta: newTodayDelta,
            subscriptionTier: currentProfile.subscriptionTier,
            dailyFreeXRayUsedCount: currentProfile.dailyFreeXRayUsedCount,
            completedPrescriptionStepsToday: currentProfile.completedPrescriptionStepsToday,
            weakestCategories: sortedWeak.isEmpty ? currentProfile.weakestCategories : Array(sortedWeak)
        )

        return (updatedProfile, updatedRecords, scoreDelta)
    }

    public func roundToQuarterPoint(_ value: Double) -> Double {
        (value * 4.0).rounded() / 4.0
    }

    private func roundToTwentieth(_ value: Double) -> Double {
        (value * 20.0).rounded() / 20.0
    }
}
