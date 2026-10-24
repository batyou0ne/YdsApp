import Foundation

/// Başlangıç Hata Kumbarası (Mistake Vault) ve Varsayılan Kategori Ustalık Karnesi Seed Verisi
public enum MistakeVaultSeedData {
    public static let initialMistakes: [MistakeVaultItem] = [
        MistakeVaultItem(
            id: "mv-seed-1",
            questionId: "pr-q6",
            stemPreview: "____ strict censorship laws enacted by the regime, underground printing presses continued to circulate...",
            selectedWrongOptionId: "C",
            selectedWrongOptionText: "Although",
            correctOptionId: "B",
            correctOptionText: "Regardless of",
            category: .conjunction,
            track: .socialSciences,
            grammarRuleTag: "CONJ_PARTICIPLE_NP_TRAP",
            grammarRuleTitleTr: "İsim + V3 Kısaltmasını Tam Cümle Sanma Tuzağı",
            praiseTextTr: "Sol (-) sansür ile Sağ (+) bildiri dağıtımı arasındaki zıtlığı harika yakaladın!",
            trapReasonTr: "'laws enacted by the regime' ifadesindeki 'enacted' çekimli yüklem (V2) değil, 'which were enacted' pasif sıfat kısaltmasıdır. Virgüle kadar tam cümle değil İsim Öbeği vardır.",
            winningRuleTr: "İsim + V3 (Participle) bir İsim Öbeğidir -> 'Although' değil, 'Regardless of / Despite' alır!",
            failedCount: 2,
            masteredInReviewCount: 0,
            isResolved: false
        ),
        MistakeVaultItem(
            id: "mv-seed-2",
            questionId: "diag-q2-prep",
            stemPreview: "Coral reef ecosystems are extraordinarily susceptible ____ even minor fluctuations ____ ocean surface temperatures.",
            selectedWrongOptionId: "B",
            selectedWrongOptionText: "against / of",
            correctOptionId: "C",
            correctOptionText: "to / in",
            category: .preposition,
            track: .naturalSciences,
            grammarRuleTag: "PREP_TURKISH_AGAINST_TRAP",
            grammarRuleTitleTr: "Türkçe '-e Karşı' Çevirisiyle 'Against' Seçme Tuzağı",
            praiseTextTr: "Cümleyi Türkçe düşünerek '-e karşı savunmasız' diye anlamlandırdın!",
            trapReasonTr: "Türkçede '-e karşı açık/bağışık' dediğimiz için 'against' çok cazip görünür ama İngilizcede yatkınlık/savunmasızlık sıfatları 'against' almaz.",
            winningRuleTr: "Susceptible TO = Vulnerable TO = Prone TO = Immune TO + Fluctuations IN!",
            failedCount: 1,
            masteredInReviewCount: 0,
            isResolved: false
        ),
        MistakeVaultItem(
            id: "mv-seed-3",
            questionId: "th-q4",
            stemPreview: "Since the human brain consumes nearly twenty percent of the body's metabolic energy, even brief interruptions...",
            selectedWrongOptionId: "A",
            selectedWrongOptionText: "...tükettiğinden beri, beyin kan akışındaki kısa kesintiler...",
            correctOptionId: "D",
            correctOptionText: "...tükettiği için, beyin kan akışındaki kısa süreli kesintiler bile...",
            category: .translation,
            track: .healthSciences,
            grammarRuleTag: "TRANS_SINCE_CAUSE_VS_TIME",
            grammarRuleTitleTr: "Geniş Zamanda 'Since' Bağlacını '-den Beri' Çevirme Tuzağı",
            praiseTextTr: "Ana yüklemi ('sonuçlanır / yol açar') doğru yakaladın!",
            trapReasonTr: "Yan cümlede Simple Present ('consumes') varken cümle başındaki 'Since' zaman ('-den beri') değil, neden ('-dığı için') bildirir.",
            winningRuleTr: "Ana cümlede Have/Has V3 yoksa Since = Because / As (-dığı için)!",
            failedCount: 1,
            masteredInReviewCount: 0,
            isResolved: false
        ),
        MistakeVaultItem(
            id: "mv-seed-4",
            questionId: "diag-q5-red",
            stemPreview: "Artifacts ____ from the Bronze Age shipwreck off the coast of Uluburun ____ unprecedented insight...",
            selectedWrongOptionId: "A",
            selectedWrongOptionText: "recovering / had provided",
            correctOptionId: "E",
            correctOptionText: "recovered / have provided",
            category: .reductionAndTense,
            track: .socialSciences,
            grammarRuleTag: "RED_ACTIVE_VS_PASSIVE_PARTICIPLE",
            grammarRuleTitleTr: "Cansız Özne + Edat Önünde Aktif (V-ing) Kısaltma Tuzağı",
            praiseTextTr: "İlk boşluğun Relative Clause kısaltması olduğunu doğru gördün!",
            trapReasonTr: "Cansız özne ('Artifacts') kendi kendini batıktan çıkarmaz; ayrıca boşluktan hemen sonra nesne değil edat ('from') gelmiş.",
            winningRuleTr: "İsim + Boşluk + Preposition (from/in/by/at) = %95 Pasif V3 Kısaltma ('recovered')!",
            failedCount: 1,
            masteredInReviewCount: 0,
            isResolved: false
        )
    ]

    public static let defaultCategoryMasteries: [CategoryMasteryRecord] = [
        CategoryMasteryRecord(category: .conjunction, currentMasteryRatio: 0.44, targetMasteryRatio: 0.85, questionsSolvedCount: 18, correctAnswersCount: 8),
        CategoryMasteryRecord(category: .preposition, currentMasteryRatio: 0.42, targetMasteryRatio: 0.85, questionsSolvedCount: 14, correctAnswersCount: 6),
        CategoryMasteryRecord(category: .translation, currentMasteryRatio: 0.62, targetMasteryRatio: 0.90, questionsSolvedCount: 16, correctAnswersCount: 10),
        CategoryMasteryRecord(category: .academicVocab, currentMasteryRatio: 0.52, targetMasteryRatio: 0.85, questionsSolvedCount: 15, correctAnswersCount: 8),
        CategoryMasteryRecord(category: .reductionAndTense, currentMasteryRatio: 0.48, targetMasteryRatio: 0.80, questionsSolvedCount: 12, correctAnswersCount: 6),
        CategoryMasteryRecord(category: .sentenceCompletion, currentMasteryRatio: 0.56, targetMasteryRatio: 0.85, questionsSolvedCount: 14, correctAnswersCount: 8),
        CategoryMasteryRecord(category: .irrelevantSentence, currentMasteryRatio: 0.60, targetMasteryRatio: 0.85, questionsSolvedCount: 10, correctAnswersCount: 6),
        CategoryMasteryRecord(category: .clozeTest, currentMasteryRatio: 0.52, targetMasteryRatio: 0.80, questionsSolvedCount: 10, correctAnswersCount: 5),
        CategoryMasteryRecord(category: .dialogueAndRestatement, currentMasteryRatio: 0.56, targetMasteryRatio: 0.80, questionsSolvedCount: 16, correctAnswersCount: 9)
    ]
}
