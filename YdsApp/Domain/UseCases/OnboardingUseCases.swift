import Foundation

/// 5 Adımlı Kişiselleştirme ve Stratejik Seviye Tespiti İş Mantığı (OnboardingUseCases)
public struct EvaluateDiagnosticTestUseCase: Sendable {
    private let scoreCalculator: CalculateEstimatedScoreUseCase

    public init(scoreCalculator: CalculateEstimatedScoreUseCase = CalculateEstimatedScoreUseCase()) {
        self.scoreCalculator = scoreCalculator
    }

    public struct DiagnosticAnswerInput: Equatable, Sendable {
        public let question: SprintQuestion
        public let selectedOptionId: String

        public var isCorrect: Bool {
            question.correctOptionId == selectedOptionId
        }

        public init(question: SprintQuestion, selectedOptionId: String) {
            self.question = question
            self.selectedOptionId = selectedOptionId
        }
    }

    public struct DiagnosticEvaluationResult: Equatable, Sendable {
        public let calibratedProfile: UserStudyProfile
        public let initialCategoryRecords: [CategoryMasteryRecord]
        public let correctCount: Int
        public let totalCount: Int
        public let weakestTwoCategories: [QuestionCategory]
        public let neededScore: Double
        public let diagnosticSummaryHeadlineTr: String
        public let diagnosticDetailNoteTr: String

        public init(
            calibratedProfile: UserStudyProfile,
            initialCategoryRecords: [CategoryMasteryRecord],
            correctCount: Int,
            totalCount: Int,
            weakestTwoCategories: [QuestionCategory],
            neededScore: Double,
            diagnosticSummaryHeadlineTr: String,
            diagnosticDetailNoteTr: String
        ) {
            self.calibratedProfile = calibratedProfile
            self.initialCategoryRecords = initialCategoryRecords
            self.correctCount = correctCount
            self.totalCount = totalCount
            self.weakestTwoCategories = weakestTwoCategories
            self.neededScore = neededScore
            self.diagnosticSummaryHeadlineTr = diagnosticSummaryHeadlineTr
            self.diagnosticDetailNoteTr = diagnosticDetailNoteTr
        }
    }

    /// Kullanıcının beyan ettiği baz puan ile 5 soruluk mini testin sonucunu harmanlayarak
    /// `46.25` gibi küsüratlı, gerçekçi bir Mevcut Tahmini Puan ve Soru Tipi Karnesi üretir.
    public func execute(
        targetExam: ExamType,
        academicTrack: AcademicTrack,
        declaredBaselineScore: Double,
        targetScore: Double,
        daysRemaining: Int,
        answers: [DiagnosticAnswerInput],
        subscriptionTier: SubscriptionTier = .free
    ) -> DiagnosticEvaluationResult {
        let totalQuestions = max(1, answers.count)
        let correctCount = answers.filter(\.isCorrect).count
        let diagnosticRatio = Double(correctCount) / Double(totalQuestions)

        // Beyan edilen baz puan (%65 ağırlık) + 5 soruluk mini test performansı (%35 ağırlık) + gerçek YDS çeyrek puan kalibrasyonu
        let diagnosticEquivalentScore = 30.0 + (diagnosticRatio * 52.5)
        let blendedRaw = (declaredBaselineScore * 0.65) + (diagnosticEquivalentScore * 0.35) + 1.25
        let calibratedScore = scoreCalculator.roundToQuarterPoint(min(max(blendedRaw, 25.0), 92.5))
        let effectiveTarget = max(targetScore, calibratedScore + 10.0)
        let neededScore = scoreCalculator.roundToQuarterPoint(max(0.0, effectiveTarget - calibratedScore))

        // Yanlış yapılan sorulara göre en zayıf 2 alanı belirle
        var failedCategories = answers.filter { !$0.isCorrect }.map(\.question.category)
        for fallback in [QuestionCategory.conjunction, .preposition, .translation, .reductionAndTense] {
            if !failedCategories.contains(fallback) && failedCategories.count < 2 {
                failedCategories.append(fallback)
            }
        }
        let weakestTwo = Array(failedCategories.prefix(2))

        let baseRatio = min(max(calibratedScore / 100.0, 0.25), 0.85)
        let targetRatio = min(max(effectiveTarget / 100.0, baseRatio + 0.15), 0.95)

        let records: [CategoryMasteryRecord] = QuestionCategory.allCases.map { category in
            let answeredItem = answers.first { $0.question.category == category }
            let categoryRatio: Double
            if let answeredItem {
                categoryRatio = answeredItem.isCorrect
                    ? min(0.88, baseRatio + 0.12)
                    : max(0.24, baseRatio - 0.14)
            } else if weakestTwo.contains(category) {
                categoryRatio = max(0.28, baseRatio - 0.10)
            } else {
                categoryRatio = baseRatio
            }

            return CategoryMasteryRecord(
                category: category,
                currentMasteryRatio: categoryRatio,
                targetMasteryRatio: targetRatio,
                questionsSolvedCount: answeredItem != nil ? 5 : 4,
                correctAnswersCount: (answeredItem?.isCorrect == true) ? 4 : 2
            )
        }

        let weakNames = weakestTwo.map(\.shortTitleTr).joined(separator: " ve ")
        let headline = "En çok puan kaybettiğin alan: \(weakNames)"
        let detail = String(
            format: "Mevcut tahmini puanın %.2f olarak ölçüldü. Hedeflediğin %.2f puan için +%.2f puana ihtiyacın var. Günlük 15 dakikalık reçeten bu farkı kapatmak için hazırlandı.",
            calibratedScore,
            effectiveTarget,
            neededScore
        )

        let profile = UserStudyProfile(
            hasCompletedOnboarding: true,
            targetExam: targetExam,
            academicTrack: academicTrack,
            initialEstimatedScore: calibratedScore,
            currentEstimatedScore: calibratedScore,
            targetScore: effectiveTarget,
            daysRemainingUntilExam: max(7, daysRemaining),
            streakDays: 1,
            todayEarnedScoreDelta: 0.25,
            subscriptionTier: subscriptionTier,
            dailyFreeXRayUsedCount: 0,
            completedPrescriptionStepsToday: 0,
            weakestCategories: weakestTwo
        )

        return DiagnosticEvaluationResult(
            calibratedProfile: profile,
            initialCategoryRecords: records,
            correctCount: correctCount,
            totalCount: answers.count,
            weakestTwoCategories: weakestTwo,
            neededScore: neededScore,
            diagnosticSummaryHeadlineTr: headline,
            diagnosticDetailNoteTr: detail
        )
    }
}
