import Combine
import Foundation

@MainActor
public final class Vocab3DViewModel: ObservableObject {
    @Published public private(set) var state: Vocab3DViewState

    private let userStudyRepository: any UserStudyRepository
    private let vocabularyRepository: any VocabularyRepository
    private let evaluateVocab3DMasteryUseCase: EvaluateVocab3DMasteryUseCase
    private let calculateEstimatedScoreUseCase: CalculateEstimatedScoreUseCase
    private let checkEntitlementUseCase: CheckEntitlementUseCase

    public init(
        container: AppDependencyContainer,
        initialState: Vocab3DViewState = Vocab3DViewState()
    ) {
        self.state = initialState
        self.userStudyRepository = container.userStudyRepository
        self.vocabularyRepository = container.vocabularyRepository
        self.evaluateVocab3DMasteryUseCase = container.evaluateVocab3DMasteryUseCase
        self.calculateEstimatedScoreUseCase = container.calculateEstimatedScoreUseCase
        self.checkEntitlementUseCase = container.checkEntitlementUseCase
    }

    public func onEvent(_ event: Vocab3DUiEvent) {
        switch event {
        case .onAppear:
            Task { await loadInitialData() }

        case .selectTrack(let track):
            Task { await handleSelectTrack(track) }

        case .switchInteractionMode(let mode):
            let currentCard = state.currentCard
            let targetDimension = currentCard?.masteryProgress.nextPendingDimension ?? state.activeDimensionTab
            let quiz = currentCard.map { Self.buildQuizQuestion(for: $0, dimension: targetDimension) }
            updateState(
                interactionMode: mode,
                activeDimensionTab: targetDimension,
                currentQuizState: .some(quiz),
                lastEvaluationFeedbackTr: .some(nil),
                lastEarnedScoreDeltaText: .some(nil)
            )

        case .selectDimensionTab(let dimension):
            let quiz = state.currentCard.map { Self.buildQuizQuestion(for: $0, dimension: dimension) }
            updateState(
                activeDimensionTab: dimension,
                currentQuizState: .some(quiz),
                lastEvaluationFeedbackTr: .some(nil),
                lastEarnedScoreDeltaText: .some(nil)
            )

        case .selectQuizOption(let option):
            Task { await handleSelectQuizOption(option) }

        case .advanceToNextQuizOrCard:
            handleAdvanceToNextQuizOrCard()

        case .nextCard:
            guard state.canGoNext else { return }
            let nextIdx = state.currentIndex + 1
            let nextCard = state.cards[nextIdx]
            let nextDim = nextCard.masteryProgress.nextPendingDimension
            let quiz = Self.buildQuizQuestion(for: nextCard, dimension: nextDim)
            updateState(
                currentIndex: nextIdx,
                activeDimensionTab: nextDim,
                currentQuizState: .some(quiz),
                lastEvaluationFeedbackTr: .some(nil),
                lastEarnedScoreDeltaText: .some(nil)
            )

        case .previousCard:
            guard state.canGoPrevious else { return }
            let prevIdx = state.currentIndex - 1
            let prevCard = state.cards[prevIdx]
            let prevDim = prevCard.masteryProgress.nextPendingDimension
            let quiz = Self.buildQuizQuestion(for: prevCard, dimension: prevDim)
            updateState(
                currentIndex: prevIdx,
                activeDimensionTab: prevDim,
                currentQuizState: .some(quiz),
                lastEvaluationFeedbackTr: .some(nil),
                lastEarnedScoreDeltaText: .some(nil)
            )

        case .dismissPaywall:
            updateState(isPaywallPresented: false)

        case .upgradeSubscription(let tier):
            Task { await handleUpgradeSubscription(tier) }
        }
    }

    // MARK: - Deterministic Quiz Builder

    public static func buildQuizQuestion(
        for card: Vocab3DCard,
        dimension: VocabQuizDimension
    ) -> Vocab3DQuizQuestionState {
        let promptTitleTr: String
        let promptStem: String
        let correctOption: String
        let distractors: [String]

        switch dimension {
        case .meaning:
            promptTitleTr = "1. Boyut: Akademik Anlam Doğrulaması"
            promptStem = "'\(card.formattedWithPreposition)' akademik kelimesinin YDS/YÖKDİL karşılığı nedir?"
            correctOption = card.academicMeaningTr
            distractors = card.meaningDistractorsTr

        case .preposition:
            promptTitleTr = "2. Boyut: Zorunlu Edat Doğrulaması"
            promptStem = "\(card.headword) ___ (Boşluğa gelmesi gereken zorunlu edat hangisidir?)"
            correctOption = card.mandatoryPreposition
            distractors = card.prepositionDistractors

        case .synonym:
            promptTitleTr = "3. Boyut: YDS İkizi (Eş Anlam) Doğrulaması"
            promptStem = "'\(card.formattedWithPreposition)' paketinin yakın anlam ve paragraf sorularındaki YDS ikizi hangisidir?"
            correctOption = card.ydsTwins.first ?? card.formattedWithPreposition
            distractors = card.twinDistractors
        }

        var rawOptions = Array(distractors.prefix(3))
        let seedHash = abs((card.id + dimension.rawValue).unicodeScalars.reduce(0) { $0 + Int($1.value) })
        let insertionIndex = seedHash % (rawOptions.count + 1)
        rawOptions.insert(correctOption, at: insertionIndex)

        return Vocab3DQuizQuestionState(
            dimension: dimension,
            promptTitleTr: promptTitleTr,
            promptStem: promptStem,
            options: rawOptions,
            correctOption: correctOption,
            selectedOption: nil,
            isAnswered: false,
            isCorrect: nil
        )
    }

    // MARK: - Private Logic

    private func loadInitialData() async {
        let profile = await userStudyRepository.getUserProfile()
        let track = profile.academicTrack
        let rawCards = await vocabularyRepository.getVocabCards(for: track)
        let prioritized = evaluateVocab3DMasteryUseCase.prioritizeReviewQueue(
            cards: rawCards,
            for: track,
            now: Date()
        )
        let safeIndex = min(state.currentIndex, max(0, prioritized.count - 1))
        let currentCard = prioritized.indices.contains(safeIndex) ? prioritized[safeIndex] : prioritized.first
        let initialDim = currentCard?.masteryProgress.nextPendingDimension ?? .meaning
        let quiz = currentCard.map { Self.buildQuizQuestion(for: $0, dimension: initialDim) }

        updateState(
            profile: profile,
            selectedTrack: track,
            cards: prioritized,
            currentIndex: safeIndex,
            activeDimensionTab: initialDim,
            currentQuizState: .some(quiz)
        )
    }

    private func handleSelectTrack(_ track: AcademicTrack) async {
        if track != state.selectedTrack &&
            !checkEntitlementUseCase.canSwitchAcademicTrackFilter(tier: state.profile.subscriptionTier) {
            updateState(
                isPaywallPresented: true,
                paywallReasonTr: "YÖKDİL Sağlık, Fen ve Sosyal Bilimler 3 boyutlu kelime paketleri arasında sınırsız geçiş yapmak için YDS Pro'ya yükselt."
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

        let rawCards = await vocabularyRepository.getVocabCards(for: track)
        let prioritized = evaluateVocab3DMasteryUseCase.prioritizeReviewQueue(
            cards: rawCards,
            for: track,
            now: Date()
        )
        let firstCard = prioritized.first
        let initialDim = firstCard?.masteryProgress.nextPendingDimension ?? .meaning
        let quiz = firstCard.map { Self.buildQuizQuestion(for: $0, dimension: initialDim) }

        updateState(
            profile: updatedProfile,
            selectedTrack: track,
            cards: prioritized,
            currentIndex: 0,
            activeDimensionTab: initialDim,
            currentQuizState: .some(quiz),
            lastEvaluationFeedbackTr: .some(nil),
            lastEarnedScoreDeltaText: .some(nil)
        )
    }

    private func handleSelectQuizOption(_ option: String) async {
        guard let card = state.currentCard,
              let quiz = state.currentQuizState,
              !quiz.isAnswered else { return }

        let isCorrect = option == quiz.correctOption
        let now = Date()
        let evaluation = evaluateVocab3DMasteryUseCase.evaluateAnswer(
            card: card,
            dimension: quiz.dimension,
            isCorrect: isCorrect,
            now: now
        )

        await vocabularyRepository.updateVocabCardProgress(evaluation.updatedCard)

        var updatedProfile = state.profile
        if evaluation.scoreDeltaEarned > 0 {
            let newScore = min(
                100.0,
                ((updatedProfile.currentEstimatedScore + evaluation.scoreDeltaEarned) * 20.0).rounded() / 20.0
            )
            let newTodayDelta = ((updatedProfile.todayEarnedScoreDelta + evaluation.scoreDeltaEarned) * 20.0).rounded() / 20.0

            updatedProfile = UserStudyProfile(
                hasCompletedOnboarding: updatedProfile.hasCompletedOnboarding,
                targetExam: updatedProfile.targetExam,
                academicTrack: updatedProfile.academicTrack,
                initialEstimatedScore: updatedProfile.initialEstimatedScore,
                currentEstimatedScore: newScore,
                targetScore: updatedProfile.targetScore,
                daysRemainingUntilExam: updatedProfile.daysRemainingUntilExam,
                streakDays: updatedProfile.streakDays,
                todayEarnedScoreDelta: newTodayDelta,
                subscriptionTier: updatedProfile.subscriptionTier,
                dailyFreeXRayUsedCount: updatedProfile.dailyFreeXRayUsedCount,
                completedPrescriptionStepsToday: updatedProfile.completedPrescriptionStepsToday,
                weakestCategories: updatedProfile.weakestCategories
            )
            await userStudyRepository.saveUserProfile(updatedProfile)
        }

        var updatedCards = state.cards
        if let idx = updatedCards.firstIndex(where: { $0.id == evaluation.updatedCard.id }) {
            updatedCards[idx] = evaluation.updatedCard
        }

        let targetCurrentIndex: Int
        if !isCorrect {
            // Hata yapılan kelime Spaced Repetition kuyruğunun en önüne (index 0) çekilir!
            updatedCards = evaluateVocab3DMasteryUseCase.prioritizeReviewQueue(
                cards: updatedCards,
                for: state.selectedTrack,
                now: now
            )
            targetCurrentIndex = updatedCards.firstIndex(where: { $0.id == evaluation.updatedCard.id }) ?? 0
        } else {
            targetCurrentIndex = state.currentIndex
        }

        let answeredQuiz = Vocab3DQuizQuestionState(
            dimension: quiz.dimension,
            promptTitleTr: quiz.promptTitleTr,
            promptStem: quiz.promptStem,
            options: quiz.options,
            correctOption: quiz.correctOption,
            selectedOption: option,
            isAnswered: true,
            isCorrect: isCorrect
        )

        let deltaBadge: String? = evaluation.scoreDeltaEarned > 0
            ? String(format: "+%.2f puan", evaluation.scoreDeltaEarned)
            : nil

        updateState(
            profile: updatedProfile,
            cards: updatedCards,
            currentIndex: targetCurrentIndex,
            currentQuizState: .some(answeredQuiz),
            lastEvaluationFeedbackTr: .some(evaluation.feedbackMessageTr),
            lastEarnedScoreDeltaText: .some(deltaBadge)
        )
    }

    private func handleAdvanceToNextQuizOrCard() {
        guard let card = state.currentCard else { return }

        if !card.isFullyLearned {
            let nextDim: VocabQuizDimension
            if !card.masteryProgress.isMeaningMastered && state.activeDimensionTab != .meaning {
                nextDim = .meaning
            } else if !card.masteryProgress.isPrepositionMastered && state.activeDimensionTab != .preposition {
                nextDim = .preposition
            } else if !card.masteryProgress.isSynonymMastered && state.activeDimensionTab != .synonym {
                nextDim = .synonym
            } else {
                nextDim = card.masteryProgress.nextPendingDimension
            }

            let nextQuiz = Self.buildQuizQuestion(for: card, dimension: nextDim)
            updateState(
                activeDimensionTab: nextDim,
                currentQuizState: .some(nextQuiz),
                lastEvaluationFeedbackTr: .some(nil),
                lastEarnedScoreDeltaText: .some(nil)
            )
            return
        }

        // Kelime 3/3 boyutta tam öğrenildiyse sıradaki kelimeye geç
        if state.canGoNext {
            let nextIdx = state.currentIndex + 1
            let nextCard = state.cards[nextIdx]
            let nextDim = nextCard.masteryProgress.nextPendingDimension
            let nextQuiz = Self.buildQuizQuestion(for: nextCard, dimension: nextDim)
            updateState(
                currentIndex: nextIdx,
                activeDimensionTab: nextDim,
                currentQuizState: .some(nextQuiz),
                lastEvaluationFeedbackTr: .some(nil),
                lastEarnedScoreDeltaText: .some(nil)
            )
        } else {
            let reprioritized = evaluateVocab3DMasteryUseCase.prioritizeReviewQueue(
                cards: state.cards,
                for: state.selectedTrack,
                now: Date()
            )
            let firstCard = reprioritized.first
            let nextDim = firstCard?.masteryProgress.nextPendingDimension ?? .meaning
            let nextQuiz = firstCard.map { Self.buildQuizQuestion(for: $0, dimension: nextDim) }
            updateState(
                cards: reprioritized,
                currentIndex: 0,
                activeDimensionTab: nextDim,
                currentQuizState: .some(nextQuiz),
                lastEvaluationFeedbackTr: .some(nil),
                lastEarnedScoreDeltaText: .some(nil)
            )
        }
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
        updateState(
            profile: updatedProfile,
            lastEvaluationFeedbackTr: .some("Tebrikler! \(tier.displayNameTr) aktif edildi. Tüm YÖKDİL Sağlık, Fen ve Sosyal 3B Kelime paketleri açıldı!"),
            isPaywallPresented: false
        )
    }

    private func updateState(
        profile: UserStudyProfile? = nil,
        selectedTrack: AcademicTrack? = nil,
        interactionMode: Vocab3DInteractionMode? = nil,
        cards: [Vocab3DCard]? = nil,
        currentIndex: Int? = nil,
        activeDimensionTab: VocabQuizDimension? = nil,
        currentQuizState: Vocab3DQuizQuestionState?? = nil,
        lastEvaluationFeedbackTr: String?? = nil,
        lastEarnedScoreDeltaText: String?? = nil,
        isPaywallPresented: Bool? = nil,
        paywallReasonTr: String? = nil
    ) {
        state = Vocab3DViewState(
            profile: profile ?? state.profile,
            selectedTrack: selectedTrack ?? state.selectedTrack,
            interactionMode: interactionMode ?? state.interactionMode,
            cards: cards ?? state.cards,
            currentIndex: currentIndex ?? state.currentIndex,
            activeDimensionTab: activeDimensionTab ?? state.activeDimensionTab,
            currentQuizState: currentQuizState ?? state.currentQuizState,
            lastEvaluationFeedbackTr: lastEvaluationFeedbackTr ?? state.lastEvaluationFeedbackTr,
            lastEarnedScoreDeltaText: lastEarnedScoreDeltaText ?? state.lastEarnedScoreDeltaText,
            isPaywallPresented: isPaywallPresented ?? state.isPaywallPresented,
            paywallReasonTr: paywallReasonTr ?? state.paywallReasonTr
        )
    }
}
