import SwiftUI

// MARK: - Color Hex Initializer
public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Glow Nature Design System Tokens
public enum AppTheme {

    // MARK: 2.1 Renkler (Design Tokens)
    public enum Colors {
        // Backgrounds
        public static let appBackground = Color(hex: "FAFAF8")        // #FAFAF8: Kırık beyaz / açık krem zemin
        public static let surface = Color(hex: "FFFFFF")              // #FFFFFF: Kartlar, arama, ikon butonları
        public static let muted = Color(hex: "F2F2F0")                // #F2F2F0: Kategori chip zemini, pasif alanlar
        public static let presentation = Color(hex: "E0DFDD")         // #E0DFDD: Mockup sunum zemini

        // Primary (Lime / Zeytin Yeşili)
        public static let primary500 = Color(hex: "8FB83A")           // #8FB83A: Ana lime yeşil (Add to Cart, seçili chip)
        public static let primary400 = Color(hex: "A7CC4A")           // #A7CC4A: Banner gradient açık ucu
        public static let primary300 = Color(hex: "C3DB74")           // #C3DB74: Banner gradient açık ucu
        public static let primary100 = Color(hex: "E6EEC8")           // #E6EEC8: Aktif nav pill zemini, hafif vurgu
        public static let primary700 = Color(hex: "5E7D1F")           // #5E7D1F: İkon / metin koyu yeşil

        // Neutrals
        public static let neutral900 = Color(hex: "121212")           // #121212: Siyah butonlar, başlıklar
        public static let neutral700 = Color(hex: "3A3A3A")           // #3A3A3A: Gövde koyusu
        public static let neutral500 = Color(hex: "8E8E8E")           // #8E8E8E: İkincil metin, placeholder, etiketler
        public static let neutral300 = Color(hex: "D9D9D7")           // #D9D9D7: İnce çizgi, pasif nokta, stepper çerçevesi
        public static let neutral100 = Color(hex: "F5F5F3")           // #F5F5F3: İnce kart zemini / progress izi

        // Text
        public static let textOnPrimary = Color(hex: "FFFFFF")        // Yeşil buton üstü metin
        public static let textOnDark = Color(hex: "FFFFFF")           // Siyah buton üstü metin

        // Semantics
        public static let success = Color(hex: "6FA82B")              // #6FA82B: Doğru cevap
        public static let error = Color(hex: "E5604F")                // #E5604F: Yanlış cevap (yumuşak mercan)
        public static let warning = Color(hex: "F2B544")              // #F2B544: Streak / uyarı (kehribar)
    }

    // MARK: 2.2 Tipografi Ölçeği
    public enum Typography {
        /// 28 / 34 SemiBold - Ekran büyük başlıkları
        public static let display = Font.system(size: 28, weight: .semibold, design: .rounded)

        /// 20 / 26 SemiBold - "Detay" sayfa başlığı, öne çıkan başlıklar
        public static let titleLarge = Font.system(size: 20, weight: .semibold, design: .rounded)

        /// 18 / 24 SemiBold - Bölüm başlıkları ("Kategoriler", "Sana Özel Dersler")
        public static let titleMedium = Font.system(size: 18, weight: .semibold, design: .rounded)

        /// 16 / 24 Medium - Ders/kart adı, buton metni
        public static let bodyLarge = Font.system(size: 16, weight: .medium, design: .rounded)

        /// 14 / 20 Regular - Açıklama metinleri
        public static let bodyMedium = Font.system(size: 14, weight: .regular, design: .rounded)

        /// 13 / 16 Medium - Chip, küçük etiketler, "Tümünü gör"
        public static let label = Font.system(size: 13, weight: .medium, design: .rounded)

        /// 12 / 16 Regular - Alt bilgi, gri etiket ("Zorluk Seç", "Açıklama")
        public static let caption = Font.system(size: 12, weight: .regular, design: .rounded)

        /// 20 / 24 SemiBold - Sayısal vurgular (puan, süre, sayaç)
        public static let numeric = Font.system(size: 20, weight: .semibold, design: .rounded)
    }

    // MARK: 2.3 Boşluk, Radius, Gölgeler
    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let base: CGFloat = 16
        public static let lg: CGFloat = 20
        public static let screenPadding: CGFloat = 24
        public static let xl: CGFloat = 32
    }

    public enum Radius {
        public static let pill: CGFloat = 999
        public static let card: CGFloat = 24
        public static let banner: CGFloat = 28
        public static let chip: CGFloat = 14
        public static let input: CGFloat = 999
        public static let sheet: CGFloat = 32
        public static let stepper: CGFloat = 12
    }

    public enum Shadows {
        /// shadow.soft: 0 4 16 rgba(0,0,0,0.06) - İkon butonları, arama çubuğu
        public static let soft = ShadowConfig(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)

        /// shadow.float: 0 8 30 rgba(0,0,0,0.10) - Alt yüzer navigasyon, alt aksiyon çubuğu
        public static let float = ShadowConfig(color: Color.black.opacity(0.10), radius: 15, x: 0, y: 8)

        /// shadow.card: 0 2 12 rgba(0,0,0,0.05) - Ürün/ders kartları
        public static let card = ShadowConfig(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    public struct ShadowConfig {
        public let color: Color
        public let radius: CGFloat
        public let x: CGFloat
        public let y: CGFloat
    }

    // MARK: Gradients & Shapes
    public static let bannerGradient = LinearGradient(
        colors: [Colors.primary400, Colors.primary300],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let primaryActionGradient = LinearGradient(
        colors: [Colors.primary500, Colors.primary400],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let softCardGradient = LinearGradient(
        colors: [Color.white, Color(hex: "F8F9F3")],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: Animasyon Tokenları (180-280ms, easeOutCubic)
    public static let standardAnimation = Animation.timingCurve(0.215, 0.61, 0.355, 1.0, duration: 0.24)
    public static let quickAnimation = Animation.timingCurve(0.215, 0.61, 0.355, 1.0, duration: 0.18)
    public static let pillTransitionAnimation = Animation.timingCurve(0.215, 0.61, 0.355, 1.0, duration: 0.25)

    // MARK: - Geriye Dönük Uyumluluk (Legacy Screen & Seed Aliases)
    public static let backgroundDark = Colors.appBackground
    public static let surfaceCard = Colors.surface
    public static let surfaceElevated = Colors.muted
    public static let borderSubtle = Colors.neutral300.opacity(0.6)

    public static let emeraldSuccess = Colors.success
    public static let amberMainVerb = Colors.warning
    public static let coralConjunction = Colors.error
    public static let cyanMainSubject = Colors.primary700
    public static let purplePreposition = Color(hex: "8A5CF5")
    public static let proGold = Colors.primary500

    public static let textPrimary = Colors.neutral900
    public static let textSecondary = Colors.neutral500
    public static let textMuted = Colors.neutral500

    public static let proCrownGradient = bannerGradient

    public static func roleColor(for role: SegmentRole) -> Color {
        switch role {
        case .mainSubject:
            return Colors.primary700
        case .mainVerb:
            return Colors.warning
        case .conjunction:
            return Colors.error
        case .prepositionTrigger:
            return purplePreposition
        case .nonEssentialClause:
            return textSecondary
        case .standard:
            return textPrimary
        }
    }

    public static func clueColor(for clueType: ClueHighlightType) -> Color {
        switch clueType {
        case .mainVerb:
            return Colors.warning
        case .conjunction:
            return Colors.error
        case .pronounReference:
            return Colors.primary700
        case .topicShift:
            return Colors.error
        case .prepositionTrigger:
            return purplePreposition
        }
    }
}

// MARK: - View Shadow & Press Extension
public extension View {
    func glowShadow(_ config: AppTheme.ShadowConfig) -> some View {
        self.shadow(color: config.color, radius: config.radius, x: config.x, y: config.y)
    }

    func bouncyPressEffect() -> some View {
        self.buttonStyle(BouncyPressButtonStyle())
    }
}

public struct BouncyPressButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(AppTheme.quickAnimation, value: configuration.isPressed)
    }
}
