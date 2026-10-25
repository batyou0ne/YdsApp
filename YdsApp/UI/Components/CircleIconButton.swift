import SwiftUI

/// 44x44, tam yuvarlak, beyaz zeminli, yumuşak gölgeli ikon butonu (Glow Nature Referansı)
public struct CircleIconButton: View {
    public let iconSystemName: String
    public let iconSize: CGFloat
    public let tintColor: Color
    public let showBadge: Bool
    public let action: () -> Void

    public init(
        iconSystemName: String,
        iconSize: CGFloat = 20,
        tintColor: Color = AppTheme.Colors.neutral900,
        showBadge: Bool = false,
        action: @escaping () -> Void
    ) {
        self.iconSystemName = iconSystemName
        self.iconSize = iconSize
        self.tintColor = tintColor
        self.showBadge = showBadge
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(AppTheme.Colors.surface)
                    .frame(width: 44, height: 44)
                    .glowShadow(AppTheme.Shadows.soft)

                Image(systemName: iconSystemName)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(tintColor)
                    .frame(width: 44, height: 44)

                if showBadge {
                    Circle()
                        .fill(AppTheme.Colors.primary500)
                        .frame(width: 9, height: 9)
                        .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                        .offset(x: -6, y: 6)
                }
            }
        }
        .bouncyPressEffect()
    }
}
