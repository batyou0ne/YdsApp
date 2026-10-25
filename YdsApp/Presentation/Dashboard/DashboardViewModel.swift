import Combine
import Foundation

@MainActor
public final class DashboardViewModel: ObservableObject {
    @Published public private(set) var state: DashboardViewState

    private let userStudyRepository: any UserStudyRepository
    private let vocabularyRepository: any VocabularyRepository
    private let sentenceXRayRepository: any SentenceXRayRepository
    private let sprintQuestionRepository: any SprintQuestionRepository
    private let mistakeVaultRepository: any MistakeVaultRepository

    private let calculateScoreUseCase: CalculateEstimatedScoreUseCase
    private let generatePrescriptionUseCase: GenerateDailyPrescriptionUseCase
    private let checkEntitlementUseCase: CheckEntitlementUseCase
    private let onRequestOnboardingReset: (@Sendable () -> Void)?

    public init(
        container: AppDependencyContainer,
        initialState: DashboardViewState = DashboardViewState(),
        onRequestOnboardingReset: (@Sendable () -> Void)? = nil
    ) {
        self.state = initialState
        self.userStudyRepository = container.userStudyRepository
        self.vocabularyRepository = container.vocabularyRepository
        self.sentenceXRayRepository = container.sentenceXRayRepository
        self.sprintQuestionRepository = container.sprintQuestionRepository
        self.mistakeVaultRepository = container.mistakeVaultRepository
        self.calculateScoreUseCase = container.calculateEstimatedScoreUseCase
        self.generatePrescriptionUseCase = container.generateDailyPrescriptionUseCase
        self.checkEntitlementUseCase = container.checkEntitlementUseCase
        self.onRequestOnboardingReset = onRequestOnboardingReset
    }

    public func onEvent(_ event: DashboardUiEvent) {
        switch event {
        case .onAppear:
            Task { await refreshDashboardData() }

        case .startNextPrescriptionStep:
            if let nextPending = state.dailyPrescription.steps.first(where: { !$0.isCompleted }) {
                handleStepSelection(nextPending)
            }

        case .tapPrescriptionStep(let step):
            handleStepSelection(step)

        case .selectAcademicTrackFilter(let track):
            Task { await handleTrackChange(track) }

        case .openPaywall(let reasonTr):
            updateState(isPaywallPresented: true, paywallTriggerReasonTr: reasonTr)

        case .dismissPaywall:
            updateState(isPaywallPresented: false)

        case .upgradeSubscription(let tier):
            Task { await applySubscriptionUpgrade(tier) }

        case .clearNavigationRequest:
            updateState(requestedNavigationTab: .some(nil))

        case .restartOnboardingDiagnostic:
            Task {
                let current = await userStudyRepository.getUserProfile()
                let resetProfile = UserStudyProfile(
                    hasCompletedOnboarding: false,
                    targetExam: current.targetExam,
                    academicTrack: current.academicTrack,
                    initialEstimatedScore: current.initialEstimatedScore,
                    currentEstimatedScore: current.currentEstimatedScore,
                    targetScore: current.targetScore,
                    daysRemainingUntilExam: current.daysRemainingUntilExam,
                    streakDays: current.streakDays,
                    todayEarnedScoreDelta: current.todayEarnedScoreDelta,
                    subscriptionTier: current.subscriptionTier,
                    dailyFreeXRayUsedCount: current.dailyFreeXRayUsedCount,
                    completedPrescriptionStepsToday: current.completedPrescriptionStepsToday,
                    weakestCategories: current.weakestCategories
                )
                await userStudyRepository.saveUserProfile(resetProfile)
                updateState(profile: resetProfile)
                onRequestOnboardingReset?()
            }
        }
    }

    public func refreshDashboardData() async {
        let profile = await userStudyRepository.getUserProfile()
        let records = await userStudyRepository.getCategoryMasteries()
        let vocab = await vocabularyRepository.getAllVocabCards()
        let xrays = await sentenceXRayRepository.getAllXRayItems()
        let sprints = await sprintQuestionRepository.getAllQuestions()
        let mistakes = await mistakeVaultRepository.getMistakeItems()

        let reportCard = calculateScoreUseCase.execute(profile: profile, categoryRecords: records)
        let prescription = generatePrescriptionUseCase.execute(
            profile: profile,
            vocabCards: vocab,
            xrayItems: xrays,
            sprintQuestions: sprints,
            mistakeItems: mistakes
        )
        let events = await userStudyRepository.getScoreEvents(since: nil)

        updateState(
            profile: profile,
            reportCard: reportCard,
            dailyPrescription: prescription,
            recentScoreEvents: events
        )
    }

    private func handleStepSelection(_ step: DailyPrescriptionStep) {
        if checkEntitlementUseCase.isPrescriptionStepLocked(
            stepIndex: step.stepIndex,
            tier: state.profile.subscriptionTier
        ) {
            updateState(
                isPaywallPresented: true,
                paywallTriggerReasonTr: "Ücretsiz kullanıcılar günlük 14 adımlık reçetenin ilk 7 adımını (%50) tamamlayabilir. \(step.stepIndex). adıma (\(step.titleTr)) geçmek ve günde +0.55 puana kadar kazanmak için YDS Pro'yu aç."
            )
            return
        }

        Task {
            let current = state.profile
            let newCompletedCount = max(current.completedPrescriptionStepsToday, step.stepIndex)
            let didAdvance = newCompletedCount > current.completedPrescriptionStepsToday
            let deltaIncrement = didAdvance ? step.estimatedScoreImpact : 0.0
            let updatedScore = min(100.0, ((current.currentEstimatedScore + deltaIncrement) * 20.0).rounded() / 20.0)
            let updatedTodayDelta = ((current.todayEarnedScoreDelta + deltaIncrement) * 20.0).rounded() / 20.0

            let updatedProfile = UserStudyProfile(
                hasCompletedOnboarding: current.hasCompletedOnboarding,
                targetExam: current.targetExam,
                academicTrack: current.academicTrack,
                initialEstimatedScore: current.initialEstimatedScore,
                currentEstimatedScore: updatedScore,
                targetScore: current.targetScore,
                daysRemainingUntilExam: current.daysRemainingUntilExam,
                streakDays: current.streakDays,
                todayEarnedScoreDelta: updatedTodayDelta,
                subscriptionTier: current.subscriptionTier,
                dailyFreeXRayUsedCount: current.dailyFreeXRayUsedCount,
                completedPrescriptionStepsToday: newCompletedCount,
                weakestCategories: current.weakestCategories
            )

            await userStudyRepository.saveUserProfile(updatedProfile)
            await refreshDashboardData()

            let targetTab: AppMainTab
            switch step.stepType {
            case .vocab3D:
                targetTab = .vocab3D
            case .sentenceXRay:
                targetTab = .sentenceXRay
            case .microSprint:
                targetTab = .microSprint
            case .mistakeVaultReview:
                targetTab = .mistakeVault
            }

            let banner = String(
                format: "Adım %d/14 tamamlandı! Tahmini sınav puanına +%.2f puan eklendi.",
                step.stepIndex,
                step.estimatedScoreImpact
            )

            updateState(
                workoutCompletionBannerTr: banner,
                requestedNavigationTab: targetTab
            )
        }
    }

    private func handleTrackChange(_ track: AcademicTrack) async {
        if track != state.profile.academicTrack &&
            !checkEntitlementUseCase.canSwitchAcademicTrackFilter(tier: state.profile.subscriptionTier) {
            updateState(
                isPaywallPresented: true,
                paywallTriggerReasonTr: "YÖKDİL Sağlık, Fen ve Sosyal Bilimler alan filtreleri arasında sınırsız geçiş yapmak için YDS Pro'ya yükselt."
            )
            return
        }

        let current = state.profile
        let updatedProfile = UserStudyProfile(
            hasCompletedOnboarding: current.hasCompletedOnboarding,
            targetExam: current.targetExam,
            academicTrack: track,
            initialEstimatedScore: current.initialEstimatedScore,
            currentEstimatedScore: current.currentEstimatedScore,
            targetScore: current.targetScore,
            daysRemainingUntilExam: current.daysRemainingUntilExam,
            streakDays: current.streakDays,
            todayEarnedScoreDelta: current.todayEarnedScoreDelta,
            subscriptionTier: current.subscriptionTier,
            dailyFreeXRayUsedCount: current.dailyFreeXRayUsedCount,
            completedPrescriptionStepsToday: current.completedPrescriptionStepsToday,
            weakestCategories: current.weakestCategories
        )
        await userStudyRepository.saveUserProfile(updatedProfile)
        await refreshDashboardData()
    }

    private func applySubscriptionUpgrade(_ tier: SubscriptionTier) async {
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
        await refreshDashboardData()
        updateState(
            isPaywallPresented: false,
            workoutCompletionBannerTr: "Tebrikler! \(tier.displayNameTr) aktif edildi. Tüm 14 adımlık reçete, Cümle Röntgeni ve Çeldirici Koçu kilitleri açıldı!"
        )
    }

    private func updateState(
        profile: UserStudyProfile? = nil,
        reportCard: ScoreReportCard? = nil,
        dailyPrescription: DailyPrescription? = nil,
        isPaywallPresented: Bool? = nil,
        paywallTriggerReasonTr: String? = nil,
        workoutCompletionBannerTr: String?? = nil,
        requestedNavigationTab: AppMainTab?? = nil,
        recentScoreEvents: [ScoreEvent]? = nil
    ) {
        state = DashboardViewState(
            profile: profile ?? state.profile,
            reportCard: reportCard ?? state.reportCard,
            dailyPrescription: dailyPrescription ?? state.dailyPrescription,
            isPaywallPresented: isPaywallPresented ?? state.isPaywallPresented,
            paywallTriggerReasonTr: paywallTriggerReasonTr ?? state.paywallTriggerReasonTr,
            workoutCompletionBannerTr: workoutCompletionBannerTr ?? state.workoutCompletionBannerTr,
            requestedNavigationTab: requestedNavigationTab ?? state.requestedNavigationTab,
            recentScoreEvents: recentScoreEvents ?? state.recentScoreEvents
        )
    }
}
