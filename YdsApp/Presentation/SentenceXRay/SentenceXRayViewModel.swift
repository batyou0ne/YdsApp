import Combine
import Foundation

@MainActor
public final class SentenceXRayViewModel: ObservableObject {
    @Published public private(set) var state: SentenceXRayViewState

    private let userStudyRepository: any UserStudyRepository
    private let sentenceXRayRepository: any SentenceXRayRepository
    private let checkEntitlementUseCase: CheckEntitlementUseCase
    private let calculateEstimatedScoreUseCase: CalculateEstimatedScoreUseCase

    public init(
        container: AppDependencyContainer,
        initialState: SentenceXRayViewState = SentenceXRayViewState()
    ) {
        self.state = initialState
        self.userStudyRepository = container.userStudyRepository
        self.sentenceXRayRepository = container.sentenceXRayRepository
        self.checkEntitlementUseCase = container.checkEntitlementUseCase
        self.calculateEstimatedScoreUseCase = container.calculateEstimatedScoreUseCase
    }

    public func onEvent(_ event: SentenceXRayUiEvent) {
        switch event {
        case .onAppear:
            Task { await loadInitialData() }

        case .selectTrack(let track):
            Task { await handleSelectTrack(track) }

        case .toggleXRayMode:
            Task { await handleToggleXRayMode() }

        case .selectSegment(let segmentId):
            updateState(selectedSegmentId: .some(segmentId))

        case .toggleFullTranslation:
            updateState(isTranslationVisible: !state.isTranslationVisible)

        case .nextSentence:
            guard state.canGoNext else { return }
            let nextIdx = state.currentIndex + 1
            let nextItem = state.items[nextIdx]
            let defaultSegmentId = nextItem.segments.first(where: { $0.examLogicTipTr != nil })?.id
                ?? nextItem.segments.first?.id
            updateState(
                currentIndex: nextIdx,
                isXRayActive: false,
                selectedSegmentId: .some(defaultSegmentId),
                isTranslationVisible: false,
                scoreToastMessageTr: .some(nil)
            )

        case .previousSentence:
            guard state.canGoPrevious else { return }
            let prevIdx = state.currentIndex - 1
            let prevItem = state.items[prevIdx]
            let defaultSegmentId = prevItem.segments.first(where: { $0.examLogicTipTr != nil })?.id
                ?? prevItem.segments.first?.id
            updateState(
                currentIndex: prevIdx,
                isXRayActive: false,
                selectedSegmentId: .some(defaultSegmentId),
                isTranslationVisible: false,
                scoreToastMessageTr: .some(nil)
            )

        case .markSentenceMastered:
            Task { await handleMarkSentenceMastered() }

        case .dismissPaywall:
            updateState(isPaywallPresented: false)

        case .upgradeSubscription(let tier):
            Task { await handleUpgradeSubscription(tier) }
        }
    }

    // MARK: - Private Logic

    private func loadInitialData() async {
        let profile = await userStudyRepository.getUserProfile()
        let track = profile.academicTrack
        let loadedItems = await sentenceXRayRepository.getXRayItems(for: track)
        let currentIdx = min(state.currentIndex, max(0, loadedItems.count - 1))
        let firstItem = loadedItems.indices.contains(currentIdx) ? loadedItems[currentIdx] : loadedItems.first
        let defaultSegmentId = firstItem?.segments.first(where: { $0.examLogicTipTr != nil })?.id
            ?? firstItem?.segments.first?.id

        updateState(
            profile: profile,
            selectedTrack: track,
            items: loadedItems,
            currentIndex: currentIdx,
            selectedSegmentId: .some(defaultSegmentId)
        )
    }

    private func handleSelectTrack(_ track: AcademicTrack) async {
        if track != state.selectedTrack &&
            !checkEntitlementUseCase.canSwitchAcademicTrackFilter(tier: state.profile.subscriptionTier) {
            updateState(
                isPaywallPresented: true,
                paywallReasonTr: "YÖKDİL Sağlık, Fen, Sosyal ve Genel YDS Cümle Röntgeni filtreleri arasında sınırsız geçiş yapmak için YDS Pro'ya yükselt."
            )
            return
        }

        let currentProfile = state.profile
        let updatedProfile = UserStudyProfile(
            hasCompletedOnboarding: currentProfile.hasCompletedOnboarding,
            targetExam: currentProfile.targetExam,
            academicTrack: track,
            initialEstimatedScore: currentProfile.initialEstimatedScore,
            currentEstimatedScore: currentProfile.currentEstimatedScore,
            targetScore: currentProfile.targetScore,
            daysRemainingUntilExam: currentProfile.daysRemainingUntilExam,
            streakDays: currentProfile.streakDays,
            todayEarnedScoreDelta: currentProfile.todayEarnedScoreDelta,
            subscriptionTier: currentProfile.subscriptionTier,
            dailyFreeXRayUsedCount: currentProfile.dailyFreeXRayUsedCount,
            completedPrescriptionStepsToday: currentProfile.completedPrescriptionStepsToday,
            weakestCategories: currentProfile.weakestCategories
        )
        await userStudyRepository.saveUserProfile(updatedProfile)

        let loadedItems = await sentenceXRayRepository.getXRayItems(for: track)
        let firstItem = loadedItems.first
        let defaultSegmentId = firstItem?.segments.first(where: { $0.examLogicTipTr != nil })?.id
            ?? firstItem?.segments.first?.id

        updateState(
            profile: updatedProfile,
            selectedTrack: track,
            items: loadedItems,
            currentIndex: 0,
            isXRayActive: false,
            selectedSegmentId: .some(defaultSegmentId),
            isTranslationVisible: false,
            scoreToastMessageTr: .some(nil)
        )
    }

    private func handleToggleXRayMode() async {
        if state.isXRayActive {
            updateState(isXRayActive: false)
            return
        }

        let currentProfile = state.profile
        guard checkEntitlementUseCase.canOpenSentenceXRay(profile: currentProfile) else {
            updateState(
                isXRayActive: false,
                isPaywallPresented: true,
                paywallReasonTr: "Günlük ücretsiz 1/1 Cümle Röntgeni hakkını kullandın. 4-5 satırlık tüm akademik cümlelerin Özne-Yüklem-Bağlaç iskeletini sınırsız açmak için YDS Pro'ya geç!"
            )
            return
        }

        let updatedProfile: UserStudyProfile
        if currentProfile.subscriptionTier.isPro {
            updatedProfile = currentProfile
        } else {
            updatedProfile = UserStudyProfile(
                hasCompletedOnboarding: currentProfile.hasCompletedOnboarding,
                targetExam: currentProfile.targetExam,
                academicTrack: currentProfile.academicTrack,
                initialEstimatedScore: currentProfile.initialEstimatedScore,
                currentEstimatedScore: currentProfile.currentEstimatedScore,
                targetScore: currentProfile.targetScore,
                daysRemainingUntilExam: currentProfile.daysRemainingUntilExam,
                streakDays: currentProfile.streakDays,
                todayEarnedScoreDelta: currentProfile.todayEarnedScoreDelta,
                subscriptionTier: currentProfile.subscriptionTier,
                dailyFreeXRayUsedCount: currentProfile.dailyFreeXRayUsedCount + 1,
                completedPrescriptionStepsToday: currentProfile.completedPrescriptionStepsToday,
                weakestCategories: currentProfile.weakestCategories
            )
            await userStudyRepository.saveUserProfile(updatedProfile)
        }

        let firstMeaningfulSegmentId = state.currentItem?.segments.first(where: { $0.examLogicTipTr != nil })?.id
            ?? state.currentItem?.segments.first?.id

        updateState(
            profile: updatedProfile,
            isXRayActive: true,
            selectedSegmentId: .some(firstMeaningfulSegmentId)
        )
    }

    private func handleMarkSentenceMastered() async {
        guard let item = state.currentItem else { return }
        if state.masteredItemIds.contains(item.id) {
            updateState(
                scoreToastMessageTr: .some("Bu cümlenin röntgen analiz puanı (+0.08 puan) zaten karnene eklendi.")
            )
            return
        }

        let current = state.profile
        let delta = 0.08
        let newEstimatedScore = min(100.0, ((current.currentEstimatedScore + delta) * 100.0).rounded() / 100.0)
        let newTodayDelta = ((current.todayEarnedScoreDelta + delta) * 100.0).rounded() / 100.0

        let updatedProfile = UserStudyProfile(
            hasCompletedOnboarding: current.hasCompletedOnboarding,
            targetExam: current.targetExam,
            academicTrack: current.academicTrack,
            initialEstimatedScore: current.initialEstimatedScore,
            currentEstimatedScore: newEstimatedScore,
            targetScore: current.targetScore,
            daysRemainingUntilExam: current.daysRemainingUntilExam,
            streakDays: current.streakDays,
            todayEarnedScoreDelta: newTodayDelta,
            subscriptionTier: current.subscriptionTier,
            dailyFreeXRayUsedCount: current.dailyFreeXRayUsedCount,
            completedPrescriptionStepsToday: current.completedPrescriptionStepsToday,
            weakestCategories: current.weakestCategories
        )

        await userStudyRepository.saveUserProfile(updatedProfile)

        var updatedMasteredIds = state.masteredItemIds
        updatedMasteredIds.insert(item.id)

        let toast = String(
            format: "Cümle İskeleti Çözüldü! Tahmini sınav puanına +0.08 puan eklendi (Yeni Puan: %.2f).",
            newEstimatedScore
        )

        updateState(
            profile: updatedProfile,
            scoreToastMessageTr: .some(toast),
            masteredItemIds: updatedMasteredIds
        )
    }

    private func handleUpgradeSubscription(_ tier: SubscriptionTier) async {
        let current = state.profile
        let updatedProfile = UserStudyProfile(
            hasCompletedOnboarding: current.hasCompletedOnboarding,
            targetExam: current.targetExam,
            academicTrack: current.academicTrack,
            initialEstimatedScore: current.initialEstimatedScore,
            currentEstimatedScore: current.currentEstimatedScore,
            targetScore: current.targetScore,
            daysRemainingUntilExam: current.daysRemainingUntilExam,
            streakDays: current.streakDays,
            todayEarnedScoreDelta: current.todayEarnedScoreDelta,
            subscriptionTier: tier,
            dailyFreeXRayUsedCount: current.dailyFreeXRayUsedCount,
            completedPrescriptionStepsToday: current.completedPrescriptionStepsToday,
            weakestCategories: current.weakestCategories
        )
        await userStudyRepository.saveUserProfile(updatedProfile)

        let firstMeaningfulSegmentId = state.currentItem?.segments.first(where: { $0.examLogicTipTr != nil })?.id
            ?? state.currentItem?.segments.first?.id

        updateState(
            profile: updatedProfile,
            isXRayActive: true,
            selectedSegmentId: .some(firstMeaningfulSegmentId),
            isPaywallPresented: false,
            scoreToastMessageTr: .some("Tebrikler! \(tier.displayNameTr) aktif edildi. Sınırsız Cümle Röntgeni açıldı!")
        )
    }

    private func updateState(
        profile: UserStudyProfile? = nil,
        selectedTrack: AcademicTrack? = nil,
        items: [SentenceXRayItem]? = nil,
        currentIndex: Int? = nil,
        isXRayActive: Bool? = nil,
        selectedSegmentId: String?? = nil,
        isTranslationVisible: Bool? = nil,
        isPaywallPresented: Bool? = nil,
        paywallReasonTr: String? = nil,
        scoreToastMessageTr: String?? = nil,
        masteredItemIds: Set<String>? = nil
    ) {
        state = SentenceXRayViewState(
            profile: profile ?? state.profile,
            selectedTrack: selectedTrack ?? state.selectedTrack,
            items: items ?? state.items,
            currentIndex: currentIndex ?? state.currentIndex,
            isXRayActive: isXRayActive ?? state.isXRayActive,
            selectedSegmentId: selectedSegmentId ?? state.selectedSegmentId,
            isTranslationVisible: isTranslationVisible ?? state.isTranslationVisible,
            isPaywallPresented: isPaywallPresented ?? state.isPaywallPresented,
            paywallReasonTr: paywallReasonTr ?? state.paywallReasonTr,
            scoreToastMessageTr: scoreToastMessageTr ?? state.scoreToastMessageTr,
            masteredItemIds: masteredItemIds ?? state.masteredItemIds
        )
    }
}
