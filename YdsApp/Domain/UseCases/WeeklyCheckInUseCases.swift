import Foundation

// MARK: - 1. BuildWeeklyCheckInUseCase
/// 15 soruluk, YDS kategori ağırlıklarına orantılı Haftalık Check-In mini denemesi oluşturucu
///
/// Dağılım Kuralı:
/// - Kelime & Edat: 3 soru (.academicVocab + .preposition)
/// - Bağlaç & Tense/Kısaltma: 3 soru (.conjunction + .reductionAndTense)
/// - Cümle Tamamlama: 2 soru (.sentenceCompletion)
/// - Çeviri: 2 soru (.translation)
/// - Cloze Test: 2 soru (.clozeTest)
/// - Paragraf, Yakın Anlam & Akış Bozan: 3 soru (.dialogueAndRestatement + .irrelevantSentence)
/// Toplam = 15 soru.
///
/// Ağırlık Kuralı:
/// - Daha önce çözülmemiş sorulara ve Hata Kumbarasındaki zayıf kategorilere %30 ağırlık.
/// - Zorluk: %30 Kolay (4-5 soru), %40 Orta (6 soru), %30 Zor (4-5 soru).
public struct BuildWeeklyCheckInUseCase: Sendable {
    public static let targetTotalQuestions: Int = 15

    public init() {}

    private struct CategorySlot {
        let name: String
        let categories: [QuestionCategory]
        let targetCount: Int
        let targetBands: [QuestionDifficultyBand]
    }

    private let slots: [CategorySlot] = [
        CategorySlot(
            name: "Kelime & Edat",
            categories: [.academicVocab, .preposition],
            targetCount: 3,
            targetBands: [.easy, .medium, .hard]
        ),
        CategorySlot(
            name: "Bağlaç & Tense",
            categories: [.conjunction, .reductionAndTense],
            targetCount: 3,
            targetBands: [.easy, .medium, .hard]
        ),
        CategorySlot(
            name: "Cümle Tamamlama",
            categories: [.sentenceCompletion],
            targetCount: 2,
            targetBands: [.easy, .medium]
        ),
        CategorySlot(
            name: "Çeviri",
            categories: [.translation],
            targetCount: 2,
            targetBands: [.medium, .hard]
        ),
        CategorySlot(
            name: "Cloze Test",
            categories: [.clozeTest],
            targetCount: 2,
            targetBands: [.easy, .medium]
        ),
        CategorySlot(
            name: "Paragraf & Yakın Anlam",
            categories: [.dialogueAndRestatement, .irrelevantSentence],
            targetCount: 3,
            targetBands: [.easy, .medium, .hard]
        )
    ]

    public func execute(
        availableQuestions: [SprintQuestion],
        mistakes: [MistakeVaultItem] = [],
        profile: UserStudyProfile? = nil,
        solvedQuestionIds: Set<String> = []
    ) -> [SprintQuestion] {
        guard !availableQuestions.isEmpty else { return [] }

        let weakCategories = Set(
            mistakes.filter { !$0.isResolved }.map(\.category)
            + (profile?.weakestCategories ?? [])
        )
        let weakRuleTags = Set(mistakes.filter { !$0.isResolved }.map(\.grammarRuleTag))
        let preferredTrack = profile?.academicTrack ?? .generalAcademic

        var selectedQuestions: [SprintQuestion] = []
        var usedIds = Set<String>()

        // 1. Her slottan hedeflenen sayıda ve zorluk bandında soru seç
        for slot in slots {
            var slotQuestions: [SprintQuestion] = []

            for band in slot.targetBands {
                if let candidate = pickBestQuestion(
                    from: availableQuestions,
                    categories: slot.categories,
                    band: band,
                    weakCategories: weakCategories,
                    weakRuleTags: weakRuleTags,
                    preferredTrack: preferredTrack,
                    solvedQuestionIds: solvedQuestionIds,
                    excluding: usedIds
                ) {
                    slotQuestions.append(candidate)
                    usedIds.insert(candidate.id)
                }
            }

            // Slot hedefine ulaşılamadıysa aynı kategorilerden serbest bantta tamamla
            while slotQuestions.count < slot.targetCount {
                if let fallback = pickBestQuestion(
                    from: availableQuestions,
                    categories: slot.categories,
                    band: nil,
                    weakCategories: weakCategories,
                    weakRuleTags: weakRuleTags,
                    preferredTrack: preferredTrack,
                    solvedQuestionIds: solvedQuestionIds,
                    excluding: usedIds
                ) {
                    slotQuestions.append(fallback)
                    usedIds.insert(fallback.id)
                } else {
                    break
                }
            }

            selectedQuestions.append(contentsOf: slotQuestions)
        }

        // 2. Havuz kısıtlıysa ve toplam 15'in altındaysa kalan boşlukları genel havuzdan doldur
        while selectedQuestions.count < Self.targetTotalQuestions {
            if let filler = pickBestQuestion(
                from: availableQuestions,
                categories: nil,
                band: nil,
                weakCategories: weakCategories,
                weakRuleTags: weakRuleTags,
                preferredTrack: preferredTrack,
                solvedQuestionIds: solvedQuestionIds,
                excluding: usedIds
            ) {
                selectedQuestions.append(filler)
                usedIds.insert(filler.id)
            } else {
                break
            }
        }

        return Array(selectedQuestions.prefix(Self.targetTotalQuestions))
    }

    private func pickBestQuestion(
        from pool: [SprintQuestion],
        categories: [QuestionCategory]?,
        band: QuestionDifficultyBand?,
        weakCategories: Set<QuestionCategory>,
        weakRuleTags: Set<String>,
        preferredTrack: AcademicTrack,
        solvedQuestionIds: Set<String>,
        excluding: Set<String>
    ) -> SprintQuestion? {
        let matching = pool.filter { q in
            !excluding.contains(q.id)
            && (categories == nil || categories!.contains(q.category))
            && (band == nil || q.difficultyBand == band)
        }

        guard !matching.isEmpty else { return nil }

        // Ağırlıklandırma:
        // - Çözülmemiş soru: +2.0 puan
        // - Zayıf kategori (Mistake Vault / Profil): +3.0 puan
        // - Zayıf kural etiketi: +2.5 puan
        // - Alan uyumu (AcademicTrack): +1.0 puan
        let scored = matching.map { q -> (question: SprintQuestion, score: Double) in
            var score = 1.0
            if !solvedQuestionIds.contains(q.id) {
                score += 2.0
            }
            if weakCategories.contains(q.category) {
                score += 3.0
            }
            let hasWeakTag = q.options.contains { weakRuleTags.contains($0.distractorCoachFeedback.grammarRuleTag) }
            if hasWeakTag {
                score += 2.5
            }
            if preferredTrack != .generalAcademic && q.track == preferredTrack {
                score += 1.0
            }
            return (q, score)
        }

        return scored.max(by: { $0.score < $1.score })?.question
    }
}

// MARK: - 2. EvaluateWeeklyCheckInUseCase
/// 15 soruluk Haftalık Check-In mini denemesini değerlendirir ve canlı puan motoruna kalibre eder
public struct EvaluateWeeklyCheckInUseCase: Sendable {
    private let scoreUseCase: CalculateEstimatedScoreUseCase
    private let entitlementUseCase: CheckEntitlementUseCase

    public init(
        scoreUseCase: CalculateEstimatedScoreUseCase = CalculateEstimatedScoreUseCase(),
        entitlementUseCase: CheckEntitlementUseCase = CheckEntitlementUseCase()
    ) {
        self.scoreUseCase = scoreUseCase
        self.entitlementUseCase = entitlementUseCase
    }

    private enum SlotType: CaseIterable {
        case vocabAndPrep
        case conjAndTense
        case sentenceCompletion
        case translation
        case clozeTest
        case readingAndRestatement

        var examMaxPoints: Double {
            switch self {
            case .vocabAndPrep: return 15.00
            case .conjAndTense: return 20.00
            case .sentenceCompletion: return 12.50
            case .translation: return 10.00
            case .clozeTest: return 12.50
            case .readingAndRestatement: return 30.00
            }
        }

        static func from(category: QuestionCategory) -> SlotType {
            switch category {
            case .academicVocab, .preposition: return .vocabAndPrep
            case .conjunction, .reductionAndTense: return .conjAndTense
            case .sentenceCompletion: return .sentenceCompletion
            case .translation: return .translation
            case .clozeTest: return .clozeTest
            case .dialogueAndRestatement, .irrelevantSentence: return .readingAndRestatement
            }
        }
    }

    /// Kategori gruplarının 80 soruluk gerçek YDS'deki maksimum puan payları (Toplam = 100.00 puan)
    /// - Kelime & Edat (12 soru = 15.00 puan) -> 3 soru (her biri 5.00 puan)
    /// - Bağlaç & Tense (16 soru = 20.00 puan) -> 3 soru (her biri 6.666... puan)
    /// - Cümle Tamamlama (10 soru = 12.50 puan) -> 2 soru (her biri 6.25 puan)
    /// - Çeviri (8 soru = 10.00 puan) -> 2 soru (her biri 5.00 puan)
    /// - Cloze Test (10 soru = 12.50 puan) -> 2 soru (her biri 6.25 puan)
    /// - Paragraf & Yakın Anlam (24 soru = 30.00 puan) -> 3 soru (her biri 10.00 puan)
    public func execute(
        questions: [SprintQuestion],
        answers: [String: String], // questionId -> selectedOptionId (boş bırakılanlar nil/empty)
        elapsedSeconds: Int,
        profile: UserStudyProfile,
        categoryRecords: [CategoryMasteryRecord],
        previousReport: CheckInReport? = nil,
        date: Date = Date()
    ) -> (report: CheckInReport, outcomeResult: ScoreOutcomeResult) {
        let total = questions.count
        guard total > 0 else {
            let emptyReport = CheckInReport(
                scoreBefore: profile.currentEstimatedScore,
                scoreAfter: profile.currentEstimatedScore,
                measuredScore: profile.currentEstimatedScore,
                earnedDelta: 0.0,
                totalQuestions: 0,
                correctCount: 0,
                wrongCount: 0,
                blankCount: 0,
                elapsedSeconds: elapsedSeconds,
                categoryReports: [],
                nextWeekFocusRecommendationTr: "Henüz soru çözülmedi.",
                isPaywallBlurActive: entitlementUseCase.shouldBlurDistractorCoachDetails(tier: profile.subscriptionTier)
            )
            let dummyEvent = ScoreEvent(
                source: .checkIn,
                delta: 0.0,
                scoreBefore: profile.currentEstimatedScore,
                scoreAfter: profile.currentEstimatedScore
            )
            let dummyExplanation = ScoreChangeExplanation(
                deltaPoints: 0.0,
                headlineTr: "Check-In Tamamlanamadı",
                reasonTr: "Soru bulunamadı.",
                nextActionTr: "Yeniden deneyiniz."
            )
            return (emptyReport, ScoreOutcomeResult(
                updatedProfile: profile,
                updatedRecords: categoryRecords,
                earnedDelta: 0.0,
                explanation: dummyExplanation,
                scoreEvent: dummyEvent
            ))
        }

        var correctCount = 0
        var blankCount = 0
        var wrongCount = 0

        // Kategori bazlı istatistikler
        var categoryMap: [QuestionCategory: (total: Int, correct: Int, wrong: Int, blank: Int)] = [:]
        var slotStats: [SlotType: (total: Int, correct: Int)] = [:]

        for q in questions {
            let selected = answers[q.id]?.trimmingCharacters(in: .whitespacesAndNewlines)
            let isBlank = selected == nil || selected!.isEmpty
            let isCorrect = !isBlank && selected == q.correctOptionId

            if isBlank {
                blankCount += 1
            } else if isCorrect {
                correctCount += 1
            } else {
                wrongCount += 1
            }

            var entry = categoryMap[q.category] ?? (total: 0, correct: 0, wrong: 0, blank: 0)
            entry.total += 1
            if isBlank {
                entry.blank += 1
            } else if isCorrect {
                entry.correct += 1
            } else {
                entry.wrong += 1
            }
            categoryMap[q.category] = entry

            let slot = SlotType.from(category: q.category)
            var s = slotStats[slot] ?? (total: 0, correct: 0)
            s.total += 1
            if isCorrect { s.correct += 1 }
            slotStats[slot] = s
        }

        // Ağırlıklı puan hesabı: 6 slot üzerinden tam 100.00 puana orantılama
        var rawMeasuredSum: Double = 0.0
        var availableSlotsMaxPoints: Double = 0.0

        for slot in SlotType.allCases {
            if let stats = slotStats[slot], stats.total > 0 {
                let ratio = Double(stats.correct) / Double(stats.total)
                rawMeasuredSum += ratio * slot.examMaxPoints
                availableSlotsMaxPoints += slot.examMaxPoints
            }
        }

        if availableSlotsMaxPoints > 0 && availableSlotsMaxPoints < 99.9 {
            rawMeasuredSum = (rawMeasuredSum / availableSlotsMaxPoints) * 100.0
        }

        var categoryReports: [CheckInCategoryReport] = []

        for (category, stats) in categoryMap {
            let accuracy = stats.total > 0 ? Double(stats.correct) / Double(stats.total) : 0.0
            let slotWeightRatio = Double(stats.total) / Double(total)
            let allocatedMaxPoints = scoreUseCase.roundToQuarterPoint(slotWeightRatio * 100.0)
            let earnedPoints = scoreUseCase.roundToQuarterPoint(accuracy * allocatedMaxPoints)

            let noteTr: String
            if accuracy >= 0.75 {
                noteTr = "\(category.shortTitleTr) alanında güçlü refleks sergiledin!"
            } else if accuracy >= 0.50 {
                noteTr = "\(category.shortTitleTr) sorularında orta seviyedesin, pratikle hızlanabilirsin."
            } else {
                noteTr = "En çok puan kaçırdığın alan. Önümüzdeki hafta odaklanmalısın!"
            }

            categoryReports.append(CheckInCategoryReport(
                category: category,
                totalQuestions: stats.total,
                correctCount: stats.correct,
                wrongCount: stats.wrong,
                blankCount: stats.blank,
                accuracyRatio: accuracy,
                maxScoreContribution: allocatedMaxPoints,
                earnedScoreContribution: earnedPoints,
                performanceNoteTr: noteTr
            ))
        }

        categoryReports.sort { $0.accuracyRatio < $1.accuracyRatio }

        let clampedMeasured = min(100.0, max(0.0, rawMeasuredSum))
        let measuredScore = scoreUseCase.roundToQuarterPoint(clampedMeasured)

        // Canlı puan kalibrasyonu (%60 ölçülene çekme, güven aralığı daraltma)
        let calibrationResult = scoreUseCase.applyCheckInCalibration(
            measuredScore: measuredScore,
            profile: profile,
            records: categoryRecords,
            date: date
        )

        let calibratedScore = calibrationResult.updatedProfile.currentEstimatedScore
        let scoreDelta = calibrationResult.earnedDelta

        let topDropped = categoryReports.first?.category
        let topImproved = categoryReports.last?.category

        let nextWeekAdviceTr: String
        if let dropped = topDropped {
            nextWeekAdviceTr = "Gelecek hafta \(dropped.titleTr) tuzaklarına odaklanarak tahmini puanına +2.50 puan ekleyebilirsin. Çeldirici Koçundaki kural analizlerini Hata Kumbarasından incele."
        } else {
            nextWeekAdviceTr = "Tüm soru tiplerinde dengeli bir performans gösterdin. Hız refleksini korumak için günlük 15 dakikalık reçeteye devam et."
        }

        let isPaywallBlur = entitlementUseCase.shouldBlurDistractorCoachDetails(tier: profile.subscriptionTier)

        let report = CheckInReport(
            id: UUID().uuidString,
            date: date,
            scoreBefore: profile.currentEstimatedScore,
            scoreAfter: calibratedScore,
            measuredScore: measuredScore,
            earnedDelta: scoreDelta,
            scoreConfidenceMargin: calibrationResult.updatedProfile.scoreConfidenceMargin ?? 1.5,
            totalQuestions: total,
            correctCount: correctCount,
            wrongCount: wrongCount,
            blankCount: blankCount,
            elapsedSeconds: elapsedSeconds,
            categoryReports: categoryReports,
            topImprovedCategory: topImproved,
            topDroppedCategory: topDropped,
            nextWeekFocusRecommendationTr: nextWeekAdviceTr,
            isPaywallBlurActive: isPaywallBlur
        )

        let finalProfile = calibrationResult.updatedProfile.copying(
            lastCheckInDate: .some(date),
            lastCheckInScore: .some(calibratedScore)
        )

        let finalOutcome = ScoreOutcomeResult(
            updatedProfile: finalProfile,
            updatedRecords: calibrationResult.updatedRecords,
            earnedDelta: calibrationResult.earnedDelta,
            explanation: calibrationResult.explanation,
            scoreEvent: calibrationResult.scoreEvent
        )

        return (report, finalOutcome)
    }
}

// MARK: - 3. CheckInEligibilityUseCase
/// Haftalık Check-In uygunluk denetleyicisi
/// Kurallar:
/// - Free kullanıcı: Ayda 1 kez (30 gün aralıkla).
/// - Pro kullanıcı: Sınırsız.
public struct CheckInEligibilityUseCase: Sendable {
    public static let freeCooldownDays: Int = 30

    public init() {}

    public func execute(
        profile: UserStudyProfile,
        lastReportDate: Date? = nil,
        currentDate: Date = Date()
    ) -> CheckInEligibility {
        let isPro = profile.subscriptionTier.isPro
        let lastDate = lastReportDate ?? profile.lastCheckInDate

        if isPro {
            return CheckInEligibility(
                isEligible: true,
                daysUntilNextAvailable: 0,
                nextAvailableDate: nil,
                reasonTr: nil,
                isFreeTier: false,
                lastCheckInDate: lastDate,
                lastCheckInScore: profile.lastCheckInScore
            )
        }

        // Ücretsiz kullanıcı
        guard let last = lastDate else {
            return CheckInEligibility(
                isEligible: true,
                daysUntilNextAvailable: 0,
                nextAvailableDate: nil,
                reasonTr: nil,
                isFreeTier: true,
                lastCheckInDate: nil,
                lastCheckInScore: profile.lastCheckInScore
            )
        }

        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let daysPassed = calendar.dateComponents([.day], from: last, to: currentDate).day ?? 0

        if daysPassed >= Self.freeCooldownDays {
            return CheckInEligibility(
                isEligible: true,
                daysUntilNextAvailable: 0,
                nextAvailableDate: nil,
                reasonTr: nil,
                isFreeTier: true,
                lastCheckInDate: last,
                lastCheckInScore: profile.lastCheckInScore
            )
        } else {
            let remaining = max(1, Self.freeCooldownDays - daysPassed)
            let nextDate = calendar.date(byAdding: .day, value: remaining, to: currentDate)
            let reason = "Ücretsiz planda ayda 1 Check-In yapabilirsin. Yeni denemen \(remaining) gün sonra açılacak. Sınırsız haftalık mini deneme için Pro'ya geç."

            return CheckInEligibility(
                isEligible: false,
                daysUntilNextAvailable: remaining,
                nextAvailableDate: nextDate,
                reasonTr: reason,
                isFreeTier: true,
                lastCheckInDate: last,
                lastCheckInScore: profile.lastCheckInScore
            )
        }
    }
}
