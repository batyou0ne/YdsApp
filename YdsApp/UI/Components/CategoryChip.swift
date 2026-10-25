import SwiftUI

/// Yükseklik ~52, radius 14, background.muted, solda kategori adı, sağda küçük görsel rozeti
public struct CategoryChip: View {
    public let title: String
    public let iconSystemName: String
    public let isSelected: Bool
    public let action: () -> Void

    public init(
        title: String,
        iconSystemName: String,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.iconSystemName = iconSystemName
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.md) {
                Text(title)
                    .font(AppTheme.Typography.label)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? AppTheme.Colors.primary700 : AppTheme.Colors.neutral900)

                // Sağdaki küçük illüstrasyon / thumbnail kapsülü
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? AppTheme.Colors.primary100 : Color.white)
                        .frame(width: 32, height: 32)
                        .glowShadow(AppTheme.ShadowConfig(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1))

                    Image(systemName: iconSystemName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isSelected ? AppTheme.Colors.primary500 : AppTheme.Colors.neutral700)
                }
            }
            .padding(.leading, AppTheme.Spacing.base)
            .padding(.trailing, AppTheme.Spacing.sm)
            .frame(height: 52)
            .background(isSelected ? AppTheme.Colors.primary100 : AppTheme.Colors.muted)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.chip))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.chip)
                    .stroke(isSelected ? AppTheme.Colors.primary500 : Color.clear, lineWidth: 1.5)
            )
        }
        .bouncyPressEffect()
    }
}
