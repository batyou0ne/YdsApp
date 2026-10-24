import SwiftUI

/// Canlı Tahmini Sınav Puanı İbresi (Örn: 46.25 -> 58.50 • Bugün +0.40 puan)
public struct ScoreGaugeView: View {
    public let currentScoreText: String
    public let trajectoryText: String
    public let targetScoreText: String
    public let neededScoreText: String
    public let todayDeltaText: String
    public let examTitle: String
    public let trackTitle: String
    public let daysRemaining: Int
    public let streakDays: Int
    public let gaugeFraction: Double

    public init(
        currentScoreText: String,
        trajectoryText: String,
        targetScoreText: String,
        neededScoreText: String,
        todayDeltaText: String,
        examTitle: String,
        trackTitle: String,
        daysRemaining: Int,
        streakDays: Int,
        gaugeFraction: Double
    ) {
        self.currentScoreText = currentScoreText
        self.trajectoryText = trajectoryText
        self.targetScoreText = targetScoreText
        self.neededScoreText = neededScoreText
        self.todayDeltaText = todayDeltaText
        self.examTitle = examTitle
        self.trackTitle = trackTitle
        self.daysRemaining = daysRemaining
        self.streakDays = streakDays
        self.gaugeFraction = gaugeFraction
    }

    public var body: some View {
        VStack(spacing: 18) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "graduationcap.fill")
                        .foregroundStyle(AppTheme.cyanMainSubject)
                    Text("\(examTitle) • \(trackTitle)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.surfaceElevated)
                .clipShape(Capsule())

                Spacer()

                HStack(spacing: 10) {
                    Label("\(streakDays) Gün", systemImage: "flame.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.amberMainVerb)
                    Label("Sınava \(daysRemaining)g", systemImage: "calendar")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .trim(from: 0.12, to: 0.88)
                        .stroke(
                            AppTheme.surfaceElevated,
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(90))

                    Circle()
                        .trim(from: 0.12, to: 0.12 + (0.76 * gaugeFraction))
                        .stroke(
                            AppTheme.primaryActionGradient,
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(90))
                        .animation(.spring(response: 0.55, dampingFraction: 0.82), value: gaugeFraction)

                    VStack(spacing: 2) {
                        Text("TAHMİNİ PUAN")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(AppTheme.textSecondary)
                        Text(currentScoreText)
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text(todayDeltaText)
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(AppTheme.emeraldSuccess.opacity(0.20))
                            .foregroundStyle(AppTheme.emeraldSuccess)
                            .clipShape(Capsule())
                    }
                }
                .frame(width: 138, height: 138)

                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Puan Sıçraması")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.textSecondary)
                        HStack(spacing: 4) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundStyle(AppTheme.emeraldSuccess)
                            Text(trajectoryText)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                    }

                    Divider()
                        .overlay(AppTheme.borderSubtle)

                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Hedef Puan")
                                .font(.caption2)
                                .foregroundStyle(AppTheme.textSecondary)
                            Text(targetScoreText)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(AppTheme.cyanMainSubject)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Kalan Fark")
                                .font(.caption2)
                                .foregroundStyle(AppTheme.textSecondary)
                            Text(neededScoreText)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(AppTheme.amberMainVerb)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(18)
        .background(AppTheme.surfaceCard)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

/// Soru Tipi Karnesi (Category Mastery & Potential Score Gain Card)
public struct ScoreReportCardView: View {
    public let reportCard: ScoreReportCard

    public init(reportCard: ScoreReportCard) {
        self.reportCard = reportCard
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Soru Tipi Karnesi (80 Soru Ağırlıklı)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Her soru 1.25 puan • Potansiyel puan kazancına göre sıralandı")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
            }

            ForEach(reportCard.categoryRecords) { record in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: record.category.iconName)
                            .foregroundStyle(AppTheme.cyanMainSubject)
                        Text(record.category.titleTr)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Text(String(format: "+%.2f puan cepte", record.potentialScoreGain))
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.emeraldSuccess.opacity(0.18))
                            .foregroundStyle(AppTheme.emeraldSuccess)
                            .clipShape(Capsule())
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(AppTheme.surfaceElevated)
                                .frame(height: 8)
                            Capsule()
                                .fill(AppTheme.primaryActionGradient)
                                .frame(width: max(12, geo.size.width * record.currentMasteryRatio), height: 8)
                        }
                    }
                    .frame(height: 8)

                    HStack {
                        Text("Ustalık: %\(record.masteryPercentageInt) (\(record.category.examQuestionCount) Soru = \(String(format: "%.1f", record.category.maxScorePoints)) Puan)")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.textSecondary)
                        Spacer()
                    }

                    Text(record.diagnosticNoteTr)
                        .font(.caption)
                        .foregroundStyle(AppTheme.amberMainVerb)
                }
                .padding(12)
                .background(AppTheme.backgroundDark.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(18)
        .background(AppTheme.surfaceCard)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
