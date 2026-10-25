import SwiftUI

/// İki sütunlu grid ders kartı: Üstte organik görsel kaide, sağ üstte 32px kalp butonu, altta ders başlığı, seviye ve süre/soru bilgisi
public struct ContentCard: View {
    public let lesson: LessonItem
    public let isBookmarked: Bool
    public let onBookmarkTapped: () -> Void
    public let onCardTapped: () -> Void

    public init(
        lesson: LessonItem,
        isBookmarked: Bool = false,
        onBookmarkTapped: @escaping () -> Void,
        onCardTapped: @escaping () -> Void
    ) {
        self.lesson = lesson
        self.isBookmarked = isBookmarked
        self.onBookmarkTapped = onBookmarkTapped
        self.onCardTapped = onCardTapped
    }

    public var body: some View {
        Button(action: onCardTapped) {
            VStack(alignment: .leading, spacing: 10) {
                // Üst Görsel Alanı (Kırık beyaz yumuşak zemin + Organik Taş & Yaprak İllüstrasyonu)
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                        .fill(AppTheme.Colors.muted)
                        .frame(height: 150)

                    // Organik İllüstrasyon
                    AcademicBotanicalIllustrationView(style: illustrationStyle(for: lesson.category), height: 135)
                        .padding(.top, 10)

                    // Sağ Üstte 32px Beyaz Yuvarlak Favori (Kalp) Butonu
                    Button(action: onBookmarkTapped) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 32, height: 32)
                                .glowShadow(AppTheme.ShadowConfig(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2))

                            Image(systemName: isBookmarked ? "heart.fill" : "heart")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(isBookmarked ? AppTheme.Colors.error : AppTheme.Colors.neutral700)
                                .scaleEffect(isBookmarked ? 1.15 : 1.0)
                                .animation(.spring(response: 0.25, dampingFraction: 0.5), value: isBookmarked)
                        }
                    }
                    .padding(10)
                }

                // Alt Bilgi Alanı
                VStack(alignment: .leading, spacing: 4) {
                    // Kategori & Seviye
                    HStack(spacing: 6) {
                        Text(lesson.category.titleTr)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.primary700)
                            .fontWeight(.medium)

                        Circle()
                            .fill(AppTheme.Colors.neutral300)
                            .frame(width: 3, height: 3)

                        Text(lesson.level)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.neutral500)
                    }

                    // Ders Başlığı (2 satır)
                    Text(lesson.title)
                        .font(AppTheme.Typography.bodyLarge)
                        .foregroundStyle(AppTheme.Colors.neutral900)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(minHeight: 42, alignment: .topLeading)

                    // Metrik Satırı (Referanstaki Fiyatın karşılığı: Süre ve Soru Sayısı)
                    HStack(alignment: .firstTextBaseline) {
                        HStack(spacing: 2) {
                            Text("\(lesson.durationMinutes)")
                                .font(AppTheme.Typography.numeric)
                                .foregroundStyle(AppTheme.Colors.neutral900)
                            Text("dk")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.neutral500)
                        }

                        Spacer()

                        Text("\(lesson.questionCount) soru")
                            .font(AppTheme.Typography.label)
                            .foregroundStyle(AppTheme.Colors.primary700)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AppTheme.Colors.primary100)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 4)
            }
            .padding(8)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
            .glowShadow(AppTheme.Shadows.card)
        }
        .bouncyPressEffect()
    }

    private func illustrationStyle(for category: LessonCategoryType) -> AcademicBotanicalIllustrationView.IllustrationStyle {
        switch category {
        case .grammar:
            return .cardGrammar
        case .vocabulary:
            return .cardVocabulary
        case .reading:
            return .cardReading
        case .translation:
            return .cardTranslation
        case .clozeTest, .dialogue:
            return .bannerFlask
        }
    }
}
