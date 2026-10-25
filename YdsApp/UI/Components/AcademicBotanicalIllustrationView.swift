import SwiftUI

/// Referans görseldeki taş, yaprak ve cam şişe organik estetiğini eğitim nesneleriyle (akademik tüp, kitap, yapraklar) harmanlayan illüstrasyon
public struct AcademicBotanicalIllustrationView: View {
    public let style: IllustrationStyle
    public let height: CGFloat

    public enum IllustrationStyle {
        case bannerFlask
        case cardGrammar
        case cardVocabulary
        case cardReading
        case cardTranslation
        case detailHero
    }

    public init(style: IllustrationStyle = .bannerFlask, height: CGFloat = 160) {
        self.style = style
        self.height = height
    }

    public var body: some View {
        ZStack {
            // Arka plan organik ışık / hare
            Circle()
                .fill(Color.white.opacity(0.35))
                .frame(width: height * 0.9, height: height * 0.9)
                .offset(y: -10)

            // 1. Taş Kaide (Pebble Pedestal)
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "E8E7DF"), Color(hex: "D5D4CB")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: height * 0.85, height: height * 0.22)
                    .glowShadow(AppTheme.ShadowConfig(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 4))
            }

            // 2. Küçük Çakıl Taşı (Decorative Stone)
            VStack {
                Spacer()
                HStack {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "BEBDAC"), Color(hex: "A3A294")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: height * 0.28, height: height * 0.14)
                        .rotationEffect(.degrees(-8))
                        .offset(x: -height * 0.25, y: -height * 0.04)
                    Spacer()
                }
            }

            // 3. Organik Zeytin Dalı / Yapraklar (Botanical Leaves)
            ZStack {
                // Sol yaprak
                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: height * 0.28, height: height * 0.28)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.Colors.primary700, AppTheme.Colors.primary500],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(-42))
                    .offset(x: -height * 0.32, y: -height * 0.15)

                // Sağ dal / yaprak
                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: height * 0.35, height: height * 0.35)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.Colors.primary500, AppTheme.Colors.primary400],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .rotationEffect(.degrees(36))
                    .offset(x: height * 0.30, y: -height * 0.20)
            }

            // 4. Ana Nesne (Cam Şişe / Akademik Flask / Kitap)
            centralSubjectView
        }
        .frame(height: height)
    }

    @ViewBuilder
    private var centralSubjectView: some View {
        switch style {
        case .bannerFlask, .detailHero:
            // Cam Serum / Çözelti Şişesi (Glow Nature Referans Şişesi)
            ZStack {
                // Şişe Gövdesi
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "E4EFE0"),
                                Color(hex: "A9C788"),
                                Color(hex: "7AA449")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: height * 0.38, height: height * 0.58)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                    )
                    .glowShadow(AppTheme.ShadowConfig(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 6))

                // Şişe Etiketi
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.95))
                    .frame(width: height * 0.26, height: height * 0.32)
                    .overlay(
                        VStack(spacing: 3) {
                            Text("YDS")
                                .font(.system(size: height * 0.07, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.neutral900)
                            Text("ACADEMIC")
                                .font(.system(size: height * 0.035, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.Colors.primary700)
                            Rectangle()
                                .fill(AppTheme.Colors.primary500)
                                .frame(width: height * 0.12, height: 1.5)
                            Text("Formula 80/80")
                                .font(.system(size: height * 0.03, weight: .regular))
                                .foregroundStyle(AppTheme.Colors.neutral500)
                        }
                    )
                    .offset(y: height * 0.03)

                // Damlalık / Kapak
                VStack(spacing: 1) {
                    Capsule()
                        .fill(Color.white)
                        .frame(width: height * 0.12, height: height * 0.14)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "E6E5DC"))
                        .frame(width: height * 0.16, height: height * 0.06)
                }
                .offset(y: -height * 0.31)
            }
            .offset(y: -height * 0.08)

        case .cardGrammar:
            // Gramer Kitabı + Yaprak
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.Colors.primary500, AppTheme.Colors.primary700],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: height * 0.44, height: height * 0.52)
                    .glowShadow(AppTheme.ShadowConfig(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 4))

                Image(systemName: "text.book.closed.fill")
                    .font(.system(size: height * 0.24))
                    .foregroundStyle(Color.white.opacity(0.95))
            }
            .offset(y: -height * 0.06)

        case .cardVocabulary:
            // 3D Küp / Kelime Kristali
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "C3DB74"), Color(hex: "8FB83A")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: height * 0.42, height: height * 0.42)
                    .rotationEffect(.degrees(12))
                    .glowShadow(AppTheme.ShadowConfig(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 4))

                Image(systemName: "character.book.closed.fill")
                    .font(.system(size: height * 0.22))
                    .foregroundStyle(AppTheme.Colors.neutral900)
            }
            .offset(y: -height * 0.06)

        case .cardReading:
            // Büyüteç + Parşömen
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: height * 0.44, height: height * 0.44)
                    .glowShadow(AppTheme.ShadowConfig(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3))

                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: height * 0.24, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.primary700)
            }
            .offset(y: -height * 0.06)

        case .cardTranslation:
            // Çift Yönlü İki Dil Kristali
            ZStack {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color(hex: "F2F2F0")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: height * 0.50, height: height * 0.35)
                    .glowShadow(AppTheme.ShadowConfig(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3))

                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .font(.system(size: height * 0.22))
                    .foregroundStyle(AppTheme.Colors.primary500)
            }
            .offset(y: -height * 0.06)
        }
    }
}
