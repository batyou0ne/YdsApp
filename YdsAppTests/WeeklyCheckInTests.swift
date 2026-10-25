import XCTest
@testable import YdsCore

@MainActor
final class WeeklyCheckInTests: XCTestCase {

    private var allQuestions: [SprintQuestion] {
        SprintQuestionSeedData.allQuestions
    }

    // MARK: - 1. Soru Dağılımı ve Tekrar Yok Testi
    func testQuestionDistributionAndNoDuplicates() {
        let builder = BuildWeeklyCheckInUseCase()
        let questions = builder.execute(availableQuestions: allQuestions)

        // 15 Soru tam olmalı
        XCTAssertEqual(questions.count, 15, "Check-In tam 15 sorudan oluşmalıdır")

        // Tekrar eden soru ID'si olmamalı
        let uniqueIds = Set(questions.map(\.id))
        XCTAssertEqual(uniqueIds.count, 15, "15 sorunun tümü benzersiz olmalıdır")

        // YDS Kategori Dağılım Kontrolü
        let vocabPrepCount = questions.filter { $0.category == .academicVocab || $0.category == .preposition }.count
        XCTAssertEqual(vocabPrepCount, 3, "Kelime & Edat toplam 3 soru olmalıdır")

        let conjTenseCount = questions.filter { $0.category == .conjunction || $0.category == .reductionAndTense }.count
        XCTAssertEqual(conjTenseCount, 3, "Bağlaç & Tense toplam 3 soru olmalıdır")

        let scCount = questions.filter { $0.category == .sentenceCompletion }.count
        XCTAssertEqual(scCount, 2, "Cümle Tamamlama 2 soru olmalıdır")

        let transCount = questions.filter { $0.category == .translation }.count
        XCTAssertEqual(transCount, 2, "Çeviri 2 soru olmalıdır")

        let clozeCount = questions.filter { $0.category == .clozeTest }.count
        XCTAssertEqual(clozeCount, 2, "Cloze Test 2 soru olmalıdır")

        let readingCount = questions.filter { $0.category == .dialogueAndRestatement || $0.category == .irrelevantSentence }.count
        XCTAssertEqual(readingCount, 3, "Paragraf, Yakın Anlam & Akış Bozan 3 soru olmalıdır")

        // Toplam kontrol: 3 + 3 + 2 + 2 + 2 + 3 = 15
        XCTAssertEqual(vocabPrepCount + conjTenseCount + scCount + transCount + clozeCount + readingCount, 15)

        // Zorluk Dağılımı: ~%30 Kolay (4-5), ~%40 Orta (5-6), ~%30 Zor (4-5)
        let easyCount = questions.filter { $0.difficultyBand == .easy }.count
        let mediumCount = questions.filter { $0.difficultyBand == .medium }.count
        let hardCount = questions.filter { $0.difficultyBand == .hard }.count

        XCTAssertTrue((4...5).contains(easyCount), "Kolay soru sayısı 4 veya 5 olmalıdır, mevcut: \(easyCount)")
        XCTAssertTrue((5...7).contains(mediumCount), "Orta soru sayısı 5-7 olmalıdır, mevcut: \(mediumCount)")
        XCTAssertTrue((4...6).contains(hardCount), "Zor soru sayısı 4-6 olmalıdır, mevcut: \(hardCount)")
    }

    // MARK: - 2. Zayıf Konular ve Çözülmemiş Sorulara Öncelik
    func testWeakTopicsPrioritization() {
        let builder = BuildWeeklyCheckInUseCase()

        let mistake = MistakeVaultItem(
            id: "m-test-1",
            questionId: "cd-q1",
            stemPreview: "Archaeological excavations...",
            selectedWrongOptionId: "A",
            selectedWrongOptionText: "for / on",
            correctOptionId: "B",
            correctOptionText: "with / into",
            category: .preposition,
            track: .socialSciences,
            grammarRuleTag: "PREP_PROVIDE_WITH_INSIGHT_INTO",
            grammarRuleTitleTr: "Preposition rule",
            praiseTextTr: "Praise",
            trapReasonTr: "Trap",
            winningRuleTr: "Winning",
            isResolved: false
        )

        let profile = UserStudyProfile(
            weakestCategories: [.preposition, .sentenceCompletion]
        )

        let questions = builder.execute(
            availableQuestions: allQuestions,
            mistakes: [mistake],
            profile: profile
        )

        XCTAssertEqual(questions.count, 15)
        // Zayıf kategoriler olan preposition veya sentenceCompletion soruları seçilmelidir
        let hasPreposition = questions.contains { $0.category == .preposition }
        let hasSentenceComp = questions.contains { $0.category == .sentenceCompletion }
        XCTAssertTrue(hasPreposition)
        XCTAssertTrue(hasSentenceComp)
    }

    // MARK: - 3. Süre Bitince Otomatik Teslim Testi
    func testAutoSubmitWhenTimeExpires() async {
        let container = AppDependencyContainer()
        let builder = BuildWeeklyCheckInUseCase()
        let sampleQuestions = builder.execute(availableQuestions: allQuestions)

        let vm = WeeklyCheckInViewModel(
            container: container,
            initialState: WeeklyCheckInViewState(
                phase: .inProgress,
                questions: sampleQuestions,
                remainingTimeSeconds: 1
            ),
            preloadedQuestions: sampleQuestions
        )

        // 1 saniye sonra süre biter (0 olur) ve submitAll otomatik tetiklenir
        vm.onEvent(.tickTimer)

        // Görev tamamlanana kadar kısa bekleme
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(vm.state.phase, .report, "Süre bitince otomatik teslim edilerek rapor aşamasına geçmelidir")
        XCTAssertNotNil(vm.state.report, "Rapor üretilmiş olmalıdır")
    }

    // MARK: - 4. Boş Soru Yanlış Sayılır ve Hata Kumbarasına Düşer
    func testBlankQuestionsCountAsWrongAndRecordMistakes() async {
        let container = AppDependencyContainer()
        let builder = BuildWeeklyCheckInUseCase()
        let questions = builder.execute(availableQuestions: allQuestions)

        let evaluator = EvaluateWeeklyCheckInUseCase()

        // İlk 10 soru doğru, son 5 soru boş (cevap verilmemiş)
        var answers: [String: String] = [:]
        for (idx, q) in questions.enumerated() {
            if idx < 10 {
                answers[q.id] = q.correctOptionId
            }
        }

        let profile = UserStudyProfile(currentEstimatedScore: 50.00)
        let masteries = MistakeVaultSeedData.defaultCategoryMasteries

        let (report, _) = evaluator.execute(
            questions: questions,
            answers: answers,
            elapsedSeconds: 600,
            profile: profile,
            categoryRecords: masteries
        )

        XCTAssertEqual(report.totalQuestions, 15)
        XCTAssertEqual(report.correctCount, 10, "10 doğru olmalıdır")
        XCTAssertEqual(report.blankCount, 5, "5 boş soru olmalıdır")
        XCTAssertEqual(report.wrongCount, 0, "Boşlar dışındaki yanlış sayısı 0'dır")

        // Boş sorular puan kazandırmaz, başarı oranı 10/15 (%66.7) civarındadır
        XCTAssertLessThan(report.measuredScore, 100.0)
        XCTAssertGreaterThan(report.measuredScore, 50.0)

        // ViewModel submit akışında boş soruların da MistakeVault'a kaydedildiğini doğrulayalım
        let vm = WeeklyCheckInViewModel(
            container: container,
            initialState: WeeklyCheckInViewState(
                phase: .inProgress,
                questions: questions,
                selectedAnswers: answers
            ),
            preloadedQuestions: questions
        )

        await vm.finishAndEvaluateCheckIn()

        let mistakesInVault = await container.mistakeVaultRepository.getMistakeItems()
        // Boş bırakılan 5 sorunun Hata Kumbarasına kaydedildiğini doğrula
        for q in questions[10..<15] {
            XCTAssertTrue(mistakesInVault.contains { $0.questionId == q.id }, "Boş bırakılan soru Hata Kumbarasına kaydedilmelidir: \(q.id)")
        }
    }

    // MARK: - 5. Puan Hesabı ve Kalibrasyonun Profile Yansıması
    func testScoreCalculationAndCalibrationReflectedInProfile() async {
        let container = AppDependencyContainer()
        let builder = BuildWeeklyCheckInUseCase()
        let questions = builder.execute(availableQuestions: allQuestions)

        // Tüm sorular doğru yanıtlanıyor (15/15 = 100.00 ölçülen puan)
        var allCorrectAnswers: [String: String] = [:]
        for q in questions {
            allCorrectAnswers[q.id] = q.correctOptionId
        }

        let initialProfile = UserStudyProfile(
            currentEstimatedScore: 50.00,
            scoreConfidenceMargin: 4.5
        )
        await container.userStudyRepository.saveUserProfile(initialProfile)

        let vm = WeeklyCheckInViewModel(
            container: container,
            initialState: WeeklyCheckInViewState(
                phase: .inProgress,
                questions: questions,
                selectedAnswers: allCorrectAnswers
            ),
            preloadedQuestions: questions
        )

        await vm.finishAndEvaluateCheckIn()

        guard let report = vm.state.report else {
            XCTFail("Check-In raporu oluşturulmalıdır")
            return
        }

        XCTAssertEqual(report.correctCount, 15)
        XCTAssertEqual(report.measuredScore, 100.00, accuracy: 0.001)

        // Kalibrasyon formülü: 50.00 * 0.40 + 100.00 * 0.60 = 20.00 + 60.00 = 80.00
        XCTAssertEqual(report.scoreAfter, 80.00, accuracy: 0.001)
        XCTAssertEqual(report.earnedDelta, 30.00, accuracy: 0.001)

        // Profilin veri katmanında güncellendiğini doğrula
        let updatedProfile = await container.userStudyRepository.getUserProfile()
        XCTAssertEqual(updatedProfile.currentEstimatedScore, 80.00, accuracy: 0.001)
        XCTAssertEqual(updatedProfile.lastCheckInScore ?? 0.0, 80.00, accuracy: 0.001)
        XCTAssertNotNil(updatedProfile.lastCheckInDate)

        // Güven aralığının daraldığını doğrula (max 2.0 sınırında)
        XCTAssertLessThanOrEqual(updatedProfile.scoreConfidenceMargin ?? 5.0, 2.0)
    }

    // MARK: - 6. Haftalık Limit ve Freemium Aylık Limit Testi
    func testWeeklyAndMonthlyEligibilityLimits() {
        let eligibilityUseCase = CheckInEligibilityUseCase()
        let now = Date()

        // 1. Ücretsiz kullanıcı ilk kez giriyor -> Uygun
        let freeNewUser = UserStudyProfile(
            subscriptionTier: .free,
            lastCheckInDate: nil
        )
        let status1 = eligibilityUseCase.execute(profile: freeNewUser, currentDate: now)
        XCTAssertTrue(status1.isEligible)
        XCTAssertEqual(status1.daysUntilNextAvailable, 0)
        XCTAssertEqual(status1.badgeTextTr, "HAZIR")

        // 2. Ücretsiz kullanıcı bugün check-in yaptı -> 30 gün kilitli
        let freeRecentUser = UserStudyProfile(
            subscriptionTier: .free,
            lastCheckInDate: now
        )
        let status2 = eligibilityUseCase.execute(profile: freeRecentUser, currentDate: now)
        XCTAssertFalse(status2.isEligible)
        XCTAssertEqual(status2.daysUntilNextAvailable, 30)
        XCTAssertTrue(status2.reasonTr?.contains("ayda 1") == true)
        XCTAssertEqual(status2.badgeTextTr, "30 GÜN SONRA")

        // 3. Ücretsiz kullanıcı 10 gün sonra deniyor -> 20 gün kaldı
        let calendar = Calendar.current
        let tenDaysLater = calendar.date(byAdding: .day, value: 10, to: now)!
        let status3 = eligibilityUseCase.execute(profile: freeRecentUser, currentDate: tenDaysLater)
        XCTAssertFalse(status3.isEligible)
        XCTAssertEqual(status3.daysUntilNextAvailable, 20)

        // 4. Ücretsiz kullanıcı 31 gün sonra deniyor -> Tekrar açılmış
        let thirtyOneDaysLater = calendar.date(byAdding: .day, value: 31, to: now)!
        let status4 = eligibilityUseCase.execute(profile: freeRecentUser, currentDate: thirtyOneDaysLater)
        XCTAssertTrue(status4.isEligible)
        XCTAssertEqual(status4.daysUntilNextAvailable, 0)

        // 5. Pro kullanıcı bugün check-in yapmış olsa bile -> Sınırsız / Her zaman uygun
        let proUser = UserStudyProfile(
            subscriptionTier: .proMonthly,
            lastCheckInDate: now
        )
        let status5 = eligibilityUseCase.execute(profile: proUser, currentDate: now)
        XCTAssertTrue(status5.isEligible, "Pro kullanıcı için check-in her zaman uygundur")
        XCTAssertEqual(status5.daysUntilNextAvailable, 0)
    }

    // MARK: - 7. Freemium Paywall Blur Flag'leri
    func testFreemiumBlurFlagsInViewState() async {
        let container = AppDependencyContainer()
        let builder = BuildWeeklyCheckInUseCase()
        let questions = builder.execute(availableQuestions: allQuestions)

        // Free Kullanıcı
        let freeProfile = UserStudyProfile(subscriptionTier: .free)
        await container.userStudyRepository.saveUserProfile(freeProfile)

        let freeVM = WeeklyCheckInViewModel(
            container: container,
            initialState: WeeklyCheckInViewState(questions: questions),
            preloadedQuestions: questions
        )
        await freeVM.loadInitialQuestions()
        XCTAssertTrue(freeVM.state.isPaywallBlurActive, "Free kullanıcıda Çeldirici Koçu ve Karne detayları bulanık olmalıdır")

        // Pro Kullanıcı
        let proProfile = UserStudyProfile(subscriptionTier: .proAnnual)
        await container.userStudyRepository.saveUserProfile(proProfile)

        let proVM = WeeklyCheckInViewModel(
            container: container,
            initialState: WeeklyCheckInViewState(questions: questions),
            preloadedQuestions: questions
        )
        await proVM.loadInitialQuestions()
        XCTAssertFalse(proVM.state.isPaywallBlurActive, "Pro kullanıcıda blur bayrağı pasif olmalıdır")
    }

    // MARK: - 8. Sınav İçi Etkileşim: Şık Değiştirme, Boş Bırakma, Bayrak
    func testRealExamInteractions() {
        let container = AppDependencyContainer()
        let builder = BuildWeeklyCheckInUseCase()
        let questions = builder.execute(availableQuestions: allQuestions)

        let vm = WeeklyCheckInViewModel(
            container: container,
            initialState: WeeklyCheckInViewState(questions: questions),
            preloadedQuestions: questions
        )

        vm.onEvent(.start)
        XCTAssertEqual(vm.state.phase, .inProgress)

        let q1 = questions[0]

        // 1. Şık A seçilir
        vm.onEvent(.selectOption(questionId: q1.id, optionId: "A"))
        XCTAssertEqual(vm.state.selectedAnswers[q1.id], "A")
        XCTAssertEqual(vm.state.answeredCount, 1)

        // 2. Şık B'ye değiştirilir
        vm.onEvent(.selectOption(questionId: q1.id, optionId: "B"))
        XCTAssertEqual(vm.state.selectedAnswers[q1.id], "B")

        // 3. Boş Bırakılır
        vm.onEvent(.leaveBlank(questionId: q1.id))
        XCTAssertNil(vm.state.selectedAnswers[q1.id])
        XCTAssertEqual(vm.state.answeredCount, 0)

        // 4. Bayrak (Flag) eklenir ve kaldırılır
        vm.onEvent(.flagQuestion(questionId: q1.id))
        XCTAssertTrue(vm.state.flaggedQuestionIds.contains(q1.id))
        vm.onEvent(.flagQuestion(questionId: q1.id))
        XCTAssertFalse(vm.state.flaggedQuestionIds.contains(q1.id))

        // 5. Palet üzerinden 8. soruya zıplama
        vm.onEvent(.jumpToQuestion(index: 7))
        XCTAssertEqual(vm.state.currentQuestionIndex, 7)
    }

    // MARK: - 9. Hatırlatma Politikası Hafta Sonu Hesaplama Testi
    func testReminderPolicyCalculatesWeekend() {
        let policy = CheckInReminderPolicy()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        let reminderDate = policy.nextReminderDate(from: Date(), preferredHour: 10)
        let weekday = calendar.component(.weekday, from: reminderDate)
        let hour = calendar.component(.hour, from: reminderDate)

        XCTAssertTrue(
            weekday == CheckInReminderPolicy.targetWeekdaySaturday || weekday == CheckInReminderPolicy.targetWeekdaySunday,
            "Hatırlatma Cumartesi veya Pazar olmalıdır"
        )
        XCTAssertEqual(hour, 10, "Hatırlatma saati 10:00 olmalıdır")
    }
}
