import Foundation

/// Glow Nature Eğitim Tasarım Dili için Zenginleştirilmiş Mock Veri Seti
public enum GlowMockData {

    // MARK: - Promo Banner Carousel Verileri
    public struct BannerSlide: Identifiable, Sendable {
        public let id: String
        public let badgeText: String
        public let title: String
        public let ctaText: String
        public let targetRoute: String
        public let artworkSymbol: String

        public init(
            id: String,
            badgeText: String,
            title: String,
            ctaText: String,
            targetRoute: String,
            artworkSymbol: String
        ) {
            self.id = id
            self.badgeText = badgeText
            self.title = title
            self.ctaText = ctaText
            self.targetRoute = targetRoute
            self.artworkSymbol = artworkSymbol
        }
    }

    public static let bannerSlides: [BannerSlide] = [
        BannerSlide(
            id: "slide_1",
            badgeText: "Günün Hedefi",
            title: "Günün hedefini tamamla:\n20 Soru Çöz & +0.40 Puan Kazan",
            ctaText: "Hemen Başla",
            targetRoute: "practice",
            artworkSymbol: "leaf.circle.fill"
        ),
        BannerSlide(
            id: "slide_2",
            badgeText: "Sınav Sayacı",
            title: "YDS İlkbahar Sınavına 47 Gün Kaldı\nÖzel Deneme Sınavını Başlat",
            ctaText: "Denemeye Başla",
            targetRoute: "mock_exam",
            artworkSymbol: "timer"
        ),
        BannerSlide(
            id: "slide_3",
            badgeText: "3D Kelime Kampı",
            title: "En Sık Çıkan 100 Akademik\nEdat & Fiil Çiftini Pekiştir",
            ctaText: "Kampa Katıl",
            targetRoute: "vocab",
            artworkSymbol: "sparkles"
        )
    ]

    // MARK: - 8 Kapsamlı Ders/Konu (Lessons)
    public static let lessons: [LessonItem] = [
        LessonItem(
            id: "lesson_1",
            title: "Relative Clauses (İlgi Cümlecikleri)",
            category: .grammar,
            level: "B2-C1 Akademik",
            difficulty: .medium,
            durationMinutes: 25,
            questionCount: 20,
            instructorName: "Akademik Sınav Enstitüsü",
            instructorSubtitle: "Resmî İçerik • Dr. Ayhan Demir",
            isFollowingInstructor: true,
            summaryTr: "YDS ve YÖKDİL'de her yıl en az 4-6 soruda doğrudan veya dolaylı test edilen 'which, who, whom, whose, that, preposition + which' yapılarının akademik makale düzeyinde pratik analizi.",
            examTipsTr: [
                "Virgülden sonra ASLA 'that' gelmez; non-defining yapılarda 'which' veya 'who' aranmalıdır.",
                "'whose' sonrasında daima eksiz ve yalın bir isim bulunmalıdır.",
                "Cümle başında 'Preposition + which/whom' yapısı bağlaç görevi görür ve tam bir cümle gerektirir."
            ],
            artworkType: "botanical_flask",
            isBookmarked: true
        ),
        LessonItem(
            id: "lesson_2",
            title: "Zıtlık & Karşıtlık Bağlaçları (Although / Despite)",
            category: .grammar,
            level: "B1-B2 Orta",
            difficulty: .easy,
            durationMinutes: 20,
            questionCount: 15,
            instructorName: "Akademik Sınav Enstitüsü",
            instructorSubtitle: "Resmî İçerik • Doç. Selin Vural",
            isFollowingInstructor: true,
            summaryTr: "Artı/Eksi (+ / -) kutup analiziyle 'Although, Even though, In spite of, Whereas, However' bağlaçlarını hiç çevirmeden 15 saniyede çözme stratejisi.",
            examTipsTr: [
                "Bağlaçtan sonra isim/isim tamlaması geliyorsa 'Despite / In spite of / Notwithstanding' seçilmelidir.",
                "Tam cümle (Özne + Yüklem) geliyorsa 'Although / Even though / While' aranır.",
                "İki bağımsız cümlenin arasında noktalı virgül (;) veya nokta varsa 'However / Nonetheless' önceliklidir."
            ],
            artworkType: "stone_leaf",
            isBookmarked: false
        ),
        LessonItem(
            id: "lesson_3",
            title: "Akademik Fiil & Edat Birliktelikleri (Collocations)",
            category: .vocabulary,
            level: "C1 İleri",
            difficulty: .hard,
            durationMinutes: 30,
            questionCount: 25,
            instructorName: "Oxford & YDS Dil Kurulu",
            instructorSubtitle: "Doğrulanmış Kaynak • Prof. K. Erdem",
            isFollowingInstructor: true,
            summaryTr: "ÖSYM'nin en sevdiği 'stem from, result in, attribute to, refrain from, contribute to' gibi 50 kilit fiil-edat kalıbının eş anlamlıları ve sınav çeldiricileri.",
            examTipsTr: [
                "'attribute A to B' yapısında 'to' yönelme edatıdır; infinitive mastar ekiyle karıştırılmamalıdır.",
                "'refrain from / abstain from' sonrasında daima V-ing veya isim gelir.",
                "'result in' sebep-sonuçta sonuca götürür, 'result from' ise kaynağa işaret eder."
            ],
            artworkType: "herbal_serum",
            isBookmarked: true
        ),
        LessonItem(
            id: "lesson_4",
            title: "Paragraf Tamamlama & Akış Analizi",
            category: .reading,
            level: "B2-C1 Akademik",
            difficulty: .hard,
            durationMinutes: 35,
            questionCount: 12,
            instructorName: "Akademik Sınav Enstitüsü",
            instructorSubtitle: "ÖSYM Soru Analiz Masası",
            isFollowingInstructor: false,
            summaryTr: "Boşluğun önündeki ve arkasındaki zamir (pronoun reference), zaman (tense shift) ve bağlaç köprülerini takip ederek doğru seçeneği matematiksel kesinlikle bulma.",
            examTipsTr: [
                "Boşluktan sonraki cümlede 'This discovery, Such measures' gibi göndermeler varsa, boşlukta o keşif veya önlem netçe açıklanmış olmalıdır.",
                "Kronolojik anlatımda zaman kaymaları (past -> present perfect) daima bir sebep bağlacına bağlıdır."
            ],
            artworkType: "botanical_book",
            isBookmarked: false
        ),
        LessonItem(
            id: "lesson_5",
            title: "Cloze Test Taktikleri & Boşluk Stratejisi",
            category: .clozeTest,
            level: "B2 Orta-İleri",
            difficulty: .medium,
            durationMinutes: 25,
            questionCount: 15,
            instructorName: "Akademik Sınav Enstitüsü",
            instructorSubtitle: "Resmî İçerik • Dr. Ayhan Demir",
            isFollowingInstructor: true,
            summaryTr: "5 soruluk paragraf bloklarında bağlaç, tens/kısaltma, edat ve kelime dağılımını dengeli okuma ve metnin ana fikrinden kopmadan soru çözme.",
            examTipsTr: [
                "Paragrafın ilk cümlesi daima genel ana fikri verir, boşluk olmasa bile ilk cümleyi dikkatle okuyun.",
                "Tek bir boşluğa 45 saniyeden fazla takılmayın; sonraki cümlenin bağlacı önceki boşluğun cevabını verebilir."
            ],
            artworkType: "minimal_pipette",
            isBookmarked: false
        ),
        LessonItem(
            id: "lesson_6",
            title: "Cümle Tamamlama (Sentence Completion) Ustası",
            category: .reading,
            level: "B2 Akademik",
            difficulty: .medium,
            durationMinutes: 25,
            questionCount: 18,
            instructorName: "YÖKDİL & YDS Master",
            instructorSubtitle: "Doç. Selin Vural",
            isFollowingInstructor: true,
            summaryTr: "YDS'de 10 soru (12.50 puan) getiren cümle tamamlama bölümünde özne uyumu, zaman uyumu ve bağlaç mantığını harmanlayan soru çözümleri.",
            examTipsTr: [
                "Yan cümlecik ile ana cümleciğin özneleri paralel veya mantıksal bir sebep-sonuç ilişkisinde olmalıdır.",
                "Zaman bağlaçlarında (when, while, as, before) present-past zaman uyumsuzluğu olan şıklar anında elenir."
            ],
            artworkType: "natural_stone",
            isBookmarked: true
        ),
        LessonItem(
            id: "lesson_7",
            title: "Çeviri Eklemleri (EN -> TR / TR -> EN)",
            category: .translation,
            level: "B1-B2 Orta",
            difficulty: .easy,
            durationMinutes: 20,
            questionCount: 16,
            instructorName: "Akademik Sınav Enstitüsü",
            instructorSubtitle: "ÖSYM Soru Analiz Masası",
            isFollowingInstructor: false,
            summaryTr: "Ana yüklemi ve ana özneyi bularak 6 soruluk çeviri bloğunu 2 dakikada hatasız tamamlama yöntemi.",
            examTipsTr: [
                "İngilizce cümlenin ana yüklemini bulun; Türkçe çeviride bu yüklem cümlenin en sonunda yer almalıdır.",
                "Ana özneyi belirleyin; Türkçe cümlede ilk başta veya yüklemle tam uyumlu halde olmalıdır."
            ],
            artworkType: "stone_leaf",
            isBookmarked: false
        ),
        LessonItem(
            id: "lesson_8",
            title: "Diyalog & Karşılıklı Konuşma Tamamlama",
            category: .dialogue,
            level: "B1 Orta",
            difficulty: .easy,
            durationMinutes: 18,
            questionCount: 12,
            instructorName: "Akademik Sınav Enstitüsü",
            instructorSubtitle: "Dr. Ayhan Demir",
            isFollowingInstructor: true,
            summaryTr: "Konuşmacıların tutumunu (katılma, itiraz, şüphe, soru sorma) tespit ederek bağlamdan sapmayan doğal cevabı işaretleme.",
            examTipsTr: [
                "Boşluktan hemen sonra gelen cevabın 'Actually, Exactly, I doubt it' gibi tepkilerine odaklanın.",
                "Konuşmanın resmiyet düzeyine (akademik vs. günlük) uymayan argo veya aşırı edebi seçenekleri eleyin."
            ],
            artworkType: "botanical_flask",
            isBookmarked: false
        )
    ]

    // MARK: - 20 Özgün YDS/YÖKDİL Soru Modeli
    public struct MockQuizQuestion: Identifiable, Sendable {
        public let id: String
        public let questionText: String
        public let options: [String] // A, B, C, D, E
        public let correctOptionIndex: Int
        public let explanationTr: String
        public let grammarTopicTr: String
        public let distractorTrapTr: String
        public let academicDomainTr: String

        public init(
            id: String,
            questionText: String,
            options: [String],
            correctOptionIndex: Int,
            explanationTr: String,
            grammarTopicTr: String,
            distractorTrapTr: String,
            academicDomainTr: String = "Sosyal & Beşeri Bilimler"
        ) {
            self.id = id
            self.questionText = questionText
            self.options = options
            self.correctOptionIndex = correctOptionIndex
            self.explanationTr = explanationTr
            self.grammarTopicTr = grammarTopicTr
            self.distractorTrapTr = distractorTrapTr
            self.academicDomainTr = academicDomainTr
        }
    }

    public static let practiceQuestions: [MockQuizQuestion] = [
        MockQuizQuestion(
            id: "q_1",
            questionText: "Although solar radiation provides abundant clean energy, the initial installation costs of photovoltaic panels remain a major barrier, ---- advances in nanotechnology may soon render production significantly cheaper.",
            options: [
                "whereas",
                "in case",
                "nonetheless",
                "yet",
                "as though"
            ],
            correctOptionIndex: 3,
            explanationTr: "'Yet' bağlacı iki karşıt bağımsız cümleyi birbirine bağlar ve 'fakat/yine de' anlamıyla zıtlık kurar. 'Although' ile başlayan yan cümlenin getirdiği eksi durumu dengeleyen olumlu gelişmeye bağlanır.",
            grammarTopicTr: "Zıtlık Bağlaçları (Contrast Coordinators)",
            distractorTrapTr: "'Whereas' iki nesneyi veya olguyu doğrudan karşılaştırır; 'in case' ise tedbir bildirir ve anlamca anlamsızdır.",
            academicDomainTr: "Fen & Enerji Bilimleri"
        ),
        MockQuizQuestion(
            id: "q_2",
            questionText: "The hippocampus is a complex brain structure deeply embedded within the temporal lobe, ---- primary function involves memory consolidation and spatial navigation.",
            options: [
                "which",
                "whose",
                "where",
                "that",
                "whom"
            ],
            correctOptionIndex: 1,
            explanationTr: "Boşluktan sonra eksiz bir isim olan 'primary function' gelmektedir. İsim tamlaması ve aidiyet bağı kuran tek ilgi zamiri 'whose'dur ('hipokampus ki onun birincil işlevi...').",
            grammarTopicTr: "Relative Clauses (Whose + Noun)",
            distractorTrapTr: "'which' doğrudan özne veya nesne görevini alır, arkasından yalın isim tamlaması kabul etmez. Virgülden sonra 'that' asla gelmez.",
            academicDomainTr: "Sağlık & Tıp"
        ),
        MockQuizQuestion(
            id: "q_3",
            questionText: "Chronic deficiency of micronutrients during early childhood can drastically impair cognitive development and ultimately result ---- irreversible learning deficits.",
            options: [
                "from",
                "in",
                "with",
                "at",
                "by"
            ],
            correctOptionIndex: 1,
            explanationTr: "'Result in' kalıbı 'ile sonuçlanmak / -e yol açmak' (lead to, cause) demektir. Cümlenin mantığında sebep (besin eksikliği) sonuca (öğrenme kaybı) varmaktadır.",
            grammarTopicTr: "Prepositional Verbs (Result in)",
            distractorTrapTr: "'Result from' -den kaynaklanmak demektir (kaynağı açıklar); 'in' ise sonucu gösterir.",
            academicDomainTr: "Sağlık & Biyoloji"
        ),
        MockQuizQuestion(
            id: "q_4",
            questionText: "Many endangered primate species have managed to survive in isolated pockets of the rainforest ---- rigorous international conservation accords prohibiting illegal logging.",
            options: [
                "thanks to",
                "in contrast to",
                "on behalf of",
                "in place of",
                "regardless of"
            ],
            correctOptionIndex: 0,
            explanationTr: "'Thanks to' (sayesinde), arkasından gelen olumlu koruma anlaşmalarının hayvanların hayatta kalmasını sağladığını belirten sebep bildirir.",
            grammarTopicTr: "Edat Grupları (Prepositional Phrases)",
            distractorTrapTr: "'In contrast to' zıtlık arar; 'regardless of' ise -e bakılmaksızın anlamındadır ve cümlenin mantığıyla çelişir.",
            academicDomainTr: "Fen & Çevre"
        ),
        MockQuizQuestion(
            id: "q_5",
            questionText: "---- recent economic sanctions have crippled international trade routes, small regional manufacturers have discovered creative ways to sustain local supply chains.",
            options: [
                "Even if",
                "Because of",
                "While",
                "So that",
                "Unless"
            ],
            correctOptionIndex: 2,
            explanationTr: "'While' cümle başında 'Although / İkisi zıt durumdayken' anlamında zaman değil, doğrudan karşıtlık (concession) bildirir.",
            grammarTopicTr: "Zaman/Zıtlık Bağlacı Olarak While",
            distractorTrapTr: "'Because of' arkasından tam cümle alamaz (tam cümle için 'because' gerekir). 'Unless' ise '-medikçe' anlamında koşul arar.",
            academicDomainTr: "Sosyal & Ekonomi"
        ),
        MockQuizQuestion(
            id: "q_6",
            questionText: "Archaeologists excavating the ancient Roman settlement uncovered a water drainage system ---- with remarkable architectural precision nearly two millennia ago.",
            options: [
                "constructing",
                "having constructed",
                "to construct",
                "constructed",
                "to be constructed"
            ],
            correctOptionIndex: 3,
            explanationTr: "İsimden ('a water drainage system') sonra gelen kısaltma edilgen (passive) olduğu için past participle (-ed3) 'constructed' kullanılır ('which was constructed').",
            grammarTopicTr: "Participle Reduction (Edilgen Sıfat Kısaltması)",
            distractorTrapTr: "'Constructing' aktif etken kısaltmadır ve drenaj sisteminin bir şey inşa etmesi mantıksızdır.",
            academicDomainTr: "Sosyal & Arkeoloji"
        ),
        MockQuizQuestion(
            id: "q_7",
            questionText: "Epidemiological studies indicate that regular aerobic exercise substantially enhances cardiovascular resilience, ---- mitigating the long-term risk of arterial hypertension.",
            options: [
                "thereby",
                "otherwise",
                "instead",
                "likewise",
                "nevertheless"
            ],
            correctOptionIndex: 0,
            explanationTr: "'Thereby' (böylelikle / bu sayede), bir eylemin doğal ve doğrudan sonucunu belirtir ve çoğunlukla V-ing (mitigating) ile birlikte kullanılır.",
            grammarTopicTr: "Sonuç Zarfı (Thereby + V-ing)",
            distractorTrapTr: "'Otherwise' (aksi takdirde) olumsuz bir tehdit/uyarı arar; 'instead' (bunun yerine) önceki eylemin reddedilmesini gerektirir.",
            academicDomainTr: "Sağlık & Spor Bilimleri"
        ),
        MockQuizQuestion(
            id: "q_8",
            questionText: "Before the advent of modern refrigeration technologies, microbial fermentation was widely utilized ---- perishable foodstuffs from spoiling during harsh winters.",
            options: [
                "protecting",
                "to protect",
                "having protected",
                "protected",
                "for protect"
            ],
            correctOptionIndex: 1,
            explanationTr: "'Be used / utilized to do something' kalıbı 'bir şeyi yapmak amacıyla kullanılmak' demektir. Amaç bildiren infinitive 'to protect' zorunludur.",
            grammarTopicTr: "Infinitive of Purpose (To + V1)",
            distractorTrapTr: "'Be used to V-ing' alışkın olmak demektir ancak cansız öznelerde (fermentation) pasif amaç için daima 'to V1' kullanılır.",
            academicDomainTr: "Fen & Gıda"
        ),
        MockQuizQuestion(
            id: "q_9",
            questionText: "The executive committee decided to postpone the multinational merger negotiations ---- unresolved copyright disputes regarding artificial intelligence models.",
            options: [
                "due to",
                "in spite of",
                "as well as",
                "with the aim of",
                "rather than"
            ],
            correctOptionIndex: 0,
            explanationTr: "'Due to' (-den dolayı / sebebiyle), arkasından gelen isim öbeğini ('unresolved copyright disputes') sebep olarak ana cümlenin ertelenmesine bağlar.",
            grammarTopicTr: "Sebep Edatları (Due to + Noun)",
            distractorTrapTr: "'In spite of' zıtlık arar; oysa telif uyuşmazlığı ertelemenin doğal gerekçesidir (sebep-sonuç).",
            academicDomainTr: "Sosyal & Hukuk"
        ),
        MockQuizQuestion(
            id: "q_10",
            questionText: "Had the aerospace engineers detected the micro-fractures in the turbine blades earlier, the catastrophic engine failure ---- during transatlantic flight.",
            options: [
                "would be averted",
                "would have been averted",
                "had averted",
                "will have been averted",
                "could avert"
            ],
            correctOptionIndex: 1,
            explanationTr: "'Had + S + V3' yapısı Devrik Type 3 If Clause'dur. Geçmişte gerçekleşmeyen bir durumun sonucunu 'would / could + have + been + V3' ile edilgen tamamlar.",
            grammarTopicTr: "Inversion in Conditional Sentences (Devrik Type 3)",
            distractorTrapTr: "'would be averted' Type 2'dir (günümüz varsayımı); oysa olay geçmiştedir.",
            academicDomainTr: "Fen & Mühendislik"
        ),
        MockQuizQuestion(
            id: "q_11",
            questionText: "The United Nations report highlighted that nearly two billion people lack access to safely managed drinking water, a crisis ---- by severe climatic volatility.",
            options: [
                "exacerbated",
                "exacerbating",
                "to exacerbate",
                "having exacerbated",
                "exacerbates"
            ],
            correctOptionIndex: 0,
            explanationTr: "'A crisis [which is] exacerbated by...' yapısında edilgen kısaltma olan past participle (V3) 'exacerbated' gereklidir.",
            grammarTopicTr: "Appositive Clause Reduction",
            distractorTrapTr: "'Exacerbating' etken kısaltmadır; krizin iklim tarafından şiddetlendirildiğini 'by' edatı açıkça göstermektedir.",
            academicDomainTr: "Fen & Çevre"
        ),
        MockQuizQuestion(
            id: "q_12",
            questionText: "Psychological resilience is not an immutable genetic trait; ----, it can be systematically cultivated through cognitive behavioral interventions.",
            options: [
                "furthermore",
                "rather",
                "consequently",
                "namely",
                "similarly"
            ],
            correctOptionIndex: 1,
            explanationTr: "Cümlenin başında 'not X' ifadesi yer aldığında, devamındaki noktalı virgülden sonra 'bunun yerine / bilakis' düzeltmesini yapan 'rather' veya 'instead' zarfı gelir.",
            grammarTopicTr: "Düzeltme ve Karşıtlık Zarfı (Rather)",
            distractorTrapTr: "'Furthermore' ek bilgi verir; 'consequently' ise olumsuz cümlenin doğrudan sonucu olamaz.",
            academicDomainTr: "Sağlık & Psikoloji"
        ),
        MockQuizQuestion(
            id: "q_13",
            questionText: "Cognitive neuroscientists are still investigating the precise neural pathways through ---- sensory inputs are translated into conscious perceptual experiences.",
            options: [
                "which",
                "that",
                "what",
                "whom",
                "whose"
            ],
            correctOptionIndex: 0,
            explanationTr: "Edattan ('through') sonra cansız isimleri niteleyen tek ilgi zamiri 'which'tir. 'Through which' = 'vasıtasıyla / aracılığıyla'.",
            grammarTopicTr: "Preposition + Relative Pronoun",
            distractorTrapTr: "Edat arkasından 'that' ASLA gelemez; 'what' ise isim cümlesi yapar ve önündeki ismi niteleyemez.",
            academicDomainTr: "Sağlık & Nöroloji"
        ),
        MockQuizQuestion(
            id: "q_14",
            questionText: "The government has implemented strict quotas on fossil fuel extraction, not only to meet greenhouse emission targets ---- to foster domestic renewable innovations.",
            options: [
                "or else",
                "but also",
                "as well",
                "so as",
                "in order"
            ],
            correctOptionIndex: 1,
            explanationTr: "'Not only X ... but also Y' çift bağlacı paralel iki amacı (emisyon hedefi ve yenilenebilir enerji) birbirine bağlar.",
            grammarTopicTr: "Correlative Conjunctions (Not only ... but also)",
            distractorTrapTr: "'As well' cümle sonuna gelir; 'but' olmadan iki cümleyi bağlayamaz.",
            academicDomainTr: "Fen & Politika"
        ),
        MockQuizQuestion(
            id: "q_15",
            questionText: "The recent clinical trial of the synthetic antibiotic was abruptly halted because several participants began to develop adverse reactions attributed ---- the highest dosage.",
            options: [
                "for",
                "with",
                "to",
                "about",
                "from"
            ],
            correctOptionIndex: 2,
            explanationTr: "'Attribute A to B' (A'yı B'ye bağlamak/atfetmek) fiili edilgen kullanıldığında daima 'to' edatını korur: 'attributed to the highest dosage'.",
            grammarTopicTr: "Zorunlu Edat Eşleşmesi (Attributed to)",
            distractorTrapTr: "'From' kaynağı çağrıştırsa da İngilizce akademik kuralda 'attribute' sadece 'to' ile kullanılır.",
            academicDomainTr: "Sağlık & Eczacılık"
        ),
        MockQuizQuestion(
            id: "q_16",
            questionText: "So intricate ---- the cellular mechanics of DNA repair that even microscopic anomalies can trigger programmed cell apoptosis.",
            options: [
                "are",
                "is",
                "have been",
                "was",
                "being"
            ],
            correctOptionIndex: 0,
            explanationTr: "'So + Sıfat' cümlenin başına geldiğinde devrik (inversion) yapı oluşur. Özne çoğul olan 'the cellular mechanics' olduğu için yüklem 'are' olmalıdır.",
            grammarTopicTr: "So ... That Devrik Yapısı (Inversion)",
            distractorTrapTr: "'Mechanics' kelimesi burada çoğul mekanizmalar anlamındadır ve present genellemede 'are' seçilir.",
            academicDomainTr: "Fen & Genetik"
        ),
        MockQuizQuestion(
            id: "q_17",
            questionText: "Linguists observe that second language acquisition becomes noticeably more demanding after puberty, ---- native language phonetic maps become rigidly established.",
            options: [
                "as",
                "even though",
                "unless",
                "provided that",
                "so that"
            ],
            correctOptionIndex: 0,
            explanationTr: "'As' burada 'çünkü / -dığı için' (since/because) anlamında sebep bildirmektedir. Ana dildeki fonetik haritanın kemikleşmesi, yabancı dil ediniminin zorlaşmasının nedenidir.",
            grammarTopicTr: "Sebep Bildiren Bağlaç Olarak As",
            distractorTrapTr: "'Even though' zıtlık yaratır oysa iki cümle arasında sebep-sonuç uyumu vardır.",
            academicDomainTr: "Sosyal & Dilbilim"
        ),
        MockQuizQuestion(
            id: "q_18",
            questionText: "Unlike standard lithium-ion batteries, solid-state cells demonstrate higher energy density and superior thermal stability, making them far less prone ---- catching fire.",
            options: [
                "to",
                "for",
                "of",
                "by",
                "against"
            ],
            correctOptionIndex: 0,
            explanationTr: "'Be prone to doing something' kalıbı '-e yatkın/eğilimli olmak' demektir ve daima 'to' edatıyla kullanılır.",
            grammarTopicTr: "Sıfat + Edat Eşleşmesi (Prone to)",
            distractorTrapTr: "'Prone for' veya 'prone against' hatalı edat kullanımlarıdır.",
            academicDomainTr: "Fen & Malzeme Bilimi"
        ),
        MockQuizQuestion(
            id: "q_19",
            questionText: "Historians agree that the Industrial Revolution was not a sudden rupture; ----, it represented the gradual convergence of technological breakthroughs spanning decades.",
            options: [
                "on the contrary",
                "furthermore",
                "similarly",
                "as a result",
                "for instance"
            ],
            correctOptionIndex: 0,
            explanationTr: "'Not X; on the contrary, Y' kalıbı 'Ani bir kopuş değildi; bilakis/tam tersine, kademeli bir yakınsamaydı' diyerek önceki yanlış varsayımı çürütür.",
            grammarTopicTr: "Karşıtlık ve Düzeltme Bağlacı (On the contrary)",
            distractorTrapTr: "'Furthermore' aynı yönde ek bilgi katar; burada ise olumsuz fikrin zıttı savunulmaktadır.",
            academicDomainTr: "Sosyal & Tarih"
        ),
        MockQuizQuestion(
            id: "q_20",
            questionText: "By the time the international summit on climate remediation convenes next autumn, the participating nations ---- their mandatory carbon neutrality timetables.",
            options: [
                "will submit",
                "will have submitted",
                "had submitted",
                "have submitted",
                "would submit"
            ],
            correctOptionIndex: 1,
            explanationTr: "'By the time + Present Zaman' yan cümleciği ana cümlede Future Perfect ('will have + V3') gerektirir. 'Gelecekte o vakit gelene kadar tamamlanmış olacak' kuralıdır.",
            grammarTopicTr: "Zaman Uyumu (By the time + Future Perfect)",
            distractorTrapTr: "'Had submitted' past perfect'tir ve geçmiş zaman 'by the time + Past' ile kullanılır.",
            academicDomainTr: "Sosyal & Uluslararası İlişkiler"
        )
    ]

    // MARK: - 30 Akademik Kelime Kartı (FlashCards)
    public struct MockVocabWord: Identifiable, Sendable {
        public let id: String
        public let word: String
        public let phonetic: String
        public let partOfSpeechTr: String
        public let meaningTr: String
        public let mandatoryPreposition: String?
        public let synonymsTr: [String]
        public let exampleEn: String
        public let exampleTr: String
        public let categoryTrackTr: String
        public let cefrLevel: String

        public init(
            id: String,
            word: String,
            phonetic: String,
            partOfSpeechTr: String,
            meaningTr: String,
            mandatoryPreposition: String?,
            synonymsTr: [String],
            exampleEn: String,
            exampleTr: String,
            categoryTrackTr: String,
            cefrLevel: String = "C1"
        ) {
            self.id = id
            self.word = word
            self.phonetic = phonetic
            self.partOfSpeechTr = partOfSpeechTr
            self.meaningTr = meaningTr
            self.mandatoryPreposition = mandatoryPreposition
            self.synonymsTr = synonymsTr
            self.exampleEn = exampleEn
            self.exampleTr = exampleTr
            self.categoryTrackTr = categoryTrackTr
            self.cefrLevel = cefrLevel
        }
    }

    public static let academicWords: [MockVocabWord] = [
        MockVocabWord(
            id: "w_1",
            word: "stem from",
            phonetic: "/stɛm frɒm/",
            partOfSpeechTr: "Deyimsel Fiil (Phrasal Verb)",
            meaningTr: "-den kaynaklanmak, kökeni -e dayanmak",
            mandatoryPreposition: "from",
            synonymsTr: ["originate from", "derive from", "arise from"],
            exampleEn: "Many contemporary economic bottlenecks stem from disrupted maritime supply routes.",
            exampleTr: "Birçok çağdaş ekonomik darboğaz, kesintiye uğrayan deniz tedarik rotalarından kaynaklanmaktadır.",
            categoryTrackTr: "Sosyal",
            cefrLevel: "C1"
        ),
        MockVocabWord(
            id: "w_2",
            word: "deteriorate",
            phonetic: "/dɪˈtɪəriəreɪt/",
            partOfSpeechTr: "Fiil",
            meaningTr: "Kötüleşmek, bozulmak, gerilemek",
            mandatoryPreposition: "into",
            synonymsTr: ["decline", "worsen", "degenerate"],
            exampleEn: "Air quality rapidly deteriorated after the industrial emission filters malfunctioned.",
            exampleTr: "Sanayi emisyon filtreleri arızalandıktan sonra hava kalitesi hızla kötüleşti.",
            categoryTrackTr: "Fen",
            cefrLevel: "B2"
        ),
        MockVocabWord(
            id: "w_3",
            word: "mitigate",
            phonetic: "/ˈmɪtɪɡeɪt/",
            partOfSpeechTr: "Fiil",
            meaningTr: "Hafifletmek, yatıştırmak, etkisini azaltmak",
            mandatoryPreposition: nil,
            synonymsTr: ["alleviate", "reduce", "diminish", "lessen"],
            exampleEn: "Prompt therapeutic intervention can substantially mitigate chronic symptoms.",
            exampleTr: "Zamanında yapılan tedavi edici müdahale, kronik semptomları önemli ölçüde hafifletebilir.",
            categoryTrackTr: "Sağlık",
            cefrLevel: "C1"
        ),
        MockVocabWord(
            id: "w_4",
            word: "attribute to",
            phonetic: "/əˈtrɪbjuːt tuː/",
            partOfSpeechTr: "Deyimsel Fiil",
            meaningTr: "-e bağlamak, -e atfetmek",
            mandatoryPreposition: "to",
            synonymsTr: ["ascribe to", "credit to", "put down to"],
            exampleEn: "Cardiologists attribute the sudden drop in mortality to widespread lifestyle changes.",
            exampleTr: "Kardiyologlar ölüm oranlarındaki ani düşüşü yaygın yaşam tarzı değişikliklerine bağlamaktadır.",
            categoryTrackTr: "Sağlık",
            cefrLevel: "C1"
        ),
        MockVocabWord(
            id: "w_5",
            word: "prevalent",
            phonetic: "/ˈprɛvələnt/",
            partOfSpeechTr: "Sıfat",
            meaningTr: "Yaygın, revaçta, hâkim olan",
            mandatoryPreposition: "among / in",
            synonymsTr: ["widespread", "common", "pervasive"],
            exampleEn: "Vitamin D deficiency remains prevalent among individuals living in northern latitudes.",
            exampleTr: "D vitamini eksikliği, kuzey enlemlerinde yaşayan bireyler arasında yaygın kalmaya devam etmektedir.",
            categoryTrackTr: "Sağlık",
            cefrLevel: "B2"
        ),
        MockVocabWord(
            id: "w_6",
            word: "susceptible to",
            phonetic: "/səˈsɛptɪbəl tuː/",
            partOfSpeechTr: "Sıfat",
            meaningTr: "-e duyarlı, -e yatkın, savunmasız",
            mandatoryPreposition: "to",
            synonymsTr: ["vulnerable to", "prone to", "exposed to"],
            exampleEn: "Premature infants are particularly susceptible to severe respiratory pathogens.",
            exampleTr: "Prematüre bebekler, ağır solunum yolu patojenlerine karşı özellikle savunmasızdır.",
            categoryTrackTr: "Sağlık",
            cefrLevel: "C1"
        ),
        MockVocabWord(
            id: "w_7",
            word: "unprecedented",
            phonetic: "/ʌnˈprɛsɪdɛntɪd/",
            partOfSpeechTr: "Sıfat",
            meaningTr: "Eşi benzeri görülmemiş, tarihte ilk",
            mandatoryPreposition: nil,
            synonymsTr: ["unparalleled", "novel", "groundbreaking"],
            exampleEn: "The global temperature anomalies recorded in July were completely unprecedented.",
            exampleTr: "Temmuz ayında kaydedilen küresel sıcaklık anomalileri tamamen eşi benzeri görülmemişti.",
            categoryTrackTr: "Fen",
            cefrLevel: "C1"
        ),
        MockVocabWord(
            id: "w_8",
            word: "refrain from",
            phonetic: "/rɪˈfreɪn frɒm/",
            partOfSpeechTr: "Deyimsel Fiil",
            meaningTr: "-den kaçınmak, kendini sakınmak",
            mandatoryPreposition: "from",
            synonymsTr: ["abstain from", "avoid", "withhold from"],
            exampleEn: "Patients undergoing vascular surgery must refrain from smoking for three weeks.",
            exampleTr: "Damar ameliyatı geçirecek hastalar üç hafta boyunca sigara içmekten kaçınmalıdır.",
            categoryTrackTr: "Sağlık",
            cefrLevel: "B2"
        ),
        MockVocabWord(
            id: "w_9",
            word: "jeopardize",
            phonetic: "/ˈdʒɛpədaɪz/",
            partOfSpeechTr: "Fiil",
            meaningTr: "Tehlikeye atmak, riske sokmak",
            mandatoryPreposition: nil,
            synonymsTr: ["endanger", "threaten", "imperil"],
            exampleEn: "Excessive national debt can jeopardize long-term socioeconomic stability.",
            exampleTr: "Aşırı ulusal borçlanma, uzun vadeli sosyoekonomik istikrarı tehlikeye atabilir.",
            categoryTrackTr: "Sosyal",
            cefrLevel: "C1"
        ),
        MockVocabWord(
            id: "w_10",
            word: "deprive of",
            phonetic: "/dɪˈpraɪv ɒv/",
            partOfSpeechTr: "Deyimsel Fiil",
            meaningTr: "-den mahrum bırakmak / yoksun kılmak",
            mandatoryPreposition: "of",
            synonymsTr: ["strip of", "rob of", "dispossess of"],
            exampleEn: "Sleep deprivation deprives cortical neurons of essential restorative phases.",
            exampleTr: "Uykusuzluk, kortikal nöronları temel yenilenme evrelerinden mahrum bırakır.",
            categoryTrackTr: "Sağlık",
            cefrLevel: "B2"
        ),
        MockVocabWord(
            id: "w_11",
            word: "concur with",
            phonetic: "/kənˈkɜː wɪð/",
            partOfSpeechTr: "Deyimsel Fiil",
            meaningTr: "-e katılmak, aynı fikirde olmak",
            mandatoryPreposition: "with",
            synonymsTr: ["agree with", "endorse", "accord with"],
            exampleEn: "Independent peer reviewers concurred with the primary findings of the climate paper.",
            exampleTr: "Bağımsız hakemler iklim makalesinin birincil bulgularına katıldı.",
            categoryTrackTr: "Akademik",
            cefrLevel: "C1"
        ),
        MockVocabWord(
            id: "w_12",
            word: "lucrative",
            phonetic: "/ˈluːkrətɪv/",
            partOfSpeechTr: "Sıfat",
            meaningTr: "Kârlı, kazançlı, rant getiren",
            mandatoryPreposition: nil,
            synonymsTr: ["profitable", "rewarding", "remunerative"],
            exampleEn: "Biotechnology has become one of the most lucrative industries of the 21st century.",
            exampleTr: "Biyoteknoloji 21. yüzyılın en kazançlı sanayilerinden biri haline geldi.",
            categoryTrackTr: "Sosyal",
            cefrLevel: "B2"
        ),
        MockVocabWord(
            id: "w_13",
            word: "indispensable",
            phonetic: "/ˌɪndɪˈspɛnsəbəl/",
            partOfSpeechTr: "Sıfat",
            meaningTr: "Vazgeçilmez, zorunlu, elzem",
            mandatoryPreposition: "to / for",
            synonymsTr: ["vital", "crucial", "essential"],
            exampleEn: "Clean freshwater reservoirs are indispensable for sustainable urban agriculture.",
            exampleTr: "Temiz tatlı su havzaları sürdürülebilir kentsel tarım için vazgeçilmezdir.",
            categoryTrackTr: "Fen",
            cefrLevel: "B2"
        ),
        MockVocabWord(
            id: "w_14",
            word: "comply with",
            phonetic: "/kəmˈplaɪ wɪð/",
            partOfSpeechTr: "Deyimsel Fiil",
            meaningTr: "-e uymak, kurallara riayet etmek",
            mandatoryPreposition: "with",
            synonymsTr: ["conform to", "adhere to", "abide by"],
            exampleEn: "All chemical processing plants must comply with strict environmental thresholds.",
            exampleTr: "Tüm kimyasal işleme tesisleri katı çevresel eşik değerlerine uymalıdır.",
            categoryTrackTr: "Akademik",
            cefrLevel: "B2"
        ),
        MockVocabWord(
            id: "w_15",
            word: "alleviate",
            phonetic: "/əˈliːvieɪt/",
            partOfSpeechTr: "Fiil",
            meaningTr: "Hafifletmek, acıyı/yükü dindirmek",
            mandatoryPreposition: nil,
            synonymsTr: ["mitigate", "ease", "soothe"],
            exampleEn: "Microfinance loans helped alleviate severe rural poverty in developing nations.",
            exampleTr: "Mikrofinans kredileri, gelişmekte olan ülkelerde şiddetli kırsal yoksulluğun hafifletilmesine yardımcı oldu.",
            categoryTrackTr: "Sosyal",
            cefrLevel: "C1"
        ),
        MockVocabWord(
            id: "w_16",
            word: "paucity",
            phonetic: "/ˈpɔːsɪti/",
            partOfSpeechTr: "İsim",
            meaningTr: "Kıtlık, azlık, yetersiz miktar",
            mandatoryPreposition: "of",
            synonymsTr: ["scarcity", "shortage", "dearth", "deficiency"],
            exampleEn: "The paucity of empirical evidence hindered the validation of the new hypothesis.",
            exampleTr: "Deneysel kanıtların kıtlığı, yeni hipotezin doğrulanmasını engelledi.",
            categoryTrackTr: "Akademik",
            cefrLevel: "C1"
        ),
        MockVocabWord(
            id: "w_17",
            word: "feasible",
            phonetic: "/ˈfiːzɪbəl/",
            partOfSpeechTr: "Sıfat",
            meaningTr: "Uygulanabilir, yapılabilir, fizibl",
            mandatoryPreposition: nil,
            synonymsTr: ["viable", "practicable", "workable"],
            exampleEn: "Deep geothermal drilling is technically feasible with ultra-hard diamond drillheads.",
            exampleTr: "Derin jeotermal sondaj, ultra sert elmas matkap uçlarıyla teknik olarak uygulanabilirdir.",
            categoryTrackTr: "Fen",
            cefrLevel: "B2"
        ),
        MockVocabWord(
            id: "w_18",
            word: "plausible",
            phonetic: "/ˈplɔːzɪbəl/",
            partOfSpeechTr: "Sıfat",
            meaningTr: "Makul, akla yatkın, inandırıcı",
            mandatoryPreposition: nil,
            synonymsTr: ["credible", "believable", "reasonable"],
            exampleEn: "Astronomers presented a highly plausible explanation for the interstellar signal.",
            exampleTr: "Gökbilimciler, yıldızlararası sinyal için son derece akla yatkın bir açıklama sundular.",
            categoryTrackTr: "Fen",
            cefrLevel: "C1"
        ),
        MockVocabWord(
            id: "w_19",
            word: "reconcile",
            phonetic: "/ˈrɛkənsaɪl/",
            partOfSpeechTr: "Fiil",
            meaningTr: "Uzlaştırmak, barıştırmak, bağdaştırmak",
            mandatoryPreposition: "with",
            synonymsTr: ["harmonize", "synthesize", "resolve"],
            exampleEn: "It is challenging to reconcile quantum physics with general relativity.",
            exampleTr: "Kuantum fiziği ile genel göreliliği bağdaştırmak oldukça zordur.",
            categoryTrackTr: "Akademik",
            cefrLevel: "C1"
        ),
        MockVocabWord(
            id: "w_20",
            word: "detrimental to",
            phonetic: "/ˌdɛtrɪˈmɛntəl tuː/",
            partOfSpeechTr: "Sıfat",
            meaningTr: "-e zararlı, tahrip edici, yıkıcı",
            mandatoryPreposition: "to",
            synonymsTr: ["harmful to", "damaging to", "deleterious to"],
            exampleEn: "Chronic elevated cortisol levels are detrimental to neural neurogenesis.",
            exampleTr: "Sürekli yüksek seyreden kortizol düzeyleri sinirsel nörogeneze zararlıdır.",
            categoryTrackTr: "Sağlık",
            cefrLevel: "C1"
        ),
        MockVocabWord(
            id: "w_21",
            word: "commence",
            phonetic: "/kəˈmɛns/",
            partOfSpeechTr: "Fiil",
            meaningTr: "Başlamak, start vermek (resmî)",
            mandatoryPreposition: "with",
            synonymsTr: ["initiate", "begin", "launch"],
            exampleEn: "Phase III clinical trials will commence as soon as ethics committee approvals are finalized.",
            exampleTr: "Etik kurul onayları tamamlanır tamamlanmaz Faz III klinik çalışmaları başlayacaktır.",
            categoryTrackTr: "Akademik",
            cefrLevel: "B2"
        ),
        MockVocabWord(
            id: "w_22",
            word: "pertain to",
            phonetic: "/pəˈteɪn tuː/",
            partOfSpeechTr: "Deyimsel Fiil",
            meaningTr: "-e ait olmak, -le ilişkili olmak",
            mandatoryPreposition: "to",
            synonymsTr: ["relate to", "concern", "apply to"],
            exampleEn: "The questions raised during cross-examination pertained directly to trade tariffs.",
            exampleTr: "Çapraz sorgu esnasında yöneltilen sorular doğrudan ticaret tarifeleriyle ilişkiliydi.",
            categoryTrackTr: "Sosyal",
            cefrLevel: "C1"
        ),
        MockVocabWord(
            id: "w_23",
            word: "subside",
            phonetic: "/səbˈsaɪd/",
            partOfSpeechTr: "Fiil",
            meaningTr: "Yatışmak, dinmek, azalmak",
            mandatoryPreposition: nil,
            synonymsTr: ["abate", "lessen", "recede"],
            exampleEn: "Once the volcanic tremors subsided, geologists approached the caldera rim.",
            exampleTr: "Volkanik sarsıntılar yatıştıktan sonra jeologlar kaldera kenarına yaklaştı.",
            categoryTrackTr: "Fen",
            cefrLevel: "B2"
        ),
        MockVocabWord(
            id: "w_24",
            word: "thwart",
            phonetic: "/θwɔːt/",
            partOfSpeechTr: "Fiil",
            meaningTr: "Engellemek, boşa çıkarmak, sekteye uğratmak",
            mandatoryPreposition: nil,
            synonymsTr: ["impede", "foil", "hinder", "frustrate"],
            exampleEn: "Strong immune checkpoints thwarted the malignant cells from proliferating.",
            exampleTr: "Güçlü bağışıklık kontrol noktaları kötü huylu hücrelerin çoğalmasını engelledi.",
            categoryTrackTr: "Sağlık",
            cefrLevel: "C1"
        ),
        MockVocabWord(
            id: "w_25",
            word: "eradicate",
            phonetic: "/ɪˈrædɪkeɪt/",
            partOfSpeechTr: "Fiil",
            meaningTr: "Kökünü kazımak, tamamen yok etmek",
            mandatoryPreposition: "from",
            synonymsTr: ["eliminate", "wipe out", "exterminate"],
            exampleEn: "Vaccination initiatives successfully eradicated smallpox across the globe.",
            exampleTr: "Aşılama girişimleri çiçek hastalığının kökünü dünya genelinde başarıyla kazıdı.",
            categoryTrackTr: "Sağlık",
            cefrLevel: "B2"
        ),
        MockVocabWord(
            id: "w_26",
            word: "induce",
            phonetic: "/ɪnˈdjuːs/",
            partOfSpeechTr: "Fiil",
            meaningTr: "Tetiklemek, sebep olmak, uyarmak",
            mandatoryPreposition: nil,
            synonymsTr: ["trigger", "provoke", "bring about"],
            exampleEn: "Certain food additives can induce severe migraine episodes in sensitive adults.",
            exampleTr: "Bazı gıda katkı maddeleri duyarlı yetişkinlerde ağır migren ataklarını tetikleyebilir.",
            categoryTrackTr: "Sağlık",
            cefrLevel: "B2"
        ),
        MockVocabWord(
            id: "w_27",
            word: "recede",
            phonetic: "/rɪˈsiːd/",
            partOfSpeechTr: "Fiil",
            meaningTr: "Geri çekilmek, uzaklaşmak, silinmek",
            mandatoryPreposition: "from",
            synonymsTr: ["retreat", "withdraw", "fade"],
            exampleEn: "Glacial sheets have receded by dozens of kilometers over the last fifty years.",
            exampleTr: "Buzul örtüleri son elli yıl içinde onlarca kilometre geri çekilmiştir.",
            categoryTrackTr: "Fen",
            cefrLevel: "B2"
        ),
        MockVocabWord(
            id: "w_28",
            word: "coincide with",
            phonetic: "/ˌkəʊɪnˈsaɪd wɪð/",
            partOfSpeechTr: "Deyimsel Fiil",
            meaningTr: "-le denk gelmek, aynı zamana rastlamak",
            mandatoryPreposition: "with",
            synonymsTr: ["concur with", "overlap with"],
            exampleEn: "The solar flare happened to coincide with a major atmospheric satellite recalibration.",
            exampleTr: "Güneş patlaması büyük bir atmosferik uydu kalibrasyonuyla aynı zamana denk geldi.",
            categoryTrackTr: "Fen",
            cefrLevel: "B2"
        ),
        MockVocabWord(
            id: "w_29",
            word: "profound",
            phonetic: "/prəˈfaʊnd/",
            partOfSpeechTr: "Sıfat",
            meaningTr: "Derin, köklü, çok büyük etkiye sahip",
            mandatoryPreposition: nil,
            synonymsTr: ["deep", "far-reaching", "immense"],
            exampleEn: "The invention of the printing press had a profound impact on literacy rates.",
            exampleTr: "Matbaanın icadı okuryazarlık oranları üzerinde derin ve köklü bir etki yarattı.",
            categoryTrackTr: "Sosyal",
            cefrLevel: "C1"
        ),
        MockVocabWord(
            id: "w_30",
            word: "abstain from",
            phonetic: "/əbˈsteɪn frɒm/",
            partOfSpeechTr: "Deyimsel Fiil",
            meaningTr: "-den çekimser kalmak, uzak durmak",
            mandatoryPreposition: "from",
            synonymsTr: ["refrain from", "forbear", "decline"],
            exampleEn: "Three permanent members of the council chose to abstain from the nuclear resolution.",
            exampleTr: "Konseyin üç daimi üyesi nükleer karar tasarısında çekimser kalmayı tercih etti.",
            categoryTrackTr: "Sosyal",
            cefrLevel: "B2"
        )
    ]

    // MARK: - Haftalık İlerleme Mock Verisi
    public struct WeeklyStudyDay: Identifiable, Sendable {
        public let id: String
        public let dayNameTr: String
        public let questionCount: Int
        public let accuracyPercent: Int
        public let minutesStudied: Int
        public let isToday: Bool

        public init(
            id: String,
            dayNameTr: String,
            questionCount: Int,
            accuracyPercent: Int,
            minutesStudied: Int,
            isToday: Bool = false
        ) {
            self.id = id
            self.dayNameTr = dayNameTr
            self.questionCount = questionCount
            self.accuracyPercent = accuracyPercent
            self.minutesStudied = minutesStudied
            self.isToday = isToday
        }
    }

    public static let weeklyDays: [WeeklyStudyDay] = [
        WeeklyStudyDay(id: "d_1", dayNameTr: "Pzt", questionCount: 25, accuracyPercent: 84, minutesStudied: 32),
        WeeklyStudyDay(id: "d_2", dayNameTr: "Sal", questionCount: 30, accuracyPercent: 78, minutesStudied: 40),
        WeeklyStudyDay(id: "d_3", dayNameTr: "Çar", questionCount: 20, accuracyPercent: 90, minutesStudied: 25),
        WeeklyStudyDay(id: "d_4", dayNameTr: "Per", questionCount: 35, accuracyPercent: 82, minutesStudied: 45),
        WeeklyStudyDay(id: "d_5", dayNameTr: "Cum", questionCount: 28, accuracyPercent: 86, minutesStudied: 35),
        WeeklyStudyDay(id: "d_6", dayNameTr: "Cmt", questionCount: 45, accuracyPercent: 88, minutesStudied: 60),
        WeeklyStudyDay(id: "d_7", dayNameTr: "Paz", questionCount: 20, accuracyPercent: 92, minutesStudied: 30, isToday: true)
    ]
}
