import SwiftUI

/// Yükseklik 52, tam pill, beyaz zeminli, sol büyüteç, dikey ayraç ve filtre ikonlu arama çubuğu
public struct AppSearchBar: View {
    @Binding public var text: String
    public let placeholder: String
    public let onFilterTapped: () -> Void

    public init(
        text: Binding<String>,
        placeholder: String = "Kelime, konu veya soru ara…",
        onFilterTapped: @escaping () -> Void = {}
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onFilterTapped = onFilterTapped
    }

    public var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppTheme.Colors.neutral500)
                .padding(.leading, AppTheme.Spacing.base)

            TextField(placeholder, text: $text)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundStyle(AppTheme.Colors.neutral900)
                .tint(AppTheme.Colors.primary500)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.Colors.neutral500)
                        .font(.system(size: 16))
                }
            }

            // İnce dikey ayraç
            Rectangle()
                .fill(AppTheme.Colors.neutral300)
                .frame(width: 1, height: 22)

            // Filtre Butonu
            Button(action: onFilterTapped) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.neutral900)
                    .frame(width: 36, height: 36)
            }
            .padding(.trailing, AppTheme.Spacing.md)
        }
        .frame(height: 52)
        .background(AppTheme.Colors.surface)
        .clipShape(Capsule())
        .glowShadow(AppTheme.Shadows.soft)
    }
}
