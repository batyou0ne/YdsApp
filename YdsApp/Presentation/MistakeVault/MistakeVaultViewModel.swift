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

        if isCorrect && !wasAlreadyResolved {
            // Hata Kumbarası kurtarma ödülü: +0.25 puan!
            let recoveryDelta = 0.25
            let newScore = min(100.0, ((currentProfile.currentEstimatedScore + recoveryDelta) * 20.0).rounded() / 20.0)
            let newTodayDelta = ((currentProfile.todayEarnedScoreDelta + recoveryDelta) * 20.0).rounded() / 20.0

            let updatedRecords: [CategoryMasteryRecord] = currentRecords.map { record in
                guard record.category == question.category else { return record }
                let boostedMastery = min(0.98, record.currentMasteryRatio + 0.04)
                return CategoryMasteryRecord(
                    category: record.category,
                    currentMasteryRatio: boostedMastery,
                    targetMasteryRatio: record.targetMasteryRatio,
                    questionsSolvedCount: record.questionsSolvedCount + 1,
                    correctAnswersCount: record.correctAnswersCount + 1
                )
            }

            currentProfile = UserStudyProfile(
                hasCompletedOnboarding: currentProfile.hasCompletedOnboarding,
                targetExam: currentProfile.targetExam,
                academicTrack: currentProfile.academicTrack,
                initialEstimatedScore: currentProfile.initialEstimatedScore,
                currentEstimatedScore: newScore,
                targetScore: currentProfile.targetScore,
                daysRemainingUntilExam: currentProfile.daysRemainingUntilExam,
                streakDays: currentProfile.streakDays,
                todayEarnedScoreDelta: newTodayDelta,
                subscriptionTier: currentProfile.subscriptionTier,
                dailyFreeXRayUsedCount: currentProfile.dailyFreeXRayUsedCount,
                completedPrescriptionStepsToday: currentProfile.completedPrescriptionStepsToday,
                weakestCategories: currentProfile.weakestCategories
            )

            await userStudyRepository.saveUserProfile(currentProfile)
            await userStudyRepository.saveCategoryMasteries(updatedRecords)
        }

        let updatedMistakes = await mistakeVaultRepository.getMistakeItems()

        let feedbackBanner: String
        if isCorrect {
            feedbackBanner = "ÇÖZÜLDÜ ✓ • Bu kuralı başarıyla doğruladın ve tahmini sınav puanına +0.25 puan geri eklendi!"
        } else if let wrongOpt = question.options.first(where: { $0.id == optionId }) {
            feedbackBanner = "Dikkat! Yine tuzağa düştün: \(wrongOpt.distractorCoachFeedback.winningRuleTr)"
        } else {
            feedbackBanner = "Doğru şık: \(question.correctOptionId). Sınav kısa yolunu tekrar incele."
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
