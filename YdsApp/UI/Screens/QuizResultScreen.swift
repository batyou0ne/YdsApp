import SwiftUI

/// 5.4 Sonuç Ekranı (Quiz Result Screen)
/// - Büyük ProgressRing (% başarı oranı)
/// - Doğru / Yanlış / Boş / Süre StatCard'ları
/// - "Yanlışları Gözden Geçir" (DarkPillButton)
/// - "Tekrar Çöz" (Muted pill buton) ve "Ana Sayfaya Dön" PrimaryButton
public struct QuizResultScreen: View {
    public let correctCount: Int
    public let wrongCount: Int
    public let totalCount: Int
    public let onReviewMistakes: () -> Void
    public let onRetry: () -> Void
    public let onGoHome: () -> Void

    public init(
        correctCount: Int,
        wrongCount: Int,
        totalCount: Int,
        onReviewMistakes: @escaping () -> Void,
        onRetry: @escaping () -> Void,
        onGoHome: @escaping () -> Void
    ) {
        self.correctCount = correctCount
        self.wrongCount = wrongCount
        self.totalCount = max(totalCount, 1)
        self.onReviewMistakes = onReviewMistakes
        self.onRetry = onRetry
        self.onGoHome = onGoHome
    }

    private var accuracyFraction: Double {
        Double(correctCount) / Double(totalCount)
    }

    private var accuracyPercent: Int {
        Int((accuracyFraction * 100).rounded())
    }

    private var estimatedScoreDelta: String {
        let delta = Double(correctCount) * 0.125
        return String(format: "+%.2f Puan", delta)
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppTheme.Spacing.xl) {
                // 1. Başlık & Tebrik
                VStack(spacing: 6) {
                    Text("Çalışma Tamamlandı")
                        .font(AppTheme.Typography.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.Colors.primary700)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(AppTheme.Colors.primary100)
                        .clipShape(Capsule())

                    Text("Harika İlerleme!")
                        .font(AppTheme.Typography.display)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.Colors.neutral900)

                    Text("Günün reçetesinden \(estimatedScoreDelta) kazandın.")
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundStyle(AppTheme.Colors.neutral500)
                }
                .padding(.top, 20)

                // 2. Büyük ProgressRing
                ProgressRing(
                    progressFraction: accuracyFraction,
                    lineWidth: 16,
                    size: 170,
                    centerText: "%\(accuracyPercent)",
                    subtitleText: "Başarı Oranı"
                )
                .padding(.vertical, 8)

                // 3. Stat Kartları (2x2 Grid)
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    StatCardView(
                        title: "Doğru Cevap",
                        value: "\(correctCount)",
                        iconSystemName: "checkmark.circle.fill",
                        accentColor: AppTheme.Colors.success
                    )

                    StatCardView(
                        title: "Yanlış Cevap",
                        value: "\(wrongCount)",
                        iconSystemName: "xmark.circle.fill",
                        accentColor: AppTheme.Colors.error
                    )

                    StatCardView(
                        title: "Puan Katkısı",
                        value: estimatedScoreDelta,
                        iconSystemName: "arrow.up.right.circle.fill",
                        accentColor: AppTheme.Colors.primary500
                    )

                    StatCardView(
                        title: "Çalışma Süresi",
                        value: "14 dk",
                        iconSystemName: "clock.fill",
                        accentColor: AppTheme.Colors.warning
                    )
                }

                // 4. Aksiyon Butonları
                VStack(spacing: 12) {
                    if wrongCount > 0 {
                        Button(action: onReviewMistakes) {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.bubble.fill")
                                    .font(.system(size: 15))
                                Text("Yanlışları Gözden Geçir (\(wrongCount))")
                                    .font(AppTheme.Typography.bodyLarge)
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(AppTheme.Colors.textOnDark)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(AppTheme.Colors.neutral900)
                            .clipShape(Capsule())
                        }
                        .bouncyPressEffect()
                    }

                    HStack(spacing: 12) {
                        // Tekrar Çöz (Muted Pill)
                        Button(action: onRetry) {
                            Text("Tekrar Çöz")
                                .font(AppTheme.Typography.bodyLarge)
                                .fontWeight(.semibold)
                                .foregroundStyle(AppTheme.Colors.neutral900)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(AppTheme.Colors.muted)
                                .clipShape(Capsule())
                        }
                        .bouncyPressEffect()

                        // Ana Sayfaya Dön (PrimaryButton)
                        PrimaryButton(
                            title: "Ana Sayfa",
                            iconSystemName: "house.fill",
                            height: 54,
                            isFullWidth: true,
                            action: onGoHome
                        )
                    }
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, AppTheme.Spacing.screenPadding)
            .padding(.bottom, 32)
        }
        .background(AppTheme.Colors.appBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}
