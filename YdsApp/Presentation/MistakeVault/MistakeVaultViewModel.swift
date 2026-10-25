import Combine
import Foundation

@MainActor
public final class MistakeVaultViewModel: ObservableObject {
    @Published public private(set) var state: MistakeVaultViewState

    private let userStudyRepository: any UserStudyRepository
    private let sprintQuestionRepository: any SprintQuestionRepository
    private let mistakeVaultRepository: any MistakeVaultRepository
    private let calculateEstimatedScoreUseCase: CalculateEstimatedScoreUseCase
    private let checkEntitlementUseCase: CheckEntitlementUseCase

    private var activeReviewMistakeId: String?

    public init(
        container: AppDependencyContainer,
        initialState: MistakeVaultViewState = MistakeVaultViewState()
    ) {
        self.state = initialState
        self.userStudyRepository = container.userStudyRepository
        self.sprintQuestionRepository = container.sprintQuestionRepository
        self.mistakeVaultRepository = container.mistakeVaultRepository
        self.calculateEstimatedScoreUseCase = container.calculateEstimatedScoreUseCase
        self.checkEntitlementUseCase = container.checkEntitlementUseCase
    }

    public func onEvent(_ event: MistakeVaultUiEvent) {
        switch event {
        case .onAppear:
            Task { await loadVaultData() }

        case .selectCategoryFilter(let category):
            updateState(selectedCategoryFilter: .some(category))

        case .toggleUnresolvedFilter:
            updateState(showOnlyUnresolved: !state.showOnlyUnresolved)

        case .startMistakeReviewQuestion(let item):
            Task { await openPracticeForMistake(item) }

        case .submitPracticeOption(let optionId):
            Task { await handlePracticeSubmission(optionId: optionId) }

        case .closePracticeModal:
            activeReviewMistakeId = nil
            updateState(
                activePracticeQuestion: .some(nil),
                selectedPracticeOptionId: .some(nil),
                practiceFeedbackBannerTr: .some(nil)
            )

        case .openPaywall:
            updateState(isPaywallPresented: true)

        case .dismissPaywall:
            updateState(isPaywallPresented: false)

        case .upgradeSubscription(let tier):
            Task { await applySubscriptionUpgrade(tier) }
        }
    }

    // MARK: - Private Logic

    private func loadVaultData() async {
        let profile = await userStudyRepository.getUserProfile()
        let mistakes = await mistakeVaultRepository.getMistakeItems()
        let isBlurred = checkEntitlementUseCase.shouldBlurDistractorCoachDetails(tier: profile.subscriptionTier)

        updateState(
            profile: profile,
            allMistakes: mistakes,
            isDistractorBlurred: isBlurred
        )
    }

    private func openPracticeForMistake(_ item: MistakeVaultItem) async {
        activeReviewMistakeId = item.id
        let allQuestions = await sprintQuestionRepository.getAllQuestions()
        let matchedQuestion = allQuestions.first(where: { $0.id == item.questionId })
            ?? allQuestions.first(where: { $0.category == item.category })
            ?? allQuestions.first

        updateState(
            activePracticeQuestion: .some(matchedQuestion),
            selectedPracticeOptionId: .some(nil),
            practiceFeedbackBannerTr: .some(nil)
        )
    }

    private func handlePracticeSubmission(optionId: String) async {
        guard let question = state.activePracticeQuestion else { return }
        let isCorrect = (optionId == question.correctOptionId)
        let targetMistakeId = activeReviewMistakeId
            ?? state.allMistakes.first(where: { $0.questionId == question.id })?.id

        let existingMistake = state.allMistakes.first { $0.id == targetMistakeId }
        let wasAlreadyResolved = existingMistake?.isResolved ?? false

        if let mistakeId = targetMistakeId {
            await mistakeVaultRepository.markMistakeReviewed(
                mistakeId: mistakeId,
                answeredCorrectly: isCorrect
            )
        }

        var currentProfile = await userStudyRepository.getUserProfile()
        let currentRecords = await userStudyRepository.getCategoryMasteries()

        var feedbackBanner: String = ""

        if isCorrect && !wasAlreadyResolved {
            // Hata Kumbarası kurtarma ödülü: +0.25 puan!
            let outcome = calculateEstimatedScoreUseCase.recordMistakeReviewOutcome(
                profile: currentProfile,
                category: question.category,
                isCorrect: true,
                records: currentRecords,
                recoveryDelta: 0.25
            )

            currentProfile = outcome.updatedProfile
            await userStudyRepository.saveUserProfile(outcome.updatedProfile)
            await userStudyRepository.saveCategoryMasteries(outcome.updatedRecords)
            await userStudyRepository.appendScoreEvent(outcome.scoreEvent)

            feedbackBanner = "ÇÖZÜLDÜ ✓ • Bu kuralı başarıyla doğruladın: \(outcome.scoreEvent.transitionDisplayTr)"
        } else if isCorrect {
            feedbackBanner = "Tebrikler! Bu kuralı zaten çözmüştün."
        }

        let updatedMistakes = await mistakeVaultRepository.getMistakeItems()

        if !isCorrect {
            if let wrongOpt = question.options.first(where: { $0.id == optionId }) {
                feedbackBanner = "Dikkat! Yine tuzağa düştün: \(wrongOpt.distractorCoachFeedback.winningRuleTr)"
            } else {
                feedbackBanner = "Doğru şık: \(question.correctOptionId). Sınav kısa yolunu tekrar incele."
            }
        }

        updateState(
            profile: currentProfile,
            allMistakes: updatedMistakes,
            selectedPracticeOptionId: .some(optionId),
            practiceFeedbackBannerTr: .some(feedbackBanner)
        )
    }

    private func applySubscriptionUpgrade(_ tier: SubscriptionTier) async {
        let current = await userStudyRepository.getUserProfile()
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

        let isBlurred = checkEntitlementUseCase.shouldBlurDistractorCoachDetails(tier: tier)
        updateState(
            profile: updatedProfile,
            isDistractorBlurred: isBlurred,
            isPaywallPresented: false
        )
    }

    private func updateState(
        profile: UserStudyProfile? = nil,
        allMistakes: [MistakeVaultItem]? = nil,
        selectedCategoryFilter: QuestionCategory?? = nil,
        showOnlyUnresolved: Bool? = nil,
        activePracticeQuestion: SprintQuestion?? = nil,
        selectedPracticeOptionId: String?? = nil,
        practiceFeedbackBannerTr: String?? = nil,
        isDistractorBlurred: Bool? = nil,
        isPaywallPresented: Bool? = nil
    ) {
        state = MistakeVaultViewState(
            profile: profile ?? state.profile,
            allMistakes: allMistakes ?? state.allMistakes,
            selectedCategoryFilter: selectedCategoryFilter ?? state.selectedCategoryFilter,
            showOnlyUnresolved: showOnlyUnresolved ?? state.showOnlyUnresolved,
            activePracticeQuestion: activePracticeQuestion ?? state.activePracticeQuestion,
            selectedPracticeOptionId: selectedPracticeOptionId ?? state.selectedPracticeOptionId,
            practiceFeedbackBannerTr: practiceFeedbackBannerTr ?? state.practiceFeedbackBannerTr,
            isDistractorBlurred: isDistractorBlurred ?? state.isDistractorBlurred,
            isPaywallPresented: isPaywallPresented ?? state.isPaywallPresented
        )
    }
}
