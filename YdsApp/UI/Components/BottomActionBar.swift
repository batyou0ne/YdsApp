import SwiftUI

/// Ekranın altında yüzen, beyaz, radius 32, shadow.float; solda küçük etiket + büyük değer, sağda PrimaryButton
public struct BottomActionBar: View {
    public let label: String
    public let value: String
    public let buttonTitle: String
    public let buttonIcon: String?
    public let onButtonTapped: () -> Void

    public init(
        label: String = "Tahmini süre",
        value: String = "25 dk",
        buttonTitle: String = "Derse Başla",
        buttonIcon: String? = "play.fill",
        onButtonTapped: @escaping () -> Void
    ) {
        self.label = label
        self.value = value
        self.buttonTitle = buttonTitle
        self.buttonIcon = buttonIcon
        self.onButtonTapped = onButtonTapped
    }

    public var body: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.base) {
            // Sol: Etiket + Değer
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.neutral500)

                Text(value)
                    .font(AppTheme.Typography.display)
                    .foregroundStyle(AppTheme.Colors.neutral900)
                    .fontWeight(.bold)
            }

            Spacer()

            // Sağ: Primary Action Butonu
            PrimaryButton(
                title: buttonTitle,
                iconSystemName: buttonIcon,
                height: 54,
                isFullWidth: false,
                action: onButtonTapped
            )
        }
        .padding(.horizontal, AppTheme.Spacing.screenPadding)
        .padding(.top, 16)
        .padding(.bottom, 22)
        .background(AppTheme.Colors.surface)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: AppTheme.Radius.sheet,
                bottomLeadingRadius: AppTheme.Radius.sheet,
                bottomTrailingRadius: AppTheme.Radius.sheet,
                topTrailingRadius: AppTheme.Radius.sheet
            )
        )
        .glowShadow(AppTheme.Shadows.float)
        .padding(.horizontal, AppTheme.Spacing.base)
        .padding(.bottom, 10)
    }
}
