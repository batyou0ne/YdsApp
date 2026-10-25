import SwiftUI

/// Yükseklik ~195, radius 28, gradient yeşil zeminli, sol mini rozet + 2 satır başlık + siyah CTA pill butonlu hero banner
public struct PromoBanner: View {
    public let slides: [GlowMockData.BannerSlide]
    @Binding public var currentIndex: Int
    public let onCtaTapped: (GlowMockData.BannerSlide) -> Void

    public init(
        slides: [GlowMockData.BannerSlide] = GlowMockData.bannerSlides,
        currentIndex: Binding<Int>,
        onCtaTapped: @escaping (GlowMockData.BannerSlide) -> Void
    ) {
        self.slides = slides
        self._currentIndex = currentIndex
        self.onCtaTapped = onCtaTapped
    }

    public var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            TabView(selection: $currentIndex) {
                ForEach(Array(slides.enumerated()), id: \.element.id) { index, slide in
                    bannerCard(slide: slide)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 195)

            // Sayfa Göstergesi (Alt Gösterge)
            HStack(spacing: 6) {
                ForEach(0..<slides.count, id: \.self) { index in
                    if index == currentIndex {
                        Capsule()
                            .fill(AppTheme.Colors.primary500)
                            .frame(width: 24, height: 6)
                            .animation(AppTheme.pillTransitionAnimation, value: currentIndex)
                    } else {
                        Circle()
                            .fill(AppTheme.Colors.neutral300)
                            .frame(width: 6, height: 6)
                            .animation(AppTheme.pillTransitionAnimation, value: currentIndex)
                    }
                }
            }
            .padding(.top, 2)
        }
    }

    private func bannerCard(slide: GlowMockData.BannerSlide) -> some View {
        ZStack(alignment: .bottomTrailing) {
            // Gradient Yeşil Zemin
            RoundedRectangle(cornerRadius: AppTheme.Radius.banner)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.Colors.primary400, AppTheme.Colors.primary300],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Organik Arka Plan Blobları (%15-25 opaklık)
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.20))
                    .frame(width: 170, height: 170)
                    .offset(x: 100, y: -40)

                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 130, height: 130)
                    .offset(x: 40, y: 50)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.banner))

            // Sağ: Eğitim & Doğa İllüstrasyonu
            HStack {
                Spacer()
                AcademicBotanicalIllustrationView(style: .bannerFlask, height: 165)
                    .offset(x: -6, y: 8)
            }

            // Sol: Metin Alanı + CTA Butonu
            VStack(alignment: .leading, spacing: 10) {
                // Siyah Mini Rozet
                HStack(spacing: 4) {
                    Text(slide.badgeText)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.textOnDark)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppTheme.Colors.neutral900)
                .clipShape(Capsule())

                // 2 Satır Başlık
                Text(slide.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.neutral900)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                // Siyah Pill CTA Butonu ("Hemen Başla ↗")
                Button {
                    onCtaTapped(slide)
                } label: {
                    HStack(spacing: 8) {
                        Text(slide.ctaText)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.textOnDark)

                        // Beyaz yuvarlak içinde ok ikonu
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 24, height: 24)

                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.neutral900)
                        }
                    }
                    .padding(.leading, 14)
                    .padding(.trailing, 6)
                    .padding(.vertical, 6)
                    .background(AppTheme.Colors.neutral900)
                    .clipShape(Capsule())
                }
                .bouncyPressEffect()
            }
            .padding(AppTheme.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 195)
        .glowShadow(AppTheme.Shadows.card)
    }
}
