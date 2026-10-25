import SwiftUI

public enum OptionTileState {
    case normal
    case selected
    case correct
    case wrong
}

/// Soru A–E seçenek kartı: Tam pill / radius 16, seçili = primary.100 zemin + primary.500 sol çerçeve, doğru = success, yanlış = error
public struct QuestionOptionTile: View {
    public let optionLetter: String
    public let optionText: String
    public let tileState: OptionTileState
    public let action: () -> Void

    public init(
        optionLetter: String,
        optionText: String,
        tileState: OptionTileState = .normal,
        action: @escaping () -> Void
    ) {
        self.optionLetter = optionLetter
        self.optionText = optionText
        self.tileState = tileState
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Harf Yuvarlağı (A, B, C, D, E)
                ZStack {
                    Circle()
                        .fill(letterCircleBackgroundColor)
                        .frame(width: 34, height: 34)

                    Text(optionLetter)
                        .font(AppTheme.Typography.label)
                        .fontWeight(.bold)
                        .foregroundStyle(letterTextColor)
                }

                // Seçenek Metni
                Text(optionText)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundStyle(AppTheme.Colors.neutral900)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Durum İkonu (Doğru / Yanlış)
                if tileState == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.Colors.success)
                } else if tileState == .wrong {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppTheme.Colors.error)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(tileBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(tileBorderColor, lineWidth: tileBorderWidth)
            )
            .glowShadow(AppTheme.Shadows.card)
        }
        .bouncyPressEffect()
    }

    private var tileBackgroundColor: Color {
        switch tileState {
        case .normal:
            return AppTheme.Colors.surface
        case .selected:
            return AppTheme.Colors.primary100
        case .correct:
            return AppTheme.Colors.primary100.opacity(0.8)
        case .wrong:
            return AppTheme.Colors.error.opacity(0.12)
        }
    }

    private var tileBorderColor: Color {
        switch tileState {
        case .normal:
            return Color.clear
        case .selected:
            return AppTheme.Colors.primary500
        case .correct:
            return AppTheme.Colors.success
        case .wrong:
            return AppTheme.Colors.error
        }
    }

    private var tileBorderWidth: CGFloat {
        switch tileState {
        case .normal:
            return 0
        case .selected, .correct, .wrong:
            return 1.5
        }
    }

    private var letterCircleBackgroundColor: Color {
        switch tileState {
        case .normal:
            return AppTheme.Colors.muted
        case .selected:
            return AppTheme.Colors.primary500
        case .correct:
            return AppTheme.Colors.success
        case .wrong:
            return AppTheme.Colors.error
        }
    }

    private var letterTextColor: Color {
        switch tileState {
        case .normal:
            return AppTheme.Colors.neutral900
        case .selected, .correct, .wrong:
            return Color.white
        }
    }
}
