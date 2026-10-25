import SwiftUI

public enum GlowNavTab: Int, CaseIterable, Identifiable, Sendable {
    case home = 0
    case lessons = 1
    case practice = 2
    case vocabulary = 3
    case profile = 4

    public var id: Int { rawValue }

    public var titleTr: String {
        switch self {
        case .home:
            return "Ana Sayfa"
        case .lessons:
            return "Dersler"
        case .practice:
            return "Pratik"
        case .vocabulary:
            return "Kelimeler"
        case .profile:
            return "Profil"
        }
    }

    public var iconSystemName: String {
        switch self {
        case .home:
            return "house.fill"
        case .lessons:
            return "book.closed.fill"
        case .practice:
            return "bolt.badge.clock.fill"
        case .vocabulary:
            return "heart.fill"
        case .profile:
            return "person.crop.circle.fill"
        }
    }

    public var outlineIconName: String {
        switch self {
        case .home:
            return "house"
        case .lessons:
            return "book.closed"
        case .practice:
            return "bolt.badge.clock"
        case .vocabulary:
            return "heart"
        case .profile:
            return "person.crop.circle"
        }
    }
}

/// Ekranın altından 12–16px yukarıda yüzen, tam pill, beyaz, yumuşak gölgeli, seçilince genişleyen pill navigasyon barı
public struct FloatingBottomNav: View {
    @Binding public var selectedTab: GlowNavTab

    public init(selectedTab: Binding<GlowNavTab>) {
        self._selectedTab = selectedTab
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(GlowNavTab.allCases) { tab in
                let isSelected = selectedTab == tab
                Button {
                    withAnimation(AppTheme.pillTransitionAnimation) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isSelected ? tab.iconSystemName : tab.outlineIconName)
                            .font(.system(size: 20, weight: isSelected ? .bold : .medium))
                            .foregroundStyle(isSelected ? AppTheme.Colors.primary700 : AppTheme.Colors.neutral700)

                        if isSelected {
                            Text(tab.titleTr)
                                .font(AppTheme.Typography.label)
                                .fontWeight(.semibold)
                                .foregroundStyle(AppTheme.Colors.primary700)
                                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        }
                    }
                    .padding(.horizontal, isSelected ? 16 : 14)
                    .padding(.vertical, 12)
                    .background(
                        Group {
                            if isSelected {
                                Capsule()
                                    .fill(AppTheme.Colors.primary100)
                            } else {
                                Color.clear
                            }
                        }
                    )
                }
                .bouncyPressEffect()
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 68)
        .background(AppTheme.Colors.surface)
        .clipShape(Capsule())
        .glowShadow(AppTheme.Shadows.float)
        .padding(.horizontal, AppTheme.Spacing.base)
        .padding(.bottom, 14)
    }
}
