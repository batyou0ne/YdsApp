import Foundation

/// Tek bir cevabın adaptif oturuma işlenmesinin sonucu (canlı puan ipucu dahil).
public struct AdaptiveAnswerRecordResult: Equatable, Sendable {
    public let session: AdaptiveDiagnosticSession
    public let isCorrect: Bool
    public let timedOut: Bool
    /// Cevap sonrası canlı Tahmini Sınav Puanı (çeyrek puan)
    public let liveScore: Double
    /// Cevabın canlı puana etkisi (örn. `+0.50`)
    public let liveScoreDelta: Double
}

/// Adaptif teşhis sonucundan üretilen onboarding değerlendirmesi.
public struct AdaptiveOnboardingEvaluation: Equatable, Sendable {
    public let outcome: AdaptiveDiagnosticOutcome
    public let result: EvaluateDiagnosticTestUseCase.DiagnosticEvaluationResult
}

/// Onboarding Adım 3'ün adaptif akışını yöneten saf Domain UseCase'i.
/// ViewModel yalnızca orkestrasyon yapar; oturum, puan ve sonuç hesapları burada.
public struct RunAdaptiveOnboardingDiagnosticUseCase: Sendable {
    private let engine: AdaptiveDiagnosticEngine
    private let scoreCalculator: CalculateEstimatedScoreUseCase

    public init(
        engine: AdaptiveDiagnosticEngine = AdaptiveDiagnosticEngine(),
        scoreCalculator: CalculateEstimatedScoreUseCase = CalculateEstimatedScoreUseCase()
    ) {
        self.engine = engine
        self.scoreCalculator = scoreCalculator
    }

    /// `declaredBaseline` verilirse Yol A (2 teyit sorusu), `nil` ise Yol B (6 soru).
    public func startSession(declaredBaseline: Double?) -> AdaptiveDiagnosticSession {
        .start(declaredBaseline: declaredBaseline)
    }

    /// Havuz yalnızca teşhis sorularına daraltılır; boşsa tüm havuz kullanılır.
    public func nextQuestion(
        session: AdaptiveDiagnosticSession,
        pool: [SprintQuestion],
        track: AcademicTrack
    ) -> SprintQuestion? {
        let diagnosticPool = pool.filter(\.isDiagnosticOnboarding)
        return engine.nextQuestion(
            session: session,
            pool: diagnosticPool.isEmpty ? pool : diagnosticPool,
            track: track
        )
    }

    /// `selectedOptionId == nil` süre dolması anlamına gelir (yanlış sayılır).
    public func recordAnswer(
        question: SprintQuestion,
        selectedOptionId: String?,
        responseSeconds: Double,
        session: AdaptiveDiagnosticSession
    ) -> AdaptiveAnswerRecordResult {
        let answer = AdaptiveDiagnosticAnswer(
            question: question,
            selectedOptionId: selectedOptionId,
            responseSeconds: responseSeconds
        )
        let updated = engine.submit(answer: answer, session: session)
        let before = scoreCalculator.roundToQuarterPoint(AdaptiveDiagnosticEngine.clampScore(session.abilityEstimate))
        let after = scoreCalculator.roundToQuarterPoint(AdaptiveDiagnosticEngine.clampScore(updated.abilityEstimate))
        return AdaptiveAnswerRecordResult(
            session: updated,
            isCorrect: answer.isCorrect,
            timedOut: answer.timedOut,
            liveScore: after,
            liveScoreDelta: after - before
        )
    }

    /// Oturumu kapatır ve Adım 4 / reçete için `DiagnosticEvaluationResult` üretir.
    /// Yol C: boş oturum + `declaredBaseline == nil` -> sabit 35.00 baz, düşük güven.
    public func finalize(
        session: AdaptiveDiagnosticSession,
        declaredBaseline: Double?,
        targetExam: ExamType,
        academicTrack: AcademicTrack,
        targetScore: Double,
        daysRemaining: Int,
        subscriptionTier: SubscriptionTier = .free
    ) -> AdaptiveOnboardingEvaluation {
        let outcome = engine.finalize(session: session, declaredBaseline: declaredBaseline)
        let score = outcome.estimatedScore
        let effectiveTarget = min(100.0, max(targetScore, score + 10.0))
        let needed = scoreCalculator.roundToQuarterPoint(max(0.0, effectiveTarget - score))
        let weakest = outcome.weakestTwoCategories
        let weakNames = weakest.map(\.shortTitleTr).joined(separator: " ve ")

        let headline: String
        let detail: String
        if outcome.confidenceLevel == .low {
            headline = "İlk adımda odaklanacağımız alanlar: \(weakNames)"
            detail = String(
                format: "Başlangıç tahmini puanın %.2f. Birkaç gün çalışınca puanını netleştireceğiz. Hedefin %.2f için +%.2f puanlık yol var; günlük reçeten bunun için hazır.",
                locale: Locale(identifier: "en_US_POSIX"),
                score, effectiveTarget, needed
            )
        } else {
            headline = "En çok puan kazanacağın alan: \(weakNames)"
            detail = String(
                format: "Mevcut tahmini puanın %.2f olarak ölçüldü. Hedefin %.2f için +%.2f puanlık yol var. Günlük 15 dakikalık reçeten bu farkı kapatmak için hazırlandı.",
                locale: Locale(identifier: "en_US_POSIX"),
                score, effectiveTarget, needed
            )
        }

        let hasMismatch = outcome.declaredScoreMismatchNoteTr != nil
        let profile = UserStudyProfile(
            hasCompletedOnboarding: true,
            targetExam: targetExam,
            academicTrack: academicTrack,
            initialEstimatedScore: score,
            currentEstimatedScore: score,
            targetScore: effectiveTarget,
            daysRemainingUntilExam: max(7, daysRemaining),
            streakDays: 1,
            todayEarnedScoreDelta: 0.25,
            subscriptionTier: subscriptionTier,
            dailyFreeXRayUsedCount: 0,
            completedPrescriptionStepsToday: 0,
            weakestCategories: weakest,
            scoreConfidenceMargin: 5.0,
            declaredBaselineScore: declaredBaseline,
            hasScoreDiscrepancy: hasMismatch,
            daysActiveCount: 1
        )

        let result = EvaluateDiagnosticTestUseCase.DiagnosticEvaluationResult(
            calibratedProfile: profile,
            initialCategoryRecords: outcome.categoryRecords,
            correctCount: outcome.correctCount,
            totalCount: outcome.totalCount,
            weakestTwoCategories: weakest,
            neededScore: needed,
            diagnosticSummaryHeadlineTr: headline,
            diagnosticDetailNoteTr: detail
        )
        return AdaptiveOnboardingEvaluation(outcome: outcome, result: result)
    }
}
