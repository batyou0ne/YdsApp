import SwiftUI

/// 3 Boyutlu Kelime, Zorunlu Edat ve YDS İkizleri Kart Görünümü
/// KURAL: `card.isFullyLearned` yalnızca Domain modeli üzerinden okunur; 3 boyut (Anlam, Zorunlu Edat, YDS İkizi) ayrı ayrı rozetlerle gösterilir.
public struct Vocab3DCardView: View {
    public let card: Vocab3DCard
    public let onSelectDimensionQuiz: (VocabQuizDimension) -> Void

    public init(
        card: Vocab3DCard,
        onSelectDimensionQuiz: @escaping (VocabQuizDimension) -> Void
    ) {
        self.card = card
        self.onSelectDimensionQuiz = onSelectDimensionQuiz
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            masteryDimensionRingsHeader

            headwordAndMandatoryPrepositionBanner

            dimensionOneMeaningCard

            dimensionTwoPrepositionCard

            dimensionThreeTwinsCard

            academicSentenceExampleCard

            examTipCard
        }
        .padding(18)
        .background(AppTheme.surfaceCard)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    card.isFullyLearned ? AppTheme.emeraldSuccess.opacity(0.75) : AppTheme.borderSubtle,
                    lineWidth: card.isFullyLearned ? 2.0 : 1.0
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    // MARK: - 1. 3D Mastery Rings / Badges Header

    private var masteryDimensionRingsHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(card.track.titleTr.uppercased())
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(AppTheme.cyanMainSubject)

                Spacer()

                if card.isFullyLearned {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.seal.fill")
                        Text("TAM ÖĞRENİLDİ (3/3 BOYUT)")
                    }
                    .font(.system(size: 10, weight: .heavy))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.emeraldSuccess.opacity(0.22))
                    .foregroundStyle(AppTheme.emeraldSuccess)
                    .clipShape(Capsule())
                } else {
                    Text("\(card.masteryProgress.masteredDimensionCount)/3 Boyut Doğrulandı")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppTheme.amberMainVerb.opacity(0.18))
                        .foregroundStyle(AppTheme.amberMainVerb)
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 8) {
                dimensionStatusBadge(
                    title: "1. Anlam",
                    isMastered: card.masteryProgress.isMeaningMastered,
                    accentColor: AppTheme.cyanMainSubject,
                    dimension: .meaning
                )

                dimensionStatusBadge(
                    title: "2. Edat (\(card.mandatoryPreposition.uppercased()))",
                    isMastered: card.masteryProgress.isPrepositionMastered,
                    accentColor: AppTheme.purplePreposition,
                    dimension: .preposition
                )

                dimensionStatusBadge(
                    title: "3. YDS İkizi",
                    isMastered: card.masteryProgress.isSynonymMastered,
                    accentColor: AppTheme.amberMainVerb,
                    dimension: .synonym
                )
            }
        }
    }

    private func dimensionStatusBadge(
        title: String,
        isMastered: Bool,
        accentColor: Color,
        dimension: VocabQuizDimension
    ) -> some View {
        Button {
            onSelectDimensionQuiz(dimension)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: isMastered ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isMastered ? AppTheme.emeraldSuccess : accentColor)

                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(isMastered ? AppTheme.emeraldSuccess : AppTheme.textPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .padding(.horizontal, 6)
            .background(
                (isMastered ? AppTheme.emeraldSuccess : accentColor)
                    .opacity(0.14)
            )
            .overlay(
                Capsule()
                    .stroke(
                        (isMastered ? AppTheme.emeraldSuccess : accentColor).opacity(0.45),
                        lineWidth: 1
                    )
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - 2. Headword + Mandatory Preposition Highlight

    private var headwordAndMandatoryPrepositionBanner: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(card.headword)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text(card.mandatoryPreposition.uppercased())
                .font(.system(size: 18, weight: .black, design: .rounded))
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(AppTheme.purplePreposition.opacity(0.26))
                .foregroundStyle(AppTheme.purplePreposition)
                .overlay(
                    Capsule()
                        .stroke(AppTheme.purplePreposition, lineWidth: 1.5)
                )
                .clipShape(Capsule())

            Spacer()

            Text(card.partOfSpeech.uppercased())
                .font(.caption2.weight(.heavy))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.surfaceElevated)
                .foregroundStyle(AppTheme.textSecondary)
                .clipShape(Capsule())
        }
        .padding(14)
        .background(AppTheme.backgroundDark.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 3. Dimension 1: Academic Meaning

    private var dimensionOneMeaningCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("1. BOYUT • AKADEMİK TÜRKÇE ANLAM")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(AppTheme.cyanMainSubject)
                Spacer()
                if card.masteryProgress.isMeaningMastered {
                    Text("Doğrulandı ✓")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppTheme.emeraldSuccess)
                }
            }

            Text(card.academicMeaningTr)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cyanMainSubject.opacity(0.10))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.cyanMainSubject.opacity(0.35), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - 4. Dimension 2: Mandatory Preposition Trigger

    private var dimensionTwoPrepositionCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("2. BOYUT • ZORUNLU EDAT KALIBI")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(AppTheme.purplePreposition)
                Text("Sınavda boşluktan hemen sonra '\(card.mandatoryPreposition.uppercased())' edatı aranır.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Text("\(card.headword) + \(card.mandatoryPreposition.uppercased())")
                .font(.caption.weight(.heavy))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.purplePreposition.opacity(0.22))
                .foregroundStyle(AppTheme.purplePreposition)
                .clipShape(Capsule())
        }
        .padding(14)
        .background(AppTheme.purplePreposition.opacity(0.10))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.purplePreposition.opacity(0.35), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - 5. Dimension 3: YDS Twins (Synonyms)

    private var dimensionThreeTwinsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("3. BOYUT • YDS İKİZLERİ (EŞ ANLAM & PARAGRAF EŞLEŞTİRME)")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(AppTheme.amberMainVerb)
                Spacer()
                if card.masteryProgress.isSynonymMastered {
                    Text("Doğrulandı ✓")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppTheme.emeraldSuccess)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(card.ydsTwins, id: \.self) { twin in
                        HStack(spacing: 4) {
                            Image(systemName: "equal.circle.fill")
                                .font(.caption2)
                            Text(twin)
                                .font(.caption.weight(.heavy))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.amberMainVerb.opacity(0.18))
                        .foregroundStyle(AppTheme.amberMainVerb)
                        .overlay(
                            Capsule()
                                .stroke(AppTheme.amberMainVerb.opacity(0.45), lineWidth: 1)
                        )
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(14)
        .background(AppTheme.amberMainVerb.opacity(0.10))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.amberMainVerb.opacity(0.35), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - 6. Academic Sentence Example

    private var academicSentenceExampleCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("GERÇEK SINAV CÜMLESİ ÖRNEĞİ")
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(AppTheme.textSecondary)

            Text(card.examExampleSentenceEn)
                .font(.system(.subheadline, design: .serif).weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(card.examExampleSentenceTr)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.backgroundDark.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - 7. Exam Shortcut Tip

    private var examTipCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "bolt.Badge.clock.fill")
                .font(.subheadline)
                .foregroundStyle(AppTheme.emeraldSuccess)

            VStack(alignment: .leading, spacing: 3) {
                Text("SINAV TUZAĞI & KISAYOL KOÇU")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(AppTheme.emeraldSuccess)
                Text(card.examTipTr)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.emeraldSuccess.opacity(0.12))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.emeraldSuccess.opacity(0.35), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
