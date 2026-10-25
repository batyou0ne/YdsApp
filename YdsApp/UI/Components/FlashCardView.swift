import SwiftUI

/// Kelime Defteri 3D Çevirmeli FlashCard (Radius 28, yumuşak gölge, dokununca Türkçe anlam ve örnek cümle)
public struct FlashCardView: View {
    public let wordItem: GlowMockData.MockVocabWord
    @Binding public var isFlipped: Bool

    public init(
        wordItem: GlowMockData.MockVocabWord,
        isFlipped: Binding<Bool>
    ) {
        self.wordItem = wordItem
        self._isFlipped = isFlipped
    }

    public var body: some View {
        ZStack {
            if !isFlipped {
                frontCard
            } else {
                backCard
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
        .frame(height: 320)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.7
        )
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: isFlipped)
        .onTapGesture {
            isFlipped.toggle()
        }
    }

    // Ön Yüz (İngilizce Kelime + Fonetik + Tür)
    private var frontCard: some View {
        VStack(spacing: AppTheme.Spacing.base) {
            HStack {
                Text(wordItem.categoryTrackTr)
                    .font(AppTheme.Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.primary700)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.primary100)
                    .clipShape(Capsule())

                Spacer()

                Text(wordItem.cefrLevel)
                    .font(AppTheme.Typography.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.Colors.neutral500)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.Colors.muted)
                    .clipShape(Capsule())
            }

            Spacer()

            Text(wordItem.word)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.Colors.neutral900)
                .multilineTextAlignment(.center)

            Text(wordItem.phonetic)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundStyle(AppTheme.Colors.neutral500)

            Text(wordItem.partOfSpeechTr)
                .font(AppTheme.Typography.label)
                .foregroundStyle(AppTheme.Colors.primary700)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(AppTheme.Colors.muted)
                .clipShape(Capsule())

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 12))
                Text("Anlamı ve örneği görmek için dokun")
                    .font(AppTheme.Typography.caption)
            }
            .foregroundStyle(AppTheme.Colors.neutral500)
        }
        .padding(AppTheme.Spacing.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.banner))
        .glowShadow(AppTheme.Shadows.card)
    }

    // Arka Yüz (Türkçe Karşılık + Zorunlu Edat + YDS İkizleri + Örnek Cümle)
    private var backCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text(wordItem.word)
                    .font(AppTheme.Typography.titleMedium)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.Colors.primary700)

                Spacer()

                if let prep = wordItem.mandatoryPreposition {
                    Text("+\(prep)")
                        .font(AppTheme.Typography.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.Colors.textOnDark)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppTheme.Colors.neutral900)
                        .clipShape(Capsule())
                }
            }

            Text(wordItem.meaningTr)
                .font(AppTheme.Typography.titleLarge)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.Colors.neutral900)

            // Eş Anlamlılar (YDS İkizleri)
            VStack(alignment: .leading, spacing: 4) {
                Text("YDS / YÖKDİL Eş Anlamlıları:")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.neutral500)

                HStack(spacing: 6) {
                    ForEach(wordItem.synonymsTr, id: \.self) { syn in
                        Text(syn)
                            .font(AppTheme.Typography.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.Colors.neutral700)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AppTheme.Colors.muted)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }

            Divider()
                .padding(.vertical, 2)

            // Örnek Cümle
            VStack(alignment: .leading, spacing: 4) {
                Text(wordItem.exampleEn)
                    .font(AppTheme.Typography.bodyMedium)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.Colors.neutral900)
                    .lineSpacing(3)

                Text(wordItem.exampleTr)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.neutral500)
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.banner))
        .glowShadow(AppTheme.Shadows.card)
    }
}
