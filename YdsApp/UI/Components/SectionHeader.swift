import SwiftUI

/// Solda bölüm başlığı (title-md, neutral.900), sağda "Tümünü gör" (primary.500, label) bağlantısı
public struct SectionHeader: View {
    public let title: String
    public let seeAllText: String?
    public let onSeeAllTapped: (() -> Void)?

    public init(
        title: String,
        seeAllText: String? = "Tümünü gör",
        onSeeAllTapped: (() -> Void)? = nil
    ) {
        self.title = title
        self.seeAllText = seeAllText
        self.onSeeAllTapped = onSeeAllTapped
    }

    public var body: some View {
        HStack {
            Text(title)
                .font(AppTheme.Typography.titleMedium)
                .foregroundStyle(AppTheme.Colors.neutral900)

            Spacer()

            if let seeAllText, let onSeeAllTapped {
                Button(action: onSeeAllTapped) {
                    Text(seeAllText)
                        .font(AppTheme.Typography.label)
                        .foregroundStyle(AppTheme.Colors.primary500)
                }
                .bouncyPressEffect()
            }
        }
    }
}
