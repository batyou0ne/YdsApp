import SwiftUI

/// Yüzdelik dairesel gösterge (ProgressRing): primary.500 dolgu, neutral.100 iz, yuvarlak uçlar
public struct ProgressRing: View {
    public let progressFraction: Double
    public let lineWidth: CGFloat
    public let size: CGFloat
    public let centerText: String?
    public let subtitleText: String?

    public init(
        progressFraction: Double,
        lineWidth: CGFloat = 12,
        size: CGFloat = 120,
        centerText: String? = nil,
        subtitleText: String? = nil
    ) {
        self.progressFraction = min(max(progressFraction, 0.0), 1.0)
        self.lineWidth = lineWidth
        self.size = size
        self.centerText = centerText
        self.subtitleText = subtitleText
    }

    public var body: some View {
        ZStack {
            // Pasif İz
            Circle()
                .stroke(AppTheme.Colors.neutral100, lineWidth: lineWidth)

            // Aktif Dolgu
            Circle()
                .trim(from: 0.0, to: CGFloat(progressFraction))
                .stroke(
                    AppTheme.Colors.primary500,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(AppTheme.standardAnimation, value: progressFraction)

            // Orta Metin
            VStack(spacing: 2) {
                if let centerText {
                    Text(centerText)
                        .font(AppTheme.Typography.display)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.Colors.neutral900)
                }

                if let subtitleText {
                    Text(subtitleText)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.neutral500)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

/// İnce doğrusal ilerleme çubuğu: primary.500 dolgu, neutral.100 iz, tam yuvarlak kapsül
public struct LinearProgressBar: View {
    public let progressFraction: Double
    public let height: CGFloat

    public init(progressFraction: Double, height: CGFloat = 6) {
        self.progressFraction = min(max(progressFraction, 0.0), 1.0)
        self.height = height
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.Colors.neutral100)
                    .frame(height: height)

                Capsule()
                    .fill(AppTheme.Colors.primary500)
                    .frame(width: geometry.size.width * CGFloat(progressFraction), height: height)
                    .animation(AppTheme.standardAnimation, value: progressFraction)
            }
        }
        .frame(height: height)
    }
}
