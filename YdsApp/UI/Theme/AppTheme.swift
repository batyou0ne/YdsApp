import SwiftUI

/// Akademik ciddiyeti yüksek odaklanma hissiyle birleştiren tasarım tokenları
/// - Derin Gece Laciverti: `#0F172A`
/// - Zümrüt Başarı Yeşili: `#10B981`
/// - Kehribar Ana Yüklem Vurgusu: `#F59E0B`
/// - Kırmızı/Mercan Bağlaç Vurgusu: `#EF4444`
/// - Turkuaz Ana Özne Vurgusu: `#06B6D4`
public enum AppTheme {
    // MARK: - Core Palette
    public static let backgroundDark = Color(red: 0.059, green: 0.090, blue: 0.165)      // #0F172A
    public static let surfaceCard = Color(red: 0.118, green: 0.161, blue: 0.231)         // #1E293B
    public static let surfaceElevated = Color(red: 0.165, green: 0.220, blue: 0.310)     // #2A384F
    public static let borderSubtle = Color.white.opacity(0.10)

    // MARK: - Semantic & X-Ray Highlight Tokens
    public static let emeraldSuccess = Color(red: 0.063, green: 0.725, blue: 0.506)      // #10B981
    public static let amberMainVerb = Color(red: 0.961, green: 0.620, blue: 0.043)       // #F59E0B
    public static let coralConjunction = Color(red: 0.937, green: 0.267, blue: 0.267)    // #EF4444
    public static let cyanMainSubject = Color(red: 0.024, green: 0.714, blue: 0.831)     // #06B6D4
    public static let purplePreposition = Color(red: 0.659, green: 0.333, blue: 0.969)   // #A855F7
    public static let proGold = Color(red: 0.984, green: 0.749, blue: 0.141)             // #FBBF24

    // MARK: - Text Colors
    public static let textPrimary = Color(red: 0.973, green: 0.980, blue: 0.988)         // #F8FAFC
    public static let textSecondary = Color(red: 0.580, green: 0.639, blue: 0.722)       // #94A3B8
    public static let textMuted = Color(red: 0.392, green: 0.455, blue: 0.545)           // #64748B

    // MARK: - Gradients
    public static let primaryActionGradient = LinearGradient(
        colors: [
            Color(red: 0.063, green: 0.725, blue: 0.506),
            Color(red: 0.024, green: 0.714, blue: 0.831)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let proCrownGradient = LinearGradient(
        colors: [
            Color(red: 0.961, green: 0.620, blue: 0.043),
            Color(red: 0.937, green: 0.267, blue: 0.267)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    public static func roleColor(for role: SegmentRole) -> Color {
        switch role {
        case .mainSubject:
            return cyanMainSubject
        case .mainVerb:
            return amberMainVerb
        case .conjunction:
            return coralConjunction
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
            return amberMainVerb
        case .conjunction:
            return coralConjunction
        case .pronounReference:
            return cyanMainSubject
        case .topicShift:
            return coralConjunction
        case .prepositionTrigger:
            return purplePreposition
        }
    }
}
