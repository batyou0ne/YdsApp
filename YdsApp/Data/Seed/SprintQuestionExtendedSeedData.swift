import Foundation

/// Akış Bozan Dedektifi (6 Adet) + Cloze, Edat, Kısaltma, Cümle Tamamlama ve Yakın Anlam Sprint Soruları (8 Adet)
public enum SprintQuestionExtendedSeedData {
    // MARK: - 4. AKIŞ BOZAN DEDEKTİFİ (IRRELEVANT SENTENCE DETECTIVE - 6 Adet)
    public static let irrelevantDetectiveQuestions: [SprintQuestion] = [
        SprintQuestion(
            id: "ir-q1",
            category: .irrelevantSentence,
            sprintMode: .irrelevantSentenceDetective,
            track: .healthSciences,
            timeLimitSeconds: 45,
            stemText: "(I) Circadian rhythms are endogenous 24-hour oscillations that regulate sleep-wake cycles and hormone secretion in mammals. (II) These biological clocks are primarily synchronized by light signals received through specialized retinal ganglion cells. (III) When artificial blue light from digital screens suppresses melatonin production at night, this delicate synchronization is disrupted. (IV) Prescription sleeping pills accounted for over four billion dollars in global pharmaceutical revenues last year. (V) Such circadian disruption has been strongly linked to metabolic syndrome and impaired cognitive performance.",
            highlightedClues: [
                ClueSpan(id: "ir1-c1", matchedSubstring: "(II) These biological clocks", clueType: .pronounReference, explanationTr: "'These biological clocks' -> I. cümledeki 'Circadian rhythms'e referans veriyor (I-II ayrılmaz!)."),
                ClueSpan(id: "ir1-c2", matchedSubstring: "(V) Such circadian disruption", clueType: .pronounReference, explanationTr: "'Such circadian disruption' -> III. cümledeki 'this delicate synchronization is disrupted' ifadesine bağlanıyor! Aradaki IV. cümle (uyku ilacı cirosu) akışı bozuyor!")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "I",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Giriş cümlesinin konuyu doğru açıp açmadığını kontrol ettin!",
                        trapReasonTr: "Ancak II. cümledeki 'These biological clocks' zamiri doğrudan I. cümledeki 'Circadian rhythms' tanımına bağlanıyor; bu yüzden I. cümle atılamaz.",
                        winningRuleTr: "III. cümledeki 'disrupted' ile V. cümledeki 'Such circadian disruption' arasına girip ilaç satış cirosundan bahseden D şıkkı (IV) akışı bozmaktadır.",
                        grammarRuleTag: "IRRELEVANT_PRONOUN_CHAIN"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "II",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Zamir referanslarını inceledin!",
                        trapReasonTr: "II. cümle 'These biological clocks' diyerek I'e bağlanır ve 'synchronized' kelimesini ortaya atar; III. cümle ise 'this delicate synchronization' diyerek II'ye bağlanır!",
                        winningRuleTr: "Konuyu biyolojik saatten 'ilaç firmalarının milyar dolarlık gelirine' kaydıran D şıkkı (IV) seçilmeliydi.",
                        grammarRuleTag: "IRRELEVANT_PRONOUN_CHAIN"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "III",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Mavi ışık detayının konuyu daraltıp daraltmadığını sorguladın!",
                        trapReasonTr: "Eğer III. cümleyi atarsan, V. cümledeki 'Such circadian disruption' (Bu tür bir sirkadiyen bozulma) havada kalır çünkü bozulmadan ('is disrupted') ilk kez III. cümlede bahsediliyor!",
                        winningRuleTr: "III ile V arasındaki zamir köprüsünü bölen D şıkkı (IV) akışı bozan cümledir.",
                        grammarRuleTag: "IRRELEVANT_PRONOUN_CHAIN"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "IV",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Dedektif gözü! III. cümledeki 'is disrupted' ile V. cümledeki 'Such circadian disruption' zamir köprüsünü yakaladın ve araya giren ekonomi/ilaç cirosu cümlesini (IV) eledin!",
                        trapReasonTr: "Aynı kelimeler ('sleeping') geçtiği için IV. cümleyi konuyla ilgili sanma tuzağına düşmedin.",
                        winningRuleTr: "Zamir Köprüsü Kuralı: III ('disrupted') ---> V ('Such disruption') ise aradaki IV %100 akışı bozar!",
                        grammarRuleTag: "IRRELEVANT_PRONOUN_CHAIN"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "V",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Son cümlede yeni hastalık isimleri geçtiğini fark ettin!",
                        trapReasonTr: "V. cümle 'Such circadian disruption' diyerek III. cümledeki bozulmanın sonuçlarını anlatıyor; kopukluk V'te değil, araya giren IV. cümlededir.",
                        winningRuleTr: "D şıkkı (IV) doğru cevaptır.",
                        grammarRuleTag: "IRRELEVANT_PRONOUN_CHAIN"
                    )
                )
            ],
            correctOptionId: "D"
        ),
        SprintQuestion(
            id: "ir-q2",
            category: .irrelevantSentence,
            sprintMode: .irrelevantSentenceDetective,
            track: .naturalSciences,
            timeLimitSeconds: 45,
            stemText: "(I) Graphene consists of a single layer of carbon atoms arranged in a two-dimensional hexagonal lattice. (II) Because of this unique atomic configuration, the material exhibits extraordinary electrical conductivity and tensile strength. (III) Graphite mining operations in East Africa have recently faced stringent environmental regulations regarding water usage. (IV) Furthermore, it is nearly transparent while remaining impermeable to even the smallest gas molecules like helium. (V) These remarkable properties make graphene a prime candidate for next-generation flexible electronics and filtration membranes.",
            highlightedClues: [
                ClueSpan(id: "ir2-c1", matchedSubstring: "(II) Because of this unique atomic configuration", clueType: .pronounReference, explanationTr: "'this unique atomic configuration' -> I. cümledeki 'hexagonal lattice' yapısına bağlanır."),
                ClueSpan(id: "ir2-c2", matchedSubstring: "(III) Graphite mining operations in East Africa", clueType: .topicShift, explanationTr: "Özne/Konu Kayması! Metin Grafen'in fiziksel özelliklerini anlatırken III. cümle Doğu Afrika'daki grafit madenciliği yasalarına kaymış!")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "I",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İlk cümleyi kontrol ettin!",
                        trapReasonTr: "II. cümle 'this unique atomic configuration' diyerek doğrudan I. cümleye yaslanıyor.",
                        winningRuleTr: "Grafen'in özelliklerinden Doğu Afrika madencilik yasalarına atlayan C şıkkı (III) akışı bozar.",
                        grammarRuleTag: "IRRELEVANT_TOPIC_SHIFT"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "II",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İkinci cümleyi inceledin!",
                        trapReasonTr: "IV. cümledeki 'Furthermore, it is...' ifadesi II. cümledeki üstün fiziksel özelliklere ekleme yapıyor.",
                        winningRuleTr: "Aradaki madencilik cümlesi olan C şıkkı (III) çıkarılmalıdır.",
                        grammarRuleTag: "IRRELEVANT_TOPIC_SHIFT"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "III",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Tam isabet! II. cümlede Grafen'in iletkenliği, IV. cümlede 'Furthermore, it is...' ile şeffaflığı anlatılırken araya giren 'Doğu Afrika grafit madenciliği' (III) cümlesini anında yakaladın!",
                        trapReasonTr: "'Graphene' ile 'Graphite' kelime benzerliği tuzağına düşmedin.",
                        winningRuleTr: "II (Özellik 1) + IV ('Furthermore, it...' Özellik 2) + V ('These remarkable properties') -> III dışarıda kalır!",
                        grammarRuleTag: "IRRELEVANT_TOPIC_SHIFT"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "IV",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "IV. cümledeki 'it' zamirinin III. cümleye uymadığını fark ettin!",
                        trapReasonTr: "Çok yaklaştın! IV. cümledeki 'it' III. cümleye uymuyor ÇÜNKÜ III. cümle araya sonradan sıkıştırılmış! III'ü çıkarınca IV'teki 'it' doğrudan II. cümledeki 'the material' (graphene) ile kusursuz birleşir.",
                        winningRuleTr: "Suçlu IV değil, araya giren C şıkkı (III) cümlesidir.",
                        grammarRuleTag: "IRRELEVANT_TOPIC_SHIFT"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "V",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Son cümleyi kontrol ettin!",
                        trapReasonTr: "V. cümledeki 'These remarkable properties' hem II hem de IV. cümledeki fiziksel özellikleri özetleyip kullanım alanına bağlıyor.",
                        winningRuleTr: "C şıkkı (III) doğru cevaptır.",
                        grammarRuleTag: "IRRELEVANT_TOPIC_SHIFT"
                    )
                )
            ],
            correctOptionId: "C"
        ),
        SprintQuestion(
            id: "ir-q3",
            category: .irrelevantSentence,
            sprintMode: .irrelevantSentenceDetective,
            track: .socialSciences,
            timeLimitSeconds: 45,
            stemText: "(I) The Rosetta Stone, inscribed in 196 BC, provided the critical key to deciphering ancient Egyptian hieroglyphs. (II) Its surface features the same royal decree written in three distinct scripts: Hieroglyphic, Demotic, and Ancient Greek. (III) Because scholars could already read Ancient Greek, they were able to compare the texts and unlock the phonetic value of the hieroglyphic signs. (IV) Jean-François Champollion announced this historic breakthrough in Paris in 1822. (V) Nonetheless, the construction of the Great Pyramid of Giza required tens of thousands of skilled quarry workers over two decades.",
            highlightedClues: [
                ClueSpan(id: "ir3-c1", matchedSubstring: "(II) Its surface ... (III) compare the texts ... (IV) this historic breakthrough", clueType: .pronounReference, explanationTr: "I, II, III ve IV. cümleler kesintisiz bir zincir halinde Rosetta Taşı'nın hiyeroglifleri çözme öyküsünü anlatıyor."),
                ClueSpan(id: "ir3-c2", matchedSubstring: "(V) the construction of the Great Pyramid of Giza", clueType: .topicShift, explanationTr: "Konu Kayması! V. cümle birdenbire Giza Piramidi'nin inşaat işçilerine geçiyor!")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "I",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İlk cümleyi test ettin!",
                        trapReasonTr: "II. cümledeki 'Its surface' doğrudan I. cümledeki 'The Rosetta Stone'a aittir.",
                        winningRuleTr: "Piramit inşaatından bahseden E şıkkı (V) akışı bozmaktadır.",
                        grammarRuleTag: "IRRELEVANT_TOPIC_SHIFT"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "II",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İkinci cümleyi kontrol ettin!",
                        trapReasonTr: "III. cümledeki 'Ancient Greek' ve 'compare the texts' ifadeleri doğrudan II. cümledeki 3 yazı sistemine bağlanır.",
                        winningRuleTr: "E şıkkı (V) doğru cevaptır.",
                        grammarRuleTag: "IRRELEVANT_TOPIC_SHIFT"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "III",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Üçüncü cümleyi inceledin!",
                        trapReasonTr: "IV. cümledeki 'this historic breakthrough' (bu tarihi buluş), III. cümledeki hiyerogliflerin çözülmesine referans verir.",
                        winningRuleTr: "Konuyu piramit inşaatına saptıran E şıkkı (V) seçilmeliydi.",
                        grammarRuleTag: "IRRELEVANT_TOPIC_SHIFT"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "IV",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Tarih ve kişi ismine dikkat ettin!",
                        trapReasonTr: "Champollion'un 1822'de duyurduğu buluş ('this historic breakthrough') doğrudan Rosetta Taşı'nın çözülmesidir.",
                        winningRuleTr: "Rosetta Taşı'ndan Giza Piramidi inşaatına atlayan E şıkkı (V) akışı bozar.",
                        grammarRuleTag: "IRRELEVANT_TOPIC_SHIFT"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "V",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Harika! İlk 4 cümlenin Rosetta Taşı ve hiyerogliflerin çözümü etrafında kenetlendiğini, V. cümlenin ise 'Mısır' ortak kelimesiyle Giza Piramidi inşaatına saptığını anında yakaladın!",
                        trapReasonTr: "Aynı uygarlık ('Ancient Egypt') tuzağına düşmedin.",
                        winningRuleTr: "Genel 'Mısır' teması yetmez; paragrafın mikro-konusu 'Rosetta Taşı'nın deşifresi'dir.",
                        grammarRuleTag: "IRRELEVANT_TOPIC_SHIFT"
                    )
                )
            ],
            correctOptionId: "E"
        ),
        SprintQuestion(
            id: "ir-q4",
            category: .irrelevantSentence,
            sprintMode: .irrelevantSentenceDetective,
            track: .healthSciences,
            timeLimitSeconds: 45,
            stemText: "(I) Cochlear implants have revolutionized auditory rehabilitation for individuals with severe sensorineural hearing loss. (II) Traditional acoustic hearing aids simply amplify incoming sound waves for the damaged middle ear. (III) Unlike conventional hearing aids that merely make sounds louder, a cochlear implant bypasses damaged hair cells and directly stimulates the auditory nerve. (IV) Signals generated by the implant's external processor are transmitted to an internal electrode array surgically placed in the cochlea. (V) The brain then learns to interpret these electrical impulses as recognizable speech and environmental sounds.",
            highlightedClues: [
                ClueSpan(id: "ir4-c1", matchedSubstring: "(III) Unlike conventional hearing aids that merely make sounds louder", clueType: .pronounReference, explanationTr: "DİKKAT! III. cümle zaten klasik işitme cihazlarının sadece sesi yükselttiğini yeni bir bilgi olarak açıklıyor; II. cümle ise bunu gereksiz yere tekrar edip I ile III arasına girmiş!"),
                ClueSpan(id: "ir4-c2", matchedSubstring: "(IV) Signals generated by the implant's ... (V) these electrical impulses", clueType: .pronounReference, explanationTr: "III -> IV -> V koklear implantın çalışma mekanizmasını adım adım anlatıyor.")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "I",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Giriş cümlesini sorguladın!",
                        trapReasonTr: "Paragrafın ana öznesi 'Cochlear implants' I. cümlede tanıtılıyor.",
                        winningRuleTr: "III. cümlede zaten 'Unlike conventional hearing aids...' diye özetlenen bilgiyi gereksiz yere özne yaparak akışı bölen B şıkkı (II) çıkarılmalıdır.",
                        grammarRuleTag: "IRRELEVANT_SUBJECT_SHIFT"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "II",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Usta işi! III. cümlenin 'Unlike conventional hearing aids that merely make sounds louder...' diyerek karşılaştırmayı bizzat yaptığını, dolayısıyla II. cümlenin özneyi bozan gereksiz bir saptırma olduğunu yakaladın!",
                        trapReasonTr: "'Hearing aids' kelimesi hem II hem III'te geçtiği için bunları birbirine bağlı sanma tuzağına düşmedin!",
                        winningRuleTr: "III. cümle 'Unlike X that does Y' diye başlıyorsa, bir önceki cümlede X'in Y yaptığını ayrı bir ana özne olarak anlatan cümle %100 tuzaktır!",
                        grammarRuleTag: "IRRELEVANT_SUBJECT_SHIFT"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "III",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "II ve III arasındaki tekrarı fark ettin!",
                        trapReasonTr: "Ancak III. cümleyi atarsan IV. cümledeki 'the implant's external processor' ve V. cümledeki 'these electrical impulses' havada kalır; çünkü paragrafın asıl konusu Koklear İmplanttır!",
                        winningRuleTr: "Ana öznesi 'Traditional hearing aids' olan B şıkkı (II) akışı bozmaktadır.",
                        grammarRuleTag: "IRRELEVANT_SUBJECT_SHIFT"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "IV",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Teknik detayı inceledin!",
                        trapReasonTr: "IV. cümle implantın sinyalleri nasıl ilettiğini anlatır ve V. cümle 'these electrical impulses' diyerek doğrudan IV'e bağlanır.",
                        winningRuleTr: "B şıkkı (II) doğru cevaptır.",
                        grammarRuleTag: "IRRELEVANT_SUBJECT_SHIFT"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "V",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Son cümleyi kontrol ettin!",
                        trapReasonTr: "V. cümle 'The brain then learns to interpret these electrical impulses...' diyerek III ve IV'te başlayan süreci tamamlar.",
                        winningRuleTr: "B şıkkı (II) seçilmeliydi.",
                        grammarRuleTag: "IRRELEVANT_SUBJECT_SHIFT"
                    )
                )
            ],
            correctOptionId: "B"
        ),
        SprintQuestion(
            id: "ir-q5",
            category: .irrelevantSentence,
            sprintMode: .irrelevantSentenceDetective,
            track: .naturalSciences,
            timeLimitSeconds: 45,
            stemText: "(I) Bioluminescence, the production and emission of light by living organisms, occurs predominantly in deep-sea marine environments. (II) At depths below 200 meters, where sunlight cannot penetrate, over 75 percent of pelagic species possess this biochemical capability. (III) Deep-sea submersibles must be constructed with thick titanium hulls to withstand crushing hydrostatic pressures. (IV) They utilize the emitted light for diverse survival functions, including attracting prey, camouflaging against predators, and communicating with mates. (V) This cold light is generated through a chemical reaction between luciferin and the enzyme luciferase.",
            highlightedClues: [
                ClueSpan(id: "ir5-c1", matchedSubstring: "(II) possess this biochemical capability", clueType: .pronounReference, explanationTr: "I. cümledeki biyolüminesans tanımına doğrudan bağlanır."),
                ClueSpan(id: "ir5-c2", matchedSubstring: "(IV) They utilize the emitted light", clueType: .pronounReference, explanationTr: "'They' -> II. cümledeki 'pelagic species'e referans verir! Aradaki III. cümle (denizaltıların titanyum gövdesi) akışı bozuyor!")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "I",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İlk cümleyi kontrol ettin!",
                        trapReasonTr: "I. cümle paragrafın ana kavramı olan 'Bioluminescence'ı tanımlar.",
                        winningRuleTr: "Canlıların ışık üretmesinden denizaltıların titanyum gövdesine atlayan C şıkkı (III) akışı bozar.",
                        grammarRuleTag: "IRRELEVANT_PRONOUN_CHAIN"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "II",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İkinci cümleyi inceledin!",
                        trapReasonTr: "IV. cümledeki 'They' zamiri doğrudan II. cümledeki 'pelagic species'e (deniz canlılarına) referans verir.",
                        winningRuleTr: "Aradaki C şıkkı (III) çıkarılmalıdır.",
                        grammarRuleTag: "IRRELEVANT_PRONOUN_CHAIN"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "III",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Dedektif refleksi! II. cümledeki 'pelagic species' ile IV. cümledeki 'They utilize the emitted light' arasındaki zamir bağını gördün ve araya giren 'titanyum denizaltı gövdesi' (III) cümlesini avladın!",
                        trapReasonTr: "'Deep-sea' kelimesine aldanıp III'ü konuyla uyumlu sanmadın.",
                        winningRuleTr: "II (Çoğul Canlılar) ---> IV ('They utilize the light') = Aradaki cansız III. cümle akışı bozar!",
                        grammarRuleTag: "IRRELEVANT_PRONOUN_CHAIN"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "IV",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "IV. cümledeki 'They' zamirinin III'teki 'submersibles' (denizaltılar) ile uyuşmadığını yakaladın!",
                        trapReasonTr: "Çok doğru bir tespit yaptın ama yanlış cümleyi suçladın! 'They' avını çekmek ve eşleşmek için ışığı kullanan denizaltılar olamayacağına göre, araya sonradan giren cümle III. cümledir!",
                        winningRuleTr: "C şıkkı (III) doğru cevaptır.",
                        grammarRuleTag: "IRRELEVANT_PRONOUN_CHAIN"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "V",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Son cümleyi kontrol ettin!",
                        trapReasonTr: "V. cümledeki 'This cold light' doğrudan IV. cümledeki 'the emitted light'a bağlanır.",
                        winningRuleTr: "C şıkkı (III) seçilmeliydi.",
                        grammarRuleTag: "IRRELEVANT_PRONOUN_CHAIN"
                    )
                )
            ],
            correctOptionId: "C"
        ),
        SprintQuestion(
            id: "ir-q6",
            category: .irrelevantSentence,
            sprintMode: .irrelevantSentenceDetective,
            track: .socialSciences,
            timeLimitSeconds: 45,
            stemText: "(I) Coffeehouses emerged in sixteenth-century Istanbul as vibrant spaces where men from diverse social strata gathered to debate politics and literature. (II) Botanical studies indicate that wild Arabica coffee shrubs require high altitudes and volcanic soil to thrive in Ethiopia. (III) Known locally as 'schools of the wise', these establishments democratized public discourse outside traditional palace and mosque hierarchies. (IV) Alarmed by their potential to foment political dissent, several Ottoman sultans issued decrees ordering their closure. (V) Yet such prohibitions proved futile, and coffeehouses remained central to urban civic life.",
            highlightedClues: [
                ClueSpan(id: "ir6-c1", matchedSubstring: "(III) these establishments", clueType: .pronounReference, explanationTr: "'these establishments' (bu mekanlar) -> I. cümledeki 'Coffeehouses'a referans verir!"),
                ClueSpan(id: "ir6-c2", matchedSubstring: "(II) Botanical studies ... wild Arabica coffee shrubs", clueType: .topicShift, explanationTr: "Konu Kayması! Metin Osmanlı İstanbul'undaki kahvehanelerin sosyopolitik rolünü anlatırken, II. cümle Etiyopya'daki kahve bitkisinin toprak/rakım botaniğine kaymış!")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "I",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İlk cümleyi kontrol ettin!",
                        trapReasonTr: "III. cümledeki 'these establishments', IV'teki 'their closure' ve V'teki 'coffeehouses' tamamen I. cümledeki 'Coffeehouses' öznesini takip ediyor.",
                        winningRuleTr: "Sosyolojiden Etiyopya botaniğine sapan B şıkkı (II) akışı bozar.",
                        grammarRuleTag: "IRRELEVANT_TOPIC_SHIFT"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "II",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Mükemmel! I. cümledeki 'Coffeehouses' (kahvehaneler) ile III. cümledeki 'these establishments' (bu mekanlar) köprüsünü kurdun ve araya giren Etiyopya botanik cümlesini (II) eledin!",
                        trapReasonTr: "'Coffee' kelimesi geçtiği için II. cümleyi konuyla alakalı sanma tuzağına düşmedin.",
                        winningRuleTr: "I ('Coffeehouses') ---> III ('these establishments') = Aradaki II ('coffee shrubs') dışarı!",
                        grammarRuleTag: "IRRELEVANT_TOPIC_SHIFT"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "III",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "III. cümledeki 'these establishments'ın II. cümleye uymadığını fark ettin!",
                        trapReasonTr: "Doğru ipucunu buldun ama III'ü değil, araya giren II. cümleyi atmalıydın; çünkü III, IV ve V. cümlelerin tamamı I. cümledeki kahvehaneleri anlatıyor.",
                        winningRuleTr: "B şıkkı (II) doğru cevaptır.",
                        grammarRuleTag: "IRRELEVANT_TOPIC_SHIFT"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "IV",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Dördüncü cümleyi inceledin!",
                        trapReasonTr: "V. cümledeki 'Yet such prohibitions' doğrudan IV. cümledeki kapatma fermanlarına ('decrees ordering their closure') bağlanır.",
                        winningRuleTr: "B şıkkı (II) seçilmeliydi.",
                        grammarRuleTag: "IRRELEVANT_TOPIC_SHIFT"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "V",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Son cümleyi kontrol ettin!",
                        trapReasonTr: "V. cümle 'such prohibitions' ile IV. cümleye sıkı sıkıya bağlıdır.",
                        winningRuleTr: "B şıkkı (II) doğru cevaptır.",
                        grammarRuleTag: "IRRELEVANT_TOPIC_SHIFT"
                    )
                )
            ],
            correctOptionId: "B"
        )
    ]

    // MARK: - 5. CLOZE TEST, EDAT, KISALTMA, CÜMLE TAMAMLAMA VE YAKIN ANLAM SPRINT SORULARI (8 Adet)
    public static let clozeAndDialogueQuestions: [SprintQuestion] = [
        SprintQuestion(
            id: "cd-q1",
            category: .preposition,
            sprintMode: .clozeAndDialogueSprint,
            track: .socialSciences,
            timeLimitSeconds: 30,
            stemText: "Archaeological excavations at Çatalhöyük have provided historians ____ invaluable insight ____ the egalitarian social organization of Neolithic settlements.",
            highlightedClues: [
                ClueSpan(id: "cd1-c1", matchedSubstring: "provided historians", clueType: .prepositionTrigger, explanationTr: "'provide somebody WITH something' (birine bir şey sağlamak)"),
                ClueSpan(id: "cd1-c2", matchedSubstring: "insight", clueType: .prepositionTrigger, explanationTr: "'insight INTO' (bir konuya dair derin kavrayış / ışık tutma)")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "for / on",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Provide fiilinin 'for' alabildiğini hatırladın!",
                        trapReasonTr: "Dikkat! 'Provide something FOR somebody' olur ama boşluktan önce KİŞİ ('historians'), sonra NESNE ('insight') gelmişse 'provide somebody WITH something' kullanılır!",
                        winningRuleTr: "'provide somebody WITH' + 'insight INTO' = B şıkkı ('with / into').",
                        grammarRuleTag: "PREP_PROVIDE_WITH_INSIGHT_INTO"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "with / into",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Çifte altın kalıp! 'provide somebody WITH' ve 'insight INTO' ikilisini hatasız birleştirdin!",
                        trapReasonTr: "'Provide for' ve 'insight on' tuzaklarına düşmedin.",
                        winningRuleTr: "Provide + Kişi + WITH + Nesne & Insight INTO.",
                        grammarRuleTag: "PREP_PROVIDE_WITH_INSIGHT_INTO"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "to / about",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Türkçe '-e sağlamak' ve 'hakkında kavrayış' mantığıyla yaklaştın!",
                        trapReasonTr: "Türkçe çeviri tuzağı! 'Provide' kişiden sonra 'to' almaz ('with' alır) ve 'insight' kelimesinin ayrılmaz edatı 'INTO'dur.",
                        winningRuleTr: "B şıkkındaki 'with / into' seçilmeliydi.",
                        grammarRuleTag: "PREP_PROVIDE_WITH_INSIGHT_INTO"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "by / over",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Edat uyumunu denedin!",
                        trapReasonTr: "Aktif bir cümlede 'provided' fiilinden sonra nesneyi bağlamak için 'by' kullanılmaz.",
                        winningRuleTr: "B şıkkı ('with / into') doğru cevaptır.",
                        grammarRuleTag: "PREP_PROVIDE_WITH_INSIGHT_INTO"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "with / from",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İlk boşluktaki 'provide historians WITH' kalıbını harika yakaladın!",
                        trapReasonTr: "İkinci boşlukta 'insight' kelimesi bir konunun İÇİNE nüfuz etmeyi anlattığı için 'from' değil 'INTO' alır.",
                        winningRuleTr: "'with / into' (B şıkkı) seçilmeliydi.",
                        grammarRuleTag: "PREP_PROVIDE_WITH_INSIGHT_INTO"
                    )
                )
            ],
            correctOptionId: "B"
        ),
        SprintQuestion(
            id: "cd-q2",
            category: .reductionAndTense,
            sprintMode: .clozeAndDialogueSprint,
            track: .naturalSciences,
            timeLimitSeconds: 35,
            stemText: "By the time the Voyager 1 spacecraft ____ the heliopause in 2012, it ____ through the solar system for nearly thirty-five years.",
            highlightedClues: [
                ClueSpan(id: "cd2-c1", matchedSubstring: "By the time ... in 2012", clueType: .conjunction, explanationTr: "Geçmiş zaman referansı ('in 2012') ile 'By the time + V2' kalıbı"),
                ClueSpan(id: "cd2-c2", matchedSubstring: "for nearly thirty-five years", clueType: .mainVerb, explanationTr: "Ana cümlede süreç ('for 35 years') olduğu için Past Perfect Continuous ('had been V-ing')!")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "crossed / had been traveling",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Altın Tense kuralı! 'By the time + V2 (in 2012), had been V-ing (for 35 years)' formülünü saniyesinde uyguladın!",
                        trapReasonTr: "'has been traveling' (Present) ve 'will have' (Future) tuzaklarını 'in 2012' ipucuyla eledin.",
                        winningRuleTr: "By the time + V2, had V3 / had been V-ing (for + süreç).",
                        grammarRuleTag: "TENSE_BY_THE_TIME_PAST"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "had crossed / was traveling",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Cümlenin Past (geçmiş) eksende olduğunu doğru gördün!",
                        trapReasonTr: "Ancak 'By the time' yan cümleciğinin içine 'had V3' GELMEZ! 'had V3 / had been V-ing' virgülden sonraki ana cümlede yer alır.",
                        winningRuleTr: "'By the time + V2 (crossed), had been traveling' (A şıkkı) doğrudur.",
                        grammarRuleTag: "TENSE_BY_THE_TIME_PAST"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "crosses / will have been traveling",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "'By the time'ın Perfect bir ana yüklem istediğini çok iyi biliyorsun!",
                        trapReasonTr: "Fakat cümlede net bir geçmiş tarih ('in 2012') var! 'in 2012' varken Present/Future ('crosses / will have') kullanılamaz.",
                        winningRuleTr: "Past versiyonu olan A şıkkı ('crossed / had been traveling') seçilmeliydi.",
                        grammarRuleTag: "TENSE_PAST_TIME_MARKER"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "has crossed / had traveled",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İkinci kısımda Past Perfect araman doğruydu!",
                        trapReasonTr: "İlk kısımda 'in 2012' (net geçmiş zaman) olduğu için Present Perfect ('has crossed') kesinlikle elenir.",
                        winningRuleTr: "A şıkkı ('crossed / had been traveling') doğru cevaptır.",
                        grammarRuleTag: "TENSE_PAST_TIME_MARKER"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "was crossing / has been traveling",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Süreç ifadesini ('for 35 years') fark ettin!",
                        trapReasonTr: "2012 yılına kadar süren 35 yıllık geçmiş süreç 'has been' (şu ana kadar) değil, 'had been traveling' (2012'ye kadar) ile anlatılır.",
                        winningRuleTr: "A şıkkı doğru cevaptır.",
                        grammarRuleTag: "TENSE_BY_THE_TIME_PAST"
                    )
                )
            ],
            correctOptionId: "A"
        ),
        SprintQuestion(
            id: "cd-q3",
            category: .sentenceCompletion,
            sprintMode: .clozeAndDialogueSprint,
            track: .healthSciences,
            timeLimitSeconds: 40,
            stemText: "Even though the human immune system is remarkably adept at neutralizing familiar viral pathogens, ____.",
            highlightedClues: [
                ClueSpan(id: "cd3-c1", matchedSubstring: "Even though", clueType: .conjunction, explanationTr: "Zıtlık Bağlacı (⇄): Yan cümle (+) olumlu ('remarkably adept' = son derece yetenekli), ana cümle (-) olumsuz olmalı!"),
                ClueSpan(id: "cd3-c2", matchedSubstring: "familiar viral pathogens", clueType: .topicShift, explanationTr: "Karşıtlık İpucu: 'tanıdık virüslere karşı yetenekli (+)' <-> 'yeni/mutasyonlu virüslere karşı zorlanır (-)'")
            ],
            expectedLeftPolarity: .positive,
            expectedRightPolarity: .negative,
            options: [
                QuestionOption(
                    id: "A",
                    text: "vaccination campaigns have successfully eradicated smallpox across the globe",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Bağışıklık ve virüs temalı bir şık seçtin!",
                        trapReasonTr: "Kutup hatası! 'Even though' yan cümlesi (+) olumlu ('remarkably adept'). Bu şık da (+) olumlu ('successfully eradicated')! Zıtlık oluşmadı ve 'the human immune system' referansı koptu.",
                        winningRuleTr: "Hem 'it' zamir takibini koruyan hem de (-) olumsuz zıtlığı veren D şıkkı seçilmeliydi.",
                        grammarRuleTag: "COMP_EVEN_THOUGH_POLARITY"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "memory B-cells continue to produce targeted antibodies for decades after exposure",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Konu bütünlüğünü korudun!",
                        trapReasonTr: "Bu şık bağışıklık sisteminin başarısını (+) anlatmaya devam ediyor; oysa cümle başında 'Even though' (-e rağmen) var, yani bir zayıflık (-) gelmeli!",
                        winningRuleTr: "Yeni mutasyonlar karşısında savunmasız kaldığını (-) anlatan D şıkkı doğrudur.",
                        grammarRuleTag: "COMP_EVEN_THOUGH_POLARITY"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "antibiotics remain completely ineffective against viral infections such as influenza",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Olumsuz (-) kutuplu bir cümle araman çok doğruydu!",
                        trapReasonTr: "Ancak ÖZNE KAYMASI tuzağına düştün! Yan cümle 'insan bağışıklık sisteminin tanıdık virüsleri etkisiz hale getirmesinden' bahsederken bu şık birdenbire 'antibiyotiklere' atlıyor.",
                        winningRuleTr: "Özneyi 'it' (= human immune system) ile takip eden ve 'tanıdık virüs <-> yeni zoonotik suş' zıtlığı kuran D şıkkı seçilmeliydi.",
                        grammarRuleTag: "COMP_SUBJECT_CONTINUITY"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "it can be easily overwhelmed when confronted with novel zoonotic strains that mutate rapidly",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Kusursuz! 1) 'Even though' (+) -> (-) kutup zıtlığı, 2) 'the human immune system' -> 'it' zamir takibi, 3) 'familiar pathogens' <-> 'novel strains' karşıtlığı!",
                        trapReasonTr: "Özne değiştiren C şıkkı ve (+) kutuplu A-B tuzaklarını ustalıkla eledin.",
                        winningRuleTr: "Cümle Tamamlama Altın Üçgeni: Kutup (+ / -) + Zamir ('it') + Sıfat Karşıtlığı ('familiar' vs 'novel').",
                        grammarRuleTag: "COMP_EVEN_THOUGH_POLARITY"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "regular physical exercise strengthens leukocyte circulation throughout the bloodstream",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Bağışıklık konusuyla ilgili şıkkı inceledin!",
                        trapReasonTr: "Hem olumlu (+) olduğu için 'Even though' ile çelişiyor hem de 'fiziksel egzersiz' diyerek konuyu dağıtıyor.",
                        winningRuleTr: "D şıkkı doğru cevaptır.",
                        grammarRuleTag: "COMP_EVEN_THOUGH_POLARITY"
                    )
                )
            ],
            correctOptionId: "D"
        ),
        SprintQuestion(
            id: "cd-q4",
            category: .academicVocab,
            sprintMode: .clozeAndDialogueSprint,
            track: .naturalSciences,
            timeLimitSeconds: 30,
            stemText: "Microplastic particles have become so ____ in marine food webs that researchers have detected them even in amphipods inhabiting the deepest ocean trenches.",
            highlightedClues: [
                ClueSpan(id: "cd4-c1", matchedSubstring: "so ____ in marine food webs that", clueType: .conjunction, explanationTr: "'So + Sıfat + that' kalıbı: Sonuç cümlesi sıfatın anlamını açıklar!"),
                ClueSpan(id: "cd4-c2", matchedSubstring: "detected them even in ... the deepest ocean trenches", clueType: .mainVerb, explanationTr: "En derin okyanus çukurlarında bile tespit edildiyse -> 'her yerde bulunan / çok yaygın' (ubiquitous / pervasive / prevalent)")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "negligible",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Akademik bir sıfat seçtin!",
                        trapReasonTr: "'Negligible' (göz ardı edilebilir derecede az / önemsiz) demektir; eğer önemsiz olsaydı 'en derin okyanus çukurlarında bile tespit edildi' denmezdi.",
                        winningRuleTr: "'Her yerde bulunan / çok yaygın' anlamındaki C şıkkı ('ubiquitous' = pervasive/prevalent) seçilmeliydi.",
                        grammarRuleTag: "VOCAB_SO_THAT_CLUE"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "obsolete",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "YDS'de sık çıkan bir sıfatı tanıdın!",
                        trapReasonTr: "'Obsolete' (modası geçmiş / kullanımdan kalkmış) teknolojiler veya yöntemler için kullanılır.",
                        winningRuleTr: "Yaygınlık bildiren C şıkkındaki 'ubiquitous' doğrudur.",
                        grammarRuleTag: "VOCAB_SO_THAT_CLUE"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "ubiquitous",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Tam isabet! 'even in the deepest ocean trenches' (en derin çukurlarda bile) ipucundan boşluğun 'her yerde hazır ve nazır / çok yaygın' ('ubiquitous') olduğunu buldun!",
                        trapReasonTr: "'Negligible' ve 'scarce' (az/kıt) tuzaklarını eledin.",
                        winningRuleTr: "Ubiquitous = Omnipresent = Pervasive = Prevalent (Her yerde bulunan / yaygın).",
                        grammarRuleTag: "VOCAB_SO_THAT_CLUE"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "ambiguous",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Akademik sıfatları değerlendirdin!",
                        trapReasonTr: "'Ambiguous' (muğlak / belirsiz = vague) ifadeler veya kurallar için kullanılır; mikroplastiklerin okyanustaki varlığı için kullanılmaz.",
                        winningRuleTr: "C şıkkındaki 'ubiquitous' doğru cevaptır.",
                        grammarRuleTag: "VOCAB_SO_THAT_CLUE"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "scarce",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Miktar/yoğunluk bildiren bir sıfat aradın!",
                        trapReasonTr: "'Scarce' (kıt / nadir) tam zıt anlamdır; en derin çukurlarda bile çıkması kıt değil, her yerde ('ubiquitous') olduğunu kanıtlar.",
                        winningRuleTr: "C şıkkı seçilmeliydi.",
                        grammarRuleTag: "VOCAB_SO_THAT_CLUE"
                    )
                )
            ],
            correctOptionId: "C"
        ),
        SprintQuestion(
            id: "cd-q5",
            category: .dialogueAndRestatement,
            sprintMode: .clozeAndDialogueSprint,
            track: .socialSciences,
            timeLimitSeconds: 45,
            stemText: "Yakın Anlam (Restatement): No sooner had the central bank announced an aggressive interest rate hike than foreign investors began to withdraw capital from emerging markets.",
            highlightedClues: [
                ClueSpan(id: "cd5-c1", matchedSubstring: "No sooner had ... than", clueType: .conjunction, explanationTr: "Kalıp İkizi: 'No sooner ... than' = 'Hardly ... when' = 'Immediately after / As soon as' (Yapar yapmaz / Hemen ardından)"),
                ClueSpan(id: "cd5-c2", matchedSubstring: "announced ... began to withdraw", clueType: .mainVerb, explanationTr: "1. Olay: Faiz artışı duyurusu -> Hemen 2. Olay: Yabancı yatırımcıların sermaye çekmeye başlaması")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "Foreign investors started pulling capital out of emerging markets immediately after the central bank declared a sharp increase in interest rates.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Yakın anlam ustası! 'No sooner ... than' kalıbını 'immediately after' ile, 'aggressive hike'ı 'sharp increase' ile, 'withdraw'u 'pull out of' ile 1:1 eşleştirdin!",
                        trapReasonTr: "Olay sırasını ters çeviren veya neden-sonuç uyduran şıklara düşmedin.",
                        winningRuleTr: "No sooner had X than Y = Immediately after X, Y = As soon as X, Y.",
                        grammarRuleTag: "RESTATE_NO_SOONER_THAN"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "Until the central bank decided to raise interest rates aggressively, foreign investors had been reluctant to withdraw their capital from emerging markets.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Zaman bağlacı dönüşümünü aradın!",
                        trapReasonTr: "Soru kökünde yatırımcıların önceden 'isteksiz olduğu' ('reluctant') bilgisi kesinlikle yok.",
                        winningRuleTr: "'Immediately after' (hemen ardından) dönüşümü yapan A şıkkı doğrudur.",
                        grammarRuleTag: "RESTATE_NO_SOONER_THAN"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "The central bank announced a steep interest rate hike only after foreign investors began withdrawing capital from emerging markets.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İki olayın peş peşe olduğunu gördün!",
                        trapReasonTr: "KRONOLOJİ TUZAĞI! 'No sooner had X than Y' kalıbında ÖNCE X (merkez bankası duyurusu), SONRA Y (sermaye çekimi) olur. Bu şıkta ise 'only after' ile sıra tersine çevrilmiş!",
                        winningRuleTr: "Önce duyuru, hemen ardından sermaye çekimi diyen A şıkkı seçilmeliydi.",
                        grammarRuleTag: "RESTATE_CHRONOLOGY_SWAP"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "Had the central bank not raised interest rates so aggressively, foreign investors would not have withdrawn their capital from emerging markets.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Devrik yapıyı ('Had...') tanıdın!",
                        trapReasonTr: "Soru kökündeki 'No sooner had' zaman kalıbıdır; 'Had ... not' ise hayali koşul (If Type 3) kalıbıdır.",
                        winningRuleTr: "Zaman eşdeğeri olan A şıkkı doğru cevaptır.",
                        grammarRuleTag: "RESTATE_NO_SOONER_THAN"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "Even though the central bank announced an aggressive interest rate hike, foreign investors segera withdrew their capital from emerging markets.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "İki cümleyi karşılaştırdın!",
                        trapReasonTr: "'No sooner ... than' zıtlık ('Even though') değil, anlık ardışıklık ('yapar yapmaz') bildirir.",
                        winningRuleTr: "A şıkkı doğru cevaptır.",
                        grammarRuleTag: "RESTATE_NO_SOONER_THAN"
                    )
                )
            ],
            correctOptionId: "A"
        ),
        SprintQuestion(
            id: "cd-q6",
            category: .clozeTest,
            sprintMode: .clozeAndDialogueSprint,
            track: .healthSciences,
            timeLimitSeconds: 35,
            stemText: "Cloze Test: Alzheimer's disease is characterized by the progressive accumulation of amyloid-beta plaques in cerebral tissue. Researchers have long debated ____ these protein aggregates are the primary cause of neurodegeneration or merely a byproduct of an underlying inflammatory process.",
            highlightedClues: [
                ClueSpan(id: "cd6-c1", matchedSubstring: "debated ____", clueType: .conjunction, explanationTr: "Fiilden sonra gelen Noun Clause (İsim Cümleciği)"),
                ClueSpan(id: "cd6-c2", matchedSubstring: "or merely a byproduct", clueType: .conjunction, explanationTr: "Cümle devamında '... OR ...' (birincil neden mi YOKSA sadece bir yan ürün mü olduğu) ikilemi var -> 'whether ... or'!")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "that",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Fiilden sonra Noun Clause bağlacı geleceğini doğru gördün!",
                        trapReasonTr: "'That' kesinlik bildirir; oysa 'debated' (tartışmaktadır) fiili ve devamındaki '... or merely a byproduct' (yoksa ... mı) yapısı bir ikilem/şüphe anlatır.",
                        winningRuleTr: "'Debate / question / wonder' + '... or ...' gördüğün yerde cevap %100 B şıkkındaki 'whether'dır!",
                        grammarRuleTag: "CLOZE_WHETHER_OR"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "whether",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Tam isabet! 'debated' (tartıştı) fiilini ve cümle sonundaki 'or' ikilemini birleştirip 'whether ... or' (-ip -mediğini) kalıbını anında yakaladın!",
                        trapReasonTr: "'That' ve 'what' çeldiricilerine hiç takılmadın.",
                        winningRuleTr: "Debate / Determine / Investigate + WHETHER ... OR ... (-ip -mediği).",
                        grammarRuleTag: "CLOZE_WHETHER_OR"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "what",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Noun Clause bağlacı seçtin!",
                        trapReasonTr: "'What' kendisinden sonra gelen cümlede özne veya nesnenin EKSİK olmasını ister; oysa 'these protein aggregates are the primary cause' tam ve eksiksiz bir cümledir.",
                        winningRuleTr: "Tam cümle ve 'or' ile çalışan B şıkkındaki 'whether' seçilmeliydi.",
                        grammarRuleTag: "CLOZE_WHAT_VS_THAT_WHETHER"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "which",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Seçenek/ikilem anlamını hissettin!",
                        trapReasonTr: "'Which' tek başına tam cümle önünde '-ip -mediği' anlamı vermez ('which of these...' veya 'which protein...' olmalıydı).",
                        winningRuleTr: "'Whether ... or' kalıbıyla B şıkkı doğrudur.",
                        grammarRuleTag: "CLOZE_WHETHER_OR"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "how",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Soru kelimesiyle başlayan isim cümleciği düşündün!",
                        trapReasonTr: "Devamındaki 'or merely a byproduct' (yoksa sadece bir yan ürün mü) ifadesi 'nasıl' ('how') sorusuna değil, 'öyle mi yoksa böyle mi' ('whether ... or') sorusuna cevap verir.",
                        winningRuleTr: "B şıkkındaki 'whether' doğru cevaptır.",
                        grammarRuleTag: "CLOZE_WHETHER_OR"
                    )
                )
            ],
            correctOptionId: "B"
        ),
        SprintQuestion(
            id: "cd-q7",
            category: .sentenceCompletion,
            sprintMode: .clozeAndDialogueSprint,
            track: .socialSciences,
            timeLimitSeconds: 40,
            stemText: "Because early cuneiform tablets in Mesopotamia were primarily used to record grain rations and tax deliveries, ____.",
            highlightedClues: [
                ClueSpan(id: "cd7-c1", matchedSubstring: "Because", clueType: .conjunction, explanationTr: "Neden-Sonuç Bağlacı (⇉): Tahıl tayınlarını ve vergi teslimatlarını kaydetmek için kullanıldığı İÇİN..."),
                ClueSpan(id: "cd7-c2", matchedSubstring: "early cuneiform tablets", clueType: .pronounReference, explanationTr: "Çoğul Özne: Ana cümlede 'they' zamiriyle veya 'yazının kökeni ekonomi/bürokrasiye dayanır' sonucuyla karşılanmalı!")
            ],
            expectedLeftPolarity: .positive,
            expectedRightPolarity: .positive,
            options: [
                QuestionOption(
                    id: "A",
                    text: "the invention of writing is widely considered by historians to have been driven by administrative and economic necessity rather than literary expression",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Mükemmel çıkarım! 'Tahıl ve vergi kaydı için kullanıldığı için -> yazının icadı edebi ifadeden ziyade idari ve ekonomik ihtiyaçtan doğmuştur' neden-sonuç zincirini kurdun!",
                        trapReasonTr: "Konuyu dağıtıp Mısır papirüslerine veya zıtlığa kaçan şıkları eledin.",
                        winningRuleTr: "Tahıl & Vergi Kaydı (Neden) ---> İdari ve Ekonomik İhtiyaç (Sonuç).",
                        grammarRuleTag: "COMP_CAUSE_EFFECT_LOGIC"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "ancient Egyptian scribes preferred papyrus scrolls over heavy clay surfaces for monumental inscriptions",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Antik yazı malzemesi temasını gördün!",
                        trapReasonTr: "ÖZNE VE COĞRAFYA KAYMASI! Yan cümle Mezopotamya çivi yazılı tabletlerinin vergi kaydı için kullanılmasından bahsederken, bu şık Mısır katiplerinin papirüs tercihine atlıyor.",
                        winningRuleTr: "Mezopotamya'daki vergi kaydını yazının ekonomik kökenine bağlayan A şıkkı doğrudur.",
                        grammarRuleTag: "COMP_SUBJECT_CONTINUITY"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "epic poetry such as the Epic of Gilgamesh constituted the earliest known examples of cuneiform script",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Mezopotamya bağlamını korudun!",
                        trapReasonTr: "ÇELİŞKİ TUZAĞI! Yan cümlede 'öncelikle tahıl ve vergi kaydetmek için kullanıldığı İÇİN' denirken, sonuçta 'en eski örnekleri Gılgamış gibi destansı şiirlerdi' denemez!",
                        winningRuleTr: "'Edebi ifadeden ziyade idari ve ekonomik ihtiyaçtan doğdu' diyen A şıkkı seçilmeliydi.",
                        grammarRuleTag: "COMP_CAUSE_EFFECT_LOGIC"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "most rural farmers in the Tigris valley were fluent in both Sumerian and Akkadian dialects",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Bölge uyumuna dikkat ettin!",
                        trapReasonTr: "Tabletlerin vergi kaydı için kullanılması, kırsaldaki çiftçilerin iki dili akıcı konuştuğunun nedeni olamaz.",
                        winningRuleTr: "A şıkkı doğru cevaptır.",
                        grammarRuleTag: "COMP_CAUSE_EFFECT_LOGIC"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "archaeologists have failed to decipher the numerical symbols engraved on temple walls",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Arkeoloji ve sembol bağlantısını inceledin!",
                        trapReasonTr: "Eğer tabletlerin tahıl ve vergi kaydı için kullanıldığını biliyorsak, sayısal sembollerin çözülemediği ('failed to decipher') söylenemez.",
                        winningRuleTr: "A şıkkı doğru cevaptır.",
                        grammarRuleTag: "COMP_CAUSE_EFFECT_LOGIC"
                    )
                )
            ],
            correctOptionId: "A"
        ),
        SprintQuestion(
            id: "cd-q8",
            category: .dialogueAndRestatement,
            sprintMode: .clozeAndDialogueSprint,
            track: .naturalSciences,
            timeLimitSeconds: 40,
            stemText: "Diyalog Tamamlama:\nDr. Aris: Many policymakers assume that planting fast-growing monoculture pine plantations is just as effective for carbon sequestration as preserving old-growth rainforests.\nDr. Tekin: ____\nDr. Aris: Exactly. Moreover, single-species plantations lack the complex root networks and fungal symbiosis that lock carbon deep underground for centuries.",
            highlightedClues: [
                ClueSpan(id: "cd8-c1", matchedSubstring: "assume that ... monoculture pine plantations is just as effective ... as preserving old-growth rainforests", clueType: .topicShift, explanationTr: "Dr. Aris politikacıların yanlış bir varsayımını ('tek tip çam dikmek kadim ormanları korumak kadar etkilidir sanıyorlar') ortaya koyuyor."),
                ClueSpan(id: "cd8-c2", matchedSubstring: "Exactly. Moreover, single-species plantations lack", clueType: .pronounReference, explanationTr: "Dr. Aris 'Kesinlikle! Üstelik tek tür ağaçlandırmalar ...-dan yoksundur' diyerek onaylıyor -> Dr. Tekin de bu varsayımın YANLIŞ olduğunu ve doğal ormanların çok daha üstün olduğunu söylemeli!")
            ],
            options: [
                QuestionOption(
                    id: "A",
                    text: "Indeed, commercial timber plantations reach maturity much faster than tropical ecosystems.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Plantasyon konusunu takip ettin!",
                        trapReasonTr: "Eğer Dr. Tekin ticari plantasyonları överse, Dr. Aris'in 'Exactly. Moreover, single-species plantations lack...' (Kesinlikle. Üstelik tek tür plantasyonlar ...-dan yoksundur) diyerek plantasyonları eleştirmesi çelişkili olur!",
                        winningRuleTr: "Politikacıların bu varsayımının yanıltıcı olduğunu söyleyen C şıkkı seçilmeliydi.",
                        grammarRuleTag: "DIALOGUE_AGREEMENT_FLOW"
                    )
                ),
                QuestionOption(
                    id: "B",
                    text: "Why do you think governments prioritize reforestation over industrial carbon capture technologies?",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Politika boyutuna dikkat ettin!",
                        trapReasonTr: "Dr. Aris'in cevabı 'Exactly' (Kesinlikle/Tamamen öyle) diye başlıyor! 'Why do you think...?' (Neden böyle düşünüyorsun?) sorusuna 'Kesinlikle!' diye cevap verilmez!",
                        winningRuleTr: "Soru cümlesi olmayan ve varsayımı eleştiren C şıkkı doğrudur.",
                        grammarRuleTag: "DIALOGUE_EXACTLY_RESPONSE_TRAP"
                    )
                ),
                QuestionOption(
                    id: "C",
                    text: "That is a dangerous misconception, as commercial plantations store only a fraction of the carbon held by biodiverse primary forests.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Tam isabet! 1) 'assume that' -> 'That is a dangerous misconception', 2) Sonraki 'Exactly. Moreover, single-species plantations lack...' ile %100 organik akış!",
                        trapReasonTr: "'Why...?' sorusuna 'Exactly' denmeyeceğini ve kutup uyumunu harika kullandın.",
                        winningRuleTr: "Diyalog İpucu: Boşluktan sonra 'Exactly. Moreover + (-)' varsa boşluk da (-) eleştiri cümlesi olmak zorundadır!",
                        grammarRuleTag: "DIALOGUE_AGREEMENT_FLOW"
                    )
                ),
                QuestionOption(
                    id: "D",
                    text: "On the contrary, old-growth forests release more methane than newly planted saplings.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "Karşılaştırma yapısını gördün!",
                        trapReasonTr: "Bu şık yaşlı ormanları kötüleyip yeni fidanları savunuyor; oysa Dr. Aris 'Moreover, single-species plantations lack...' diyerek tek tip plantasyonların yetersizliğini anlatıyor.",
                        winningRuleTr: "Birincil ormanların üstünlüğünü vurgulayan C şıkkı doğrudur.",
                        grammarRuleTag: "DIALOGUE_AGREEMENT_FLOW"
                    )
                ),
                QuestionOption(
                    id: "E",
                    text: "I wasn't aware that fungal symbiosis played any role in soil carbon retention.",
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: "'Fungal symbiosis' kelimesini Dr. Aris'in ikinci konuşmasında gördün!",
                        trapReasonTr: "YDS DİYALOG TUZAĞI! Dr. Aris 'fungal symbiosis'ten ilk kez İKİNCİ konuşmasında ('Moreover...' diyerek yeni bir bilgi eklerken) bahsediyor; Dr. Tekin daha söylenmemiş bir şeye tepki veremez ve buna 'Exactly' denmez!",
                        winningRuleTr: "C şıkkı doğru cevaptır.",
                        grammarRuleTag: "DIALOGUE_PREMATURE_KEYWORD_TRAP"
                    )
                )
            ],
            correctOptionId: "C"
        )
    ]
}
