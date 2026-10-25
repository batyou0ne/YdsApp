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
                    Text("Seviye Belirlemeye Geç (Adım 3/5)")
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

    // MARK: - Adım 3: Seviye Belirleme & Adaptif Teşhis
    @ViewBuilder
    private func step3DiagnosticTestView(state: OnboardingViewState) -> some View {
        if state.isPathChooserVisible {
            step3PathChooserView(state: state)
        } else {
            step3QuestionView(state: state)
        }
    }

    // MARK: - Adım 3 Yol Seçici
    private func step3PathChooserView(state: OnboardingViewState) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Nasıl Başlamak İstersin?")
                        .font(AppTheme.Typography.display)
                        .foregroundStyle(AppTheme.Colors.neutral900)
                    Text("Sana en uygun başlangıç yolunu seç; seviyeni sınav stresi olmadan, oyun tadında birlikte belirleyelim.")
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundStyle(AppTheme.Colors.neutral700)
                }

                // 3 Yol Kartı
                VStack(spacing: 12) {
                    ForEach(OnboardingStartPath.allCases, id: \.self) { path in
                        startPathCard(path: path, isSelected: state.selectedStartPath == path)
                    }
                }

                VStack(spacing: 12) {
                    Button {
                        viewModel.onEvent(.confirmStartPath)
                    } label: {
                        HStack(spacing: 8) {
                            Text(state.selectedStartPath == .freshStart ? "Sıfırdan Başla" : "Bu Yolla Başla")
                                .font(AppTheme.Typography.bodyLarge)
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                                .font(.subheadline.weight(.bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.primaryActionGradient)
                        .foregroundStyle(AppTheme.Colors.textOnPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(state.selectedStartPath == .freshStart ? "Sıfırdan başla ve reçeteni oluştur" : "Seçilen yolla teşhise başla")

                    if state.selectedStartPath != .freshStart {
                        Button {
                            viewModel.onEvent(.skipDiagnosticWithFreshStart)
                        } label: {
                            Text("Soru çözmeden sıfırdan başlamak istiyorum")
                                .font(AppTheme.Typography.label)
                                .foregroundStyle(AppTheme.Colors.neutral500)
                                .underline()
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                        .accessibilityLabel("Soru çözmeden sıfırdan başla")
                    }
                }
            }
            .padding(20)
        }
    }

    private func startPathCard(path: OnboardingStartPath, isSelected: Bool) -> some View {
        Button {
            viewModel.onEvent(.selectStartPath(path))
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(isSelected ? AppTheme.Colors.primary100 : AppTheme.Colors.muted)
                            .frame(width: 44, height: 44)

                        Image(systemName: path.iconSystemName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(isSelected ? AppTheme.Colors.primary700 : AppTheme.Colors.neutral700)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(path.titleTr)
                                .font(AppTheme.Typography.titleMedium)
                                .foregroundStyle(AppTheme.Colors.neutral900)

                            if path.isRecommended {
                                HStack(spacing: 3) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 9, weight: .bold))
                                    Text("Önerilen")
                                        .font(AppTheme.Typography.caption)
                                        .fontWeight(.bold)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppTheme.Colors.primary100)
                                .foregroundStyle(AppTheme.Colors.primary700)
                                .clipShape(Capsule())
                            }
                        }

                        Text(path.subtitleTr)
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundStyle(AppTheme.Colors.neutral500)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 4)

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? AppTheme.Colors.primary500 : AppTheme.Colors.neutral300)
                        .padding(.top, 2)
                }
            }
            .padding(16)
            .background(AppTheme.Colors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .stroke(isSelected ? AppTheme.Colors.primary500 : AppTheme.Colors.neutral300.opacity(0.6), lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
            .glowShadow(isSelected ? AppTheme.Shadows.card : AppTheme.Shadows.soft)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(path.titleTr), \(path.isRecommended ? "Önerilen, " : "")\(path.subtitleTr)")
        .accessibilityHint(isSelected ? "Seçili" : "Seçmek için çift dokun")
    }

    // MARK: - Adım 3 Soru Ekranı
    private func step3QuestionView(state: OnboardingViewState) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let question = state.currentDiagnosticQuestion {
                    // Üst Bar: İlerleme, Seviye, Kalan Süre
                    HStack(spacing: 8) {
                        Text(state.diagnosticProgressText)
                            .font(AppTheme.Typography.label)
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppTheme.Colors.primary100)
                            .foregroundStyle(AppTheme.Colors.primary700)
                            .clipShape(Capsule())

                        Text(state.levelIndicatorText)
                            .font(AppTheme.Typography.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.Colors.muted)
                            .foregroundStyle(AppTheme.Colors.neutral700)
                            .clipShape(Capsule())

                        Spacer()

                        // Kalan Süre Halkası
                        HStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .stroke(AppTheme.Colors.neutral100, lineWidth: 3)
                                    .frame(width: 28, height: 28)
                                Circle()
                                    .trim(from: 0.0, to: CGFloat(state.remainingTimeFraction))
                                    .stroke(
                                        state.remainingSeconds <= 5 ? AppTheme.Colors.error : AppTheme.Colors.primary500,
                                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .animation(AppTheme.quickAnimation, value: state.remainingTimeFraction)
                                    .frame(width: 28, height: 28)
                                Text("\(state.remainingSeconds)")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(state.remainingSeconds <= 5 ? AppTheme.Colors.error : AppTheme.Colors.neutral900)
                            }
                            Text("sn")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.neutral500)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Kalan süre: \(state.remainingSeconds) saniye")
                    }

                    // Kategori başlığı
                    Text(question.category.titleTr)
                        .font(AppTheme.Typography.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.Colors.primary700)

                    // Soru Kökü
                    Text(question.stemText)
                        .font(AppTheme.Typography.bodyLarge)
                        .foregroundStyle(AppTheme.Colors.neutral900)
                        .lineSpacing(5)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                        .glowShadow(AppTheme.Shadows.soft)

                    // Şıklar (QuestionOptionTile)
                    VStack(spacing: 10) {
                        ForEach(question.options) { option in
                            let isSelected = state.selectedOptionIdForCurrentQuestion == option.id
                            let isCorrect = option.id == question.correctOptionId
                            let tileState: OptionTileState = {
                                if !state.isCurrentQuestionAnswered {
                                    return isSelected ? .selected : .normal
                                }
                                if isCorrect { return .correct }
                                if isSelected { return .wrong }
                                return .normal
                            }()

                            QuestionOptionTile(
                                optionLetter: option.id,
                                optionText: option.text,
                                tileState: tileState
                            ) {
                                viewModel.onEvent(.selectDiagnosticOption(option.id))
                            }
                            .disabled(state.isCurrentQuestionAnswered)
                            .accessibilityLabel("\(option.id) şıkkı: \(option.text)")
                            .accessibilityHint(state.isCurrentQuestionAnswered ? (isCorrect ? "Doğru şık" : (isSelected ? "Seçtiğin yanlış şık" : "")) : "İşaretlemek için çift dokun")
                        }
                    }

                    // Canlı Puan İpucu (Hafif, oyun tadında animasyonlu geribildirim)
                    if let hint = state.liveScoreHintText {
                        HStack(spacing: 10) {
                            Image(systemName: state.lastAnswerWasCorrect == true ? "sparkles" : "waveform.path.ecg")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(state.lastAnswerWasCorrect == true ? AppTheme.Colors.success : AppTheme.Colors.warning)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(hint)
                                    .font(AppTheme.Typography.label)
                                    .fontWeight(.bold)
                                    .foregroundStyle(AppTheme.Colors.neutral900)
                                Text(state.lastAnswerWasCorrect == true ? "Harika gidiyorsun! Kalibrasyon anında güncellendi." : "Önemli değil! Motor senin için en doğru dengeyi arıyor.")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundStyle(AppTheme.Colors.neutral500)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(state.lastAnswerWasCorrect == true ? AppTheme.Colors.primary100.opacity(0.7) : AppTheme.Colors.muted)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.chip))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.chip)
                                .stroke(state.lastAnswerWasCorrect == true ? AppTheme.Colors.primary500.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                        .transition(.scale.combined(with: .opacity))
                    }

                    // Distractor Coach Açıklaması
                    if let feedback = state.feedbackOption?.distractorCoachFeedback {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: state.lastAnswerWasCorrect == true ? "sparkles" : "lightbulb.fill")
                                    .foregroundStyle(state.lastAnswerWasCorrect == true ? AppTheme.Colors.success : AppTheme.Colors.warning)
                                Text("Anlık Teşhis Notu")
                                    .font(AppTheme.Typography.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(state.lastAnswerWasCorrect == true ? AppTheme.Colors.success : AppTheme.Colors.warning)
                            }

                            Text(feedback.praiseTextTr)
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundStyle(AppTheme.Colors.neutral900)

                            if state.lastAnswerWasCorrect == false && !feedback.trapReasonTr.isEmpty {
                                Text("Tuzak: " + feedback.trapReasonTr)
                                    .font(AppTheme.Typography.caption)
                                    .foregroundStyle(AppTheme.Colors.error)
                            }

                            Text(feedback.winningRuleTr)
                                .font(AppTheme.Typography.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(AppTheme.Colors.primary700)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.Colors.muted)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        Button {
                            viewModel.onEvent(.submitCurrentDiagnosticQuestion)
                        } label: {
                            Text(advanceButtonTitle(state: state))
                                .font(AppTheme.Typography.bodyLarge)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(AppTheme.primaryActionGradient)
                                .foregroundStyle(AppTheme.Colors.textOnPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(advanceButtonTitle(state: state))
                    }
                }
            }
            .padding(20)
        }
        .task(id: "\(state.currentQuestionIndex)-\(state.isCurrentQuestionAnswered)") {
            guard !state.isCurrentQuestionAnswered, !state.isPathChooserVisible else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { break }
                viewModel.onEvent(.tickTimer)
            }
        }
    }

    private func advanceButtonTitle(state: OnboardingViewState) -> String {
        let maxQ = state.adaptiveSession?.maxQuestions ?? state.diagnosticQuestions.count
        return (state.currentQuestionIndex + 1 < maxQ) ? "Sonraki Teşhis Sorusuna Geç" : "Teşhis Raporumu ve Reçetemi Üret"
    }

    // MARK: - Adım 4: Teşhis ve Reçete Ekranı
    private func step4DiagnosisReportView(state: OnboardingViewState) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let result = state.diagnosticResult {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("STRATEJİK TEŞHİS RAPORUN HAZIR")
                                .font(AppTheme.Typography.label)
                                .fontWeight(.heavy)
                                .foregroundStyle(AppTheme.Colors.primary700)

                            Spacer()

                            // Güven Seviyesi Rozeti
                            if let outcome = state.diagnosticOutcome {
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(confidenceColor(outcome.confidenceLevel))
                                        .frame(width: 7, height: 7)
                                    Text(outcome.confidenceLevel.titleTr)
                                        .font(AppTheme.Typography.caption)
                                        .fontWeight(.bold)
                                        .foregroundStyle(AppTheme.Colors.neutral700)
                                }
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(AppTheme.Colors.muted)
                                .clipShape(Capsule())
                            }
                        }

                        // Puan Kıyaslaması (Tahmini Puan ± Güven Aralığı ve Hedef Puan)
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Mevcut Tahmini Puan")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundStyle(AppTheme.Colors.neutral500)
                                Text(state.formattedOutcomeScoreWithRange ?? String(format: "%.2f", result.calibratedProfile.currentEstimatedScore))
                                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                                    .foregroundStyle(AppTheme.Colors.neutral900)
                            }

                            Image(systemName: "arrow.right")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(AppTheme.Colors.primary500)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hedef Puan")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundStyle(AppTheme.Colors.neutral500)
                                Text(String(format: "%.2f", result.calibratedProfile.targetScore))
                                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                                    .foregroundStyle(AppTheme.Colors.primary700)
                            }
                        }

                        Text(String(format: "Hedefine ulaşmak için +%.2f puana ihtiyacın var.", result.neededScore))
                            .font(AppTheme.Typography.bodyMedium)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.Colors.warning)

                        // Düşük güven bilgilendirme notu
                        if state.diagnosticOutcome?.confidenceLevel == .low {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(AppTheme.Colors.primary700)
                                Text("Birkaç gün çalışınca puanını netleştireceğiz.")
                                    .font(AppTheme.Typography.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(AppTheme.Colors.neutral700)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.Colors.primary100.opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Beyan-ölçüm uyuşmazlığı notu
                        if let mismatchNote = state.diagnosticOutcome?.declaredScoreMismatchNoteTr {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundStyle(AppTheme.Colors.warning)
                                Text(mismatchNote)
                                    .font(AppTheme.Typography.caption)
                                    .foregroundStyle(AppTheme.Colors.neutral700)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.Colors.muted)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        Divider().overlay(AppTheme.Colors.neutral300.opacity(0.6))

                        // En Zayıf 2 Alan
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Öncelikli Gelişim Alanların")
                                .font(AppTheme.Typography.label)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.Colors.neutral900)

                            HStack(spacing: 8) {
                                ForEach(result.weakestTwoCategories, id: \.self) { category in
                                    HStack(spacing: 4) {
                                        Image(systemName: "target")
                                            .font(.caption2)
                                        Text(category.titleTr)
                                            .font(AppTheme.Typography.caption)
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(AppTheme.Colors.error.opacity(0.12))
                                    .foregroundStyle(AppTheme.Colors.error)
                                    .clipShape(Capsule())
                                }
                            }
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "chart.bar.xaxis")
                                .foregroundStyle(AppTheme.Colors.primary700)
                            Text(result.diagnosticSummaryHeadlineTr)
                                .font(AppTheme.Typography.bodyMedium)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.Colors.neutral900)
                        }

                        Text(result.diagnosticDetailNoteTr)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.neutral500)
                    }
                    .padding(18)
                    .background(AppTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                    .glowShadow(AppTheme.Shadows.card)

                    if let prescription = state.previewPrescription {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Günün 15 Dakikalık Reçetesi (14 Adım)")
                                .font(AppTheme.Typography.titleMedium)
                                .foregroundStyle(AppTheme.Colors.neutral900)

                            Text("• 5x 3 Boyutlu Kelime & Edat Kartı\n• 2x 5 Satırlık Akademik Cümle Röntgeni\n• 5x Zayıf Alan Mikro-Sprint Sorusu\n• 2x Hata Kumbarası Tuzak Tekrarı")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.neutral500)
                                .lineSpacing(4)

                            Text("Beklenen Günlük Puan Artışı: +\(String(format: "%.2f", prescription.expectedScoreDeltaRangeMin)) ile +\(String(format: "%.2f", prescription.expectedScoreDeltaRangeMax)) puan")
                                .font(AppTheme.Typography.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.Colors.success)
                        }
                        .padding(16)
                        .background(AppTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                        .glowShadow(AppTheme.Shadows.card)
                    }

                    Button {
                        viewModel.onEvent(.proceedToNextStep)
                    } label: {
                        Text("Kişisel Reçetemi Aktifleştir (Adım 5/5)")
                            .font(AppTheme.Typography.bodyLarge)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.primaryActionGradient)
                            .foregroundStyle(AppTheme.Colors.textOnPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Kişisel reçetemi aktifleştir ve 5. adıma geç")
                }
            }
            .padding(20)
        }
    }

    private func confidenceColor(_ level: DiagnosticConfidenceLevel) -> Color {
        switch level {
        case .high: return AppTheme.Colors.success
        case .medium: return AppTheme.Colors.warning
        case .low: return AppTheme.Colors.neutral500
        }
    }
}
