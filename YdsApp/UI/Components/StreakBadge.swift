import SwiftUI

/// Günlük çalışma serisi ve hedef ilerleme kartı (Streak & Goal Banner)
public struct StreakBadge: View {
    public let streakDays: Int
    public let todayScoreDelta: String
    public let completedQuestionsToday: Int
    public let targetQuestionsToday: Int

    public init(
        streakDays: Int = 12,
        todayScoreDelta: String = "+0.40",
        completedQuestionsToday: Int = 14,
        targetQuestionsToday: Int = 20
    ) {
        self.streakDays = streakDays
        self.todayScoreDelta = todayScoreDelta
        self.completedQuestionsToday = completedQuestionsToday
        self.targetQuestionsToday = targetQuestionsToday
    }

    public var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Seri Rozeti
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.Colors.warning)

                Text("\(streakDays) Gün")
                    .font(AppTheme.Typography.bodyLarge)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.Colors.neutral900)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppTheme.Colors.muted)
            .clipShape(Capsule())

            // Günlük İlerleme & Hedef
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Günlük Hedef")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.neutral500)

                    Spacer()

                    Text("\(completedQuestionsToday)/\(targetQuestionsToday) soru (\(todayScoreDelta) Puan)")
                        .font(AppTheme.Typography.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.primary700)
                }

                LinearProgressBar(
                    progressFraction: Double(completedQuestionsToday) / Double(max(targetQuestionsToday, 1)),
                    height: 5
                )
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .glowShadow(AppTheme.Shadows.card)
    }
}
