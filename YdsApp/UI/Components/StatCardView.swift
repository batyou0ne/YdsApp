import SwiftUI

/// Sonuç ve İstatistik ekranları için yumuşak kart metrik bileşeni (StatCard)
public struct StatCardView: View {
    public let title: String
    public let value: String
    public let subtitle: String?
    public let iconSystemName: String?
    public let accentColor: Color

    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        iconSystemName: String? = nil,
        accentColor: Color = AppTheme.Colors.primary500
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.iconSystemName = iconSystemName
        self.accentColor = accentColor
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.neutral500)

                Spacer()

                if let iconSystemName {
                    Image(systemName: iconSystemName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(accentColor)
                }
            }

            Text(value)
                .font(AppTheme.Typography.numeric)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.Colors.neutral900)

            if let subtitle {
                Text(subtitle)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.neutral500)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .glowShadow(AppTheme.Shadows.card)
    }
}
