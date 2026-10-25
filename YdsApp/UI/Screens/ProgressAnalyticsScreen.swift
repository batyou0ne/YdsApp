import SwiftUI

/// 5.6 İlerleme / İstatistik Ekranı (Progress & Analytics Screen)
/// - Haftalık çalışma çubuk grafiği (primary.500 çubuklar, tam yuvarlak uçlar, aktif gün vurgusu)
/// - Tahmini sınav puan ibresi (YDS 0-100 ölçeği)
/// - Konu bazlı güç ve zayıflık analizi
public struct ProgressAnalyticsScreen: View {
    public let weeklyDays: [GlowMockData.WeeklyStudyDay]

    @State private var selectedDayIndex: Int = 6

    public init(weeklyDays: [GlowMockData.WeeklyStudyDay] = GlowMockData.weeklyDays) {
        self.weeklyDays = weeklyDays
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                // 1. Üst Başlık & Puan Özeti
                headerScoreCardView

                // 2. Haftalık Soru Çözüm Çubuk Grafiği
                weeklyBarChartView

                // 3. 4 Temel Metrik Kartı
                quickMetricsGrid

                // 4. Konu Bazlı Güç & Zayıflık Analizi
                topicMasterySectionView

                Spacer(minLength: 84)
            }
            .padding(.horizontal, AppTheme.Spacing.screenPadding)
            .padding(.top, 12)
        }
        .background(AppTheme.Colors.appBackground.ignoresSafeArea())
    }

    // MARK: - 1. Puan Özeti Kartı
    private var headerScoreCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tahmini Sınav Puanı")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.neutral500)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("68.75")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.neutral900)

                        Text("Hedef: 85.00")
                            .font(AppTheme.Typography.label)
                            .foregroundStyle(AppTheme.Colors.neutral500)
                    }
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.primary100)
                        .frame(width: 48, height: 48)

                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.primary700)
                }
            }

            // Puan Cetveli İlerlemesi
            VStack(spacing: 4) {
                LinearProgressBar(progressFraction: 68.75 / 100.0, height: 8)

                HStack {
                    Text("Mevcut: 68.75 (B2)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.primary700)

                    Spacer()

                    Text("Kalan: +16.25 Puan")
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.Colors.neutral500)
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .glowShadow(AppTheme.Shadows.card)
    }

    // MARK: - 2. Haftalık Çubuk Grafiği
    private var weeklyBarChartView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Haftalık Çalışma Aktivitesi")
                    .font(AppTheme.Typography.titleMedium)
                    .foregroundStyle(AppTheme.Colors.neutral900)

                Spacer()

                Text("Toplam 203 Soru")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.primary700)
                    .fontWeight(.semibold)
            }

            // Çubuklar
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(Array(weeklyDays.enumerated()), id: \.element.id) { index, day in
                    VStack(spacing: 6) {
                        // Çözülen Soru Sayısı Balonu
                        if selectedDayIndex == index {
                            Text("\(day.questionCount)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.textOnDark)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.Colors.neutral900)
                                .clipShape(Capsule())
                        } else {
                            Text("\(day.questionCount)")
                                .font(.system(size: 10))
                                .foregroundStyle(AppTheme.Colors.neutral500)
                        }

                        // Yuvarlak Çubuk (primary.500 dolgu)
                        Button {
                            selectedDayIndex = index
                        } label: {
                            Capsule()
                                .fill(
                                    day.isToday || selectedDayIndex == index
                                        ? AppTheme.Colors.primary500
                                        : AppTheme.Colors.primary100
                                )
                                .frame(height: max(CGFloat(day.questionCount) * 2.2, 16))
                        }

                        // Gün Adı
                        Text(day.dayNameTr)
                            .font(AppTheme.Typography.caption)
                            .fontWeight(day.isToday ? .bold : .regular)
                            .foregroundStyle(day.isToday ? AppTheme.Colors.neutral900 : AppTheme.Colors.neutral500)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140, alignment: .bottom)
            .padding(.vertical, 4)
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .glowShadow(AppTheme.Shadows.card)
    }

    // MARK: - 3. Metrikler Grid'i
    private var quickMetricsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            StatCardView(
                title: "Ortalama Doğruluk",
                value: "%84.2",
                subtitle: "Son 7 gün",
                iconSystemName: "percent",
                accentColor: AppTheme.Colors.success
            )

            StatCardView(
                title: "Toplam Süre",
                value: "267 dk",
                subtitle: "Günde ~38 dk",
                iconSystemName: "hourglass",
                accentColor: AppTheme.Colors.primary700
            )
        }
    }

    // MARK: - 4. Konu Hakimiyeti
    private var topicMasterySectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Konu Hakimiyet Raporu", seeAllText: nil)

            VStack(spacing: 10) {
                masteryRow(topic: "Zıtlık & Karşıtlık Bağlaçları", percent: 88, status: "Güçlü", statusColor: AppTheme.Colors.success)
                masteryRow(topic: "Relative & Noun Clauses", percent: 82, status: "İyi", statusColor: AppTheme.Colors.primary500)
                masteryRow(topic: "Cloze Test Boşluk Tamamlama", percent: 74, status: "Gelişiyor", statusColor: AppTheme.Colors.warning)
                masteryRow(topic: "Akademik Edatlar (Prepositions)", percent: 58, status: "Kritik Odak", statusColor: AppTheme.Colors.error)
            }
        }
    }

    private func masteryRow(topic: String, percent: Int, status: String, statusColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(topic)
                    .font(AppTheme.Typography.bodyMedium)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.neutral900)

                Spacer()

                Text(status)
                    .font(AppTheme.Typography.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.12))
                    .clipShape(Capsule())
            }

            HStack {
                LinearProgressBar(progressFraction: Double(percent) / 100.0, height: 6)

                Text("%\(percent)")
                    .font(AppTheme.Typography.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.Colors.neutral700)
                    .frame(width: 36, alignment: .trailing)
            }
        }
        .padding(14)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .glowShadow(AppTheme.Shadows.card)
    }
}
