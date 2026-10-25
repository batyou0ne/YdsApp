import XCTest
@testable import YdsCore

/// Hata Kumbarası'nı UserDefaults'a yazmadan sayan test çifti.
private actor RecordingMistakeVault: MistakeVaultRepository {
    private(set) var recorded: [String] = []
    func getMistakeItems() async -> [MistakeVaultItem] { [] }
    func recordMistake(question: SprintQuestion, selectedOption: QuestionOption, date: Date) async {
        recorded.append(question.id)
    }
    func markMistakeReviewed(mistakeId: String, answeredCorrectly: Bool) async {}
    func recordedIds() -> [String] { recorded }
}

@MainActor
final class OnboardingViewModelTests: XCTestCase {
    private var vault = RecordingMistakeVault()

    private func makeViewModel(useAdaptive: Bool = true) -> OnboardingViewModel {
        vault = RecordingMistakeVault()
        let container = AppDependencyContainer(
            mistakeVaultRepository: vault,
            runAdaptiveOnboardingDiagnosticUseCase: RunAdaptiveOnboardingDiagnosticUseCase(
                engine: AdaptiveDiagnosticEngine(randomness: SeededRandomnessProvider(seed: 3))
            )
        )
        return OnboardingViewModel(container: container, useAdaptiveDiagnostic: useAdaptive)
    }

    private func send(_ vm: OnboardingViewModel, _ event: OnboardingUiEvent) async {
        vm.onEvent(event)
        await vm.waitForPendingWork()
    }

    private func goToStep3(_ vm: OnboardingViewModel) async {
        await send(vm, .onAppear)
        await send(vm, .proceedToNextStep)
        await send(vm, .proceedToNextStep)
    }

    /// Soruyu doğru cevaplayıp (veya yanlış) sonraki adıma geçer.
    private func answerAndAdvance(_ vm: OnboardingViewModel, correct: Bool) async {
        guard let q = vm.state.currentDiagnosticQuestion else { return XCTFail("Soru yok") }
        let wrong = q.options.first { $0.id != q.correctOptionId }!.id
        await send(vm, .selectDiagnosticOption(correct ? q.correctOptionId : wrong))
        await send(vm, .submitCurrentDiagnosticQuestion)
    }

    // MARK: Yol seçici

    func testEnteringStep3ShowsPathChooserWithRecommendedDefault() async {
        let vm = makeViewModel()
        await goToStep3(vm)
        XCTAssertEqual(vm.state.currentStep, .step3DiagnosticTest)
        XCTAssertTrue(vm.state.isPathChooserVisible)
        XCTAssertEqual(vm.state.selectedStartPath, .quickDiagnostic)
        XCTAssertTrue(OnboardingStartPath.quickDiagnostic.isRecommended)
        XCTAssertNil(vm.state.adaptiveSession)
        XCTAssertEqual(OnboardingStep.step3DiagnosticTest.stepTitleTr, "Adım 3/5 • Seviyeni Belirle")
    }

    func testSelectStartPathUpdatesSelection() async {
        let vm = makeViewModel()
        await goToStep3(vm)
        await send(vm, .selectStartPath(.declaredScore))
        XCTAssertEqual(vm.state.selectedStartPath, .declaredScore)
    }

    // MARK: Yol B

    func testPathBAsksSixAdaptiveQuestionsAndReachesStep4() async {
        let vm = makeViewModel()
        await goToStep3(vm)
        await send(vm, .confirmStartPath)

        XCTAssertFalse(vm.state.isPathChooserVisible)
        XCTAssertEqual(vm.state.adaptiveSession?.maxQuestions, 6)
        XCTAssertEqual(vm.state.diagnosticProgressText, "Soru 1 / 6")
        XCTAssertEqual(vm.state.levelIndicatorText, "Seviye: Orta")
        XCTAssertGreaterThan(vm.state.remainingSeconds, 0)

        for index in 0..<6 {
            XCTAssertEqual(vm.state.currentStep, .step3DiagnosticTest)
            guard let q = vm.state.currentDiagnosticQuestion else { return XCTFail("Soru yok") }
            XCTAssertEqual(vm.state.diagnosticProgressText, "Soru \(index + 1) / 6")
            XCTAssertFalse(vm.state.isShowingInstantCoachFeedback)

            await send(vm, .selectDiagnosticOption(q.correctOptionId))
            XCTAssertTrue(vm.state.isShowingInstantCoachFeedback)
            XCTAssertEqual(vm.state.lastAnswerWasCorrect, true)
            XCTAssertNotNil(vm.state.estimatedLiveScoreHint)
            XCTAssertNotNil(vm.state.feedbackOption?.distractorCoachFeedback.winningRuleTr)
            await send(vm, .submitCurrentDiagnosticQuestion)
        }

        XCTAssertEqual(vm.state.currentStep, .step4DiagnosisAndPrescription)
        XCTAssertEqual(vm.state.diagnosticOutcome?.totalCount, 6)
        XCTAssertNotNil(vm.state.diagnosticResult)
        XCTAssertNotNil(vm.state.previewPrescription)
        XCTAssertNotNil(vm.state.formattedOutcomeScoreWithRange)
        XCTAssertEqual(vm.state.diagnosticOutcome?.weakestTwoCategories.count, 2)
    }

    func testAnsweredQuestionIsLockedAndWrongAnswerRecordedInMistakeVault() async {
        let vm = makeViewModel()
        await goToStep3(vm)
        await send(vm, .confirmStartPath)
        guard let q = vm.state.currentDiagnosticQuestion else { return XCTFail("Soru yok") }
        let wrong = q.options.first { $0.id != q.correctOptionId }!.id

        await send(vm, .selectDiagnosticOption(wrong))
        XCTAssertEqual(vm.state.lastAnswerWasCorrect, false)
        let answeredCount = vm.state.adaptiveSession?.answers.count

        // Aynı soruda ikinci seçim yok sayılır
        await send(vm, .selectDiagnosticOption(q.correctOptionId))
        XCTAssertEqual(vm.state.selectedOptionIdForCurrentQuestion, wrong)
        XCTAssertEqual(vm.state.adaptiveSession?.answers.count, answeredCount)
        let ids = await vault.recordedIds()
        XCTAssertEqual(ids, [q.id])
    }

    func testTimerExpiryCountsAsMissedWithGentleFeedback() async {
        let vm = makeViewModel()
        await goToStep3(vm)
        await send(vm, .confirmStartPath)
        let limit = vm.state.remainingSeconds
        for _ in 0..<limit { await send(vm, .tickTimer) }

        XCTAssertEqual(vm.state.remainingSeconds, 0)
        XCTAssertTrue(vm.state.didCurrentQuestionTimeOut)
        XCTAssertEqual(vm.state.lastAnswerWasCorrect, false)
        XCTAssertTrue(vm.state.isCurrentQuestionAnswered)
        // Süre dolsa da doğru şıkkın koç açıklaması gösterilir
        XCTAssertNotNil(vm.state.feedbackOption)
        // Kilitlendikten sonra tik'ler etkisizdir
        await send(vm, .tickTimer)
        XCTAssertEqual(vm.state.remainingSeconds, 0)
    }

    // MARK: Yol A

    func testPathAAsksTwoConfirmationQuestions() async {
        let vm = makeViewModel()
        await send(vm, .onAppear)
        await send(vm, .updateDeclaredBaselineScore(62.5))
        await send(vm, .proceedToNextStep)
        await send(vm, .proceedToNextStep)
        await send(vm, .selectStartPath(.declaredScore))
        await send(vm, .confirmStartPath)

        XCTAssertEqual(vm.state.adaptiveSession?.maxQuestions, 2)
        XCTAssertEqual(vm.state.diagnosticProgressText, "Soru 1 / 2")
        await answerAndAdvance(vm, correct: true)
        XCTAssertEqual(vm.state.currentStep, .step3DiagnosticTest)
        await answerAndAdvance(vm, correct: true)

        XCTAssertEqual(vm.state.currentStep, .step4DiagnosisAndPrescription)
        XCTAssertEqual(vm.state.diagnosticOutcome?.totalCount, 2)
        XCTAssertNotNil(vm.state.diagnosticResult)
    }

    // MARK: Yol C

    func testPathCSkipsQuestionsAndUsesBaseline35() async {
        let vm = makeViewModel()
        await goToStep3(vm)
        await send(vm, .selectStartPath(.freshStart))
        await send(vm, .confirmStartPath)

        XCTAssertEqual(vm.state.currentStep, .step4DiagnosisAndPrescription)
        XCTAssertTrue(vm.state.diagnosticQuestions.isEmpty)
        XCTAssertNil(vm.state.adaptiveSession)
        XCTAssertEqual(vm.state.diagnosticOutcome?.estimatedScore, 35.0)
        XCTAssertEqual(vm.state.diagnosticOutcome?.confidenceLevel, .low)
        XCTAssertEqual(vm.state.diagnosticResult?.calibratedProfile.currentEstimatedScore, 35.0)
        XCTAssertNotNil(vm.state.previewPrescription)
    }

    func testSkipDiagnosticWithFreshStartEventReachesStep4() async {
        let vm = makeViewModel()
        await goToStep3(vm)
        await send(vm, .skipDiagnosticWithFreshStart)
        XCTAssertEqual(vm.state.currentStep, .step4DiagnosisAndPrescription)
        XCTAssertEqual(vm.state.selectedStartPath, .freshStart)
        XCTAssertEqual(vm.state.diagnosticOutcome?.estimatedScore, 35.0)
    }

    // MARK: Geri dönüş

    func testBackFromQuestionReturnsToChooserWithoutReopeningAnsweredQuestion() async {
        let vm = makeViewModel()
        await goToStep3(vm)
        await send(vm, .confirmStartPath)
        await answerAndAdvance(vm, correct: true)
        XCTAssertEqual(vm.state.diagnosticQuestions.count, 2)

        await send(vm, .goBackStep)
        XCTAssertEqual(vm.state.currentStep, .step3DiagnosticTest)
        XCTAssertTrue(vm.state.isPathChooserVisible)
        XCTAssertNil(vm.state.adaptiveSession)
        XCTAssertTrue(vm.state.diagnosticQuestions.isEmpty)
        XCTAssertNil(vm.state.currentDiagnosticQuestion)
    }

    func testBackFromChooserGoesToStep2() async {
        let vm = makeViewModel()
        await goToStep3(vm)
        await send(vm, .goBackStep)
        XCTAssertEqual(vm.state.currentStep, .step2ScoreAndTimeGoal)
        XCTAssertFalse(vm.state.isPathChooserVisible)
    }

    func testBackFromStep4ReturnsToChooserForEveryPath() async {
        for path in OnboardingStartPath.allCases {
            let vm = makeViewModel()
            await goToStep3(vm)
            await send(vm, .selectStartPath(path))
            await send(vm, .confirmStartPath)
            if path != .freshStart {
                let total = vm.state.adaptiveSession?.maxQuestions ?? 0
                for _ in 0..<total { await answerAndAdvance(vm, correct: true) }
            }
            XCTAssertEqual(vm.state.currentStep, .step4DiagnosisAndPrescription, "\(path)")

            await send(vm, .goBackStep)
            XCTAssertEqual(vm.state.currentStep, .step3DiagnosticTest, "\(path)")
            XCTAssertTrue(vm.state.isPathChooserVisible, "\(path)")
            XCTAssertNil(vm.state.diagnosticResult, "\(path)")
            XCTAssertNil(vm.state.diagnosticOutcome, "\(path)")
        }
    }

    // MARK: Feature flag kapalı: eski akış

    func testFlagOffKeepsLegacyFiveQuestionFlow() async {
        let vm = makeViewModel(useAdaptive: false)
        await goToStep3(vm)

        XCTAssertFalse(vm.state.useAdaptiveDiagnostic)
        XCTAssertFalse(vm.state.isPathChooserVisible)
        XCTAssertEqual(vm.state.diagnosticQuestions.count, 5)
        XCTAssertNil(vm.state.adaptiveSession)

        for _ in 0..<5 {
            guard let q = vm.state.currentDiagnosticQuestion else { return XCTFail("Soru yok") }
            await send(vm, .selectDiagnosticOption(q.correctOptionId))
            await send(vm, .submitCurrentDiagnosticQuestion)
        }
        XCTAssertEqual(vm.state.currentStep, .step4DiagnosisAndPrescription)
        XCTAssertEqual(vm.state.diagnosticResult?.totalCount, 5)
        XCTAssertNil(vm.state.diagnosticOutcome)

        // Yol olayları eski akışta etkisizdir
        await send(vm, .confirmStartPath)
        XCTAssertEqual(vm.state.currentStep, .step4DiagnosisAndPrescription)
    }
}
