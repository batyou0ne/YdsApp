import SwiftUI

/// Eğitmen ve resmî kurum isimleri yanında doğrulama rozeti (VerifiedBadge)
public struct VerifiedBadge: View {
    public let size: CGFloat

    public init(size: CGFloat = 16) {
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.Colors.neutral900)
                .frame(width: size, height: size)

            Image(systemName: "checkmark")
                .font(.system(size: size * 0.55, weight: .bold))
                .foregroundStyle(Color.white)
        }
    }
}
