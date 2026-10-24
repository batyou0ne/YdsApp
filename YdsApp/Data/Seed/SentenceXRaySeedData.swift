import Foundation

/// Gerçek YDS / e-YDS / YÖKDİL kalitesinde 20 adet (Sağlık: 6, Fen: 6, Sosyal: 6, Genel: 2)
/// 4-5 satırlık Akademik Cümle Röntgeni (Sentence X-Ray) Seed Verisi.
/// KURAL: `examLogicTipTr` dilbilgisi terimlerine boğmaz; doğrudan şık eleme ve sınav kısayolu verir!
public enum SentenceXRaySeedData {
    public static let allItems: [SentenceXRayItem] = healthItems + naturalItems + socialItems + generalItems

    // MARK: - SAĞLIK BİLİMLERİ (6 Adet)
    public static let healthItems: [SentenceXRayItem] = [
        SentenceXRayItem(
            id: "xray-health-1",
            track: .healthSciences,
            difficultyLevel: 4,
            fullTranslationTr: "Dünya genelinde milyonlarca yaşlı bireyi etkileyen nörodejeneratif bozukluklar erken evrelerde nadiren belirgin semptomlar gösterse de, yeni geliştirilen biyobelirteç testleri klinik yıkım başlamadan yıllar önce hücresel hasarı tespit edebilmektedir.",
            skeletonSummaryTr: "Bozukluklar semptom göstermese de, testler hasarı tespit edebilir.",
            clausePolarityLeft: .negative,
            clausePolarityRight: .positive,
            segments: [
                SentenceSegment(
                    id: "xh1-s1",
                    text: "Although",
                    role: .conjunction,
                    examLogicTipTr: "Cümle başında 'Although' (-se bile / -e rağmen) görürsen: Virgüle kadar olan kısımla virgülden sonrası ZIT kutuplu olmak zorundadır. İlk taraf eksi (-) ise ikinci taraf artı (+) olacaktır.",
                    conjunctionDirection: .contrast,
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xh1-s2",
                    text: "neurodegenerative disorders",
                    role: .mainSubject,
                    examLogicTipTr: "Yan cümleciğin öznesi. Çoğul ('disorders') olduğu için ileride 'they' veya 'their' zamiriyle takip edilir."
                ),
                SentenceSegment(
                    id: "xh1-s3",
                    text: "affecting millions of elderly individuals worldwide",
                    role: .nonEssentialClause,
                    examLogicTipTr: "Sınav Kısayolu: İsimden hemen sonra gelen 'affecting...' (etkileyen) kısmı sadece 'disorders' kelimesini süslüyor. Çeviri sorularında süreyi korumak için bu kısmı ilk okumada atla!"
                ),
                SentenceSegment(
                    id: "xh1-s4",
                    text: "rarely manifest overt symptoms in their initial stages,",
                    role: .mainVerb,
                    examLogicTipTr: "DİKKAT! 'rarely' (nadiren) kelimesi cümlede 'not' olmasa bile cümleyi OLUMSUZ (-) kutba çevirir!",
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xh1-s5",
                    text: "newly developed biomarker assays",
                    role: .mainSubject,
                    examLogicTipTr: "İşte virgülden sonraki gerçek ANA ÖZNE! Çeviri şıklarında özne olarak mutlaka 'yeni geliştirilen biyobelirteç testleri' aranmalı."
                ),
                SentenceSegment(
                    id: "xh1-s6",
                    text: "can detect",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM! Türkçe çeviri şıklarında cümlenin en sonu mutlaka 'tespit edebilmektedir / saptayabilir' ile bitmek zorunda. Bitmeyen 3 şıkkı anında ele!",
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xh1-s7",
                    text: "cellular damage years before clinical deterioration begins.",
                    role: .standard,
                    examLogicTipTr: "Zaman eki: 'years before...' (yıllar önce). Paragraf sorularında 'erken teşhis mümkündür' çıkarımını doğrular."
                )
            ]
        ),
        SentenceXRayItem(
            id: "xray-health-2",
            track: .healthSciences,
            difficultyLevel: 5,
            fullTranslationTr: "Uzun süreli antibiyotik kullanımına atfedilen bağırsak mikrobiyotası bozulması, bağışıklık tepkilerini o kadar derinden zayıflatır ki hastalar normalde zararsız olan fırsatçı enfeksiyonlara karşı savunmasız hale gelir.",
            skeletonSummaryTr: "Mikrobiyota bozulması bağışıklığı zayıflatır ve hastalar savunmasız kalır.",
            clausePolarityLeft: .negative,
            clausePolarityRight: .negative,
            segments: [
                SentenceSegment(
                    id: "xh2-s1",
                    text: "The disruption of gut microbiota,",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: 'of' tamlamalarında asıl özne 'of'tan önceki kelimedir ('The disruption' = Bozulma).",
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xh2-s2",
                    text: "which is frequently attributed to prolonged antibiotic administration,",
                    role: .nonEssentialClause,
                    examLogicTipTr: "İki virgül arası bilgi! Sınavda bu kısmı paranteze al ve üstünü çiz; ana özne doğrudan virgülden sonraki yükleme bağlanır."
                ),
                SentenceSegment(
                    id: "xh2-s3",
                    text: "impairs",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM: 'impairs' (zayıflatır / bozar). Tekil özne ('The disruption') olduğu için '-s' takısı almış.",
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xh2-s4",
                    text: "immune responses",
                    role: .standard
                ),
                SentenceSegment(
                    id: "xh2-s5",
                    text: "so profoundly that",
                    role: .conjunction,
                    examLogicTipTr: "'so + zarf + that' kalıbı: 'O kadar ... ki' demektir. Neden-sonuç bağlar; sol taraf eksi (-) olduğu için sağ taraf da bunun olumsuz sonucu (-) olur.",
                    conjunctionDirection: .parallel,
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xh2-s6",
                    text: "patients become susceptible to",
                    role: .prepositionTrigger,
                    examLogicTipTr: "ALTIN EDAT KALIBI: 'susceptible TO' = 'vulnerable TO' = 'prone TO' (-e karşı açık/savunmasız). Boşluktan sonra 'to' varsa gözün kapalı işaretle!"
                ),
                SentenceSegment(
                    id: "xh2-s7",
                    text: "opportunistic infections that would otherwise remain benign.",
                    role: .nonEssentialClause,
                    examLogicTipTr: "'otherwise' (aksi takdirde / normal şartlarda) ipucu: Bağışıklık bozulmasaydı zararsız ('benign') kalacak enfeksiyonları anlatır."
                )
            ]
        ),
        SentenceXRayItem(
            id: "xray-health-3",
            track: .healthSciences,
            difficultyLevel: 4,
            fullTranslationTr: "mRNA aşı teknolojisi başlangıçta yalnızca bulaşıcı salgınları kontrol altına almak için tasarlanmış olsa da, onkologlar şimdi aynı platformu hastaya özgü kanser tümörlerini hedeflemek amacıyla uyarlamaktadır.",
            skeletonSummaryTr: "Teknoloji salgınlar için tasarlansa da, onkologlar onu kanser için uyarlıyor.",
            clausePolarityLeft: .neutral,
            clausePolarityRight: .positive,
            segments: [
                SentenceSegment(
                    id: "xh3-s1",
                    text: "Whereas",
                    role: .conjunction,
                    examLogicTipTr: "'Whereas' / 'While' cümle başında 'iken / -e karşın' anlamıyla iki farklı durumu veya zamanı ('initially' vs 'now') karşılaştırır.",
                    conjunctionDirection: .contrast,
                    segmentPolarity: .neutral
                ),
                SentenceSegment(
                    id: "xh3-s2",
                    text: "mRNA vaccine technology was initially engineered solely to contain infectious outbreaks,",
                    role: .nonEssentialClause,
                    examLogicTipTr: "'initially' (başlangıçta) ve 'solely' (yalnızca) kelimeleri yan cümlede geçmişteki dar amacı gösterir; ana cümlede 'now' ile kapsam genişleyecek!"
                ),
                SentenceSegment(
                    id: "xh3-s3",
                    text: "oncologists",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: Virgülden hemen sonra gelen 'oncologists' (onkologlar)."
                ),
                SentenceSegment(
                    id: "xh3-s4",
                    text: "are now adapting",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM: 'şimdi uyarlamaktadır'. Çeviri şıklarında yüklemi 'uyarlamaktadır' olmayan tüm şıkları saniyesinde ele!",
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xh3-s5",
                    text: "the same lipid-nanoparticle platform",
                    role: .standard
                ),
                SentenceSegment(
                    id: "xh3-s6",
                    text: "in order to target",
                    role: .prepositionTrigger,
                    examLogicTipTr: "'in order to' = 'so as to' (-mek amacıyla). Amaç bildiren bağlaç ailesi her zaman yalın fiil (V1) alır."
                ),
                SentenceSegment(
                    id: "xh3-s7",
                    text: "patient-specific malignant tumors.",
                    role: .standard
                )
            ]
        ),
        SentenceXRayItem(
            id: "xray-health-4",
            track: .healthSciences,
            difficultyLevel: 5,
            fullTranslationTr: "Kronik uyku yoksunluğu yalnızca prefrontal korteksteki bilişsel işlevleri bozmakla kalmaz, aynı zamanda sistemik iltihaplanmayı tetikleyerek kardiyovasküler hastalık riskini iki katına çıkarır.",
            skeletonSummaryTr: "Uyku yoksunluğu hem bilişsel işlevi bozar hem de kalp riskini artırır.",
            clausePolarityLeft: .negative,
            clausePolarityRight: .negative,
            segments: [
                SentenceSegment(
                    id: "xh4-s1",
                    text: "Chronic sleep deprivation",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: 'Kronik uyku yoksunluğu'. Olumsuz (-) bir kavram olduğu için devamında olumsuz fiiller bekleriz.",
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xh4-s2",
                    text: "not only",
                    role: .conjunction,
                    examLogicTipTr: "'not only ... but also' (yalnızca ... değil, aynı zamanda ...): Paralel bağlaçtır (⇉). Sol taraf eksi (-) ise sağ taraf da eksi (-) olmak zorundadır!",
                    conjunctionDirection: .parallel,
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xh4-s3",
                    text: "compromises",
                    role: .mainVerb,
                    examLogicTipTr: "YÖKDİL Sağlık Favori Fiili: 'compromise' sağlık metinlerinde 'uzlaşmak' DEĞİL, 'tehlikeye atmak / bozmak / zayıflatmak' demektir!",
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xh4-s4",
                    text: "cognitive executive functions within the prefrontal cortex",
                    role: .standard
                ),
                SentenceSegment(
                    id: "xh4-s5",
                    text: "but also",
                    role: .conjunction,
                    examLogicTipTr: "'not only'nin ayrılmaz eşi. İkinci ana fiili birbirine bağlar.",
                    conjunctionDirection: .parallel,
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xh4-s6",
                    text: "doubles the risk of",
                    role: .mainVerb,
                    examLogicTipTr: "İKİNCİ ANA YÜKLEM: 'riskini iki katına çıkarır'.",
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xh4-s7",
                    text: "cardiovascular mortality by triggering systemic inflammation.",
                    role: .prepositionTrigger,
                    examLogicTipTr: "'by + V-ing' (-erek / -arak): 'tetikleyerek'. Çeviri sorularında zarf-fiil ekini doğrudan yakalamanı sağlar."
                )
            ]
        ),
        SentenceXRayItem(
            id: "xray-health-5",
            track: .healthSciences,
            difficultyLevel: 4,
            fullTranslationTr: "Kan-beyin bariyeri merkezi sinir sistemini dolaşımdaki patojenlerden koruma konusunda hayati bir rol oynadığından, nörologlar terapötik ilaçları beyin dokusuna ulaştırmakta büyük zorluklarla karşılaşmaktadır.",
            skeletonSummaryTr: "Bariyer beyni koruduğu için, nörologlar ilaç ulaştırmakta zorlanıyor.",
            clausePolarityLeft: .positive,
            clausePolarityRight: .negative,
            segments: [
                SentenceSegment(
                    id: "xh5-s1",
                    text: "Since",
                    role: .conjunction,
                    examLogicTipTr: "Cümle başındaki 'Since' yan cümlede Present Tense varsa '%99' '-dığı için / چونکه (Because/As)' anlamındadır! ('-den beri' olması için ana cümlede have/has V3 gerekir).",
                    conjunctionDirection: .parallel,
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xh5-s2",
                    text: "the blood-brain barrier plays a pivotal role in shielding",
                    role: .prepositionTrigger,
                    examLogicTipTr: "'play a pivotal role IN + V-ing' (... konusunda hayati rol oynamak) ve 'shield / protect FROM' (-den korumak) ikilisine dikkat!",
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xh5-s3",
                    text: "the central nervous system from circulating pathogens,",
                    role: .nonEssentialClause,
                    examLogicTipTr: "Virgüle kadar olan neden cümleciği bitti. Şimdi ana özne ve ana yüklem geliyor."
                ),
                SentenceSegment(
                    id: "xh5-s4",
                    text: "neurologists",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: 'nörologlar'."
                ),
                SentenceSegment(
                    id: "xh5-s5",
                    text: "encounter formidable obstacles",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM: 'ciddi/büyük engellerle karşılaşmaktadır'. Bumlu görünen koruma mekanizmasının, ilaç geçişinde olumsuz (-) bir zorluk yarattığını gösterir.",
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xh5-s6",
                    text: "in delivering therapeutic agents across neural tissues.",
                    role: .prepositionTrigger,
                    examLogicTipTr: "'difficulty / obstacle IN + V-ing': '... yapmakta zorluk/engel'."
                )
            ]
        ),
        SentenceXRayItem(
            id: "xray-health-6",
            track: .healthSciences,
            difficultyLevel: 5,
            fullTranslationTr: "Klinik deneylerde plasebo etkisi ne kadar güçlü olursa olsun, yeni bir farmakolojik bileşiğin onay alabilmesi için standart tedavilere kıyasla istatistiksel olarak anlamlı bir üstünlük göstermesi şarttır.",
            skeletonSummaryTr: "Plasebo ne kadar güçlü olursa olsun, yeni ilacın üstünlük göstermesi şarttır.",
            clausePolarityLeft: .neutral,
            clausePolarityRight: .positive,
            segments: [
                SentenceSegment(
                    id: "xh6-s1",
                    text: "No matter how",
                    role: .conjunction,
                    examLogicTipTr: "'No matter how + Sıfat/Zarf' = 'However + Sıfat/Zarf' (Ne kadar ... olursa olsun). Hemen arkasından mutlaka bir sıfat ('potent') gelir!",
                    conjunctionDirection: .contrast,
                    segmentPolarity: .neutral
                ),
                SentenceSegment(
                    id: "xh6-s2",
                    text: "potent the placebo response may appear in clinical trials,",
                    role: .nonEssentialClause,
                    examLogicTipTr: "Taviz yan cümleciği: 'Klinik deneylerde plasebo tepkisi ne kadar güçlü görünürse görünsün'."
                ),
                SentenceSegment(
                    id: "xh6-s3",
                    text: "a novel pharmacological compound",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: 'Yeni (novel) bir farmakolojik bileşik'. Sınavda 'novel' = 'yeni/özgün' demektir, 'roman' tuzağına düşme!"
                ),
                SentenceSegment(
                    id: "xh6-s4",
                    text: "must demonstrate",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM: 'göstermelidir / göstermesi şarttır'.",
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xh6-s5",
                    text: "statistically significant superiority over",
                    role: .prepositionTrigger,
                    examLogicTipTr: "ALTIN EDAT: 'superiority OVER' / 'advantage OVER' (bir şeye kıyasla üstünlük/avantaj). 'to' veya 'than' ile karıştırma!"
                ),
                SentenceSegment(
                    id: "xh6-s6",
                    text: "standard treatment regimens before regulatory approval is granted.",
                    role: .standard
                )
            ]
        )
    ]

    // MARK: - FEN BİLİMLERİ (6 Adet)
    public static let naturalItems: [SentenceXRayItem] = [
        SentenceXRayItem(
            id: "xray-natural-1",
            track: .naturalSciences,
            difficultyLevel: 4,
            fullTranslationTr: "Güneş panellerinin enerji dönüşüm verimliliği son on yılda önemli ölçüde artmış olmasına rağmen, şebeke ölçekli batarya depolama altyapısının yetersizliği yenilenebilir enerjinin kesintisiz kullanımını hâlâ kısıtlamaktadır.",
            skeletonSummaryTr: "Verimlilik artsa da, depolama yetersizliği kullanımı kısıtlamaktadır.",
            clausePolarityLeft: .positive,
            clausePolarityRight: .negative,
            segments: [
                SentenceSegment(
                    id: "xn1-s1",
                    text: "Despite",
                    role: .conjunction,
                    examLogicTipTr: "'Despite / In spite of' (-e rağmen): Zıtlık bağlacıdır (⇄) ve arkasından TAM CÜMLE DEĞİL, İsim Öbeği (Noun Phrase) alır!",
                    conjunctionDirection: .contrast,
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xn1-s2",
                    text: "the remarkable surge in the energy conversion efficiency of photovoltaic cells over the past decade,",
                    role: .nonEssentialClause,
                    examLogicTipTr: "'surge IN' (...-daki ani artış). Burası artı (+) kutuplu bir isim öbeğidir, yüklem içermez."
                ),
                SentenceSegment(
                    id: "xn1-s3",
                    text: "the inadequacy of grid-scale battery storage infrastructure",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: Asıl özne ilk 'of'tan önceki 'the inadequacy' (yetersizlik) kelimesidir! Olumsuz (-) kutbu hemen belli eder.",
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xn1-s4",
                    text: "still constrains",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM: 'hâlâ kısıtlamaktadır / sınırlamaktadır' (= restricts / limits / hampers).",
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xn1-s5",
                    text: "the uninterrupted deployment of renewable power.",
                    role: .standard,
                    examLogicTipTr: "'deployment' Fen metinlerinde 'askeri konuşlandırma' değil, 'teknolojinin sahada kullanımı / devreye alınması' demektir."
                )
            ]
        ),
        SentenceXRayItem(
            id: "xray-natural-2",
            track: .naturalSciences,
            difficultyLevel: 5,
            fullTranslationTr: "Arktik permafrost tabakaları küresel ısınma nedeniyle hızla çözülürken, binlerce yıldır donmuş toprakta hapsolmuş devasa miktarda metan gazı atmosfere karışmakta ve iklim değişikliğini daha da hızlandırmaktadır.",
            skeletonSummaryTr: "Permafrost çözülürken, metan gazı atmosfere karışıp ısınmayı hızlandırıyor.",
            clausePolarityLeft: .negative,
            clausePolarityRight: .negative,
            segments: [
                SentenceSegment(
                    id: "xn2-s1",
                    text: "As",
                    role: .conjunction,
                    examLogicTipTr: "'As' arkasından değişim/artış/azalış fiili ('thaw rapidly') geldiğinde 'dıkça / -iken' (paralel süreç ⇉) anlamı verir!",
                    conjunctionDirection: .parallel,
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xn2-s2",
                    text: "Arctic permafrost layers thaw rapidly due to anthropogenic global warming,",
                    role: .nonEssentialClause,
                    examLogicTipTr: "'due to' = 'owing to' = 'because of' (-den dolayı). Arkasından isim öbeği alır."
                ),
                SentenceSegment(
                    id: "xn2-s3",
                    text: "vast quantities of methane gas",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: 'Devasa miktarda metan gazı'."
                ),
                SentenceSegment(
                    id: "xn2-s4",
                    text: "trapped within frozen sediments for millennia",
                    role: .nonEssentialClause,
                    examLogicTipTr: "KISALTMA (Reduction): 'which have been trapped' yerine doğrudan V3 ('trapped' = hapsolmuş) kullanılmış. İki virgül arası gibi düşünüp atlayabilirsin!"
                ),
                SentenceSegment(
                    id: "xn2-s5",
                    text: "are being released into",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM (Edilgen): 'salınmaktadır / karışmaktadır'. 'release INTO' edatıyla birlikte çalışır.",
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xn2-s6",
                    text: "the atmosphere, thereby accelerating the greenhouse feedback loop.",
                    role: .prepositionTrigger,
                    examLogicTipTr: "'thereby + V-ing' (böylece ...-erek): YDS Çeviri ve Cloze Test sorularının en sevdiği sonuç bağlama kalıbıdır!"
                )
            ]
        ),
        SentenceXRayItem(
            id: "xray-natural-3",
            track: .naturalSciences,
            difficultyLevel: 4,
            fullTranslationTr: "Kuantum bilgisayarlar geleneksel süper bilgisayarların çözmesi binlerce yıl sürecek şifreleme algoritmalarını saniyeler içinde kırabilme potansiyeline sahiptir; ancak çevresel gürültüye olan aşırı duyarlılıkları ticari ölçeklenebilirliği engellemektedir.",
            skeletonSummaryTr: "Kuantum bilgisayarlar şifreleri kırabilir; ancak duyarlılıkları ölçeklenmeyi engelliyor.",
            clausePolarityLeft: .positive,
            clausePolarityRight: .negative,
            segments: [
                SentenceSegment(
                    id: "xn3-s1",
                    text: "Quantum processors",
                    role: .mainSubject,
                    examLogicTipTr: "1. Cümlenin Ana Öznesi: 'Kuantum işlemciler'."
                ),
                SentenceSegment(
                    id: "xn3-s2",
                    text: "possess the potential to decipher",
                    role: .mainVerb,
                    examLogicTipTr: "1. Ana Yüklem: 'çözme/kırma potansiyeline sahiptir'. Olumlu (+) bir yetenek anlatılıyor.",
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xn3-s3",
                    text: "cryptographic algorithms that would take classical supercomputers millennia to solve;",
                    role: .nonEssentialClause,
                    examLogicTipTr: "'that would take...' sıfat cümleciği algoritmaları tanımlar."
                ),
                SentenceSegment(
                    id: "xn3-s4",
                    text: "nevertheless,",
                    role: .conjunction,
                    examLogicTipTr: "Noktalı virgül + 'nevertheless / however / nonetheless' (buna rağmen / ancak): Keskin zıtlık (⇄) başlatır! Artıdan (+) eksiye (-) geçişin sinyalidir.",
                    conjunctionDirection: .contrast,
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xn3-s5",
                    text: "their extreme sensitivity to",
                    role: .prepositionTrigger,
                    examLogicTipTr: "EDAT İKİZİ: 'sensitivity TO' = 'susceptibility TO' (-e karşı duyarlılık/hassasiyet)."
                ),
                SentenceSegment(
                    id: "xn3-s6",
                    text: "thermal and electromagnetic noise",
                    role: .standard
                ),
                SentenceSegment(
                    id: "xn3-s7",
                    text: "severely impedes",
                    role: .mainVerb,
                    examLogicTipTr: "2. ANA YÜKLEM: 'ciddi biçimde engellemektedir' (= hinders / hampers / obstructs).",
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xn3-s8",
                    text: "commercial scalability.",
                    role: .standard
                )
            ]
        ),
        SentenceXRayItem(
            id: "xray-natural-4",
            track: .naturalSciences,
            difficultyLevel: 4,
            fullTranslationTr: "James Webb Uzay Teleskobu kızılötesi dalga boylarında benzeri görülmemiş bir çözünürlük sunduğu için, astrofizikçiler artık kozmik toz bulutlarının ardında gizlenen ilk galaksilerin oluşumunu gözlemleyebilmektedir.",
            skeletonSummaryTr: "Teleskop yüksek çözünürlük sunduğu için, astrofizikçiler ilk galaksileri gözlemleyebiliyor.",
            clausePolarityLeft: .positive,
            clausePolarityRight: .positive,
            segments: [
                SentenceSegment(
                    id: "xn4-s1",
                    text: "Inasmuch as",
                    role: .conjunction,
                    examLogicTipTr: "YDS Üst Düzey Bağlaç: 'Inasmuch as' = 'Since' = 'Because' (-dığı için / mademki). Gördüğün yerde 'Because' yazıp geçebilirsin!",
                    conjunctionDirection: .parallel,
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xn4-s2",
                    text: "the James Webb Space Telescope provides unprecedented resolution across infrared wavelengths,",
                    role: .nonEssentialClause,
                    examLogicTipTr: "'unprecedented' (benzeri görülmemiş / eşsiz): YDS'de olumlu (+) bilimsel gelişmeleri anlatırken en sık çıkan sıfattır."
                ),
                SentenceSegment(
                    id: "xn4-s3",
                    text: "astrophysicists",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: 'astrofizikçiler'."
                ),
                SentenceSegment(
                    id: "xn4-s4",
                    text: "are now able to observe",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM: 'artık gözlemleyebilmektedir'.",
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xn4-s5",
                    text: "the formation of primordial galaxies",
                    role: .standard
                ),
                SentenceSegment(
                    id: "xn4-s6",
                    text: "obscured behind dense clouds of cosmic dust.",
                    role: .nonEssentialClause,
                    examLogicTipTr: "Pasif Kısaltma (V3): 'which are obscured behind...' (ardında gizlenen/örtülen)."
                )
            ]
        ),
        SentenceXRayItem(
            id: "xray-natural-5",
            track: .naturalSciences,
            difficultyLevel: 5,
            fullTranslationTr: "Biyoçözünür polimerlerin üretim maliyetleri petrokimya türevli plastiklerle rekabet edebilecek düzeye indirilmedikçe, ambalaj endüstrisinin fosil yakıt bağımlılığından tamamen kurtulması pek olası görünmemektedir.",
            skeletonSummaryTr: "Maliyetler düşürülmedikçe, endüstrinin fosil yakıttan kurtulması olası değildir.",
            clausePolarityLeft: .negative,
            clausePolarityRight: .negative,
            segments: [
                SentenceSegment(
                    id: "xn5-s1",
                    text: "Unless",
                    role: .conjunction,
                    examLogicTipTr: "'Unless' (-medikçe / -madıkça = If ... not): İçinde gizli olumsuzluk barındırır! Ana cümlede genellikle olumsuz bir sonuç ('unlikely', 'cannot', 'fail') ister.",
                    conjunctionDirection: .parallel,
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xn5-s2",
                    text: "the manufacturing costs of biodegradable polymers are reduced to a level competitive with petrochemical plastics,",
                    role: .nonEssentialClause,
                    examLogicTipTr: "'competitive WITH' (... ile rekabet edebilir) edat uyumuna dikkat."
                ),
                SentenceSegment(
                    id: "xn5-s3",
                    text: "it remains highly unlikely that",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM ÇERÇEVESİ: 'pek olası görünmemektedir'. 'Unless' ile %100 uyumlu olumsuz (-) beklenti!",
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xn5-s4",
                    text: "the global packaging industry",
                    role: .mainSubject,
                    examLogicTipTr: "İç Cümlenin Öznesi: 'küresel ambalaj endüstrisi'."
                ),
                SentenceSegment(
                    id: "xn5-s5",
                    text: "will emancipate itself from",
                    role: .prepositionTrigger,
                    examLogicTipTr: "'emancipate / free / liberate FROM' (-den kurtarmak / özgürleştirmek) + 'reliance ON' (-e bağımlılık)."
                ),
                SentenceSegment(
                    id: "xn5-s6",
                    text: "its heavy reliance on fossil feedstocks.",
                    role: .standard
                )
            ]
        ),
        SentenceXRayItem(
            id: "xray-natural-6",
            track: .naturalSciences,
            difficultyLevel: 4,
            fullTranslationTr: "Sismik dalgaların yer kabuğunun farklı katmanlarından geçerken uğradığı kırılma açıları, jeofizikçilere doğrudan sondaj yapmanın imkansız olduğu gezegen çekirdeğinin bileşimi hakkında dolaylı fakat kesin kanıtlar sağlar.",
            skeletonSummaryTr: "Kırılma açıları, jeofizikçilere gezegen çekirdeği hakkında kanıt sağlar.",
            clausePolarityLeft: .positive,
            clausePolarityRight: .positive,
            segments: [
                SentenceSegment(
                    id: "xn6-s1",
                    text: "The refraction angles",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: 'Kırılma açıları' (Çoğul!). Aradaki uzun sıfat cümleciğine aldanma, ana fiil çoğul olmak zorunda."
                ),
                SentenceSegment(
                    id: "xn6-s2",
                    text: "experienced by seismic waves as they propagate through distinct strata of the Earth's crust",
                    role: .nonEssentialClause,
                    examLogicTipTr: "Sınav Kısayolu: 'experienced by...' ile başlayan 12 kelimelik kısım sadece 'kırılma açılarını' tanımlıyor. Paranteze al [ ... ] ve doğrudan ana yükleme atla!"
                ),
                SentenceSegment(
                    id: "xn6-s3",
                    text: "provide",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM: 'sağlar'. Kalıbı: 'provide somebody WITH something' (birine bir şey sağlamak).",
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xn6-s4",
                    text: "geophysicists with",
                    role: .prepositionTrigger,
                    examLogicTipTr: "ALTIN EDAT: 'provide / supply / equip + Kişi + WITH + Nesne'!"
                ),
                SentenceSegment(
                    id: "xn6-s5",
                    text: "indirect yet conclusive evidence regarding the composition of the planetary core,",
                    role: .standard
                ),
                SentenceSegment(
                    id: "xn6-s6",
                    text: "where direct mechanical drilling remains physically impossible.",
                    role: .nonEssentialClause,
                    examLogicTipTr: "'where' burada 'planetary core'u (gezegen çekirdeğini) niteleyen 'ki orada...' anlamında yan cümleciktir."
                )
            ]
        )
    ]

    // MARK: - SOSYAL BİLİMLER (6 Adet)
    public static let socialItems: [SentenceXRayItem] = [
        SentenceXRayItem(
            id: "xray-social-1",
            track: .socialSciences,
            difficultyLevel: 4,
            fullTranslationTr: "Mezopotamya'daki erken şehir devletlerinin çöküşü geleneksel olarak yalnızca yabancı istilalara bağlanmış olsa da, son arkeobotanik bulgular uzun süreli kuraklık ve toprak tuzlanmasının tarımsal temeli içeriden çökerttiğini ortaya koymaktadır.",
            skeletonSummaryTr: "Çöküş istilalara bağlansa da, bulgular kuraklığın tarımı çökerttiğini ortaya koyuyor.",
            clausePolarityLeft: .neutral,
            clausePolarityRight: .positive,
            segments: [
                SentenceSegment(
                    id: "xs1-s1",
                    text: "Even though",
                    role: .conjunction,
                    examLogicTipTr: "'Even though / Although' + 'traditionally' (geleneksel olarak): Akademik metinlerde 'Eskiden böyle sanılırdı AMA yeni bulgular tam tersini söylüyor' kalıbının %100 habercisidir!",
                    conjunctionDirection: .contrast,
                    segmentPolarity: .neutral
                ),
                SentenceSegment(
                    id: "xs1-s2",
                    text: "the collapse of early Mesopotamian city-states has traditionally been ascribed exclusively to foreign invasions,",
                    role: .nonEssentialClause,
                    examLogicTipTr: "EDAT İKİZLERİ: 'ascribe TO' = 'attribute TO' (-e bağlamak / atfetmek)."
                ),
                SentenceSegment(
                    id: "xs1-s3",
                    text: "recent archaeobotanical findings",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: 'Son arkeobotanik bulgular'."
                ),
                SentenceSegment(
                    id: "xs1-s4",
                    text: "reveal that",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM: 'ortaya koymaktadır ki...'. Çeviri şıklarında cümlenin sonu 'ortaya koymaktadır' ile bitmeli!",
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xs1-s5",
                    text: "prolonged drought and soil salinization undermined the agricultural foundation from within.",
                    role: .standard,
                    examLogicTipTr: "'undermine' (altını oymak / zayıflatmak / çökertmek): Sosyal ve Sağlık bilimleri sınavlarının en kritik fiillerinden biridir."
                )
            ]
        ),
        SentenceXRayItem(
            id: "xray-social-2",
            track: .socialSciences,
            difficultyLevel: 5,
            fullTranslationTr: "Matbaanın 15. yüzyıl Avrupası'nda hızla yayılması yalnızca bilimsel eserlerin maliyetini düşürmekle kalmamış, aynı zamanda bilginin tekelini kırarak entelektüel otoritenin sorgulanmasına zemin hazırlamıştır.",
            skeletonSummaryTr: "Matbaa hem maliyeti düşürmüş hem de otoritenin sorgulanmasına zemin hazırlamıştır.",
            clausePolarityLeft: .positive,
            clausePolarityRight: .positive,
            segments: [
                SentenceSegment(
                    id: "xs2-s1",
                    text: "The rapid proliferation of the printing press across fifteenth-century Europe",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: 'proliferation' (hızla yayılma / çoğalma). Tarih olarak 'fifteenth-century' verildiği için yüklem Past (V2) olmak zorundadır!"
                ),
                SentenceSegment(
                    id: "xs2-s2",
                    text: "not only",
                    role: .conjunction,
                    examLogicTipTr: "'not only ... but also' paralel eklemi: İki olumlu/tarihsel etkiyi birbirine bağlar.",
                    conjunctionDirection: .parallel,
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xs2-s3",
                    text: "diminished the reproduction cost of scholarly treatises",
                    role: .mainVerb,
                    examLogicTipTr: "1. ANA YÜKLEM: 'akademik eserlerin çoğaltım maliyetini düşürdü'.",
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xs2-s4",
                    text: "but also",
                    role: .conjunction,
                    conjunctionDirection: .parallel,
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xs2-s5",
                    text: "paved the way for",
                    role: .mainVerb,
                    examLogicTipTr: "2. ANA YÜKLEM & KALIP: 'pave the way FOR' (-e zemin hazırlamak / yolunu açmak). YDS/YÖKDİL'de her yıl mutlaka şıklarda yer alır!",
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xs2-s6",
                    text: "challenging established intellectual authority by dismantling the monopoly over knowledge.",
                    role: .prepositionTrigger,
                    examLogicTipTr: "'monopoly OVER / ON' (... üzerindeki tekel)."
                )
            ]
        ),
        SentenceXRayItem(
            id: "xray-social-3",
            track: .socialSciences,
            difficultyLevel: 4,
            fullTranslationTr: "Küreselleşme yerel kültürleri tek tipleştirdiği gerekçesiyle sıkça eleştirilse de, dijital iletişim ağları aslında yok olma tehlikesi altındaki azınlık dillerinin belgelenmesine ve canlandırılmasına olanak tanımaktadır.",
            skeletonSummaryTr: "Küreselleşme eleştirilse de, dijital ağlar azınlık dillerinin canlanmasına olanak tanıyor.",
            clausePolarityLeft: .negative,
            clausePolarityRight: .positive,
            segments: [
                SentenceSegment(
                    id: "xs3-s1",
                    text: "Much as",
                    role: .conjunction,
                    examLogicTipTr: "TUZAK AVcISI: Cümle başındaki 'Much as' miktar bildirmez; tam olarak 'Although / Even though' (-e rağmen / -se de) demektir!",
                    conjunctionDirection: .contrast,
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xs3-s2",
                    text: "globalization is frequently criticized on the grounds that it homogenizes indigenous cultures,",
                    role: .nonEssentialClause,
                    examLogicTipTr: "'on the grounds that + Tam Cümle' = 'because / gerekçesiyle'. Yan cümle 'eleştirilse de' (-) diyerek zıtlığı kurdu."
                ),
                SentenceSegment(
                    id: "xs3-s3",
                    text: "digital communication networks",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: 'dijital iletişim ağları'."
                ),
                SentenceSegment(
                    id: "xs3-s4",
                    text: "actually enable",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM: 'aslında olanak tanımaktadır' (+).",
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xs3-s5",
                    text: "linguists to document and revitalize endangered minority languages.",
                    role: .standard,
                    examLogicTipTr: "'enable somebody TO V1': Birinin bir şey yapmasına olanak tanımak."
                )
            ]
        ),
        SentenceXRayItem(
            id: "xray-social-4",
            track: .socialSciences,
            difficultyLevel: 5,
            fullTranslationTr: "Davranışsal iktisatçılar, bireylerin finansal kararlar alırken tamamen rasyonel davrandığını varsayan klasik teorinin aksine, bilişsel önyargıların ve kayıptan kaçınma dürtüsünün piyasa tercihlerini şekillendirdiğini savunmaktadır.",
            skeletonSummaryTr: "İktisatçılar, klasik teorinin aksine, önyargıların tercihleri şekillendirdiğini savunuyor.",
            clausePolarityLeft: .neutral,
            clausePolarityRight: .positive,
            segments: [
                SentenceSegment(
                    id: "xs4-s1",
                    text: "Contrary to",
                    role: .conjunction,
                    examLogicTipTr: "'Contrary to / Unlike' (-nın aksine): İki farklı görüşü ('klasik teori' vs 'davranışsal iktisatçılar') karşılaştırır.",
                    conjunctionDirection: .contrast,
                    segmentPolarity: .neutral
                ),
                SentenceSegment(
                    id: "xs4-s2",
                    text: "neoclassical economic theory, which presupposes that individuals act with complete rationality when making financial decisions,",
                    role: .nonEssentialClause,
                    examLogicTipTr: "Virgüle kadar olan 16 kelimelik kısım 'Contrary to' edat öbeğidir; asla ana özne olamaz!"
                ),
                SentenceSegment(
                    id: "xs4-s3",
                    text: "behavioral economists",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: 'davranışsal iktisatçılar'."
                ),
                SentenceSegment(
                    id: "xs4-s4",
                    text: "contend that",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM: 'contend that' = 'argue / maintain / assert that' (... olduğunu savunmaktadır / ileri sürmektedir). 'Memnun olmak (content)' ile karıştırma!",
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xs4-s5",
                    text: "cognitive biases and loss aversion fundamentally shape market preferences.",
                    role: .standard
                )
            ]
        ),
        SentenceXRayItem(
            id: "xray-social-5",
            track: .socialSciences,
            difficultyLevel: 4,
            fullTranslationTr: "Göbeklitepe'de ortaya çıkarılan anıtsal taş dikilitaşlar, avcı-toplayıcı toplulukların yerleşik tarıma geçmeden çok önce karmaşık dini ritüeller ve kolektif işgücü örgütlenmesi geliştirdiğini kanıtlamıştır.",
            skeletonSummaryTr: "Göbeklitepe dikilitaşları, toplulukların tarımdan önce örgütlendiğini kanıtlamıştır.",
            clausePolarityLeft: .positive,
            clausePolarityRight: .positive,
            segments: [
                SentenceSegment(
                    id: "xs5-s1",
                    text: "The monumental limestone pillars",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: 'Anıtsal kireçtaşı dikilitaşlar'."
                ),
                SentenceSegment(
                    id: "xs5-s2",
                    text: "unearthed at Göbeklitepe",
                    role: .nonEssentialClause,
                    examLogicTipTr: "KISALTMA (V3): 'which were unearthed at Göbeklitepe' (Göbeklitepe'de gün yüzüne çıkarılan). Sıfat fiil ekidir."
                ),
                SentenceSegment(
                    id: "xs5-s3",
                    text: "have conclusively demonstrated that",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM: 'kesin olarak kanıtlamıştır ki...'.",
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xs5-s4",
                    text: "forager societies developed intricate ritualistic architecture and collective labor organization",
                    role: .standard
                ),
                SentenceSegment(
                    id: "xs5-s5",
                    text: "long before transitioning to",
                    role: .prepositionTrigger,
                    examLogicTipTr: "'transition TO' (-e geçiş yapmak): Zaman bağlacı 'long before' (...-den çok önce) ile kronolojik sırayı ters yüz eder!"
                ),
                SentenceSegment(
                    id: "xs5-s6",
                    text: "sedentary agriculture.",
                    role: .standard,
                    examLogicTipTr: "'sedentary' (yerleşik / hareketsiz): Arkeolojide 'yerleşik yaşam', tıpta ise 'hareketsiz yaşam tarzı' anlamında çıkar!"
                )
            ]
        ),
        SentenceXRayItem(
            id: "xray-social-6",
            track: .socialSciences,
            difficultyLevel: 5,
            fullTranslationTr: " Kentleşme ekonomik üretkenliği ve uzmanlaşmayı teşvik ederken, uygun fiyatlı konut politikalarıyla desteklenmediği takdirde gelir eşitsizliğini ve mekânsal ayrışmayı derinleştirme eğilimindedir.",
            skeletonSummaryTr: "Kentleşme üretkenliği teşvik ederken, desteklenmezse eşitsizliği derinleştirir.",
            clausePolarityLeft: .positive,
            clausePolarityRight: .negative,
            segments: [
                SentenceSegment(
                    id: "xs6-s1",
                    text: "While",
                    role: .conjunction,
                    examLogicTipTr: "Cümle başındaki 'While': Bir tarafta olumlu (+) 'foster productivity', diğer tarafta olumsuz (-) 'exacerbate inequality' olduğu için '%100 ZITLIK' (-iken / -e karşın) bağlacıdır!",
                    conjunctionDirection: .contrast,
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xs6-s2",
                    text: "rapid urbanization fosters economic productivity and occupational specialization,",
                    role: .nonEssentialClause,
                    examLogicTipTr: "'foster' (teşvik etmek / geliştirmek / beslemek = promote / cultivate): Her zaman olumlu (+) kutup verir."
                ),
                SentenceSegment(
                    id: "xs6-s3",
                    text: "it",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: 'it' (= rapid urbanization)."
                ),
                SentenceSegment(
                    id: "xs6-s4",
                    text: "tends to exacerbate",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM: 'exacerbate' (kötüleştirmek / derinleştirmek / şiddetlendirmek = aggravate / worsen). YDS'nin en popüler olumsuz (-) fiilidir!",
                    segmentPolarity: .negative
                ),
                SentenceSegment(
                    id: "xs6-s5",
                    text: "income disparity and spatial segregation",
                    role: .standard
                ),
                SentenceSegment(
                    id: "xs6-s6",
                    text: "unless accompanied by",
                    role: .prepositionTrigger,
                    examLogicTipTr: "Kısaltılmış Koşul + Edat: 'unless (it is) accompanied BY' (... ile desteklenmedikçe / eşlik edilmedikçe)."
                ),
                SentenceSegment(
                    id: "xs6-s7",
                    text: "inclusive affordable housing policies.",
                    role: .standard
                )
            ]
        )
    ]

    // MARK: - GENEL AKADEMİK (2 Adet)
    public static let generalItems: [SentenceXRayItem] = [
        SentenceXRayItem(
            id: "xray-general-1",
            track: .generalAcademic,
            difficultyLevel: 5,
            fullTranslationTr: "Yapay zeka modelleri devasa veri kümelerindeki karmaşık örüntüleri insan hızının çok ötesinde analiz edebilse de, ürettikleri sonuçların etik sorumluluğu ve bağlamsal yorumu hâlâ insan denetimine bağlıdır.",
            skeletonSummaryTr: "Yapay zeka veriyi hızla analiz edebilse de, etik yorum insan denetimine bağlıdır.",
            clausePolarityLeft: .positive,
            clausePolarityRight: .neutral,
            segments: [
                SentenceSegment(
                    id: "xg1-s1",
                    text: "Albeit",
                    role: .conjunction,
                    examLogicTipTr: "'Albeit' / 'Although' (-e rağmen / -se de): Zıtlık eklemidir; yapay zekanın hızı (+) ile insan denetimine muhtaçlığı (-) arasında denge kurar.",
                    conjunctionDirection: .contrast,
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xg1-s2",
                    text: "capable of analyzing intricate patterns within massive datasets far beyond human speed,",
                    role: .nonEssentialClause,
                    examLogicTipTr: "'capable OF + V-ing' (-ebilme yeteneğine sahip)."
                ),
                SentenceSegment(
                    id: "xg1-s3",
                    text: "the ethical accountability and contextual interpretation of generative AI outputs",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: 'of'tan önceki 'accountability and interpretation' (sorumluluk ve yorum)."
                ),
                SentenceSegment(
                    id: "xg1-s4",
                    text: "remain contingent upon",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM & EDAT: 'contingent UPON / ON' = 'dependent ON' (-e bağlı olmak).",
                    segmentPolarity: .neutral
                ),
                SentenceSegment(
                    id: "xg1-s5",
                    text: "rigorous human oversight.",
                    role: .standard
                )
            ]
        ),
        SentenceXRayItem(
            id: "xray-general-2",
            track: .generalAcademic,
            difficultyLevel: 4,
            fullTranslationTr: "Bilimsel bir hipotezin evrensel kabul görmesi, yalnızca ilk deneyin başarısına değil, aynı zamanda bağımsız laboratuvarların aynı sonuçları farklı koşullar altında tekrar üretip üretemeyeceğine bağlıdır.",
            skeletonSummaryTr: "Hipotezin kabulü hem ilk deneye hem de bağımsız tekrarlanabilirliğe bağlıdır.",
            clausePolarityLeft: .positive,
            clausePolarityRight: .positive,
            segments: [
                SentenceSegment(
                    id: "xg2-s1",
                    text: "The universal acceptance of a scientific hypothesis",
                    role: .mainSubject,
                    examLogicTipTr: "ANA ÖZNE: 'Bilimsel bir hipotezin evrensel kabulü'."
                ),
                SentenceSegment(
                    id: "xg2-s2",
                    text: "hinges on",
                    role: .mainVerb,
                    examLogicTipTr: "ANA YÜKLEM & EDAT: 'hinge ON / UPON' = 'depend ON' = 'rely ON' (-e dayanmak / bağlı olmak).",
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xg2-s3",
                    text: "not only the validity of the initial experiment",
                    role: .conjunction,
                    conjunctionDirection: .parallel,
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xg2-s4",
                    text: "but also whether",
                    role: .conjunction,
                    examLogicTipTr: "'whether ... or not' (-ip -mediği): Edatlardan ('hinges on') sonra 'if' GELMEZ, sadece 'whether' gelir!",
                    conjunctionDirection: .parallel,
                    segmentPolarity: .positive
                ),
                SentenceSegment(
                    id: "xg2-s5",
                    text: "independent laboratories can replicate identical findings under diverse conditions.",
                    role: .standard
                )
            ]
        )
    ]
}
