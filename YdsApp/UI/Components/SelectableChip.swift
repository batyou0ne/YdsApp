import SwiftUI

/// Yükseklik 40, radius 12; seçili: primary.500 zemin + beyaz metin; pasif: background.muted + neutral.900 metin
public struct SelectableChip: View {
    public let title: String
    public let isSelected: Bool
    public let action: () -> Void

    public init(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.label)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundStyle(isSelected ? AppTheme.Colors.textOnPrimary : AppTheme.Colors.neutral900)
                .padding(.horizontal, 16)
                .frame(height: 40)
                .background(isSelected ? AppTheme.Colors.primary500 : AppTheme.Colors.muted)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .bouncyPressEffect()
    }
}
