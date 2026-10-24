import SwiftUI

/// Ana Ekran (Dashboard): Canlı Puan İbresi, Günün 15 Dakikalık Reçetesi (14 Adım) ve Soru Tipi Karnesi
public struct DashboardScreen: View {
    @ObservedObject private var viewModel: DashboardViewModel

    public init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        let state = viewModel.state
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                topStatusHeader(state: state)

                if let banner = state.workoutCompletionBannerTr {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(AppTheme.emeraldSuccess)
                        Text(banner)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                    }
                    .padding(12)
                    .background(AppTheme.emeraldSuccess.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                // 1. Canlı Puan Tahmin İbresi
                ScoreGaugeView(
                    currentScoreText: state.formattedCurrentScore,
                    trajectoryText: state.scoreTrajectorySummaryTr,
                    targetScoreText: state.formattedTargetScore,
                    neededScoreText: state.formattedNeededScore,
                    todayDeltaText: state.formattedTodayDelta,
                    examTitle: state.profile.targetExam.displayName,
                    trackTitle: state.profile.academicTrack.shortTitleTr,
                    daysRemaining: state.profile.daysRemainingUntilExam,
                    streakDays: state.profile.streakDays,
                    gaugeFraction: state.gaugeProgressFraction
                )

                // 2. Akademik Alan Filtre Çubuğu (Sağlık / Fen / Sosyal / Genel)
                academicTrackFilterBar(state: state)

                // 3. Günün 15 Dakikalık Reçetesi (14 Adım + %50 Freemium Kilidi)
                dailyPrescriptionCard(state: state)

                // 4. Soru Tipi Karnesi (80 Soruluk YDS/YÖKDİL Ağırlıklı)
                ScoreReportCardView(reportCard: state.reportCard)
            }
            .padding(18)
        }
        .background(AppTheme.backgroundDark.ignoresSafeArea())
        .onAppear {
            viewModel.onEvent(.onAppear)
        }
        .sheet(
            isPresented: Binding(
                get: { state.isPaywallPresented },
                set: { if !$0 { viewModel.onEvent(.dismissPaywall) } }
            )
        ) {
            StrategicPaywallSheetView(
                reasonMessageTr: state.paywallTriggerReasonTr,
                currentScoreText: state.formattedCurrentScore,
                targetScoreText: state.formattedTargetScore,
                selectedTier: .proAnnual,
                onSelectTier: { _ in },
                onActivatePro: { tier in
                    viewModel.onEvent(.upgradeSubscription(tier))
                },
                onContinueFree: {
                    viewModel.onEvent(.dismissPaywall)
                }
            )
        }
    }

    private func topStatusHeader(state: DashboardViewState) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("YDS & YÖKDİL Strateji Merkezi")
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(state.freeTierGatingSubtitleTr)
                    .font(.caption)
                    .foregroundStyle(state.profile.subscriptionTier.isPro ? AppTheme.emeraldSuccess : AppTheme.amberMainVerb)
            }

            Spacer()

            if !state.profile.subscriptionTier.isPro {
                Button {
                    viewModel.onEvent(.openPaywall(reasonTr: "Günlük 14 adımlık reçetenin tamamını, sınırsız Cümle Röntgenini ve Çeldirici Koçunu açmak için Pro'ya geç."))
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                        Text("PRO")
                    }
                    .font(.caption.weight(.heavy))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.proCrownGradient)
                    .foregroundStyle(Color.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            Button {
                viewModel.onEvent(.restartOnboardingDiagnostic)
            } label: {
                Image(systemName: "stethoscope")
                    .font(.subheadline.weight(.bold))
                    .padding(8)
                    .background(AppTheme.surfaceCard)
                    .foregroundStyle(AppTheme.cyanMainSubject)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("5 Soruluk Seviye Tespitini Yeniden Çalıştır")
        }
    }

    private func academicTrackFilterBar(state: DashboardViewState) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(AcademicTrack.allCases, id: \.self) { track in
                    let isSelected = state.profile.academicTrack == track
                    Button {
                        viewModel.onEvent(.selectAcademicTrackFilter(track))
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: track.iconSystemName)
                            Text(track.titleTr)
                                .font(.caption.weight(.bold))
                            if !isSelected && !state.profile.subscriptionTier.isPro {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isSelected ? AppTheme.cyanMainSubject.opacity(0.22) : AppTheme.surfaceCard)
                        .foregroundStyle(isSelected ? AppTheme.cyanMainSubject : AppTheme.textSecondary)
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? AppTheme.cyanMainSubject : AppTheme.borderSubtle, lineWidth: 1)
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func dailyPrescriptionCard(state: DashboardViewState) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.heart.fill")
                            .foregroundStyle(AppTheme.emeraldSuccess)
                        Text("Günün 15 Dakikalık Reçetesi")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    Text("5x 3B Kelime • 2x Cümle Röntgeni • 5x Mikro-Sprint • 2x Hata Kumbarası")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                Text("\(state.dailyPrescription.completedStepsCount)/\(state.dailyPrescription.totalStepsCount)")
                    .font(.subheadline.weight(.heavy))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.surfaceElevated)
                    .foregroundStyle(AppTheme.emeraldSuccess)
                    .clipShape(Capsule())
            }

            ProgressView(value: state.dailyPrescription.progressFraction)
                .tint(AppTheme.emeraldSuccess)

            Button {
                viewModel.onEvent(.startNextPrescriptionStep)
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text(state.prescriptionButtonTitleTr)
                        .font(.subheadline.weight(.bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.primaryActionGradient)
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)

            VStack(spacing: 8) {
                ForEach(state.dailyPrescription.steps) { step in
                    Button {
                        viewModel.onEvent(.tapPrescriptionStep(step))
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        step.isCompleted
                                            ? AppTheme.emeraldSuccess.opacity(0.22)
                                            : (step.isLockedForFreeTier ? AppTheme.amberMainVerb.opacity(0.18) : AppTheme.surfaceElevated)
                                    )
                                    .frame(width: 32, height: 32)

                                if step.isCompleted {
                                    Image(systemName: "checkmark")
                                        .font(.caption.weight(.heavy))
                                        .foregroundStyle(AppTheme.emeraldSuccess)
                                } else if step.isLockedForFreeTier {
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.amberMainVerb)
                                } else {
                                    Text("\(step.stepIndex)")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(AppTheme.textPrimary)
                                }
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(step.stepType.badgeTitleTr)
                                        .font(.system(size: 9, weight: .heavy))
                                        .foregroundStyle(AppTheme.cyanMainSubject)
                                    if step.isLockedForFreeTier {
                                        Text("PRO (%50 SINIRI)")
                                            .font(.system(size: 9, weight: .heavy))
                                            .foregroundStyle(AppTheme.amberMainVerb)
                                    }
                                }
                                Text(step.titleTr)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(step.isLockedForFreeTier ? AppTheme.textSecondary : AppTheme.textPrimary)
                                    .lineLimit(1)
                                Text(step.subtitleTr)
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Text(String(format: "+%.2fp", step.estimatedScoreImpact))
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(AppTheme.emeraldSuccess)
                        }
                        .padding(10)
                        .background(AppTheme.backgroundDark.opacity(0.55))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
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
