import SwiftUI

/// 5 Adımlı Kişiselleştirme, Seviye Tespiti, Teşhis Raporu ve Stratejik Paywall Ekranı
public struct OnboardingScreen: View {
    @ObservedObject private var viewModel: OnboardingViewModel

    public init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        let state = viewModel.state
        VStack(spacing: 0) {
            headerBar(state: state)

            switch state.currentStep {
            case .step1ExamAndTrack:
                step1ExamAndTrackView(state: state)
            case .step2ScoreAndTimeGoal:
                step2ScoreAndTimeView(state: state)
            case .step3DiagnosticTest:
                step3DiagnosticTestView(state: state)
            case .step4DiagnosisAndPrescription:
                step4DiagnosisReportView(state: state)
            case .step5StrategicPaywall:
                StrategicPaywallSheetView(
                    reasonMessageTr: state.diagnosticResult?.diagnosticDetailNoteTr
                        ?? "Teşhis raporuna göre hazırlanan 14 adımlık günlük reçeteni %100 kapasiteyle başlat.",
                    currentScoreText: String(format: "%.2f", state.diagnosticResult?.calibratedProfile.currentEstimatedScore ?? state.declaredBaselineScore),
                    targetScoreText: state.formattedTargetScore,
                    selectedTier: state.selectedSubscriptionTier,
                    onSelectTier: { viewModel.onEvent(.selectSubscriptionPlan($0)) },
                    onActivatePro: { viewModel.onEvent(.completeOnboardingWithSelectedTier($0)) },
                    onContinueFree: { viewModel.onEvent(.completeOnboardingWithSelectedTier(.free)) }
                )
            }
        }
        .background(AppTheme.backgroundDark.ignoresSafeArea())
        .onAppear {
            viewModel.onEvent(.onAppear)
        }
    }

    private func headerBar(state: OnboardingViewState) -> some View {
        VStack(spacing: 10) {
            HStack {
                if state.currentStep != .step1ExamAndTrack {
                    Button {
                        viewModel.onEvent(.goBackStep)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Geri")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Text(state.currentStep.stepTitleTr)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.cyanMainSubject)

                Spacer()
            }

            ProgressView(value: state.currentStep.progressFraction)
                .tint(AppTheme.emeraldSuccess)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .background(AppTheme.surfaceCard)
    }

    // MARK: - Adım 1: Hedef Sınav & Alan
    private func step1ExamAndTrackView(state: OnboardingViewState) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Hedef Sınavını ve Akademik Alanını Seç")
                        .font(.title2.weight(.heavy))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Cümle Röntgenleri, 3 boyutlu kelime paketleri ve Mikro-Sprint soruları seçtiğin alana göre filtrelenir.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("1. Hangi Sınava Hazırlanıyorsun?")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    ForEach(ExamType.allCases, id: \.self) { exam in
                        let isSelected = state.selectedExam == exam
                        Button {
                            viewModel.onEvent(.selectExam(exam))
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exam.displayName)
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(AppTheme.textPrimary)
                                    Text(exam.subtitleTr)
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                                Spacer()
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundStyle(isSelected ? AppTheme.emeraldSuccess : AppTheme.textSecondary)
                            }
                            .padding(14)
                            .background(AppTheme.surfaceCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(isSelected ? AppTheme.emeraldSuccess : AppTheme.borderSubtle, lineWidth: isSelected ? 2 : 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("2. Akademik Alan Filtresi (YÖKDİL & YDS)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    ForEach(AcademicTrack.allCases, id: \.self) { track in
                        let isSelected = state.selectedTrack == track
                        Button {
                            viewModel.onEvent(.selectTrack(track))
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: track.iconSystemName)
                                    .font(.title2)
                                    .foregroundStyle(isSelected ? AppTheme.cyanMainSubject : AppTheme.textSecondary)
                                    .frame(width: 34)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(track.titleTr)
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(AppTheme.textPrimary)
                                    Text(track.descriptionTr)
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                }

                                Spacer()

                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(isSelected ? AppTheme.cyanMainSubject : AppTheme.textSecondary)
                            }
                            .padding(14)
                            .background(AppTheme.surfaceCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(isSelected ? AppTheme.cyanMainSubject : AppTheme.borderSubtle, lineWidth: isSelected ? 2 : 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    viewModel.onEvent(.proceedToNextStep)
                } label: {
                    Text("Puan Hedefine Geç (Adım 2/5)")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.primaryActionGradient)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
    }

    // MARK: - Adım 2: Puan & Zaman Hedefi
    private func step2ScoreAndTimeView(state: OnboardingViewState) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Mevcut Seviyen ve Hedef Puanın")
                        .font(.title2.weight(.heavy))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("İlerlemeyi ezberlenen kelime sayısıyla değil, 0.00 - 100.00 arası gerçek tahmini sınav puanıyla ölçüyoruz.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Tahmini Mevcut Puanın")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                        Spacer()
                        Text(state.formattedDeclaredScore)
                            .font(.title3.weight(.heavy))
                            .foregroundStyle(AppTheme.amberMainVerb)
                    }
                    Slider(
                        value: Binding(
                            get: { state.declaredBaselineScore },
                            set: { viewModel.onEvent(.updateDeclaredBaselineScore($0)) }
                        ),
                        in: 25.0...85.0,
                        step: 1.25
                    )
                    .tint(AppTheme.amberMainVerb)
                }
                .padding(16)
                .background(AppTheme.surfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Hedef Sınav Puanın")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                        Spacer()
                        Text(state.formattedTargetScore)
                            .font(.title3.weight(.heavy))
                            .foregroundStyle(AppTheme.emeraldSuccess)
                    }
                    Slider(
                        value: Binding(
                            get: { state.targetScore },
                            set: { viewModel.onEvent(.updateTargetScore($0)) }
                        ),
                        in: 40.0...97.5,
                        step: 1.25
                    )
                    .tint(AppTheme.emeraldSuccess)

                    Text("Hedeflenen Sıçrama: \(state.formattedProjectedGain)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.cyanMainSubject)
                }
                .padding(16)
                .background(AppTheme.surfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Sınava Kalan Süre")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textSecondary)

                    HStack(spacing: 10) {
                        ForEach([30, 60, 90, 120], id: \.self) { days in
                            let isSelected = state.daysRemaining == days
                            Button {
                                viewModel.onEvent(.updateDaysRemaining(days))
                            } label: {
                                Text("\(days) Gün")
                                    .font(.subheadline.weight(.bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isSelected ? AppTheme.cyanMainSubject.opacity(0.22) : AppTheme.surfaceElevated)
                                    .foregroundStyle(isSelected ? AppTheme.cyanMainSubject : AppTheme.textPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
                .background(AppTheme.surfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Button {
                    viewModel.onEvent(.proceedToNextStep)
                } label: {
                    Text("5 Soruluk Seviye Tespitine Başla (Adım 3/5)")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.primaryActionGradient)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
    }

    // MARK: - Adım 3: 5 Soruluk Stratejik Seviye Tespiti
    private func step3DiagnosticTestView(state: OnboardingViewState) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let question = state.currentDiagnosticQuestion {
                    HStack {
                        Text(state.diagnosticProgressText)
                            .font(.caption.weight(.heavy))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppTheme.cyanMainSubject.opacity(0.20))
                            .foregroundStyle(AppTheme.cyanMainSubject)
                            .clipShape(Capsule())

                        Text(question.category.titleTr)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.amberMainVerb)

                        Spacer()
                    }

                    Text(question.stemText)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(5)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.surfaceCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    VStack(spacing: 10) {
                        ForEach(question.options) { option in
                            let isSelected = state.selectedOptionIdForCurrentQuestion == option.id
                            let isCorrect = option.id == question.correctOptionId
                            Button {
                                viewModel.onEvent(.selectDiagnosticOption(option.id))
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Text(option.id)
                                        .font(.subheadline.weight(.heavy))
                                        .frame(width: 28, height: 28)
                                        .background(
                                            isSelected
                                                ? (isCorrect ? AppTheme.emeraldSuccess : AppTheme.coralConjunction)
                                                : AppTheme.surfaceElevated
                                        )
                                        .foregroundStyle(Color.white)
                                        .clipShape(Circle())

                                    Text(option.text)
                                        .font(.subheadline)
                                        .foregroundStyle(AppTheme.textPrimary)
                                        .multilineTextAlignment(.leading)

                                    Spacer()
                                }
                                .padding(14)
                                .background(AppTheme.surfaceCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            isSelected
                                                ? (isCorrect ? AppTheme.emeraldSuccess : AppTheme.coralConjunction)
                                                : AppTheme.borderSubtle,
                                            lineWidth: isSelected ? 2 : 1
                                        )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if let selectedOption = state.currentSelectedOption {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(AppTheme.emeraldSuccess)
                                Text("Anlık Teşhis Notu")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(AppTheme.emeraldSuccess)
                            }
                            Text(selectedOption.distractorCoachFeedback.praiseTextTr)
                                .font(.caption)
                                .foregroundStyle(AppTheme.textPrimary)
                            Text(selectedOption.distractorCoachFeedback.winningRuleTr)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.amberMainVerb)
                        }
                        .padding(14)
                        .background(AppTheme.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                        Button {
                            viewModel.onEvent(.submitCurrentDiagnosticQuestion)
                        } label: {
                            Text(state.currentQuestionIndex + 1 < state.diagnosticQuestions.count ? "Sonraki Teşhis Sorusuna Geç" : "Teşhis Raporumu ve Reçetemi Üret")
                                .font(.headline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(AppTheme.primaryActionGradient)
                                .foregroundStyle(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - Adım 4: Teşhis ve Reçete Ekranı
    private func step4DiagnosisReportView(state: OnboardingViewState) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let result = state.diagnosticResult {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("STRATEJİK TEŞHİS RAPORUN HAZIR")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(AppTheme.emeraldSuccess)

                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Mevcut Tahmini Puan")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textSecondary)
                                Text(String(format: "%.2f", result.calibratedProfile.currentEstimatedScore))
                                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                                    .foregroundStyle(AppTheme.textPrimary)
                            }

                            Image(systemName: "arrow.right")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(AppTheme.emeraldSuccess)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hedef Puan")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textSecondary)
                                Text(String(format: "%.2f", result.calibratedProfile.targetScore))
                                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                                    .foregroundStyle(AppTheme.cyanMainSubject)
                            }
                        }

                        Text(String(format: "Hedefine ulaşmak için +%.2f puana ihtiyacın var.", result.neededScore))
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppTheme.amberMainVerb)

                        Divider().overlay(AppTheme.borderSubtle)

                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(AppTheme.coralConjunction)
                            Text(result.diagnosticSummaryHeadlineTr)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(AppTheme.textPrimary)
                        }

                        Text(result.diagnosticDetailNoteTr)
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(18)
                    .background(AppTheme.surfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    if let prescription = state.previewPrescription {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Günün 15 Dakikalık Reçetesi (14 Adım)")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(AppTheme.textPrimary)

                            Text("• 5x 3 Boyutlu Kelime & Edat Kartı\n• 2x 5 Satırlık Akademik Cümle Röntgeni\n• 5x Zayıf Alan Mikro-Sprint Sorusu\n• 2x Hata Kumbarası Tuzak Tekrarı")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineSpacing(4)

                            Text("Beklenen Günlük Puan Artışı: +\(String(format: "%.2f", prescription.expectedScoreDeltaRangeMin)) ile +\(String(format: "%.2f", prescription.expectedScoreDeltaRangeMax)) puan")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppTheme.emeraldSuccess)
                        }
                        .padding(16)
                        .background(AppTheme.surfaceCard)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }

                    Button {
                        viewModel.onEvent(.proceedToNextStep)
                    } label: {
                        Text("Kişisel Reçetemi Aktifleştir (Adım 5/5)")
                            .font(.headline.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.primaryActionGradient)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
    }
}
