import Foundation

/// 35 Adet Gerçek YDS / e-YDS / YÖKDİL Sınav Sorusu (5 Seviye Tespit + 30 Mikro-Sprint Sorusu)
/// PEDAGOJİK KURAL: Her şıkta (`A`..`E`) özel `DistractorExplanation` (`praiseTextTr`, `trapReasonTr`, `winningRuleTr`, `grammarRuleTag`) bulunur!
public enum SprintQuestionSeedData {
    public static let allQuestions: [SprintQuestion] =
        diagnosticQuestions +
        translationHuntQuestions +
        polarityRadarQuestions +
        SprintQuestionExtendedSeedData.irrelevantDetectiveQuestions +
        SprintQuestionExtendedSeedData.clozeAndDialogueQuestions

    // MARK: - 1. 5 SORULUK STRATEJİK SEVİYE TESPİTİ (ONBOARDING DIAGNOSTIC)
    public static let diagnosticQuestions: [SprintQuestion] = [
        // Soru 1: Zıtlık Bağlacı (Conjunction)
        SprintQuestion(
            id: "diag-q1-conj",
            category: .conjunction,
            sprintMode: .diagnosticMiniTest,
            track: .healthSciences,
            isDiagnosticOnboarding: true,
            timeLimitSeconds: 35,
            stemText: "____ early-stage pancreatic tumors rarely produce noticeable clinical symptoms, the majority of cases are diagnosed only after metastasis has occurred.",
            highlightedClues: [
                ClueSpan(id: "dq1-c1", matchedSubstring: "rarely produce noticeable clinical symptoms", clueType: .mainVerb, explanationTr: "1. Cümle: Erken evrede belirti üretmemesi (Neden)"),
                ClueSpan(id: "dq1-c2", matchedSubstring: "are diagnosed only after metastasis", clueType: .mainVerb, explanationTr: "2. Cümle: Ancak metastazdan sonra teşhis edilebilmesi (Sonuç)")
            ],
            expectedLeftPolarity: .negative,
            expectedRightPolarity: .negative,
            options: [
                QuestionOption(
                    id: "A",
                    text: "Despite",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Cümle başındaki yapısal bağlantıyı araman güzel bir refleks!",
                        trapReasonTr: "Ancak 'Despite' (-e rağmen) bir edattır ve arkasından sadece İsim Öbeği (Noun Phrase) alır. Boşluktan sonra ise 'tumors rarely produce' şeklinde TAM CÜMLE (Özne + Yüklem) gelmiş.",
                        winningRuleTr: "Tam cümle alan ve 'belirti göstermediği İÇİN geç teşhis edilir' neden-sonuç akışını kuran D şıkkındaki 'Because' seçilmeliydi.",
                        grammarRuleTag: "CONJ_CLAUSE_VS_NP"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "Although",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Boşluktan sonra tam cümle (Özne + Yüklem) geldiğini doğru tespit ettin!",
                        trapReasonTr: "Ancak anlam tuzağına düştün: 'Erken belirti vermemesi' ile 'ancak geç evrede teşhis edilmesi' birbirine ZIT değil, doğrudan NEDEN-SONUÇ (-dığı için) ilişkisidir.",
                        winningRuleTr: "İki eksi (-) durumu neden-sonuç olarak bağlayan D şıkkındaki 'Because' (Since/As) doğru cevaptır.",
                        grammarRuleTag: "CONJ_CAUSE_VS_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "Unless",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Tam cümle alan bir bağlaç seçerek dilbilgisi elenmesini doğru yaptın!",
                        trapReasonTr: "'Unless' (-medikçe) zaten içinde olumsuzluk taşır ve 'rarely' (nadiren) gibi olumsuz zarflarla aynı yan cümlede kullanılmaz.",
                        winningRuleTr: "Neden-sonuç ilişkisi kuran D şıkkındaki 'Because' seçilmeliydi.",
                        grammarRuleTag: "CONJ_UNLESS_DOUBLE_NEGATIVE"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "Because",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Harika! Hem tam cümle yapısını hem de neden-sonuç (-dığı için) mantığını kusursuz yakaladın.",
                        trapReasonTr: "Tuzak olan 'Although' (zıtlık) ve 'Despite' (isim öbeği) şıklarını başarıyla eledin.",
                        winningRuleTr: "Belirti vermemesi (Neden) -> Geç teşhis edilmesi (Sonuç) = Because / Since / As.",
                        grammarRuleTag: "CONJ_CAUSE_EFFECT_MASTERED"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "Owing to",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Cümlenin neden-sonuç (-den dolayı) ilişkisi kurduğunu tam12'den vurdun!",
                        trapReasonTr: "Fakat yapısal tuzağa düştün: 'Owing to / Due to' arkasından sadece İsim Öbeği alır; boşluktan sonra ise 'tumors rarely produce' tam cümlesi var.",
                        winningRuleTr: "Aynı anlamı tam cümleyle veren D şıkkındaki 'Because' seçilmeliydi.",
                        grammarRuleTag: "CONJ_CLAUSE_VS_NP"
                    )
                )
            ],
            correctOptionId: "D"
        ),

        // Soru 2: Akademik Edat (Preposition)
        SprintQuestion(
            id: "diag-q2-prep",
            category: .preposition,
            sprintMode: .diagnosticMiniTest,
            track: .naturalSciences,
            isDiagnosticOnboarding: true,
            timeLimitSeconds: 30,
            stemText: "Coral reef ecosystems are extraordinarily susceptible ____ even minor fluctuations ____ ocean surface temperatures.",
            highlightedClues: [
                ClueSpan(id: "dq2-c1", matchedSubstring: "susceptible", clueType: .prepositionTrigger, explanationTr: "'susceptible / vulnerable / prone' sıfatları her zaman 'TO' edatı ister."),
                ClueSpan(id: "dq2-c2", matchedSubstring: "fluctuations", clueType: .prepositionTrigger, explanationTr: "Bir alandaki dalgalanma/artış/azalış ('fluctuations / surge / decline') 'IN' alır.")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "for / on",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İki boşluklu edat sorusunda her iki tarafı da kontrol etme yaklaşımın doğru!",
                        trapReasonTr: "'Susceptible' sıfatı Türkçeye '-e karşı açık' diye çevrilse de 'for' almaz.",
                        winningRuleTr: "'Susceptible TO' ve 'fluctuations IN' kalıbıyla C şıkkı ('to / in') seçilmeliydi.",
                        grammarRuleTag: "PREP_SUSCEPTIBLE_TO_IN"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "against / of",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İlk boşluğu Türkçe düşünerek '-e karşı savunmasız' diye yorumladın!",
                        trapReasonTr: "En klasik YDS tuzağı! Türkçede '-e karşı' dediğimiz için 'against' çok cazip görünür ama 'susceptible / vulnerable / immune / resistant' kelimeleri İngilizcede 'TO' alır.",
                        winningRuleTr: "'Susceptible TO' + 'fluctuations IN' = C şıkkı ('to / in').",
                        grammarRuleTag: "PREP_TURKISH_AGAINST_TRAP"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "to / in",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Mükemmel! YDS'nin en sık sorduğu iki altın edat kalıbını ('susceptible TO' ve 'fluctuations IN') tek hamlede yakaladın.",
                        trapReasonTr: "Türkçe '-e karşı' çeviri tuzağı olan 'against' şıkkına düşmedin.",
                        winningRuleTr: "Savunmasızlık/Yatkınlık sıfatları -> TO; Artış/Azalış/Dalgalanma isimleri -> IN.",
                        grammarRuleTag: "PREP_SUSCEPTIBLE_TO_IN"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "with / at",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Sıfat+edat uyumunu araman doğru bir strateji.",
                        trapReasonTr: "'With' edatı 'compatible with / consistent with' gibi uyum sıfatlarıyla kullanılır; 'susceptible' ile kullanılmaz.",
                        winningRuleTr: "'Susceptible TO' ve 'fluctuations IN' (C şıkkı) ezber paketine alınmalı.",
                        grammarRuleTag: "PREP_SUSCEPTIBLE_TO_IN"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "from / by",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İkinci boşlukta değişim miktarı olabileceğini düşündün!",
                        trapReasonTr: "'By' edatı artış/azalışlarda sadece rakam/yüzde ('by 15%') varsa kullanılır; alan belirtirken ('in ocean temperatures') 'IN' kullanılır.",
                        winningRuleTr: "'Susceptible TO' + 'fluctuations IN' (C şıkkı) doğru cevaptır.",
                        grammarRuleTag: "PREP_INCREASE_IN_VS_BY"
                    )
                )
            ],
            correctOptionId: "C"
        ),

        // Soru 3: Çeviri Eklemi (Translation)
        SprintQuestion(
            id: "diag-q3-trans",
            category: .translation,
            sprintMode: .diagnosticMiniTest,
            track: .socialSciences,
            isDiagnosticOnboarding: true,
            timeLimitSeconds: 25,
            stemText: "While digital archives have democratized access to historical manuscripts, historians warn that the context of physical artifacts cannot be fully replicated online.",
            highlightedClues: [
                ClueSpan(id: "dq3-c1", matchedSubstring: "While", clueType: .conjunction, explanationTr: "Cümle başı zıtlık eklemi: '-iken / -e karşın / -se de'"),
                ClueSpan(id: "dq3-c2", matchedSubstring: "historians warn that", clueType: .mainVerb, explanationTr: "Ana Özne + Ana Yüklem: 'tarihçiler ... konusunda uyarmaktadır'")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "Dijital arşivler tarihi el yazmalarına erişimi demokratikleştirirken, tarihçiler fiziksel eserlerin bağlamının çevrimiçi ortamda tam olarak kopyalanamayacağı konusunda uyarmaktadır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Tam isabet! Sadece 'While' (-iken) eklemini ve 'historians warn that' (tarihçiler ... uyarmaktadır) ana yüklemini eşleştirerek 5 saniyede çözdün!",
                        trapReasonTr: "Diğer şıklardaki yüklem kaydırma tuzaklarına hiç takılmadın.",
                        winningRuleTr: "Çeviri Avı Kuralı: Ana Özne (tarihçiler) + Ana Yüklem (uyarmaktadır) + Bağlaç (-iken).",
                        grammarRuleTag: "TRANS_MAIN_VERB_AND_CONJ"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "Tarihçilerin fiziksel eserlerin bağlamının çevrimiçi ortamda kopyalanamayacağı konusunda uyarmasının nedeni, dijital arşivlerin tarihi el yazmalarına erişimi demokratikleştirmesidir.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Cümledeki tüm kelimelerin Türkçe karşılıklarını doğru takip ettin!",
                        trapReasonTr: "Ancak ANA YÜKLEM tuzağına düştün! İngilizce cümlenin ana yüklemi 'warn' (uyarmaktadır) iken bu şık '... demokratikleştirmesidir' diye bitiyor ve 'nedeni' diyerek olmayan bir 'because' uyduruyor.",
                        winningRuleTr: "Türkçe çeviride cümlenin en sonundaki kelime İngilizce ana yüklem ('warn' = uyarmaktadır) olmak zorundadır (A şıkkı).",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "Dijital arşivler tarihi el yazmalarına erişimi demokratikleştirdiği için tarihçiler fiziksel eserlerin bağlamının çevrimiçi kopyalanamayacağını savunmaktadır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Ana özne olan 'tarihçiler'i doğru yerde yakaladın!",
                        trapReasonTr: "Bağlaç tuzağı! Cümle başındaki 'While' zıtlık (-iken / -se de) bildirir; '-dığı için' (Because/Since) diye çevrilemez. Ayrıca 'warn' = 'uyarmaktadır', 'savunmaktadır' değil.",
                        winningRuleTr: "'While' = '-iken' ve 'warn' = 'uyarmaktadır' eşleşmesiyle A şıkkı seçilmeliydi.",
                        grammarRuleTag: "TRANS_CONJUNCTION_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "Fiziksel eserlerin bağlamı çevrimiçi ortamda tam olarak kopyalanamasa da, dijital arşivler tarihi el yazmalarına erişimi demokratikleştirmeyi başarmıştır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Cümlede zıtlık bağlacı olduğunu doğru yakaladın!",
                        trapReasonTr: "Ancak yan cümle ile ana cümleyi ters yüz eden tuzağa düştün! 'While' dijital arşivler cümlesinin başındadır ve 'tarihçiler uyarmaktadır' kısmı tamamen yutulmuş.",
                        winningRuleTr: "Ana yüklemi 'uyarmaktadır' olan A şıkkı doğrudan işaretlenmeliydi.",
                        grammarRuleTag: "TRANS_CLAUSE_INVERSION_TRAP"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "Dijital arşivlerin tarihi el yazmalarına erişimi demokratikleştirmesi, tarihçileri fiziksel eserlerin bağlamının çevrimiçi kopyalanamayacağı konusunda uyarmıştır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Yüklemin 'uyarmak' fiili olduğunu doğru gördün!",
                        trapReasonTr: "Özne tuzağı! İngilizce cümlede uyaran kişi 'historians' (tarihçiler) iken, bu şıkta 'tarihçileri uyarmıştır' denilerek özne nesneye dönüştürülmüş.",
                        winningRuleTr: "'Tarihçiler ... uyarmaktadır' diyen A şıkkı doğru cevaptır.",
                        grammarRuleTag: "TRANS_SUBJECT_OBJECT_SWAP"
                    )
                )
            ],
            correctOptionId: "A"
        ),

        // Soru 4: Akademik Kelime (Academic Vocab)
        SprintQuestion(
            id: "diag-q4-vocab",
            category: .academicVocab,
            sprintMode: .diagnosticMiniTest,
            track: .healthSciences,
            isDiagnosticOnboarding: true,
            timeLimitSeconds: 30,
            stemText: "Although the new analgesic drug effectively ____ acute postoperative pain, its potential to cause hepatic toxicity limits its long-term prescription.",
            highlightedClues: [
                ClueSpan(id: "dq4-c1", matchedSubstring: "Although", clueType: .conjunction, explanationTr: "Zıtlık bağlacı: İkinci kısım olumsuz ('toxicity limits' -) olduğu için boşluk olumlu (+) olmalı!"),
                ClueSpan(id: "dq4-c2", matchedSubstring: "acute postoperative pain", clueType: .mainVerb, explanationTr: "Ağrıyı olumlu yönde 'hafifletmek / dindirmek' anlamına gelen fiil aranıyor.")
            ],
            expectedLeftPolarity: .positive,
            expectedRightPolarity: .negative,
            options: [
                QuestionOption(
                    id: "A",
                    text: "exacerbates",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "'Pain' (ağrı) kelimesiyle çok sık kullanılan akademik bir fiil seçtin!",
                        trapReasonTr: "Ancak kutup tuzağına düştün! Cümle 'Although' (zıtlık) ile başlıyor ve ikinci kısım olumsuz ('karaciğer toksisitesi kullanımını kısıtlıyor' -). İlk kısım olumlu (+) olmak zorunda! 'Exacerbate' ise ağrıyı 'şiddetlendirmek/kötüleştirmek' (-) demektir.",
                        winningRuleTr: "Ağrıyı 'hafifletmek/dindirmek' (+) anlamına gelen B şıkkındaki 'alleviates' (= mitigates/relieves) seçilmeliydi.",
                        grammarRuleTag: "VOCAB_POLARITY_REVERSAL_TRAP"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "alleviates",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Muhteşem! 'Although' zıtlığından boşluğun (+) olumlu olması gerektiğini buldun ve 'alleviate pain' (ağrıyı hafifletmek) eşleşmesini vurdun!",
                        trapReasonTr: "Zıt anlamlı tuzak şık olan 'exacerbates' (kötüleştirir) çeldiricisine düşmedin.",
                        winningRuleTr: "Alleviate = Mitigate = Relieve (Ağrıyı/sorunu hafifletmek +).",
                        grammarRuleTag: "VOCAB_ALLEVIATE_MASTERED"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "jeopardizes",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "YDS'nin üst düzey akademik fiillerinden birini tanıdın!",
                        trapReasonTr: "'Jeopardize' (tehlikeye atmak = endanger) olumsuz (-) bir fiildir ve 'ağrıyı tehlikeye atmak' şeklinde kullanılmaz.",
                        winningRuleTr: "'Effectively alleviates pain' (ağrıyı etkili biçimde hafifletir) diyen B şıkkı doğrudur.",
                        grammarRuleTag: "VOCAB_COLLOCATION_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "triggers",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "'Trigger pain' (ağrıyı tetiklemek) eşleşmesini doğru hatırladın!",
                        trapReasonTr: "Fakat cümledeki 'Although' ve 'effectively' (etkili bir şekilde) kelimelerine dikkat: Ağrı kesici ('analgesic') bir ilacın olumlu özelliği ağrıyı tetiklemek değil, dindirmektir.",
                        winningRuleTr: "Olumlu (+) anlam veren B şıkkındaki 'alleviates' seçilmeliydi.",
                        grammarRuleTag: "VOCAB_POLARITY_REVERSAL_TRAP"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "depletes",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "'Azaltmak/tüketmek' ekseninde bir fiil araman mantıklı!",
                        trapReasonTr: "'Deplete' doğal kaynakları, enerjiyi veya vitamin rezervlerini 'tüketip bitirmek' için kullanılır; ağrı ('pain') için kullanılmaz.",
                        winningRuleTr: "Semptom ve ağrıyı azaltmak/hafifletmek için B şıkkındaki 'alleviates' kullanılır.",
                        grammarRuleTag: "VOCAB_COLLOCATION_MISMATCH"
                    )
                )
            ],
            correctOptionId: "B"
        ),

        // Soru 5: Kısaltma & Tense (Reduction & Tense)
        SprintQuestion(
            id: "diag-q5-red",
            category: .reductionAndTense,
            sprintMode: .diagnosticMiniTest,
            track: .socialSciences,
            isDiagnosticOnboarding: true,
            timeLimitSeconds: 35,
            stemText: "Artifacts ____ from the Bronze Age shipwreck off the coast of Uluburun ____ unprecedented insight into ancient Mediterranean trade routes.",
            highlightedClues: [
                ClueSpan(id: "dq5-c1", matchedSubstring: "Artifacts ____ from", clueType: .mainVerb, explanationTr: "İsimden sonra gelen edilgen kısaltma: 'batıktan çıkarılan eserler' (which were recovered -> recovered V3)"),
                ClueSpan(id: "dq5-c2", matchedSubstring: "insight into", clueType: .prepositionTrigger, explanationTr: "Eserlerin günümüzde arkeologlara genel/kalıcı bilgi sağlaması (have provided / provide)")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "recovering / had provided",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İlk boşluğun bir sıfat cümleciği kısaltması olduğunu doğru gördün!",
                        trapReasonTr: "Ancak Aktif/Pasif tuzağına düştün: Eserler ('Artifacts') kendi kendini çıkarmaz, batıktan 'çıkarılır' (Edilgen = V3 'recovered'). Ayrıca cümlede Past Perfect ('had V3') gerektirecek geçmişte ikinci bir olay yok.",
                        winningRuleTr: "Pasif kısaltma 'recovered' (V3) + günümüze uzanan etki 'have provided' = E şıkkı.",
                        grammarRuleTag: "RED_ACTIVE_VS_PASSIVE_PARTICIPLE"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "to recover / provided",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İkinci boşlukta geçmiş zaman olabileceğini düşündün!",
                        trapReasonTr: "İlk boşlukta 'the first, the only, the best' veya amaç anlamı olmadığı için 'to recover' kullanılmaz; 'batıktan çıkarılan eserler' edilgen kısaltmadır.",
                        winningRuleTr: "'which were recovered' kısaltması olan V3 ('recovered') ile E şıkkı seçilmeliydi.",
                        grammarRuleTag: "RED_TO_INFINITIVE_TRAP"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "having recovered / will provide",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Öncelik-sonralık kısaltmasını ('having...') tanıdın!",
                        trapReasonTr: "'Having V3' AKTİF bir kısaltmadır; cansız özne olan 'Artifacts' (eserler) nesne almadan aktif fiil yapamaz ('having been recovered' olmalıydı).",
                        winningRuleTr: "Edilgen V3 kısaltması olan E şıkkındaki 'recovered / have provided' doğrudur.",
                        grammarRuleTag: "RED_ACTIVE_VS_PASSIVE_PARTICIPLE"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "being recovered / would provide",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İlk boşluğun pasif (edilgen) olması gerektiğini harika yakaladın!",
                        trapReasonTr: "'Being V3' sadece 'şu an çıkarılmakta olan' anlık süreçlerde kullanılır ve ikinci taraftaki 'would provide' koşul veya geçmişin geleceği olmadan tek başına ana yüklem olamaz.",
                        winningRuleTr: "Yalın pasif kısaltma 'recovered' + Present Perfect 'have provided' (E şıkkı) seçilmeliydi.",
                        grammarRuleTag: "RED_BEING_V3_VS_V3"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "recovered / have provided",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Kusursuz! İlk boşlukta 'which were recovered' -> 'recovered' (V3 pasif kısaltma) ve ikinci boşlukta 'have provided' ana yüklemini tam isabetle buldun!",
                        trapReasonTr: "Aktif 'recovering' ve 'had V3' tuzaklarını başarıyla eledin.",
                        winningRuleTr: "Cansız İsim + Boşluk + Edat ('Artifacts ___ from') = %95 Pasif V3 Kısaltma!",
                        grammarRuleTag: "RED_PASSIVE_V3_MASTERED"
                    )
                )
            ],
            correctOptionId: "E"
        )
    ]

    // MARK: - 2. 10 SANİYEDE ÇEVİRİ AVI SORULARI (TRANSLATION 10-SEC HUNT - 8 Adet)
    public static let translationHuntQuestions: [SprintQuestion] = [
        SprintQuestion(
            id: "th-q1",
            category: .translation,
            sprintMode: .translation10SecHunt,
            track: .healthSciences,
            timeLimitSeconds: 10,
            stemText: "Although genetic predisposition plays a significant role in autoimmune diseases, environmental triggers determine when the clinical symptoms actually emerge.",
            highlightedClues: [
                ClueSpan(id: "th1-c1", matchedSubstring: "Although", clueType: .conjunction, explanationTr: "Bağlaç Eklemi: '-se de / -e rağmen'"),
                ClueSpan(id: "th1-c2", matchedSubstring: "environmental triggers determine", clueType: .mainVerb, explanationTr: "Ana Özne + Yüklem: 'çevresel tetikleyiciler ... belirler'")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "Genetik yatkınlık otoimmün hastalıklarda önemli bir rol oynadığı için çevresel tetikleyiciler klinik semptomların ne zaman ortaya çıkacağını belirler.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Ana yüklemi ('belirler') doğru yakaladın!",
                        trapReasonTr: "Ancak bağlaç tuzağına düştün: 'Although' (-se de) yerine '-dığı için' (Because) çevirisi yapılmış.",
                        winningRuleTr: "Hem '-se de' bağlacını hem de 'belirler' ana yüklemini içeren B şıkkı seçilmeliydi.",
                        grammarRuleTag: "TRANS_CONJUNCTION_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "Genetik yatkınlık otoimmün hastalıklarda önemli bir rol oynasa da, klinik semptomların gerçekte ne zaman ortaya çıkacağını çevresel tetikleyiciler belirler.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "10 Saniye Çeviri Avı refleksi! 'Although' (-sa da) + 'determine' (belirler) ikilisinden şıkkı anında vurdun!",
                        trapReasonTr: "Yüklemi 'ortaya çıkar' veya 'rol oynar' olan çeldiricileri saniyesinde eledin.",
                        winningRuleTr: "Although = -sa da + determine = belirler.",
                        grammarRuleTag: "TRANS_MAIN_VERB_AND_CONJ"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "Çevresel tetikleyiciler klinik semptomların ne zaman ortaya çıkacağını belirlese de, otoimmün hastalıklarda asıl önemli rolü genetik yatkınlık oynar.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "'-se de' bağlacını araman doğruydu!",
                        trapReasonTr: "Yan cümle ile ana cümle yer değiştirmiş! İngilizcede 'Although' genetik yatkınlık cümlesindedir ve ana yüklem 'oynar' değil 'belirler'dir.",
                        winningRuleTr: "Cümlenin en sonu 'belirler' ile biten B şıkkı doğrudur.",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "Otoimmün hastalıklarda önemli bir rol oynayan genetik yatkınlığa rağmen, klinik semptomlar çevresel tetikleyiciler tarafından belirlenir.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Zıtlık anlamını doğru korudun!",
                        trapReasonTr: "İngilizce ana yüklem aktif ('determine' = belirler) iken bu şıkta pasif ('tarafından belirlenir') yapılmış.",
                        winningRuleTr: "Aktif yüklemli B şıkkı ('çevresel tetikleyiciler belirler') seçilmeliydi.",
                        grammarRuleTag: "TRANS_ACTIVE_PASSIVE_TRAP"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "Genetik yatkınlık otoimmün hastalıklarda önemli bir rol oynarken, klinik semptomların ortaya çıkışı çevresel tetikleyicilere bağlıdır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İki cümle arasındaki karşılaştırmayı yakaladın!",
                        trapReasonTr: "Ana yüklem olan 'determine' (belirler) fiili 'bağlıdır' (depend on) şeklinde değiştirilmiş.",
                        winningRuleTr: "Yüklemi 'belirler' olan B şıkkı doğru cevaptır.",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                )
            ],
            correctOptionId: "B"
        ),
        SprintQuestion(
            id: "th-q2",
            category: .translation,
            sprintMode: .translation10SecHunt,
            track: .naturalSciences,
            timeLimitSeconds: 10,
            stemText: "Unless global carbon emissions are halved within the next decade, irreversible melting of polar ice sheets will accelerate coastal flooding worldwide.",
            highlightedClues: [
                ClueSpan(id: "th2-c1", matchedSubstring: "Unless", clueType: .conjunction, explanationTr: "Koşul Eklemi: '-medikçe / -madıkça'"),
                ClueSpan(id: "th2-c2", matchedSubstring: "will accelerate", clueType: .mainVerb, explanationTr: "Ana Yüklem: 'hızlandıracaktır'")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "Küresel karbon emisyonları önümüzdeki on yıl içinde yarıya indirilmedikçe, kutup buz tabakalarının geri döndürülemez erimesi dünya çapında kıyı taşkınlarını hızlandıracaktır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Süper hız! 'Unless' (-medikçe) + 'will accelerate' (hızlandıracaktır) ipuçlarıyla 10 saniyenin altında çözdün!",
                        trapReasonTr: "Diğer şıklardaki bağlaç ve yüklem tuzaklarını anında eledin.",
                        winningRuleTr: "Unless = -medikçe / -madıkça + will accelerate = hızlandıracaktır.",
                        grammarRuleTag: "TRANS_MAIN_VERB_AND_CONJ"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "Küresel karbon emisyonları önümüzdeki on yılda yarıya indirilmezse bile, kutup buz tabakalarının erimesi kıyı taşkınlarını hızlandırmaya devam edecektir.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Olumsuz koşul yapısını fark ettin!",
                        trapReasonTr: "'Unless' (-medikçe) yerine '-se bile' (Even if) çevirisi yapılmış ve yükleme cümlede olmayan 'devam edecektir' eklenmiş.",
                        winningRuleTr: "'Yarıya indirilmedikçe ... hızlandıracaktır' diyen A şıkkı doğrudur.",
                        grammarRuleTag: "TRANS_CONJUNCTION_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "Kutup buz tabakalarının geri döndürülemez erimesinin kıyı taşkınlarını hızlandırmaması için küresel karbon emisyonlarının on yıl içinde yarıya indirilmesi gerekir.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Cümlenin genel mesajını doğru anladın!",
                        trapReasonTr: "Ancak çeviri sorularında yorum değil, 1:1 yapısal eşleşme aranır! Cümlede 'için ... gerekir' yok; ana yüklem 'hızlandıracaktır'dır.",
                        winningRuleTr: "Sonu 'hızlandıracaktır' ile biten A şıkkı seçilmeliydi.",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "Küresel karbon emisyonları on yıl içinde yarıya indirildiğinde, kutup buz tabakalarının erimesi ve kıyı taşkınları yavaşlayacaktır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Zaman/koşul yan cümlesini takip ettin!",
                        trapReasonTr: "Cümle tamamen tersine çevrilmiş: 'Unless' (-medikçe) yerine '-dığında' ve 'accelerate' (hızlandıracaktır) yerine 'yavaşlayacaktır' yazılmış.",
                        winningRuleTr: "'Unless' = -medikçe ve 'will accelerate' = hızlandıracaktır (A şıkkı).",
                        grammarRuleTag: "TRANS_CONJUNCTION_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "Küresel karbon emisyonlarının yarıya indirilmemesi, önümüzdeki on yılda kutup buz tabakalarını eriterek kıyı taşkınlarını hızlandıracaktır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Ana yüklemi ('hızlandıracaktır') doğru yakaladın!",
                        trapReasonTr: "Fakat 'Unless' bağlaçlı yan cümle yutulup isimleştirilmiş ve ana özne olan 'kutup buz tabakalarının erimesi' zarf-fiile ('eriterek') dönüştürülmüş.",
                        winningRuleTr: "'Unless' eklemini '-medikçe' olarak koruyan A şıkkı doğrudur.",
                        grammarRuleTag: "TRANS_CLAUSE_INVERSION_TRAP"
                    )
                )
            ],
            correctOptionId: "A"
        ),
        SprintQuestion(
            id: "th-q3",
            category: .translation,
            sprintMode: .translation10SecHunt,
            track: .socialSciences,
            timeLimitSeconds: 10,
            stemText: "Not only did the Industrial Revolution transform rural agrarian societies into urban centers, but it also fundamentally altered family structures.",
            highlightedClues: [
                ClueSpan(id: "th3-c1", matchedSubstring: "Not only did ... transform", clueType: .conjunction, explanationTr: "Devrik Bağlaç: 'Yalnızca dönüştürmekle kalmamış'"),
                ClueSpan(id: "th3-c2", matchedSubstring: "but it also fundamentally altered", clueType: .mainVerb, explanationTr: "Ana Eylem: 'aynı zamanda ... kökten değiştirmiştir'")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "Sanayi Devrimi kırsal tarım toplumlarını kent merkezlerine dönüştürürken aile yapılarını da kökten değiştirmiştir.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Son yüklemi ('değiştirmiştir') doğru yakaladın!",
                        trapReasonTr: "Ancak cümle başındaki vurgulu 'Not only ... but also' (yalnızca ... kalmamış, aynı zamanda ...) kalıbı '-iken' diye basitleştirilmiş.",
                        winningRuleTr: "'Not only ... but also' kalıbını eksiksiz veren C şıkkı seçilmeliydi.",
                        grammarRuleTag: "TRANS_CONJUNCTION_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "Aile yapılarını kökten değiştiren Sanayi Devrimi, kırsal tarım toplumlarını da kent merkezlerine dönüştürmüştür.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Cümledeki iki eylemi de fark ettin!",
                        trapReasonTr: "Birinci ve ikinci cümle yer değiştirmiş; üstelik 'Not only ... but also' bağlacı tamamen atılmış.",
                        winningRuleTr: "C şıkkındaki 'yalnızca dönüştürmekle kalmamış, aynı zamanda ... değiştirmiştir' yapısı doğrudur.",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "Sanayi Devrimi kırsal tarım toplumlarını kent merkezlerine dönüştürmekle kalmamış, aynı zamanda aile yapılarını da kökten değiştirmiştir.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Harika! 'Not only ... but also' (...-mekle kalmamış, aynı zamanda ...) ve 'altered' (değiştirmiştir) ikilisini saniyesinde eşleştirdin!",
                        trapReasonTr: "Cümle başındaki 'did' devrik (inversion) yapısının soru değil vurgu olduğunu çok iyi bildin.",
                        winningRuleTr: "Not only ... but also = Yalnızca ...-mekle kalmayıp aynı zamanda ...",
                        grammarRuleTag: "TRANS_MAIN_VERB_AND_CONJ"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "Sanayi Devrimi hem kırsal tarım toplumlarını kent merkezlerine dönüştürmüş hem de aile yapılarının değişmesine neden olmuştur.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Paralel bağlaç yapısını yakın yakaladın!",
                        trapReasonTr: "'Hem ... hem de' ('both ... and') çeldiricisinin yanı sıra, son yüklem 'değiştirmiştir' ('altered') yerine 'değişmesine neden olmuştur' ('caused to change') yapılmış.",
                        winningRuleTr: "Doğrudan 'kökten değiştirmiştir' diye biten C şıkkı seçilmeliydi.",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "Kırsal tarım toplumlarını kent merkezlerine dönüştüren Sanayi Devrimi, aile yapılarını bile kökten değiştirmeyi başarmıştır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Özne olan Sanayi Devrimi'ni doğru takip ettin!",
                        trapReasonTr: "'Not only' yapısı sıfat-fiile ('dönüştüren') çevrilmiş ve cümlede 'başarmıştır' ('managed to') fiili yok.",
                        winningRuleTr: "C şıkkı hem bağlacı hem de yüklemi birebir karşılar.",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                )
            ],
            correctOptionId: "C"
        ),
        SprintQuestion(
            id: "th-q4",
            category: .translation,
            sprintMode: .translation10SecHunt,
            track: .healthSciences,
            timeLimitSeconds: 10,
            stemText: "Since the human brain consumes nearly twenty percent of the body's metabolic energy, even brief interruptions in cerebral blood flow result in irreversible neuronal loss.",
            highlightedClues: [
                ClueSpan(id: "th4-c1", matchedSubstring: "Since", clueType: .conjunction, explanationTr: "Neden Bağlacı: '-dığı için'"),
                ClueSpan(id: "th4-c2", matchedSubstring: "result in", clueType: .mainVerb, explanationTr: "Ana Yüklem: '-e yol açar / -ile sonuçlanır'")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "İnsan beyni vücudun metabolik enerjisinin yaklaşık yüzde yirmisini tükettiğinden beri, beyin kan akışındaki kısa kesintiler kalıcı nöron kaybına yol açmaktadır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Ana yüklemi ('yol açmaktadır') doğru yakaladın!",
                        trapReasonTr: "KLASİK YDS TUZAĞI! Yan cümlede geniş zaman ('consumes') varken cümle başındaki 'Since' asla '-den beri' diye çevrilmez; '-dığı için' (Because) demektir!",
                        winningRuleTr: "'Tükettiği için ... sonuçlanır/yol açar' diyen D şıkkı doğrudur.",
                        grammarRuleTag: "TRANS_SINCE_CAUSE_VS_TIME"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "Beyin kan akışındaki kısa kesintilerin geri döndürülemez nöron kaybıyla sonuçlanmasının sebebi, insan beyninin metabolik enerjinin yüzde yirmisini tüketmesidir.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Cümledeki neden-sonuç ilişkisini doğru gördün!",
                        trapReasonTr: "Ancak ana yüklem olan 'result in' (sonuçlanır) cümlenin ortasına çekilmiş ve sonu '... tüketmesidir' diye bitirilmiş.",
                        winningRuleTr: "Sonu 'sonuçlanır' ile biten D şıkkı seçilmeliydi.",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "İnsan beyni vücudun metabolik enerjisinin neredeyse yüzde yirmisini tüketse de, beyin kan akışındaki kısa kesintiler nöron kaybıyla sonuçlanır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Ana yüklemi ('sonuçlanır') doğru tespit ettin!",
                        trapReasonTr: "Bağlaç tuzağı: 'Since' (-dığı için) yerine '-se de' (Although) zıtlık eki kullanılmış.",
                        winningRuleTr: "'Since' = '-dığı için' olan D şıkkı doğru cevaptır.",
                        grammarRuleTag: "TRANS_CONJUNCTION_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "İnsan beyni vücudun metabolik enerjisinin neredeyse yüzde yirmisini tükettiği için, beyin kan akışındaki kısa süreli kesintiler bile geri döndürülemez nöron kaybıyla sonuçlanır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Mükemmel! 'Since' (-dığı için), 'even' (bile) ve 'result in' (sonuçlanır) üçlüsünü 10 saniyede eksiksiz vurdun!",
                        trapReasonTr: "A şıkkındaki '-den beri' tuzağına hiç düşmedin.",
                        winningRuleTr: "Geniş zamanda cümle başı Since = -dığı için + result in = -ile sonuçlanır.",
                        grammarRuleTag: "TRANS_MAIN_VERB_AND_CONJ"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "Vücudun metabolik enerjisinin yüzde yirmisini tüketen insan beyninde, kan akışındaki kısa kesintiler bile kalıcı nöron kaybına neden olur.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Yüklemi yakın yakaladın!",
                        trapReasonTr: "'Since' bağlaçlı yan cümle yutulup sıfat-fiile ('tüketen insan beyninde') dönüştürülmüş.",
                        winningRuleTr: "'Tükettiği için' yan cümlesini koruyan D şıkkı seçilmeliydi.",
                        grammarRuleTag: "TRANS_CLAUSE_INVERSION_TRAP"
                    )
                )
            ],
            correctOptionId: "D"
        ),
        SprintQuestion(
            id: "th-q5",
            category: .translation,
            sprintMode: .translation10SecHunt,
            track: .naturalSciences,
            timeLimitSeconds: 10,
            stemText: "So sensitive are gravitational wave detectors that they can measure spatial distortions smaller than the width of a single proton.",
            highlightedClues: [
                ClueSpan(id: "th5-c1", matchedSubstring: "So sensitive are ... that", clueType: .conjunction, explanationTr: "Devrik Bağlaç: 'O kadar hassastır ki'"),
                ClueSpan(id: "th5-c2", matchedSubstring: "they can measure", clueType: .mainVerb, explanationTr: "Sonuç Yüklemi: 'ölçebilirler'")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "Kütleçekim dalgası dedektörleri tek bir protonun genişliğinden daha küçük uzamsal bükülmeleri ölçebilecek kadar hassastır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Anlamca çok yakın bir şık seçtin!",
                        trapReasonTr: "Bu şık 'sensitive enough to measure' kalıbının çevirisidir; oysa soru kökünde 'So sensitive ... that they can measure' (o kadar hassastır ki ... ölçebilirler) yapısı var.",
                        winningRuleTr: "'O kadar hassastır ki ... ölçebilirler' diyen E şıkkı seçilmeliydi.",
                        grammarRuleTag: "TRANS_SO_THAT_VS_ENOUGH"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "Tek bir protonun genişliğinden daha küçük uzamsal bükülmeleri ölçebilen kütleçekim dalgası dedektörleri son derece hassastır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Kelimeleri doğru eşleştirdin!",
                        trapReasonTr: "'So ... that' neden-sonuç eklemi tamamen atılmış ve yüklem 'hassastır' yapılmış.",
                        winningRuleTr: "Sonu 'ölçebilirler' ile biten E şıkkı doğrudur.",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "Kütleçekim dalgası dedektörleri çok hassas olduğu için tek bir protondan bile küçük uzamsal bükülmeleri ölçmektedir.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Neden-sonuç akışını doğru hissettin!",
                        trapReasonTr: "'So ... that' yerine '-dığı için' kullanılmış ve 'can measure' (ölçebilir) modal'ı 'ölçmektedir' diye çevrilmiş.",
                        winningRuleTr: "'O kadar hassastır ki ... ölçebilirler' diyen E şıkkı doğrudur.",
                        grammarRuleTag: "TRANS_CONJUNCTION_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "Kütleçekim dalgası dedektörlerinin bu kadar hassas olması, tek bir proton genişliğinden küçük bükülmeleri ölçmelerini sağlar.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Vurguyu fark ettin!",
                        trapReasonTr: "Cümlede 'sağlar' (enables) fiili yok; yüklem doğrudan 'can measure' (ölçebilirler) olmalıydı.",
                        winningRuleTr: "E şıkkı hem 'o kadar ... ki' kalıbını hem de 'ölçebilirler' yüklemini birebir verir.",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "Kütleçekim dalgası dedektörleri o kadar hassastır ki tek bir protonun genişliğinden daha küçük uzamsal bükülmeleri ölçebilirler.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Tam isabet! Cümle başındaki devrik 'So sensitive are ... that' yapısını 'o kadar hassastır ki ... ölçebilirler' olarak 10 saniyede çözdün!",
                        trapReasonTr: "'Enough to' tuzağı olan A şıkkına düşmedin.",
                        winningRuleTr: "So + adj + be + Subject + that = O kadar ...-dır ki ...",
                        grammarRuleTag: "TRANS_MAIN_VERB_AND_CONJ"
                    )
                )
            ],
            correctOptionId: "E"
        ),
        SprintQuestion(
            id: "th-q6",
            category: .translation,
            sprintMode: .translation10SecHunt,
            track: .socialSciences,
            timeLimitSeconds: 10,
            stemText: "Much as ancient empires relied on military coercion to expand their borders, long-term stability always required administrative integration and local trade.",
            highlightedClues: [
                ClueSpan(id: "th6-c1", matchedSubstring: "Much as", clueType: .conjunction, explanationTr: "Zıtlık Bağlacı: 'Her ne kadar ... -se de / -e rağmen'"),
                ClueSpan(id: "th6-c2", matchedSubstring: "required", clueType: .mainVerb, explanationTr: "Ana Yüklem: 'gerektirmiştir / gerektiriyordu'")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "Antik imparatorluklar sınırlarını genişletmek için askeri baskıya ne kadar güvenirse güvensin, uzun vadeli istikrar idari bütünleşmeye bağlıydı.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Zıtlık tonunu yakaladın!",
                        trapReasonTr: "Ana yüklem 'required' (gerektirmiştir) iken bu şıkta 'bağlıydı' (depended on) denilmiş ve 'local trade' kısmı yutulmuş.",
                        winningRuleTr: "Yüklemi 'gerektirmiştir' olan B şıkkı doğrudur.",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "Antik imparatorluklar sınırlarını genişletmek için askeri baskıya dayanmış olsa da, uzun vadeli istikrar her zaman idari bütünleşmeyi ve yerel ticareti gerektirmiştir.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Usta işi! Cümle başındaki 'Much as' bağlacının 'Although' (-mış olsa da) demek olduğunu ve 'required' (gerektirmiştir) ana yüklemini anında yakaladın!",
                        trapReasonTr: "'Much as'ı miktar/benzerlik sanan C şıkkı tuzağını eledin.",
                        winningRuleTr: "Cümle başı Much as = Although / Even though (-se de).",
                        grammarRuleTag: "TRANS_MAIN_VERB_AND_CONJ"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "Antik imparatorlukların sınırlarını genişletmek için askeri baskıya dayandığı kadar, uzun vadeli istikrar da idari bütünleşmeyi ve yerel ticareti gerektirmiştir.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Ana yüklemi ('gerektirmiştir') doğru buldun!",
                        trapReasonTr: "BÜYÜK TUZAK! Cümle başındaki 'Much as' '...-dığı kadar' demek DEĞİLDİR; 'Although / Even though' (-se de / -e rağmen) anlamında zıtlık bağlacıdır!",
                        winningRuleTr: "'Much as' = '-mış olsa da' çevirisiyle B şıkkı seçilmeliydi.",
                        grammarRuleTag: "TRANS_MUCH_AS_TRAP"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "Uzun vadeli istikrar her zaman idari bütünleşmeyi ve yerel ticareti gerektirdiği için antik imparatorluklar sadece askeri baskıya dayanmamıştır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İki cümleyi de okudun!",
                        trapReasonTr: "Hem bağlaç '-dığı için' diye değiştirilmiş hem de ana yüklem yer değiştirmiş.",
                        winningRuleTr: "Sonu 'gerektirmiştir' ile biten B şıkkı doğrudur.",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "Sınırlarını genişletmek için askeri baskıya dayanan antik imparatorluklarda, uzun vadeli istikrar idari bütünleşme ve yerel ticaretle sağlanmıştır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Anlam bütünlüğünü korudun!",
                        trapReasonTr: "Yan cümle sıfat-fiile çevrilmiş ve ana yüklem 'required' (gerektirmiştir) yerine 'sağlanmıştır' yapılmış.",
                        winningRuleTr: "B şıkkı 1:1 yapısal karşılıktır.",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                )
            ],
            correctOptionId: "B"
        ),
        SprintQuestion(
            id: "th-q7",
            category: .translation,
            sprintMode: .translation10SecHunt,
            track: .healthSciences,
            timeLimitSeconds: 10,
            stemText: "What makes antibiotic resistance particularly alarming to epidemiologists is that horizontal gene transfer allows bacteria to share defense mechanisms across species.",
            highlightedClues: [
                ClueSpan(id: "th7-c1", matchedSubstring: "What makes ... is that", clueType: .conjunction, explanationTr: "Noun Clause İskeleti: '...-yı özellikle endişe verici kılan şey, ... -masıdır'"),
                ClueSpan(id: "th7-c2", matchedSubstring: "allows bacteria to share", clueType: .mainVerb, explanationTr: "Yüklem Eklemi: 'paylaşmasına olanak tanımasıdır'")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "Antibiyotik direncini epidemiyologlar için özellikle endişe verici kılan şey, yatay gen transferinin bakterilerin türler arasında savunma mekanizmalarını paylaşmasına olanak tanımasıdır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Harika! 'What makes ... is that ...' (... kılan şey, ... -masıdır) kalıbını 10 saniyede şıp diye oturtup A şıkkını vurdun!",
                        trapReasonTr: "Özne ile yüklemi yer değiştiren çeldiricilere hiç takılmadın.",
                        winningRuleTr: "What + V + is that + Clause = ... yapan şey, ... -masıdır.",
                        grammarRuleTag: "TRANS_NOUN_CLAUSE_FRAME"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "Yatay gen transferi bakterilerin türler arasında savunma mekanizmalarını paylaşmasına olanak tanıdığı için antibiyotik direnci epidemiyologlar için endişe vericidir.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Cümlenin anlamını doğru kavradın!",
                        trapReasonTr: "Ancak cümlede 'because' (-dığı için) yok; 'What makes X is that Y' (... kılan şey, ... -masıdır) vurgulu isim cümleciği kalıbı var.",
                        winningRuleTr: "'... kılan şey, ... olanak tanımasıdır' diyen A şıkkı doğrudur.",
                        grammarRuleTag: "TRANS_NOUN_CLAUSE_FRAME"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "Epidemiyologları özellikle endişelendiren antibiyotik direnci, yatay gen transferi yoluyla bakterilerin savunma mekanizmalarını paylaşmasından kaynaklanır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Özne grubunu takip ettin!",
                        trapReasonTr: "Yüklem 'allows ... to share' (paylaşmasına olanak tanımasıdır) iken 'kaynaklanır' (stems from) yapılmış.",
                        winningRuleTr: "A şıkkı yapısal olarak birebir eşleşir.",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "Bakterilerin türler arasında savunma mekanizmalarını paylaşmasına olanak tanıyan yatay gen transferi, antibiyotik direncini endişe verici kılmaktadır.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Kelimelerin tamamını doğru eşleştirdin!",
                        trapReasonTr: "Özne ile yüklem ters çevrilmiş! 'What makes...' cümle başında olduğu için Türkçe cümle '... kılan şey' diye başlamalıydı.",
                        winningRuleTr: "A şıkkı özne-yüklem sırasını doğru korur.",
                        grammarRuleTag: "TRANS_SUBJECT_OBJECT_SWAP"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "Antibiyotik direncinin epidemiyologlar için endişe verici olması, bakterilerin yatay gen transferiyle savunma mekanizmalarını paylaşabileceğini göstermektedir.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İsim cümleciği yapısını fark ettin!",
                        trapReasonTr: "Cümlede 'göstermektedir' (shows/indicates) fiili yok; yüklem 'is that ... allows' (... olanak tanımasıdır) olmalıydı.",
                        winningRuleTr: "A şıkkı doğru cevaptır.",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                )
            ],
            correctOptionId: "A"
        ),
        SprintQuestion(
            id: "th-q8",
            category: .translation,
            sprintMode: .translation10SecHunt,
            track: .naturalSciences,
            timeLimitSeconds: 10,
            stemText: "Hardly had the lunar lander touched down on the crater's rim when mission control detected an unexpected drop in solar panel voltage.",
            highlightedClues: [
                ClueSpan(id: "th8-c1", matchedSubstring: "Hardly had ... touched down ... when", clueType: .conjunction, explanationTr: "Zaman Kalıbı: 'Tam iniş yapmıştı ki / İner inmez'"),
                ClueSpan(id: "th8-c2", matchedSubstring: "mission control detected", clueType: .mainVerb, explanationTr: "Ana Yüklem: 'görev kontrol merkezi ... tespit etti'")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "Ay aracı kraterin kenarına neredeyse hiç iniş yapamamıştı çünkü görev kontrol merkezi güneş paneli voltajında beklenmedik bir düşüş tespit etti.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Son yüklemi ('tespit etti') doğru yakaladın!",
                        trapReasonTr: "DEV TUZAK! 'Hardly had ... when' kalıbındaki 'Hardly' 'neredeyse hiç yapamadı' demek DEĞİLDİR! 'No sooner ... than' ile aynıdır ve 'Tam ... yapmıştı ki / ... yapar yapmaz' demektir!",
                        winningRuleTr: "'Tam iniş yapmıştı ki ... tespit etti' diyen C şıkkı seçilmeliydi.",
                        grammarRuleTag: "TRANS_HARDLY_WHEN_TRAP"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "Görev kontrol merkezi güneş paneli voltajında beklenmedik bir düşüş tespit ettiğinde, ay aracı kraterin kenarına zorlukla iniş yapmıştı.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Past Perfect yapısını gördün!",
                        trapReasonTr: "'Hardly' burada 'zorlukla' demek değildir; 'Hardly ... when' kalıbı 'Tam ... olmuştu ki' demektir ve ana yüklem 'tespit etti' olmalıdır.",
                        winningRuleTr: "C şıkkı kalıbı ve yüklemi eksiksiz verir.",
                        grammarRuleTag: "TRANS_HARDLY_WHEN_TRAP"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "Ay aracı kraterin kenarına tam iniş yapmıştı ki görev kontrol merkezi güneş paneli voltajında beklenmedik bir düşüş tespit etti.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Efsane refleks! YDS'nin en zor kalıbı olan 'Hardly had V3 ... when V2' (Tam ... yapmıştı ki ...) yapısını 10 saniyede avladın!",
                        trapReasonTr: "'Hardly' kelimesini 'neredeyse hiç' veya 'zorlukla' diye çeviren A ve B tuzaklarına düşmedin.",
                        winningRuleTr: "Hardly/Scarcely had V3 ... when V2 = No sooner had V3 ... than V2 = Tam ... yapmıştı ki ...",
                        grammarRuleTag: "TRANS_HARDLY_WHEN_TRAP"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "Ay aracının kraterin kenarına iniş yapmasıyla birlikte görev kontrol merkezi güneş paneli voltajındaki düşüşü fark etmekte zorlandı.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Eşzamanlılık hissini yakaladın!",
                        trapReasonTr: "Yüklem 'detected' (tespit etti) iken 'fark etmekte zorlandı' şeklinde uydurulmuş.",
                        winningRuleTr: "Sonu 'tespit etti' ile biten C şıkkı doğrudur.",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "Görev kontrol merkezinin güneş paneli voltajında beklenmedik bir düşüş tespit etmesi, ay aracı kratere indikten hemen sonra gerçekleşti.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Olayların sırasını doğru anladın!",
                        trapReasonTr: "Ancak cümlede 'gerçekleşti' (took place/occurred) yüklemi yok; ana yüklem 'detected' (tespit etti) olmalıdır.",
                        winningRuleTr: "C şıkkı doğru cevaptır.",
                        grammarRuleTag: "TRANS_MAIN_VERB_MISMATCH"
                    )
                )
            ],
            correctOptionId: "C"
        )
    ]

    // MARK: - 3. ARTI / EKSİ BAĞLAÇ RADARI SORULARI (CONJUNCTION POLARITY RADAR - 8 Adet)
    public static let polarityRadarQuestions: [SprintQuestion] = [
        SprintQuestion(
            id: "pr-q1",
            category: .conjunction,
            sprintMode: .conjunctionPolarityRadar,
            track: .healthSciences,
            timeLimitSeconds: 35,
            stemText: "____ robotic surgery systems significantly reduce intraoperative blood loss and recovery times, their prohibitive acquisition cost prevents widespread adoption in rural hospitals.",
            highlightedClues: [
                ClueSpan(id: "pr1-c1", matchedSubstring: "significantly reduce intraoperative blood loss", clueType: .mainVerb, explanationTr: "Sol Cümle Kutbu: Kan kaybını ve iyileşme süresini azaltması -> OLUMLU (+)"),
                ClueSpan(id: "pr1-c2", matchedSubstring: "prohibitive acquisition cost prevents widespread adoption", clueType: .mainVerb, explanationTr: "Sağ Cümle Kutbu: Aşırı maliyetin yaygın kullanımı engellemesi -> OLUMSUZ (-)")
            ],
            expectedLeftPolarity: .positive,
            expectedRightPolarity: .negative,
            options: [
                QuestionOption(
                    id: "A",
                    text: "Because",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Boşluktan sonra tam cümle geldiğini doğru gördün!",
                        trapReasonTr: "Kutup hatası! Sol taraf (+) olumlu (kan kaybını azaltır), sağ taraf (-) olumsuz (maliyeti kullanımı engeller). Artı ile eksiyi 'Because' (-dığı için) bağlayamaz!",
                        winningRuleTr: "(+) ile (-) kutupları birbirine bağlayan Zıtlık ailesinden C şıkkındaki 'While' (-e karşın / -se de) seçilmeliydi.",
                        grammarRuleTag: "CONJ_POLARITY_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "In spite of",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Sol (+) ve Sağ (-) arasındaki ZITLIK kutbunu mükemmel yakaladın!",
                        trapReasonTr: "Ancak dilbilgisi tuzağına düştün: 'In spite of / Despite' arkasından sadece İsim Öbeği alır; boşluktan sonra ise 'systems reduce...' tam cümlesi var.",
                        winningRuleTr: "Tam cümle alan zıtlık bağlacı C şıkkındaki 'While' (= Although/Whereas) seçilmeliydi.",
                        grammarRuleTag: "CONJ_CLAUSE_VS_NP"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "While",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Tam isabet! Sol (+) ve Sağ (-) kutuplarını radarda yakaladın ve tam cümle alan zıtlık bağlacı 'While'ı vurdun!",
                        trapReasonTr: "İsim öbeği alan 'In spite of' tuzağına düşmedin.",
                        winningRuleTr: "(+) Tam Cümle <-> (-) Tam Cümle = While / Although / Even though / Whereas.",
                        grammarRuleTag: "CONJ_POLARITY_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "Provided that",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Tam cümle alan bir bağlaç seçtin!",
                        trapReasonTr: "'Provided that' (-mesi şartıyla = If) koşul bağlacıdır; bir teknolojinin avantajı (+) ile maliyet dezavantajı (-) arasında koşul kurulmaz.",
                        winningRuleTr: "Zıtlık bağlacı olan C şıkkındaki 'While' doğrudur.",
                        grammarRuleTag: "CONJ_CONDITION_VS_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "As a result of",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İki durum arasında bağlantı aradın!",
                        trapReasonTr: "Hem kutup uyumsuz (+ ve - neden-sonuç olmaz) hem de 'As a result of' arkasından tam cümle almaz.",
                        winningRuleTr: "Tam cümleli zıtlık bağlacı C şıkkındaki 'While' seçilmeliydi.",
                        grammarRuleTag: "CONJ_CLAUSE_VS_NP"
                    )
                )
            ],
            correctOptionId: "C"
        ),
        SprintQuestion(
            id: "pr-q2",
            category: .conjunction,
            sprintMode: .conjunctionPolarityRadar,
            track: .naturalSciences,
            timeLimitSeconds: 35,
            stemText: "____ the extreme atmospheric pressure and sulfuric acid clouds on Venus, several Soviet Venera probes managed to transmit surface images before melting.",
            highlightedClues: [
                ClueSpan(id: "pr2-c1", matchedSubstring: "the extreme atmospheric pressure and sulfuric acid clouds", clueType: .topicShift, explanationTr: "Sol İsim Öbeği Kutbu: Aşırı basınç ve sülfürik asit bulutları -> OLUMSUZ (-)"),
                ClueSpan(id: "pr2-c2", matchedSubstring: "managed to transmit surface images", clueType: .mainVerb, explanationTr: "Sağ Cümle Kutbu: Görüntü iletmeyi başarması -> OLUMLU (+)")
            ],
            expectedLeftPolarity: .negative,
            expectedRightPolarity: .positive,
            options: [
                QuestionOption(
                    id: "A",
                    text: "Notwithstanding",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Harika! Sol (-) İsim Öbeği ile Sağ (+) başarıyı yakaladın ve 'Despite'ın akademik ikizi olan 'Notwithstanding' (-e rağmen) şıkkını vurdun!",
                        trapReasonTr: "Tam cümle isteyen 'Even though' tuzağına düşmedin.",
                        winningRuleTr: "Notwithstanding = Despite = In spite of + İsim Öbeği (-e rağmen).",
                        grammarRuleTag: "CONJ_NP_CONTRAST_MASTERED"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "Even though",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Sol (-) zorluk ile Sağ (+) başarı arasındaki ZITLIĞI kusursuz yakaladın!",
                        trapReasonTr: "Fakat yapısal tuzağa düştün! Virgüle kadar olan kısımda ('the extreme atmospheric pressure and sulfuric acid clouds on Venus') hiçbir FİİL/YÜKLEM yok! Burası bir İsim Öbeğidir.",
                        winningRuleTr: "İsim öbeği alan zıtlık edatı A şıkkındaki 'Notwithstanding' (= Despite) seçilmeliydi.",
                        grammarRuleTag: "CONJ_CLAUSE_VS_NP"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "Due to",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Boşluktan sonra İsim Öbeği (Noun Phrase) geldiğini harika tespit ettin!",
                        trapReasonTr: "Ancak kutup tuzağına düştün: Sülfürik asit bulutları (-) yüzünden görüntü göndermeyi başarmaz (+); bunlara RAĞMEN başarır!",
                        winningRuleTr: "İsim öbeğiyle zıtlık kuran A şıkkındaki 'Notwithstanding' (= Despite) doğrudur.",
                        grammarRuleTag: "CONJ_CAUSE_VS_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "Inasmuch as",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Akademik bir bağlaç tanıdın!",
                        trapReasonTr: "'Inasmuch as' = 'Because' demektir; hem tam cümle ister hem de paralel kutup bağlar.",
                        winningRuleTr: "İsim öbeği + Zıtlık isteyen A şıkkındaki 'Notwithstanding' seçilmeliydi.",
                        grammarRuleTag: "CONJ_CLAUSE_VS_NP"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "On account of",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Boşluktan sonra isim öbeği geldiğini doğru gördün!",
                        trapReasonTr: "'On account of' = 'Because of' (-den dolayı) demektir; (-) ile (+) kutbu bağlayamaz.",
                        winningRuleTr: "Zıtlık bildiren A şıkkındaki 'Notwithstanding' doğru cevaptır.",
                        grammarRuleTag: "CONJ_CAUSE_VS_CONTRAST"
                    )
                )
            ],
            correctOptionId: "A"
        ),
        SprintQuestion(
            id: "pr-q3",
            category: .conjunction,
            sprintMode: .conjunctionPolarityRadar,
            track: .socialSciences,
            timeLimitSeconds: 35,
            stemText: "Oral histories passed down through generations are often dismissed by positivists as subjective; ____, modern anthropologists regard them as indispensable records of marginalized communities.",
            highlightedClues: [
                ClueSpan(id: "pr3-c1", matchedSubstring: "are often dismissed ... as subjective", clueType: .mainVerb, explanationTr: "Sol Cümle Kutbu: Öznel olduğu gerekçesiyle reddedilmesi/küçümsenmesi -> OLUMSUZ (-)"),
                ClueSpan(id: "pr3-c2", matchedSubstring: "regard them as indispensable records", clueType: .mainVerb, explanationTr: "Sağ Cümle Kutbu: Vazgeçilmez kayıtlar olarak görülmesi -> OLUMLU (+)")
            ],
            expectedLeftPolarity: .negative,
            expectedRightPolarity: .positive,
            options: [
                QuestionOption(
                    id: "A",
                    text: "consequently",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Noktalı virgül ve virgül (`; ___,`) arasına geçiş zarfı geleceğini doğru gördün!",
                        trapReasonTr: "Ancak kutuplara dikkat: Sol tarafta 'reddedilir' (-), sağ tarafta 'vazgeçilmez görülür' (+). 'Consequently' (sonuç olarak) aynı yönlü kutupları bağlar.",
                        winningRuleTr: "(-) ile (+) arasında zıtlık kuran D şıkkındaki 'nonetheless' (buna rağmen / yine de) seçilmeliydi.",
                        grammarRuleTag: "CONJ_POLARITY_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "moreover",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Geçiş bağlacı (transition) yapısını tanıdın!",
                        trapReasonTr: "'Moreover / Furthermore' (üstelik) paralel ekleme yapar: Sol (-) ise sağ da (-) olmalıydı.",
                        winningRuleTr: "Zıt kutupları bağlayan D şıkkındaki 'nonetheless' (= however/nevertheless) doğrudur.",
                        grammarRuleTag: "CONJ_PARALLEL_VS_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "for instance",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İki bağımsız cümle arasındaki geçişi inceledin!",
                        trapReasonTr: "İkinci cümle birinci cümlenin örneği değil, tam tersi bir bakış açısıdır ('positivists dismiss' <-> 'anthropologists regard as indispensable').",
                        winningRuleTr: "Zıtlık zarfı olan D şıkkındaki 'nonetheless' seçilmeliydi.",
                        grammarRuleTag: "CONJ_POLARITY_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "nonetheless",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Mükemmel! Sol (-) 'dismissed' ile Sağ (+) 'indispensable' zıtlığını yakaladın ve `; ___,` noktalama kalıbına uyan 'nonetheless'i vurdun!",
                        trapReasonTr: "Neden-sonuç ('consequently') ve ekleme ('moreover') tuzaklarını eledin.",
                        winningRuleTr: "Nonetheless = Nevertheless = However (Buna rağmen / Ancak).",
                        grammarRuleTag: "CONJ_POLARITY_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "thereby",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Akademik bir bağlaç seçtin!",
                        trapReasonTr: "'Thereby' (böylece) arkasından genellikle `V-ing` alır ve neden-sonuç bağlar.",
                        winningRuleTr: "Tam cümleli zıtlık geçişi sağlayan D şıkkındaki 'nonetheless' doğrudur.",
                        grammarRuleTag: "CONJ_POLARITY_CONTRAST"
                    )
                )
            ],
            correctOptionId: "D"
        ),
        SprintQuestion(
            id: "pr-q4",
            category: .conjunction,
            sprintMode: .conjunctionPolarityRadar,
            track: .healthSciences,
            timeLimitSeconds: 35,
            stemText: "____ broad-spectrum antibiotics eradicate pathogenic bacteria rapidly, they simultaneously destroy beneficial commensal flora in the digestive tract.",
            highlightedClues: [
                ClueSpan(id: "pr4-c1", matchedSubstring: "eradicate pathogenic bacteria rapidly", clueType: .mainVerb, explanationTr: "Sol Cümle Kutbu: Zararlı bakterileri hızla yok etmesi (Tedavi başarısı) -> OLUMLU (+)"),
                ClueSpan(id: "pr4-c2", matchedSubstring: "destroy beneficial commensal flora", clueType: .mainVerb, explanationTr: "Sağ Cümle Kutbu: Yararlı bağırsak florasını tahrip etmesi (Yan etki) -> OLUMSUZ (-)")
            ],
            expectedLeftPolarity: .positive,
            expectedRightPolarity: .negative,
            options: [
                QuestionOption(
                    id: "A",
                    text: "Just as",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Tam cümle alan bir bağlaç seçtin!",
                        trapReasonTr: "'Just as' (tıpkı ... olduğu gibi) iki farklı özne arasında benzerlik kurar; burada ise aynı ilacın hem faydası (+) hem zararı (-) anlatılıyor.",
                        winningRuleTr: "(+) fayda ile (-) yan etkiyi karşılaştıran E şıkkındaki 'Much as' (= Although) seçilmeliydi.",
                        grammarRuleTag: "CONJ_POLARITY_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "Provided",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Cümle başı bağlaç yapısını kontrol ettin!",
                        trapReasonTr: "'Provided (that)' koşul bağlacıdır; 'zararlı bakterileri yok etmesi şartıyla yararlı florayı tahrip eder' anlamsız olur.",
                        winningRuleTr: "Zıtlık bildiren E şıkkındaki 'Much as' (-se de) doğrudur.",
                        grammarRuleTag: "CONJ_CONDITION_VS_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "Seeing that",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "'Seeing that'in tam cümle aldığını biliyorsun!",
                        trapReasonTr: "'Seeing that' = 'Because / Mademki' demektir. Olumlu (+) tedavi etkisi ile olumsuz (-) yan etki arasında neden-sonuç değil zıtlık vardır.",
                        winningRuleTr: "Zıtlık bağlacı olan E şıkkındaki 'Much as' (= Although) seçilmeliydi.",
                        grammarRuleTag: "CONJ_CAUSE_VS_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "In order that",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Tam cümle alan bir bağlaç seçtin!",
                        trapReasonTr: "'In order that' (-sın diye) amaç bildirir ve genellikle 'can/could/may' ile kullanılır.",
                        winningRuleTr: "E şıkkındaki 'Much as' (= Although / Even though) doğru cevaptır.",
                        grammarRuleTag: "CONJ_PURPOSE_VS_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "Much as",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Harika! Sol (+) tedavi başarısı ile Sağ (-) yan etki zıtlığını buldun ve 'Although'un üst düzey ikizi 'Much as'ı işaretledin!",
                        trapReasonTr: "'Much as'ı miktar/benzerlik bağlacı sanma tuzağına düşmedin.",
                        winningRuleTr: "Cümle başı Much as + Tam Cümle = Although / Even though (-e rağmen / -se de).",
                        grammarRuleTag: "CONJ_MUCH_AS_MASTERED"
                    )
                )
            ],
            correctOptionId: "E"
        ),
        SprintQuestion(
            id: "pr-q5",
            category: .conjunction,
            sprintMode: .conjunctionPolarityRadar,
            track: .naturalSciences,
            timeLimitSeconds: 35,
            stemText: "Lithium-ion batteries suffer from thermal runaway risks at high temperatures; ____, solid-state batteries utilize non-flammable ceramic electrolytes that remain stable.",
            highlightedClues: [
                ClueSpan(id: "pr5-c1", matchedSubstring: "suffer from thermal runaway risks", clueType: .mainVerb, explanationTr: "Sol Cümle Kutbu: Lityum-iyon pillerin aşırı ısınma/yangın riski taşıması -> OLUMSUZ (-)"),
                ClueSpan(id: "pr5-c2", matchedSubstring: "utilize non-flammable ... remain stable", clueType: .mainVerb, explanationTr: "Sağ Cümle Kutbu: Katı hal pillerin yanmaz ve kararlı olması -> OLUMLU (+)")
            ],
            expectedLeftPolarity: .negative,
            expectedRightPolarity: .positive,
            options: [
                QuestionOption(
                    id: "A",
                    text: "by contrast",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Noktadan vurdun! İki farklı pil teknolojisini (Lithium-ion '-' vs Solid-state '+') kıyaslayan 'by contrast' (buna karşılık / aksine) bağlacını tam isabetle seçtin!",
                        trapReasonTr: "Benzerlik kuran 'likewise' ve neden-sonuç kuran 'therefore' çeldiricilerini eledin.",
                        winningRuleTr: "Özne 1 (-) ; by contrast / conversely, Özne 2 (+).",
                        grammarRuleTag: "CONJ_DIRECT_OPPOSITION"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "likewise",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İki farklı öznenin kıyaslandığını doğru gördün!",
                        trapReasonTr: "'Likewise / Similarly' (benzer şekilde) her iki özne de aynı kutuptaysa (- / - veya + / +) kullanılır. Burada ilki yanıcı (-), ikincisi yanmaz ve güvenli (+).",
                        winningRuleTr: "Tam zıt kutuplu iki özneyi kıyaslayan A şıkkındaki 'by contrast' seçilmeliydi.",
                        grammarRuleTag: "CONJ_SIMILARITY_VS_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "therefore",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Noktalı virgül sonrası geçiş zarfı aradın!",
                        trapReasonTr: "Lityum pillerin risk taşıması (-) katı hal pillerin kararlı olmasının (+) nedeni değildir; iki teknoloji karşılaştırılmaktadır.",
                        winningRuleTr: "Karşıtlık bildiren A şıkkındaki 'by contrast' doğrudur.",
                        grammarRuleTag: "CONJ_CAUSE_VS_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "in other words",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Geçiş ifadesi yapısını inceledin!",
                        trapReasonTr: "'In other words' (başka bir deyişle) ilk cümleyi yeniden açıklar; yeni ve zıt bir özneye ('solid-state batteries') geçmez.",
                        winningRuleTr: "İki zıt teknolojiyi kıyaslayan A şıkkındaki 'by contrast' seçilmeliydi.",
                        grammarRuleTag: "CONJ_RESTATEMENT_VS_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "for example",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Bağlaç pozisyonunu doğru okudun!",
                        trapReasonTr: "Katı hal pilleri, lityum-iyon pillerin bir örneği değil, onun rakibi/alternatifidir.",
                        winningRuleTr: "A şıkkındaki 'by contrast' (aksine / buna karşılık) doğru cevaptır.",
                        grammarRuleTag: "CONJ_DIRECT_OPPOSITION"
                    )
                )
            ],
            correctOptionId: "A"
        ),
        SprintQuestion(
            id: "pr-q6",
            category: .conjunction,
            sprintMode: .conjunctionPolarityRadar,
            track: .socialSciences,
            timeLimitSeconds: 35,
            stemText: "____ strict censorship laws enacted by the regime, underground printing presses continued to circulate reformist pamphlets across the capital.",
            highlightedClues: [
                ClueSpan(id: "pr6-c1", matchedSubstring: "strict censorship laws enacted by the regime", clueType: .topicShift, explanationTr: "Sol İsim Öbeği Kutbu: Sıkı sansür yasaları (Engelleyici) -> OLUMSUZ (-)"),
                ClueSpan(id: "pr6-c2", matchedSubstring: "continued to circulate reformist pamphlets", clueType: .mainVerb, explanationTr: "Sağ Cümle Kutbu: Bildirilerin dağıtılmaya devam etmesi (Direnç) -> OLUMLU (+)")
            ],
            expectedLeftPolarity: .negative,
            expectedRightPolarity: .positive,
            options: [
                QuestionOption(
                    id: "A",
                    text: "Thanks to",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Virgüle kadar olan kısmın İsim Öbeği olduğunu doğru tespit ettin! ('enacted' burada 'which were enacted' kısaltmasıdır, ana yüklem değildir!)",
                        trapReasonTr: "Ancak kutup tuzağına düştün: Sıkı sansür yasaları (-) sayesinde ('Thanks to') yeraltı basını bildiri dağıtmaz; sansüre RAĞMEN dağıtır!",
                        winningRuleTr: "İsim öbeğiyle zıtlık kuran B şıkkındaki 'Regardless of' (bakılmaksızın / -e rağmen) seçilmeliydi.",
                        grammarRuleTag: "CONJ_CAUSE_VS_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "Regardless of",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Muhteşem! Hem 'enacted by' kısmının V3 kısaltma (İsim Öbeği) olduğunu anladın hem de (-) sansüre rağmen (+) dağıtım zıtlığını 'Regardless of' ile vurdun!",
                        trapReasonTr: "'enacted' kelimesini V2 yüklem sanıp 'Although' seçme tuzağına düşmedin!",
                        winningRuleTr: "İsim + V3 ('laws enacted by...') = İsim Öbeğidir -> Despite / Regardless of / Irrespective of alır!",
                        grammarRuleTag: "CONJ_PARTICIPLE_NP_TRAP"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "Although",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Sol (-) ve Sağ (+) arasındaki ZITLIK kutbunu %100 doğru yakaladın!",
                        trapReasonTr: "YDS'nin EN MEŞHUR TUZAĞINA düştün! 'laws enacted by the regime' ifadesindeki 'enacted' geçmiş zaman yüklemi DEĞİL, 'which were enacted' (yürürlüğe konulan yasalar) pasif sıfat kısaltmasıdır! Yani virgüle kadar tam cümle yok, İsim Öbeği var!",
                        winningRuleTr: "İsim öbeği alan zıtlık bağlacı B şıkkındaki 'Regardless of' (= Despite) seçilmeliydi.",
                        grammarRuleTag: "CONJ_PARTICIPLE_NP_TRAP"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "In view of",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Virgüle kadar İsim Öbeği olduğunu doğru gördün!",
                        trapReasonTr: "'In view of' (-yı göz önüne alarak / -den dolayı) paralel neden-sonuç bağlar; sansür ile yeraltı basını arasındaki zıtlığı vermez.",
                        winningRuleTr: "B şıkkındaki 'Regardless of' doğru cevaptır.",
                        grammarRuleTag: "CONJ_CAUSE_VS_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "Whereas",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Zıtlık arayışın doğruydu!",
                        trapReasonTr: "'Whereas' arkasından tam cümle (Özne + Çekimli Fiil) ister; 'strict censorship laws enacted by the regime' ise bir isim öbeğidir.",
                        winningRuleTr: "İsim öbeği alan B şıkkındaki 'Regardless of' seçilmeliydi.",
                        grammarRuleTag: "CONJ_PARTICIPLE_NP_TRAP"
                    )
                )
            ],
            correctOptionId: "B"
        ),
        SprintQuestion(
            id: "pr-q7",
            category: .conjunction,
            sprintMode: .conjunctionPolarityRadar,
            track: .healthSciences,
            timeLimitSeconds: 35,
            stemText: "Early clinical intervention is crucial in sepsis cases, ____ every hour of delayed antibiotic administration decreases patient survival probability by nearly eight percent.",
            highlightedClues: [
                ClueSpan(id: "pr7-c1", matchedSubstring: "Early clinical intervention is crucial", clueType: .mainVerb, explanationTr: "Sol Cümle: Erken müdahale hayati önem taşır (Sonuç / İddia)"),
                ClueSpan(id: "pr7-c2", matchedSubstring: "every hour of delayed ... decreases patient survival", clueType: .mainVerb, explanationTr: "Sağ Cümle: Geciken her saatin hayatta kalma şansını %8 düşürmesi (Gerekçe / Neden)")
            ],
            expectedLeftPolarity: .positive,
            expectedRightPolarity: .negative,
            options: [
                QuestionOption(
                    id: "A",
                    text: "whereas",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İki tam cümle olduğunu doğru gördün!",
                        trapReasonTr: "Yüzeysel kutup tuzağı! İlk cümlede 'crucial' (+), ikinci cümlede 'decreases survival' (-) görünce zıtlık sandın; oysa ikinci cümle birinci cümlenin GEREKÇESİDİR ('Erken müdahale hayatidir, ÇÜNKÜ geciken her saat sağkalımı düşürür')!",
                        winningRuleTr: "'Çünkü / -dığı için' anlamı veren D şıkkındaki 'in that' (= because / since) seçilmeliydi.",
                        grammarRuleTag: "CONJ_IN_THAT_JUSTIFICATION"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "even if",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Tam cümle alan bir bağlaç seçtin!",
                        trapReasonTr: "'Even if' (-se bile) koşul-zıtlık bağlar; burada ise gecikmenin ölümcül olması erken müdahalenin neden hayati olduğunu açıklıyor.",
                        winningRuleTr: "Açıklama ve gerekçe bildiren D şıkkındaki 'in that' (-mesi bakımından / çünkü) doğrudur.",
                        grammarRuleTag: "CONJ_IN_THAT_JUSTIFICATION"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "unless",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İkinci cümledeki olumsuz sonucu fark ettin!",
                        trapReasonTr: "'Unless' (-medikçe) buraya konursa 'geciken her saat sağkalımı düşürmedikçe erken müdahale hayatidir' gibi çelişkili bir anlam çıkar.",
                        winningRuleTr: "Gerekçe bağlacı olan D şıkkındaki 'in that' (= since/because) seçilmeliydi.",
                        grammarRuleTag: "CONJ_IN_THAT_JUSTIFICATION"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "in that",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "YDS Şampiyonu! İkinci cümlenin ilk cümledeki 'crucial' iddiasını kanıtlayan bir gerekçe olduğunu anladın ve 'in that' (çünkü / -mesi bakımından) bağlacını vurdun!",
                        trapReasonTr: "Yüzeysel (+) / (-) görüntüsüne aldanıp 'whereas' tuzağına düşmedin.",
                        winningRuleTr: "İddia Cümlesi, in that / for / since / inasmuch as + Kanıt/Gerekçe Cümlesi.",
                        grammarRuleTag: "CONJ_IN_THAT_JUSTIFICATION"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "so that",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Tam cümle bağlacı aradın!",
                        trapReasonTr: "'So that' (-sın diye) amaç bildirir; kimse sağkalım düşsün diye erken müdahale yapmaz!",
                        winningRuleTr: "'Çünkü / -mesi bakımından' anlamındaki D şıkkı ('in that') doğrudur.",
                        grammarRuleTag: "CONJ_PURPOSE_VS_CAUSE"
                    )
                )
            ],
            correctOptionId: "D"
        ),
        SprintQuestion(
            id: "pr-q8",
            category: .conjunction,
            sprintMode: .conjunctionPolarityRadar,
            track: .naturalSciences,
            timeLimitSeconds: 35,
            stemText: " Desalination plants provide arid coastal nations with a reliable freshwater supply; ____, the discharge of hyper-saline brine poses severe threats to marine benthic ecosystems.",
            highlightedClues: [
                ClueSpan(id: "pr8-c1", matchedSubstring: "provide ... a reliable freshwater supply", clueType: .mainVerb, explanationTr: "Sol Cümle Kutbu: Güvenilir tatlı su kaynağı sağlaması -> OLUMLU (+)"),
                ClueSpan(id: "pr8-c2", matchedSubstring: "poses severe threats to marine benthic ecosystems", clueType: .mainVerb, explanationTr: "Sağ Cümle Kutbu: Deniz ekosistemine ciddi tehdit oluşturması -> OLUMSUZ (-)")
            ],
            expectedLeftPolarity: .positive,
            expectedRightPolarity: .negative,
            options: [
                QuestionOption(
                    id: "A",
                    text: "furthermore",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Noktalı virgül sonrası geçiş zarfı aradın!",
                        trapReasonTr: "'Furthermore' (dahası / üstelik) paralel kutup ister (+ -> + veya - -> -). Oysa burada sol taraf fayda (+), sağ taraf çevre tehdidi (-).",
                        winningRuleTr: "Olumludan olumsuza geçiş yapan C şıkkındaki 'nevertheless' (buna rağmen / ancak) seçilmeliydi.",
                        grammarRuleTag: "CONJ_PARALLEL_VS_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "accordingly",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Akademik geçiş zarfını tanıdın!",
                        trapReasonTr: "'Accordingly' (buna uygun olarak / dolayısıyla = therefore) neden-sonuç bağlar; tatlı su sağlaması (+) deniz yaşamını tehdit etmesinin (-) zıttı olan öteki yüzüdür.",
                        winningRuleTr: "Zıtlık bildiren C şıkkındaki 'nevertheless' doğrudur.",
                        grammarRuleTag: "CONJ_CAUSE_VS_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "nevertheless",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Tam isabet! Sol (+) tatlı su faydası ile Sağ (-) ekolojik tehdit zıtlığını yakalayıp 'nevertheless'i işaretledin!",
                        trapReasonTr: "'Furthermore' ve 'accordingly' tuzaklarını anında eledin.",
                        winningRuleTr: "(+) Fayda ; nevertheless / however / nonetheless, (-) Yan Etki/Tehdit.",
                        grammarRuleTag: "CONJ_POLARITY_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "hence",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Geçiş bağlacı olduğunu gördün!",
                        trapReasonTr: "'Hence' = 'Therefore' (bu yüzden) demektir; (+) ile (-) arasında zıtlık kuramaz.",
                        winningRuleTr: "C şıkkındaki 'nevertheless' doğru cevaptır.",
                        grammarRuleTag: "CONJ_CAUSE_VS_CONTRAST"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "similarly",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İki cümleyi ilişkilendirdin!",
                        trapReasonTr: "'Similarly' (benzer şekilde) paralel kutup ister; burada ise fayda (+) ve zarar (-) karşılaştırılıyor.",
                        winningRuleTr: "C şıkkındaki 'nevertheless' seçilmeliydi.",
                        grammarRuleTag: "CONJ_SIMILARITY_VS_CONTRAST"
                    )
                )
            ],
            correctOptionId: "C"
        )
    ]
}
