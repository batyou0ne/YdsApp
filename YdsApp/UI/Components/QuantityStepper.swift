import SwiftUI

/// 1px neutral.300 çerçeveli radius 12 kutu; − ve + küçük kare butonlar, ortada soru sayısı
public struct QuantityStepper: View {
    @Binding public var value: Int
    public let step: Int
    public let minValue: Int
    public let maxValue: Int

    public init(
        value: Binding<Int>,
        step: Int = 5,
        minValue: Int = 5,
        maxValue: Int = 80
    ) {
        self._value = value
        self.step = step
        self.minValue = minValue
        self.maxValue = maxValue
    }

    public var body: some View {
        HStack(spacing: 6) {
            Button {
                if value - step >= minValue {
                    value -= step
                }
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(value > minValue ? AppTheme.Colors.neutral900 : AppTheme.Colors.neutral300)
                    .frame(width: 28, height: 28)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .disabled(value <= minValue)

            Text("\(value)")
                .font(AppTheme.Typography.bodyLarge)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.Colors.neutral900)
                .frame(minWidth: 32)
                .multilineTextAlignment(.center)

            Button {
                if value + step <= maxValue {
                    value += step
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(value < maxValue ? AppTheme.Colors.neutral900 : AppTheme.Colors.neutral300)
                    .frame(width: 28, height: 28)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .disabled(value >= maxValue)
        }
        .padding(4)
        .frame(height: 40)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.Colors.neutral300, lineWidth: 1)
        )
    }
}
