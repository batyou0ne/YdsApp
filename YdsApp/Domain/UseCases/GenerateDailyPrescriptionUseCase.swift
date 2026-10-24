import Foundation

/// Günün 15 Dakikalık Reçetesi Üreticisi (GenerateDailyPrescriptionUseCase)
/// 14 adımlık hazır sekans:
/// - 5x 3 Boyutlu Kelime Kartı (Adım 1..5)
/// - 2x Cümle Röntgeni (Adım 6..7)
/// - 5x Mikro-Sprint Sorusu (Adım 8..12)
/// - 2x Hata Kumbarası Tekrarı (Adım 13..14)
public struct GenerateDailyPrescriptionUseCase: Sendable {
    private let entitlementUseCase: CheckEntitlementUseCase
    private let vocabUseCase: EvaluateVocab3DMasteryUseCase

    public init(
        entitlementUseCase: CheckEntitlementUseCase = CheckEntitlementUseCase(),
        vocabUseCase: EvaluateVocab3DMasteryUseCase = EvaluateVocab3DMasteryUseCase()
    ) {
        self.entitlementUseCase = entitlementUseCase
        self.vocabUseCase = vocabUseCase
    }

    public func execute(
        profile: UserStudyProfile,
        vocabCards: [Vocab3DCard],
        xrayItems: [SentenceXRayItem],
        sprintQuestions: [SprintQuestion],
        mistakeItems: [MistakeVaultItem],
        dateString: String = "Bugün"
    ) -> DailyPrescription {
        let prioritizedVocab = vocabUseCase.prioritizeReviewQueue(cards: vocabCards, for: profile.academicTrack)
        let selectedVocab = Array(prioritizedVocab.prefix(5))

        let trackXRays = xrayItems.filter {
            profile.academicTrack == .generalAcademic ? true : $0.track == profile.academicTrack
        }
        let selectedXRays = Array((trackXRays.isEmpty ? xrayItems : trackXRays).prefix(2))

        let weakCategories = Set(profile.weakestCategories)
        let prioritizedQuestions = sprintQuestions
            .filter { !$0.isDiagnosticOnboarding }
            .sorted { lhs, rhs in
                let lhsMatchesTrack = lhs.track == profile.academicTrack
                let rhsMatchesTrack = rhs.track == profile.academicTrack
                if lhsMatchesTrack != rhsMatchesTrack {
                    return lhsMatchesTrack && !rhsMatchesTrack
                }
                let lhsWeak = weakCategories.contains(lhs.category)
                let rhsWeak = weakCategories.contains(rhs.category)
                if lhsWeak != rhsWeak {
                    return lhsWeak && !rhsWeak
                }
                return lhs.id < rhs.id
            }
        let selectedQuestions = Array(prioritizedQuestions.prefix(5))

        let unresolvedMistakes = mistakeItems.filter { !$0.isResolved }
        let selectedMistakes = Array((unresolvedMistakes.isEmpty ? mistakeItems : unresolvedMistakes).prefix(2))

        var steps: [DailyPrescriptionStep] = []
        var currentIndex = 1

        // 1. 5x 3 Boyutlu Kelime Kartı (Adım 1 - 5)
        for card in selectedVocab {
            let isCompleted = currentIndex <= profile.completedPrescriptionStepsToday
            let isLocked = entitlementUseCase.isPrescriptionStepLocked(
                stepIndex: currentIndex,
                tier: profile.subscriptionTier
            )
            steps.append(
                DailyPrescriptionStep(
                    id: "step-\(currentIndex)-\(card.id)",
                    stepIndex: currentIndex,
                    stepType: .vocab3D,
                    referenceItemId: card.id,
                    titleTr: "3B Kelime: \(card.formattedWithPreposition)",
                    subtitleTr: "\(card.academicMeaningTr) • İkizi: \(card.ydsTwins.first ?? "")",
                    estimatedScoreImpact: 0.05,
                    isCompleted: isCompleted,
                    isLockedForFreeTier: isLocked
                )
            )
            currentIndex += 1
        }

        // 2. 2x Cümle Röntgeni (Adım 6 - 7)
        for xray in selectedXRays {
            let isCompleted = currentIndex <= profile.completedPrescriptionStepsToday
            let isLocked = entitlementUseCase.isPrescriptionStepLocked(
                stepIndex: currentIndex,
                tier: profile.subscriptionTier
            )
            steps.append(
                DailyPrescriptionStep(
                    id: "step-\(currentIndex)-\(xray.id)",
                    stepIndex: currentIndex,
                    stepType: .sentenceXRay,
                    referenceItemId: xray.id,
                    titleTr: "Cümle Röntgeni: \(xray.skeletonSummaryTr)",
                    subtitleTr: "\(xray.track.shortTitleTr) • Kutup: \(xray.clausePolarityLeft.symbol) / \(xray.clausePolarityRight.symbol)",
                    estimatedScoreImpact: 0.08,
                    isCompleted: isCompleted,
                    isLockedForFreeTier: isLocked
                )
            )
            currentIndex += 1
        }

        // 3. 5x Mikro-Sprint Sorusu (Adım 8 - 12)
        for question in selectedQuestions {
            let isCompleted = currentIndex <= profile.completedPrescriptionStepsToday
            let isLocked = entitlementUseCase.isPrescriptionStepLocked(
                stepIndex: currentIndex,
                tier: profile.subscriptionTier
            )
            steps.append(
                DailyPrescriptionStep(
                    id: "step-\(currentIndex)-\(question.id)",
                    stepIndex: currentIndex,
                    stepType: .microSprint,
                    referenceItemId: question.id,
                    titleTr: "\(question.sprintMode.titleTr) (\(question.category.shortTitleTr))",
                    subtitleTr: "\(question.timeLimitSeconds) sn hedef süre • Çeldirici Koçu aktif",
                    estimatedScoreImpact: 0.06,
                    isCompleted: isCompleted,
                    isLockedForFreeTier: isLocked
                )
            )
            currentIndex += 1
        }

        // 4. 2x Hata Kumbarası Tekrarı (Adım 13 - 14)
        for mistake in selectedMistakes {
            let isCompleted = currentIndex <= profile.completedPrescriptionStepsToday
            let isLocked = entitlementUseCase.isPrescriptionStepLocked(
                stepIndex: currentIndex,
                tier: profile.subscriptionTier
            )
            steps.append(
                DailyPrescriptionStep(
                    id: "step-\(currentIndex)-\(mistake.id)",
                    stepIndex: currentIndex,
                    stepType: .mistakeVaultReview,
                    referenceItemId: mistake.id,
                    titleTr: "Hata Kumbarası: \(mistake.grammarRuleTitleTr)",
                    subtitleTr: "Tuzak Tekrarı: \(mistake.selectedWrongOptionText) yerine \(mistake.correctOptionText)",
                    estimatedScoreImpact: 0.07,
                    isCompleted: isCompleted,
                    isLockedForFreeTier: isLocked
                )
            )
            currentIndex += 1
        }

        return DailyPrescription(
            dateString: dateString,
            track: profile.academicTrack,
            totalEstimatedMinutes: 15,
            steps: steps,
            expectedScoreDeltaRangeMin: 0.25,
            expectedScoreDeltaRangeMax: 0.65,
            freeTierStepLimit: CheckEntitlementUseCase.freeDailyPrescriptionStepLimit
        )
    }
}
