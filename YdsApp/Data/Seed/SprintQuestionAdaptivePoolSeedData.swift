import Foundation

/// Adaptif teşhis havuzu: 6 kategori × 3 zorluk bandı hücresini (EASY / MEDIUM / HARD) en az 2 soruya tamamlar.
/// Mevcut `diag-q*` soruları (conjunction/preposition/academicVocab: MEDIUM, reductionAndTense: HARD) ile birlikte
/// her hücrede ≥ 2 `isDiagnosticOnboarding` sorusu bulunur. Yeni soru id'leri `adp-` önekini taşır.
/// PEDAGOJİK KURAL: Her şıkta tam `DistractorExplanation` vardır; `winningRuleTr` tekrar kullanılabilir sınav kuralıdır.
public enum SprintQuestionAdaptivePoolSeedData {
    /// Legacy onboarding akışı (5 soru) bu önekle ayrılır; adaptif havuz `adp-` öneklidir.
    public static let idPrefix = "adp-"

    public static let allQuestions: [SprintQuestion] =
        conjunctionQuestions +
        prepositionQuestions +
        academicVocabQuestions +
        reductionAndTenseQuestions +
        sentenceCompletionQuestions +
        dialogueAndRestatementQuestions

    // MARK: - Builder

    private typealias Opt = (text: String, praise: String, trap: String)
    private typealias Clue = (text: String, type: ClueHighlightType, note: String)

    private static func make(
        _ id: String,
        _ category: QuestionCategory,
        _ track: AcademicTrack,
        _ band: QuestionDifficultyBand,
        irt: Double,
        stem: String,
        clues: [Clue],
        rule: String,
        tag: String,
        correct: String,
        _ opts: [Opt]
    ) -> SprintQuestion {
        let letters = ["A", "B", "C", "D", "E"]
        let time: Int = band == .easy ? 30 : (band == .medium ? 40 : 50)
        return SprintQuestion(
            id: "\(idPrefix)\(id)",
            category: category,
            sprintMode: .diagnosticMiniTest,
            track: track,
            isDiagnosticOnboarding: true,
            difficultyBand: band,
            irtDifficulty: irt,
            timeLimitSeconds: time,
            stemText: stem,
            highlightedClues: clues.enumerated().map { index, clue in
                ClueSpan(
                    id: "\(idPrefix)\(id)-c\(index + 1)",
                    matchedSubstring: clue.text,
                    clueType: clue.type,
                    explanationTr: clue.note
                )
            },
            options: opts.enumerated().map { index, opt in
                QuestionOption(
                    id: letters[index],
                    text: opt.text,
                    distractorCoachFeedback: DistractorExplanation(
                        praiseTextTr: opt.praise,
                        trapReasonTr: opt.trap,
                        winningRuleTr: rule,
                        grammarRuleTag: tag
                    )
                )
            },
            correctOptionId: correct
        )
    }

    // MARK: - 1. Conjunction

    public static let conjunctionQuestions: [SprintQuestion] = [
        // EASY: temel zıtlık bağlacı (B1), tek ipucu
        make("conj-e1", .conjunction, .healthSciences, .easy, irt: -1.2,
             stem: "____ the new vaccine was highly effective in clinical trials, regulators requested additional safety data.",
             clues: [("highly effective", .conjunction, "Olumlu bilgi: aşı etkili."), ("requested additional safety data", .conjunction, "Beklenmedik/ters yönlü sonuç: ek veri istendi.")],
             rule: "Boşluğun iki yanındaki cümlelerin yönü (+/-) ters ise zıtlık bağlacı (although, whereas) seç; aynı yönse neden-sonuç bağlacı ara.",
             tag: "CONJ_CONCESSION_ALTHOUGH", correct: "B", [
                ("Because", "Neden-sonuç bağlacını düşündün, iyi refleks.", "Aşı etkili ve 'ek veri' istendi: ikisi birbirinden beklenen sonuç gibi okunabilir, o yüzden 'Because' cazip."),
                ("Although", "Zıtlık yönünü doğru yakaladın.", "Tuzaklara düşmedin: etkili olmasına rağmen ek veri istenmesi bir zıtlıktır."),
                ("Therefore", "Sonuç bağlacını tanıdın.", "'Therefore' cümle başında bağlaç değil zarftır; iki yan cümleyi tek başına bağlayamaz."),
                ("Unless", "Koşul bağlacını bildin.", "'Unless' koşul bildirir; burada koşul değil karşıtlık var."),
                ("So that", "Amaç bağlacını hatırladın.", "'So that' amaç bildirir (...-sın diye); aşının etkisiyle ilgisi yok.")
             ]),
        // EASY: Unless = if...not, koşul mantığı
        make("conj-e2", .conjunction, .naturalSciences, .easy, irt: -1.0,
             stem: "Ice sheets will continue to shrink ____ greenhouse gas emissions are drastically reduced.",
             clues: [("will continue to shrink", .mainVerb, "Ana cümle olumlu sonuç: küçülmeye devam."), ("are drastically reduced", .conjunction, "Koşul: emisyon azalırsa sonuç değişir.")],
             rule: "'Unless' = 'if ... not'. Ana cümle olumsuz/kötü gidişatı anlatıyor ve çıkış koşulu veriliyorsa 'unless' ara.",
             tag: "CONJ_CONDITION_UNLESS", correct: "C", [
                ("Although", "Yan cümleyi bağlamaya çalıştın.", "Zıtlık gibi görünür ama emisyon azalması ile küçülme arasında karşıtlık değil koşul ilişkisi var."),
                ("Because", "Neden bağı kurmak mantıklı geldi.", "Emisyonların azalması küçülmenin nedeni olamaz; mantık tersine döner."),
                ("Unless", "Koşul mantığını doğru kurdun.", "'Although' ve 'Because' tuzaklarını eledin."),
                ("However", "Zıt anlamlı zarfı hatırladın.", "'However' zarftır; yan cümle başlatan bağlaç yerine geçmez."),
                ("Whereas", "Karşılaştırma bağlacını tanıdın.", "'Whereas' iki farklı özneyi karşılaştırır; burada tek bir olgunun koşulu var.")
             ]),
        // MEDIUM: noktalı virgül sonrası zarf bağlaç (B2)
        make("conj-m1", .conjunction, .socialSciences, .medium, irt: 0.1,
             stem: "Urban populations have grown rapidly over the past century; ____, many rural areas have steadily lost residents.",
             clues: [("grown rapidly", .conjunction, "Kentler: artış (+)."), ("steadily lost residents", .conjunction, "Kırsal: azalış (-): karşıtlık.")],
             rule: "Noktalı virgülden sonra zarf bağlaç gelir; önceki cümle (+) sonraki (-) ise karşıtlık zarfı (by contrast, however) seç.",
             tag: "CONJ_ADVERB_CONTRAST", correct: "B", [
                ("Therefore", "Zarf bağlaç kullanımını biliyorsun.", "Sonuç bağlacı kurar ama kırsalın boşalması kentin büyümesinin 'doğal sonucu' gibi görünebilir; yön ise zıttır."),
                ("By contrast", "Kent-kır karşılaştırmasını doğru okudun.", "Sonuç ve örnek ifadelerine kapılmadın."),
                ("Consequently", "Neden-sonuç zincirini düşündün.", "Sonuç gibi okunabilir ama metin iki alanı karşılaştırıyor, sebep göstermiyor."),
                ("Likewise", "Benzerlik bağlacını tanıdın.", "'Likewise' aynı yönde bilgi ekler; burada yön ters."),
                ("For instance", "Örnekleme bağlacını bildin.", "Kırsal kayıp, kentsel büyümenin örneği değil karşıt yönlü bir olgudur.")
             ]),
        // HARD: nadir bağlaç/edat ayrımı (C1)
        make("conj-h1", .conjunction, .healthSciences, .hard, irt: 1.1,
             stem: "____ the overwhelming evidence linking sedentary lifestyles to cardiovascular disease, public health campaigns have achieved only modest behavioral change.",
             clues: [("the overwhelming evidence", .conjunction, "Boşluktan sonra isim öbeği var: edat benzeri yapı gerekir."), ("only modest behavioral change", .conjunction, "Beklentiye zıt sonuç.")],
             rule: "Boşluktan sonra cümle değil isim öbeği geliyorsa bağlaç (although, whereas) değil edat-zıtlık (despite, notwithstanding) seç.",
             tag: "CONJ_NOTWITHSTANDING_NOUN_PHRASE", correct: "A", [
                ("Notwithstanding", "Edat-zıtlık yapısını yakaladın.", "Cümle yapısını kontrol ettin: isim öbeği + zıtlık = 'notwithstanding'."),
                ("Provided that", "Koşul bağlacını hatırladın.", "Sonrasında tam cümle (özne + fiil) beklenir ve anlam koşul değil karşıtlıktır."),
                ("Insofar as", "Üst düzey bağlaç bilgin var.", "'Insofar as' tam cümle ister ve 'ölçüde' anlamı katar; karşıtlık kurmaz."),
                ("Whereas", "Zıtlık bağlacını tanıdın.", "Anlam doğru gibi ama 'whereas' isim öbeği değil tam cümle alır."),
                ("Lest", "Nadir bağlaçları bildiğini gösterdin.", "'Lest' = '-mesin diye'; sonrasında 'should' + fiil gelir ve anlam uymaz.")
             ]),
        // HARD: koşul bağlacı ayrımı (C1)
        make("conj-h2", .conjunction, .naturalSciences, .hard, irt: 1.3,
             stem: "Superconductors are of practical use only ____ they can be maintained below their critical temperature, a requirement that demands costly cryogenic cooling.",
             clues: [("only", .conjunction, "'only' + koşul bağlacı: tek koşul vurgusu."), ("a requirement that demands", .conjunction, "Sonraki kısım koşulun zorunlu olduğunu gösterir.")],
             rule: "'only' sonrasında şart vurgusu varsa 'provided that / as long as / only if' ailesini seç; zıtlık ve amaç bağlaçlarını ele.",
             tag: "CONJ_PROVIDED_THAT", correct: "C", [
                ("whereas", "Karşıtlık bağlacını tanıdın.", "Burada iki durum karşılaştırılmıyor; tek bir zorunlu koşul var."),
                ("lest", "Nadir bir bağlaç seçtin.", "'Lest' olumsuz amaç ('-mesin diye') bildirir, koşul bildirmez."),
                ("provided that", "Zorunlu koşul anlamını doğru kurdun.", "Karşıtlık ve amaç bağlaçlarına yönelmedin."),
                ("albeit", "Üst düzey bağlaç bilgin var.", "'Albeit' = 'although' anlamında ve genelde sıfat/ifade öncesi gelir; koşul bildirmez."),
                ("unlike", "Zıtlık edatını biliyorsun.", "'Unlike' edattır; sonrasında özne+fiil alamaz ve koşul anlamı yoktur.")
             ])
    ]

    // MARK: - 2. Preposition

    public static let prepositionQuestions: [SprintQuestion] = [
        make("prep-e1", .preposition, .healthSciences, .easy, irt: -1.1,
             stem: "Patients with chronic kidney disease are advised to refrain ____ high-protein diets.",
             clues: [("refrain", .prepositionTrigger, "'refrain FROM' (-den kaçınmak).")],
             rule: "Kaçınma/engelleme fiilleri (refrain, prevent, prohibit) çoğunlukla 'from' alır; fiil anlamından edat tahmin et.",
             tag: "PREP_REFRAIN_FROM", correct: "A", [
                ("from", "Kaçınma fiilinin edatını bildin.", "'Refrain from' sabit kalıbını hatırladın."),
                ("to", "Yönelme edatını düşündün.", "'To' hareket/yönelme bildirir; 'kaçınma' anlamıyla ters düşer."),
                ("at", "Edat bilgin geniş.", "'At' yer/hedef bildirir; 'refrain at' diye kalıp yoktur."),
                ("with", "Birliktelik edatını denedin.", "'With' birliktelik gösterir ('refrain with' kalıbı yoktur)."),
                ("for", "Amaç edatını denedin.", "'For' amaç bildirir; 'refrain for' sınavda kalıp değildir.")
             ]),
        make("prep-e2", .preposition, .socialSciences, .easy, irt: -0.9,
             stem: "The committee's decision was based ____ reliable statistical data collected over a decade.",
             clues: [("was based", .prepositionTrigger, "'be based ON' (-e dayanmak).")],
             rule: "'Based' sıfatı daima 'on' ile kullanılır (be based on); fiil sonrası edatı ezberlenmiş kalıp olarak işaretle.",
             tag: "PREP_BASED_ON", correct: "C", [
                ("in", "İçinde-bulunma edatını denedin.", "'Based in' = 'merkezi ...'da olan' anlamına gelir; burada dayanak anlamı var."),
                ("at", "Yer edatını düşündün.", "'At' dayanma bildirmez."),
                ("on", "Sabit kalıbı doğru hatırladın.", "'Based in' tuzağını eledin."),
                ("by", "Edilgen yapıdan 'by' çıkardın.", "'By' etken varlığı gösterir; burada dayanak var, etken yok."),
                ("for", "Amaç edatını denedin.", "'Based for' kalıp değildir.")
             ]),
        make("prep-m1", .preposition, .naturalSciences, .medium, irt: 0.0,
             stem: "Climate scientists attribute the sharp rise in extreme rainfall ____ increased atmospheric moisture caused by warming.",
             clues: [("attribute", .prepositionTrigger, "'attribute X TO Y' (X'i Y'ye bağlamak).")],
             rule: "'Attribute ... to', 'owe ... to', 'credit ... to': nedeni bir kişiye/olguya bağlayan fiiller 'to' ile kurulur.",
             tag: "PREP_ATTRIBUTE_TO", correct: "B", [
                ("for", "Neden anlamından 'for' çıkardın.", "'Attribute for' kalıp değildir; neden bağlama 'to' ile yapılır."),
                ("to", "Nedensellik fiilinin edatını bildin.", "'For' ve 'with' tuzaklarından uzak durdun."),
                ("with", "Birliktelik düşündün.", "'With' eşlik bildirir, bağlama anlamı vermez."),
                ("on", "Dayanma edatını denedin.", "'Attribute on' kalıbı yoktur."),
                ("by", "Edilgen 'by' çıkardın.", "Cümle etken; 'by' gereksiz.")
             ]),
        make("prep-h1", .preposition, .socialSciences, .hard, irt: 1.0,
             stem: "The new legislation is inconsistent ____ the principles ____ which the constitution was founded.",
             clues: [("inconsistent", .prepositionTrigger, "'inconsistent WITH' (ile uyumsuz)."), ("founded", .prepositionTrigger, "'founded ON principles' (ilkelere dayalı).")],
             rule: "Çift boşlukta her boşluğu bağımsız çöz: sıfat kalıbı (inconsistent with) + fiil kalıbı (founded on).",
             tag: "PREP_INCONSISTENT_WITH_FOUNDED_ON", correct: "C", [
                ("to / in", "Her iki boşluğa farklı edat denedin.", "'Inconsistent to' ve 'founded in' yaygın kalıp değildir."),
                ("with / by", "İlk boşluğu doğru çözdün.", "İkinci boşlukta 'founded by' = 'tarafından kurulan'; ilke ise 'dayanak' olduğundan 'on' gerekir."),
                ("with / on", "İki kalıbı doğru birleştirdin.", "Tek boşluğa bakıp yanlış kombinasyon seçmedin."),
                ("from / on", "İkinci boşluğu doğru çözdün.", "'Inconsistent from' kalıbı yoktur (different from ile karıştı)."),
                ("of / at", "Alternatif edatları denedin.", "Her ikisi de kalıp dışı.")
             ]),
        make("prep-h2", .preposition, .healthSciences, .hard, irt: 1.2,
             stem: "Despite its efficacy, chemotherapy is often accompanied ____ debilitating side effects, which leads to patients' reluctance to comply ____ the prescribed regimen.",
             clues: [("accompanied", .prepositionTrigger, "'accompanied BY' (-in eşlik ettiği)."), ("comply", .prepositionTrigger, "'comply WITH' (-e uymak).")],
             rule: "Edilgen fiil + varlık/neden için 'by', uyum/uygunluk fiilleri (comply, conform, agree) için 'with' kullan.",
             tag: "PREP_ACCOMPANIED_BY_COMPLY_WITH", correct: "B", [
                ("with / to", "'Accompanied with' denemesi anlaşılır.", "Edilgende eşlik eden etken 'by' ile bağlanır; 'comply to' ise kalıp dışıdır."),
                ("by / with", "İki kalıbı hatasız çözdün.", "'Accompanied with' ve 'comply to' tuzaklarını eledin."),
                ("by / to", "İlk boşluğu doğru yaptın.", "'Comply to' yerine 'comply WITH' kullanılır."),
                ("for / with", "İkinci boşluğu doğru yaptın.", "'Accompanied for' kalıbı yoktur."),
                ("with / by", "Edatları ters sıraladın.", "'Comply by' kalıp değildir.")
             ])
    ]

    // MARK: - 3. Academic Vocabulary

    public static let academicVocabQuestions: [SprintQuestion] = [
        make("vocab-e1", .academicVocab, .healthSciences, .easy, irt: -1.2,
             stem: "Regular physical activity can significantly ____ the risk of heart disease.",
             clues: [("significantly", .mainVerb, "'Risk' ile birlikte 'azaltmak' anlamlı fiil gerekir.")],
             rule: "Kolokasyon kuralı: 'risk' ile ilişkili fiil seçerken anlam yönüne bak: reduce/lower = azaltma, increase/raise = artırma.",
             tag: "VOCAB_COLLOCATION_REDUCE_RISK", correct: "A", [
                ("reduce", "Kolokasyonu doğru buldun.", "Benzer görünen harf dizilerine kapılmadın."),
                ("reveal", "Ortaya çıkarma anlamını biliyorsun.", "'Reveal' görünürde benzer ama 'risk' ile anlam vermez."),
                ("reserve", "Ayırmak/saklamak anlamını biliyorsun.", "'Reserve' ile risk anlamlı bir birliktelik kurmaz."),
                ("recall", "Hatırlamak/geri çağırmak anlamını biliyorsun.", "'Recall the risk' = 'riski hatırlamak'; anlam bozulur."),
                ("rely", "Güvenmek anlamını biliyorsun.", "'Rely' edatlı fiildir (rely on); doğrudan nesne almaz.")
             ]),
        make("vocab-e2", .academicVocab, .socialSciences, .easy, irt: -0.9,
             stem: "The government has introduced new measures to ____ unemployment among young people.",
             clues: [("new measures", .mainVerb, "Önlem alma: sorunla mücadele (tackle) anlamı beklenir.")],
             rule: "'Measures to ____ + sorun' kalıbında sorunu çözme fiilini ara: tackle, combat, address.",
             tag: "VOCAB_TACKLE_PROBLEM", correct: "B", [
                ("inherit", "Miras alma anlamını biliyorsun.", "Önlemlerin amacı mirasla ilgili değil, sorunu çözmektir."),
                ("tackle", "Sorunla mücadele fiilini buldun.", "Anlamsal olarak uyumsuz seçenekleri eledin."),
                ("persuade", "İkna etme fiilini düşündün.", "'Persuade' kişi nesnesi ister; 'unemployment' kişi değil."),
                ("invent", "İcat etmek anlamını biliyorsun.", "İşsizlik icat edilmez, çözülür."),
                ("applaud", "Alkışlamak anlamını biliyorsun.", "Önlem amacıyla 'alkışlamak' anlam bozar.")
             ]),
        make("vocab-m1", .academicVocab, .naturalSciences, .medium, irt: 0.1,
             stem: "The researchers had to ____ their original hypothesis after the experiment yielded contradictory results.",
             clues: [("contradictory results", .mainVerb, "Çelişkili sonuçlar: hipotezin değiştirilmesi gerekir.")],
             rule: "Çelişkili/yanlışlayıcı bir bulgu geçiyorsa fiil 'değiştirmek/gözden geçirmek' anlamında olmalı (revise, amend, modify).",
             tag: "VOCAB_REVISE_HYPOTHESIS", correct: "C", [
                ("reinforce", "Güçlendirme anlamını biliyorsun.", "Çelişkili sonuçlar hipotezi güçlendirmez, zayıflatır."),
                ("retain", "Koruma anlamını biliyorsun.", "'Had to retain' mantıksal sonuç sağlamaz."),
                ("revise", "Bulgu-hipotez ilişkisini doğru kurdun.", "Anlam yönü tersine çeviren seçenekleri eledin."),
                ("resent", "Kızmak anlamını düşündün.", "'Resent' duygu fiilidir, bilimsel süreçte uymaz."),
                ("relieve", "Rahatlatmak anlamını biliyorsun.", "'Relieve' hipotezle birlikte anlamlı değildir.")
             ]),
        make("vocab-h1", .academicVocab, .socialSciences, .hard, irt: 1.1,
             stem: "The author's argument is so ____ that even sceptical readers found it difficult to dismiss.",
             clues: [("so ____ that", .conjunction, "Sonuç: şüpheci okurlar bile reddedemedi."), ("difficult to dismiss", .mainVerb, "Argüman güçlü/ikna edici olmalı.")],
             rule: "'so ___ that + sonuç' kalıbında sonuç cümlesinin yönünden sıfatın polaritesini çıkar: reddedilmesi zor = güçlü (compelling, cogent).",
             tag: "VOCAB_SO_ADJ_THAT_COMPELLING", correct: "D", [
                ("tentative", "Temkinli anlamını biliyorsun.", "'Tentative' zayıf/geçici anlamında; sonuç cümlesiyle çelişir."),
                ("arbitrary", "Keyfi anlamını biliyorsun.", "Keyfi bir argüman şüphecileri ikna etmez."),
                ("superficial", "Yüzeysel anlamını biliyorsun.", "Yüzeysel argüman reddetmesi kolay olur."),
                ("compelling", "Sonuç cümlesinden polariteyi çıkardın.", "Zayıf anlamlı seçeneklere kapılmadın."),
                ("elusive", "Zor yakalanan anlamını biliyorsun.", "'Elusive' bir kavramı anlatır; argümanın ikna ediciliği için uymaz.")
             ]),
        make("vocab-h2", .academicVocab, .healthSciences, .hard, irt: 1.3,
             stem: "The pathogen's ability to ____ the host's immune response explains why the infection often becomes chronic.",
             clues: [("becomes chronic", .mainVerb, "Enfeksiyon kronikleşiyor: bağışıklıktan kaçıyor olmalı.")],
             rule: "Sonuç 'kalıcılık/kronikleşme' ise neden tarafında 'atlatma/kaçınma' (evade, circumvent) anlamlı fiil ara.",
             tag: "VOCAB_EVADE_IMMUNE_RESPONSE", correct: "A", [
                ("evade", "Bağışıklıktan kaçışı doğru buldun.", "Benzer görünen e- ile başlayan fiillere kapılmadın."),
                ("enhance", "Artırma anlamını biliyorsun.", "Güçlenen bağışıklık enfeksiyonu kronik yapmaz."),
                ("endorse", "Onaylamak anlamını biliyorsun.", "Patojen bağışıklığı 'onaylamaz'."),
                ("emulate", "Taklit etmek anlamını biliyorsun.", "Taklit bağlamı kronikleşmeyi açıklamaz."),
                ("elicit", "Tepki doğurmak anlamını biliyorsun.", "Tepki doğurmak enfeksiyonun kronikleşmesini açıklamaz; aksine bağışıklık harekete geçer.")
             ])
    ]

    // MARK: - 4. Reduction & Tense

    public static let reductionAndTenseQuestions: [SprintQuestion] = [
        make("red-e1", .reductionAndTense, .healthSciences, .easy, irt: -1.0,
             stem: "By the time the ambulance arrived, the patient ____ consciousness.",
             clues: [("By the time", .conjunction, "'By the time + past simple' → ana cümle past perfect.")],
             rule: "'By the time + past simple' → ana cümlede past perfect (had + V3): önce biten eylem.",
             tag: "TENSE_BY_THE_TIME_PAST_PERFECT", correct: "C", [
                ("has lost", "Present perfect bildin.", "Zaman bağlacı geçmişe işaret ettiği için present perfect uymaz."),
                ("lost", "Past simple seçtin.", "İki geçmiş olayın sırası vurgulanıyor; önce olan past perfect olmalı."),
                ("had lost", "Olay sırasını doğru kurdun.", "Basit geçmiş ve present perfect tuzaklarını eledin."),
                ("was losing", "Sürmekte olan eylem düşündün.", "'Was losing' sürekliliği anlatır; burada tamamlanmış bir olay var."),
                ("would lose", "Gelecek-in-the-past düşündün.", "'Would lose' geçmişte gelecek bildirir; zamanlama uymaz.")
             ]),
        make("red-e2", .reductionAndTense, .naturalSciences, .easy, irt: -0.9,
             stem: "Water ____ at 100 degrees Celsius at sea level.",
             clues: [("at 100 degrees Celsius", .mainVerb, "Bilimsel genel gerçek: simple present.")],
             rule: "Bilimsel gerçekler ve genel doğrular simple present ile ifade edilir.",
             tag: "TENSE_GENERAL_TRUTH_PRESENT", correct: "B", [
                ("is boiling", "Sürekli zaman düşündün.", "Genel gerçek için sürekli zaman kullanılmaz."),
                ("boils", "Genel gerçeği doğru çözdün.", "Süreklilik ve gelecek tuzaklarını eledin."),
                ("boiled", "Past simple düşündün.", "Olay geçmişe ait değil, evrensel doğru."),
                ("has boiled", "Present perfect düşündün.", "Sonuç ya da deneyim değil, genel doğru var."),
                ("will be boiling", "Gelecek zaman düşündün.", "Genel doğrular gelecek zamanla ifade edilmez.")
             ]),
        make("red-m1", .reductionAndTense, .healthSciences, .medium, irt: 0.0,
             stem: "____ by chronic sleep deprivation, many shift workers develop metabolic disorders.",
             clues: [("many shift workers develop", .mainVerb, "Özne 'shift workers' etkileniyor: edilgen participle.")],
             rule: "Özne eylemi alıyorsa (etkileniyorsa) reduced clause'ta V3/Being V3 kullan; özne yapıyorsa V-ing kullan.",
             tag: "REDUCTION_PAST_PARTICIPLE_PASSIVE", correct: "B", [
                ("Affecting", "V-ing reduction'ı biliyorsun.", "Özne etkileyen değil etkilenen; edilgenlik V3 ister."),
                ("Affected", "Edilgen reduction'ı doğru kurdun.", "Özne-eylem ilişkisini kontrol ettin."),
                ("Having affected", "Perfect participle düşündün.", "Özne eylemi yapan olsaydı uyardı; burada özne etkileniyor."),
                ("To affect", "Mastar düşündün.", "Amaç anlamı verir, edilgen nedeni vermez."),
                ("Being affecting", "Karmaşık yapı düşündün.", "Gramer dışı bir yapı.")
             ]),
        make("red-m2", .reductionAndTense, .naturalSciences, .medium, irt: 0.2,
             stem: "The experiment ____ for three weeks when the power failure ruined the samples.",
             clues: [("for three weeks", .mainVerb, "Süre belirteci: süreklilik."), ("when the power failure ruined", .conjunction, "Geçmişteki kesilme: öncesinde past perfect continuous.")],
             rule: "Geçmişteki bir olaydan önce süren eylem ve süre belirteci varsa 'had been V-ing' kullan.",
             tag: "TENSE_PAST_PERFECT_CONTINUOUS", correct: "B", [
                ("has been running", "Present perfect continuous bildin.", "Anlam geçmiş; 'has been' bugünü içerir."),
                ("had been running", "Süre ve sıralamayı doğru çözdün.", "Present perfect ve past simple tuzaklarını eledin."),
                ("was run", "Edilgen düşündün.", "Süre vurgusu eksik ve 'ran' ile özne uyuşmaz."),
                ("ran", "Past simple seçtin.", "Süre belirteci ve öncelik ilişkisini göz ardı eder."),
                ("has run", "Present perfect seçtin.", "Güncel sonuç anlamı verir; geçmişteki bir olayla uyuşmaz.")
             ]),
        make("red-h1", .reductionAndTense, .socialSciences, .hard, irt: 1.2,
             stem: "Were the current trends to continue, global temperatures ____ by more than three degrees by the end of the century.",
             clues: [("Were the current trends to continue", .conjunction, "Devrik 'if' cümlesi: Type 2 koşul."), ("by the end of the century", .mainVerb, "Gelecek odaklı varsayım.")],
             rule: "'Were + özne + to V' devrik koşul = Type 2; ana cümle 'would + V1'.",
             tag: "CONDITIONAL_INVERSION_WERE_TO", correct: "B", [
                ("will rise", "Gelecek zaman düşündün.", "Devrik 'were to' varsayımsaldır; 'will' gerçek koşuldur."),
                ("would rise", "Type 2 kuralını doğru uyguladın.", "Gerçek koşul kalıbına düşmedin."),
                ("rose", "Past simple düşündün.", "Koşulun sonucu için modal gerekir."),
                ("have risen", "Present perfect düşündün.", "Tamamlanmış sonuç anlamı uymaz."),
                ("had risen", "Past perfect düşündün.", "Type 3 olurdu; 'Were' devrik yapısı Type 2'dir.")
             ])
    ]

    // MARK: - 5. Sentence Completion

    public static let sentenceCompletionQuestions: [SprintQuestion] = [
        make("sc-e1", .sentenceCompletion, .healthSciences, .easy, irt: -1.1,
             stem: "Because regular exercise strengthens the heart muscle, ____.",
             clues: [("Because", .conjunction, "Neden bağlacı: ana cümle mantıklı bir sonuç olmalı.")],
             rule: "'Because' ile başlayan yan cümleden sonra gelen ana cümle, nedenin mantıklı bir sonucunu anlatmalı; zıtlık bağlacı içeren şıkları ele.",
             tag: "SC_CAUSE_RESULT", correct: "A", [
                ("doctors often recommend it to patients with cardiac risk", "Neden-sonuç mantığını doğru kurdun.", "Seçenekleri mantık yönünden kontrol ettin."),
                ("although it is often expensive", "Bağlaç bilgin var.", "'Although' ile ana cümle tamamlanmaz; zaten başka bir bağlaç var."),
                ("however many people dislike it", "Zıtlık zarfı tanıdın.", "Cümleyi bağlaçla bitirmek anlam bozar."),
                ("which reduces the cost", "Ek bir ilgi zamiri düşündün.", "Önceki bölümle gramer olarak bağlanamaz."),
                ("whereas it has become more popular", "Karşılaştırma bağlacı düşündün.", "Ana cümle olarak kullanılamaz ve anlamsal ilişki yok.")
             ]),
        make("sc-e2", .sentenceCompletion, .socialSciences, .easy, irt: -0.8,
             stem: "Although the economy grew rapidly last year, ____.",
             clues: [("Although", .conjunction, "Zıtlık: ana cümle büyümeye ters yönlü olmalı.")],
             rule: "'Although' ile başlayan cümlenin tamamlayıcısı, yan cümleyle zıt yönlü bilgi taşımalı.",
             tag: "SC_CONCESSION_OPPOSITE", correct: "A", [
                ("unemployment remained stubbornly high", "Zıtlık ilişkisini doğru kurdun.", "Bağlaç ilişkisine odaklandın."),
                ("so unemployment fell sharply", "Mantıklı bir bağ düşündün.", "Büyüme ve işsizlik düşüşü aynı yönlü; zıtlık gerekir."),
                ("because unemployment rose", "Neden bağlacı düşündün.", "Önceki bağlaçla çatışır; cümle bozulur."),
                ("therefore wages increased", "Sonuç ifadesi düşündün.", "Sonuç zarfı zıtlıkla örtüşmez."),
                ("and as a result growth accelerated", "Eklemeli yapı düşündün.", "Aynı yönde bilgi eklemek zıtlığı bozar.")
             ]),
        make("sc-m1", .sentenceCompletion, .naturalSciences, .medium, irt: 0.0,
             stem: "Unless the polar ice sheets stabilise soon, ____.",
             clues: [("Unless", .conjunction, "Koşul: olumsuz çıkış, sonuç olumsuz.")],
             rule: "'Unless + olumlu fiil' = 'if not'; ana cümle şimdiki/gelecek zamanda olumsuz sonucu anlatmalı (will + V1).",
             tag: "SC_UNLESS_FUTURE_RESULT", correct: "C", [
                ("sea levels have already stabilised", "Perfect zaman düşündün.", "Koşul yeni gelişmeleri bekler; sonuç tamamlanmış olamaz."),
                ("they would never have melted", "Type 3 düşündün.", "Zaman uyumsuzluğu var."),
                ("sea levels will continue to rise significantly", "Koşul-sonuç ilişkisini doğru kurdun.", "Geçmiş ve varsayımsal yapılara kapılmadın."),
                ("although the water is cold", "Bağlaç düşündün.", "Ana cümle tamamlanmaz."),
                ("whereas the temperature is rising", "Karşılaştırma düşündün.", "Gramer ve anlam bütünlüğü bozuk.")
             ]),
        make("sc-m2", .sentenceCompletion, .healthSciences, .medium, irt: 0.2,
             stem: "Antibiotics are effective against bacterial infections; however, ____.",
             clues: [("however", .conjunction, "Zıtlık zarfı: ikinci cümle birincinin tersini söyler.")],
             rule: "'however' sonrası cümle, önceki cümlenin sınırını veya tersini anlatmalı.",
             tag: "SC_HOWEVER_LIMITATION", correct: "B", [
                ("they are equally effective against viruses", "Karşılaştırma yaptın.", "Antibiyotik virüslere etkisizdir; bilgi yanlış."),
                ("they have no effect on viral illnesses", "Zıtlığı ve doğru bilgiyi birlikte kurdun.", "Mantıksal ve bilimsel tuzaklara düşmedin."),
                ("they therefore cure influenza", "Sonuç bağladın.", "Antibiyotik grip tedavi etmez; ayrıca 'therefore' zıtlığı bozar."),
                ("bacteria are killed by them", "Aynı yönde bilgi verdin.", "'However' sonrası zıtlık beklenir."),
                ("this is why they are prescribed for colds", "Yanlış sonuç bağladın.", "Nezle viral olduğundan antibiyotik uygun değildir.")
             ]),
        make("sc-h1", .sentenceCompletion, .socialSciences, .hard, irt: 1.1,
             stem: "Had the central bank intervened earlier, ____.",
             clues: [("Had the central bank intervened", .conjunction, "Devrik Type 3: 'If ... had intervened'.")],
             rule: "'Had + özne + V3' devrik koşul = Type 3; ana cümle 'would/might have + V3'.",
             tag: "CONDITIONAL_TYPE3_INVERSION", correct: "A", [
                ("the currency crisis might have been averted", "Type 3 yapısını doğru kurdun.", "Zaman uyumunu kontrol ettin."),
                ("the currency crisis will be averted", "Gelecek düşündün.", "Type 3 geçmişe ait gerçek dışı durumdur."),
                ("the currency crisis might be averting", "Yanlış yapı seçtin.", "Gramatik olarak geçersiz."),
                ("the crisis had been avoided", "Past perfect seçtin.", "Type 3 ana cümlesi modal ister."),
                ("it avoids a crisis", "Present kullandın.", "Zaman uyumsuz.")
             ]),
        make("sc-h2", .sentenceCompletion, .naturalSciences, .hard, irt: 1.3,
             stem: "Not only does quantum entanglement defy classical intuition, but ____.",
             clues: [("Not only does", .conjunction, "Not only...but also: ikinci yan cümle eklemeli bilgi içerir.")],
             rule: "'Not only ..., but' kalıbında ikinci kısım aynı yönlü ve ek bilgi vermeli; zıtlık/amaç bağlaçlı şıkları ele.",
             tag: "SC_NOT_ONLY_BUT", correct: "A", [
                ("it also underpins emerging quantum-computing technologies", "Eklemeli ilişkiyi doğru kurdun.", "Paralel yapıyı gözettin."),
                ("does it also underpin emerging technologies", "Devrik yapıyı tekrar ettin.", "Devrik yapı yalnızca 'Not only' kısmında gerekir; ikinci kısım düz olmalı."),
                ("however it underpins emerging technologies", "Zıtlık zarfı seçtin.", "Aynı yönlü bilgi gerekirken zıtlık uyumsuz."),
                ("whereas it underpins emerging technologies", "Karşılaştırma bağlacı seçtin.", "Karşılaştırma değil ekleme anlamı gerekli."),
                ("because it underpins emerging technologies", "Neden bağlacı seçtin.", "Neden-sonuç ilişkisi kurmaz.")
             ])
    ]

    // MARK: - 6. Dialogue & Restatement

    public static let dialogueAndRestatementQuestions: [SprintQuestion] = [
        make("dr-e1", .dialogueAndRestatement, .socialSciences, .easy, irt: -1.0,
             stem: "Yakın Anlam (Restatement): Although the museum is small, it attracts a large number of visitors.",
             clues: [("Although", .conjunction, "Zıtlık: küçük olmasına rağmen çok ziyaretçi.")],
             rule: "Yakın anlam sorusunda bağlaç ilişkisi (zıtlık/neden/koşul) korunmalı; eş anlamlı yapıları (although = despite) ara.",
             tag: "RESTATEMENT_ALTHOUGH_DESPITE", correct: "A", [
                ("Despite its small size, the museum attracts a large number of visitors.", "Zıtlığı doğru taşıdın.", "Bağlaç ilişkisini kontrol ettin."),
                ("Because the museum is small, it attracts a large number of visitors.", "Neden-sonuç düşündün.", "Zıtlığı neden-sonuca çevirir; anlam değişir."),
                ("The museum is small, so few visitors come.", "Sonucu tersine çevirdin.", "Ziyaretçi sayısı bilgisini ters verir."),
                ("Unless the museum is small, it attracts many visitors.", "Koşul bağlacı denedin.", "Koşul anlamı kurar."),
                ("The museum attracts many visitors since it is large.", "Büyük/küçük bilgisini değiştirdin.", "Müzenin boyutu ters verilmiş.")
             ]),
        make("dr-e2", .dialogueAndRestatement, .healthSciences, .easy, irt: -0.8,
             stem: "Diyalog Tamamlama:\nNurse: The patient's fever has finally dropped.\nDoctor: ____",
             clues: [("has finally dropped", .mainVerb, "Olumlu gelişme: yanıt olumlu ve mantıklı olmalı.")],
             rule: "Diyalogda yanıt, önceki cümlenin duygusal yönü (olumlu/olumsuz) ve konusuyla uyumlu olmalı.",
             tag: "DIALOGUE_COHERENT_RESPONSE", correct: "A", [
                ("That is reassuring; we can start tapering the fever medication.", "Olumlu yönü doğru okudun.", "Yanıtın anlamsal tutarlılığını kontrol ettin."),
                ("Then we should immediately double the dose.", "Müdahale fikri verdin.", "Ateş düştüğüne göre doz artırmak mantıksız."),
                ("That means he must be getting worse.", "Olumsuz yorum yaptın.", "Ateş düşmesi iyileşme işareti."),
                ("I am afraid the lab results were lost.", "Konu dışı yanıt verdin.", "Hemşirenin cümlesiyle ilgisiz."),
                ("Why is the room so cold?", "Konu değiştirdin.", "Diyalog akışını bozar.")
             ]),
        make("dr-m1", .dialogueAndRestatement, .naturalSciences, .medium, irt: 0.0,
             stem: "Yakın Anlam (Restatement): Unless the sample is kept refrigerated, it will deteriorate within hours.",
             clues: [("Unless", .conjunction, "Unless = if not.")],
             rule: "'Unless' = 'if ... not'; yakın anlamda koşulu olumsuz 'if not' ile yeniden yaz.",
             tag: "RESTATEMENT_UNLESS_IF_NOT", correct: "A", [
                ("The sample will deteriorate within hours if it is not kept refrigerated.", "'Unless = if not' kuralını uyguladın.", "Koşul yönünü doğru çevirdin."),
                ("The sample deteriorates only when it is refrigerated.", "Koşulu ters çevirdin.", "Soğutma bozulmaya neden olur gibi yanlış anlam."),
                ("Refrigerating the sample will make it deteriorate within hours.", "Olumsuz sonuç yazdın.", "Nedensellik ters."),
                ("Even if kept refrigerated, the sample will deteriorate within hours.", "Zıtlık yapısı kurdun.", "'Even if' soğutma olsa da bozulur der; farklı anlam."),
                ("The sample deteriorates after hours, so it must be refrigerated.", "Öneri cümlesi kurdun.", "Koşullu ilişkiyi neden-sonuca çevirir.")
             ]),
        make("dr-m2", .dialogueAndRestatement, .socialSciences, .medium, irt: 0.2,
             stem: "Diyalog Tamamlama:\nA: Do you think the new tuition policy will reduce inequality?\nB: ____\nA: Right, so it may even widen the gap.",
             clues: [("it may even widen the gap", .conjunction, "A'nın son cümlesi B'nin olumsuz/şüpheci görüşünü doğruluyor.")],
             rule: "Diyalogta sonraki cümle ipucudur: 'Right, so ...' sonucu önceki yanıtın hangi yönde olduğunu gösterir.",
             tag: "DIALOGUE_FOLLOW_UP_CLUE", correct: "B", [
                ("Definitely, since it helps everyone equally.", "Olumlu görüş seçtin.", "Sonraki cümle eşitsizliğin artabileceğini söylüyor; çelişir."),
                ("Not necessarily; wealthier families may benefit from it more than poorer ones.", "Sonraki cümleyi ipucu olarak kullandın.", "Olumlu görüş tuzağına düşmedin."),
                ("Yes, it will close the gap completely.", "Çok olumlu görüş seçtin.", "Sonraki cümleyle çelişir."),
                ("I have no idea what tuition is.", "Konu dışı yanıt verdin.", "Uyumsuz ve yetersiz yanıt."),
                ("The policy was introduced last year.", "Gerçek bilgi verdin.", "Soruya yanıt vermez.")
             ]),
        make("dr-h1", .dialogueAndRestatement, .healthSciences, .hard, irt: 1.1,
             stem: "Yakın Anlam (Restatement): Rarely do patients with early-stage glaucoma notice any change in their vision.",
             clues: [("Rarely do", .conjunction, "Olumsuz zarf + devrik yapı: 'seldom' anlamı.")],
             rule: "Olumsuz zarflarla başlayan devrik cümlede (rarely, seldom) anlam 'nadiren' korunmalı; 'never' ve 'only' aşırı kesinlikleri eler.",
             tag: "RESTATEMENT_NEGATIVE_ADVERB_INVERSION", correct: "A", [
                ("Patients with early-stage glaucoma seldom perceive any visual change.", "Devrik yapıyı ve anlamı çözdün.", "Nadiren = seldom."),
                ("Patients with early-stage glaucoma frequently notice visual change.", "Anlamı ters çevirdin.", "'Rarely' olumsuzluğunu kaçırdın."),
                ("Patients with early-stage glaucoma never experience visual change.", "Olumsuz anlamı yakaladın.", "'Never' mutlak; 'rarely' mutlak değil."),
                ("Only patients with glaucoma notice any visual change.", "Sınırlayıcı yapı seçtin.", "Anlam kayması."),
                ("Patients rarely have glaucoma at an early stage.", "Nadirliği başka öğeye taşıdın.", "Nadir olan hastalığın erken evresi, görme değişikliği farkındalığı değil.")
             ]),
        make("dr-h2", .dialogueAndRestatement, .naturalSciences, .hard, irt: 1.3,
             stem: "Diyalog Tamamlama:\nDr. Lee: The anomalous readings suggest that the sensor was miscalibrated.\nDr. Ward: ____\nDr. Lee: Then we should replicate the measurement with an independent instrument before drawing conclusions.",
             clues: [("Then we should replicate", .conjunction, "Lee'nin sonucu, Ward'ın temkinli ve alternatif bir olasılık sunduğunu gösterir.")],
             rule: "Diyalogun devamındaki 'Then ...' önerisi, ara yanıtın temkinli/koşullu bir ifade içerdiğini işaret eder; kesin ifadeleri ele.",
             tag: "DIALOGUE_HEDGED_RESPONSE", correct: "B", [
                ("No, the readings prove beyond doubt that the effect is real.", "Kesin görüş seçtin.", "Replikasyon önerisi kesinlik varsa gereksizdir."),
                ("That is one possibility, but we cannot rule out a genuine physical effect without further evidence.", "Temkinli yanıtı sonraki cümleye bağladın.", "Aşırı kesin ifadelere kapılmadın."),
                ("Then we can publish immediately; calibration is irrelevant.", "Pratik çözüm seçtin.", "Replikasyon önerisini anlamsız kılar."),
                ("Sensors never malfunction in modern laboratories.", "Genelleme yaptın.", "Aşırı kesin ve mantık dışı."),
                ("I agree, so there is no need to check anything.", "Katılma yanıtı seçtin.", "Sonraki cümleyle çelişir; kontrol önerisi var.")
             ])
    ]
}
