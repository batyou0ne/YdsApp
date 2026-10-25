import SwiftUI

/// neutral.900 zemin, beyaz metin, tam pill ("Takip Ediliyor" gibi, solda checkmark ikonu)
public struct DarkPillButton: View {
    public let title: String
    public let iconSystemName: String?
    public let isFollowed: Bool
    public let action: () -> Void

    public init(
        title: String,
        iconSystemName: String? = "checkmark",
        isFollowed: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.iconSystemName = iconSystemName
        self.isFollowed = isFollowed
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let iconSystemName, isFollowed {
                    Image(systemName: iconSystemName)
                        .font(.system(size: 12, weight: .bold))
                }

                Text(title)
                    .font(AppTheme.Typography.label)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(AppTheme.Colors.textOnDark)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(AppTheme.Colors.neutral900)
            .clipShape(Capsule())
        }
        .bouncyPressEffect()
    }
}
