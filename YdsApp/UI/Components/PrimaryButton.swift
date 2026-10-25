import SwiftUI

/// Yükseklik 56–60, tam pill, primary.500, solda ikon + metin (SemiBold 16), beyaz metinli birincil buton
public struct PrimaryButton: View {
    public let title: String
    public let iconSystemName: String?
    public let height: CGFloat
    public let isFullWidth: Bool
    public let action: () -> Void

    public init(
        title: String,
        iconSystemName: String? = nil,
        height: CGFloat = 56,
        isFullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.iconSystemName = iconSystemName
        self.height = height
        self.isFullWidth = isFullWidth
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconSystemName {
                    Image(systemName: iconSystemName)
                        .font(.system(size: 18, weight: .bold))
                }

                Text(title)
                    .font(AppTheme.Typography.bodyLarge)
                    .fontWeight(.bold)
            }
            .foregroundStyle(AppTheme.Colors.textOnPrimary)
            .padding(.horizontal, 24)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: height)
            .background(AppTheme.Colors.primary500)
            .clipShape(Capsule())
            .glowShadow(AppTheme.ShadowConfig(color: AppTheme.Colors.primary500.opacity(0.35), radius: 10, x: 0, y: 5))
        }
        .bouncyPressEffect()
    }
}
