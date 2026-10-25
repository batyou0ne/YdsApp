import SwiftUI

/// Görsel altında sayfa/nokta göstergesi: aktif nokta siyah uzun pill (24x6), pasif gri nokta (6x6)
public struct ImageIndicator: View {
    public let count: Int
    public let activeIndex: Int

    public init(count: Int, activeIndex: Int) {
        self.count = count
        self.activeIndex = activeIndex
    }

    public var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                if index == activeIndex {
                    Capsule()
                        .fill(AppTheme.Colors.neutral900)
                        .frame(width: 24, height: 6)
                        .animation(AppTheme.pillTransitionAnimation, value: activeIndex)
                } else {
                    Circle()
                        .fill(AppTheme.Colors.neutral300)
                        .frame(width: 6, height: 6)
                        .animation(AppTheme.pillTransitionAnimation, value: activeIndex)
                }
            }
        }
    }
}
