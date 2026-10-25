import SwiftUI

/// Mikro-Sprint Antrenman Ekranı:
/// 1. 10 Saniyede Çeviri Avı (.translation10SecHunt)
/// 2. Artı / Eksi Bağlaç Radarı (.conjunctionPolarityRadar)
/// 3. Akış Bozan Dedektifi (.irrelevantSentenceDetective)
/// 4. Cloze & Diyalog Hız Sprinti (.clozeAndDialogueSprint)
/// KURAL: Görünüm (View) içinde sayaç, puan veya freemium hesabı bulunmaz; yalnızca `viewModel.state` okunur ve `viewModel.onEvent(...)` çağrılır.
public struct MicroSprintScreen: View {
    @ObservedObject private var viewModel: MicroSprintViewModel

    public init(viewModel: MicroSprintViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        let state = viewModel.state
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerSection(state: state)

                sprintModeSelectorBar(state: state)

                trackFilterBar(state: state)

                if let question = state.currentQuestion {
                    liveTimerAndProgressCard(state: state, question: question)

                    questionStemAndClueCard(state: state, question: question)

                    if state.selectedMode == .conjunctionPolarityRadar {
                        conjunctionPolarityRadarBox(state: state)
                    }

                    optionsListSection(state: state, question: question)

                    if state.isQuestionSubmitted {
                        if state.isCurrentAnswerCorrect, let correctOption = state.currentSelectedOption {
                            correctAnswerCelebrationCard(option: correctOption)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        } else if let wrongOption = state.activeDistractorCoachOption {
                            DistractorCoachSheetView(
                                selectedWrongOption: wrongOption,
                                correctOption: question.correctOption,
                                category: question.category,
                                isDetailsBlurred: state.isDistractorDetailsBlurred,
                                onUnlockProCoach: {
                                    viewModel.onEvent(
                                        .openPaywall(
                                            "Düştüğün sınav tuzağını (\(wrongOption.distractorCoachFeedback.grammarRuleTag)) ve 5 saniyelik şık eleme kuralını bulanıklık olmadan açmak için YDS Pro'ya geç."
                                        )
                                    )
                                },
                                onContinueNextQuestion: {
                                    viewModel.onEvent(.dismissDistractorCoachAndAdvance)
                                }
                            )
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                }
            }
            .padding(18)
            .animation(.spring(response: 0.4, dampingFraction: 0.82), value: state.isQuestionSubmitted)
            .animation(.easeInOut(duration: 0.25), value: state.isStemBlurredExpectClues)
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
                reasonMessageTr: state.paywallReasonTr,
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

    // MARK: - 1. Üst Başlık ve Canlı Puan Özeti

    private func headerSection(state: MicroSprintViewState) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.badge.clock.fill")
                        .foregroundStyle(AppTheme.amberMainVerb)
                    Text("Mikro-Sprint Refleks Motoru")
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                Text(state.selectedMode.subtitleTr)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("TAHMİNİ PUAN")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(AppTheme.textSecondary)
                Text(state.formattedCurrentScore)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(AppTheme.emeraldSuccess)
                Text(state.formattedSessionDeltaText)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppTheme.cyanMainSubject)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppTheme.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 2. Mod Seçici Çubuk (4 Oynanabilir Sprint Modu)

    private func sprintModeSelectorBar(state: MicroSprintViewState) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(MicroSprintMode.playableModes, id: \.self) { mode in
                    let isSelected = state.selectedMode == mode
                    Button {
                        viewModel.onEvent(.selectSprintMode(mode))
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: mode.iconSystemName)
                                .font(.subheadline.weight(.bold))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mode.badgeTextTr)
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundStyle(isSelected ? AppTheme.amberMainVerb : AppTheme.textMuted)
                                Text(mode.titleTr)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(isSelected ? AppTheme.surfaceElevated : AppTheme.surfaceCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? AppTheme.amberMainVerb : AppTheme.borderSubtle, lineWidth: isSelected ? 1.5 : 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - 3. Akademik Alan Filtresi

    private func trackFilterBar(state: MicroSprintViewState) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(AcademicTrack.allCases, id: \.self) { track in
                    let isSelected = state.selectedTrack == track
                    Button {
                        viewModel.onEvent(.selectTrack(track))
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: track.iconSystemName)
                            Text(track.shortTitleTr)
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

    // MARK: - 4. Canlı Geri Sayım Çubuğu

    private func liveTimerAndProgressCard(state: MicroSprintViewState, question: SprintQuestion) -> some View {
        let timerColor: Color = state.isTimerUrgent
            ? AppTheme.coralConjunction
            : (state.remainingSeconds <= state.totalLimitSeconds / 2 ? AppTheme.amberMainVerb : AppTheme.emeraldSuccess)

        return VStack(spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: question.category.iconName)
                        .font(.caption)
                        .foregroundStyle(AppTheme.cyanMainSubject)
                    Text(question.category.shortTitleTr.uppercased())
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(AppTheme.cyanMainSubject)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppTheme.cyanMainSubject.opacity(0.16))
                .clipShape(Capsule())

                Text(state.progressPositionText)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.textSecondary)

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(timerColor)
                    Text("\(state.remainingSeconds) sn")
                        .font(.system(.subheadline, design: .monospaced).weight(.heavy))
                        .foregroundStyle(timerColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(timerColor.opacity(0.18))
                .clipShape(Capsule())
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.surfaceElevated)
                        .frame(height: 8)

                    Capsule()
                        .fill(timerColor)
                        .frame(width: max(6, geo.size.width * state.timerProgressFraction), height: 8)
                        .animation(.linear(duration: 0.9), value: state.remainingSeconds)
                }
            }
            .frame(height: 8)
        }
        .padding(14)
        .background(AppTheme.surfaceCard)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 5. Moda Özel Soru Kökü ve Parlayan İpuçları Kartı

    private func questionStemAndClueCard(state: MicroSprintViewState, question: SprintQuestion) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if state.selectedMode == .translation10SecHunt {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.horizontal.fill")
                            .foregroundStyle(AppTheme.amberMainVerb)
                        Text("10 SANİYE ÇEVİRİ AVI ODAK MODU")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(AppTheme.amberMainVerb)
                    }

                    Spacer()

                    Button {
                        viewModel.onEvent(.toggleTranslationBlurClueMode)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: state.isStemBlurredExpectClues ? "eye.fill" : "sparkles")
                            Text(state.isStemBlurredExpectClues ? "Tüm Cümleyi Göster" : "Sadece İpuçlarını Parlat")
                        }
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppTheme.surfaceElevated)
                        .foregroundStyle(AppTheme.cyanMainSubject)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            // Parçalı Soru Kökü Metni (10 Sn Çeviri Avı'nda standart kısımlar soluk, Ana Yüklem #F59E0B ve Bağlaç #EF4444 parlak!)
            buildHighlightedStemText(state: state)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)

            // Vurgulanan İpucu Rozetleri (Ana Yüklem / Bağlaç / Zamir Takibi / Konu Kayması / Edat)
            if !question.highlightedClues.isEmpty {
                Divider().overlay(AppTheme.borderSubtle)

                VStack(alignment: .leading, spacing: 8) {
                    Text(clueSectionHeadline(for: state.selectedMode))
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(AppTheme.textSecondary)

                    ForEach(question.highlightedClues) { clue in
                        let clueColor = AppTheme.clueColor(for: clue.clueType)
                        HStack(alignment: .top, spacing: 10) {
                            Text(clue.clueType.labelTr.uppercased())
                                .font(.system(size: 9, weight: .heavy))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(clueColor.opacity(0.22))
                                .foregroundStyle(clueColor)
                                .clipShape(Capsule())

                            VStack(alignment: .leading, spacing: 2) {
                                Text("\"\(clue.matchedSubstring)\"")
                                    .font(.caption.weight(.heavy))
                                    .foregroundStyle(clueColor)
                                Text(clue.explanationTr)
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer()
                        }
                        .padding(10)
                        .background(clueColor.opacity(0.09))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(clueColor.opacity(0.35), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding(18)
        .background(AppTheme.surfaceCard)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    state.selectedMode == .translation10SecHunt && state.isStemBlurredExpectClues
                        ? AppTheme.amberMainVerb.opacity(0.50)
                        : AppTheme.borderSubtle,
                    lineWidth: 1.5
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func buildHighlightedStemText(state: MicroSprintViewState) -> Text {
        let shouldDimNonClues = (state.selectedMode == .translation10SecHunt && state.isStemBlurredExpectClues)
        var combined = Text("")

        for fragment in state.currentStemFragments {
            if let clueType = fragment.clueType {
                let color = AppTheme.clueColor(for: clueType)
                combined = combined + Text(fragment.text)
                    .font(.system(.body, design: .serif).weight(.heavy))
                    .foregroundColor(color)
            } else {
                let plainColor = shouldDimNonClues
                    ? AppTheme.textMuted.opacity(0.35)
                    : AppTheme.textPrimary
                combined = combined + Text(fragment.text)
                    .font(.system(.body, design: .serif).weight(.medium))
                    .foregroundColor(plainColor)
            }
        }

        return combined
    }

    private func clueSectionHeadline(for mode: MicroSprintMode) -> String {
        switch mode {
        case .translation10SecHunt:
            return "PARLAYAN ÇEVİRİ EKLEMLERİ (ANA YÜKLEM #F59E0B & BAĞLAÇ #EF4444)"
        case .conjunctionPolarityRadar:
            return "KUTUP RADARI İPUÇLARI (SOL VE SAĞ CÜMLE YÖNÜ)"
        case .irrelevantSentenceDetective:
            return "DEDEKTİF İPUÇLARI (ZAMİR KÖPRÜSÜ & KONU KAYMASI)"
        case .clozeAndDialogueSprint, .diagnosticMiniTest:
            return "SINAV STRATEJİ İPUÇLARI"
        }
    }

    // MARK: - 6. Artı / Eksi Bağlaç Radarı Kutusu (.conjunctionPolarityRadar)

    private func conjunctionPolarityRadarBox(state: MicroSprintViewState) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "plus.forwardslash.minus")
                        .foregroundStyle(AppTheme.coralConjunction)
                    Text("1. ADIM: ARTI / EKSİ KUTUP RADARI")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(AppTheme.coralConjunction)
                }

                Spacer()

                if state.isPolarityRadarVerified {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                        Text("RADAR KİLİTLENDİ")
                    }
                    .font(.system(size: 10, weight: .heavy))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.emeraldSuccess.opacity(0.22))
                    .foregroundStyle(AppTheme.emeraldSuccess)
                    .clipShape(Capsule())
                }
            }

            HStack(spacing: 12) {
                // Sol Cümle Kutbu Seçici
                VStack(alignment: .leading, spacing: 6) {
                    Text("Sol Cümle Kutbu")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.textSecondary)

                    HStack(spacing: 6) {
                        ForEach(PolarityType.allCases, id: \.self) { polarity in
                            polaritySelectorButton(
                                polarity: polarity,
                                isSelected: state.selectedLeftPolarity == polarity,
                                action: { viewModel.onEvent(.selectLeftPolarity(polarity)) }
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(
                    systemName: state.isPolarityRadarVerified && state.selectedLeftPolarity != state.selectedRightPolarity
                        ? "arrow.left.arrow.right"
                        : "arrow.right.arrow.left"
                )
                .font(.headline.weight(.heavy))
                .foregroundStyle(state.isPolarityRadarVerified ? AppTheme.emeraldSuccess : AppTheme.textSecondary)

                // Sağ Cümle Kutbu Seçici
                VStack(alignment: .leading, spacing: 6) {
                    Text("Sağ Cümle Kutbu")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.textSecondary)

                    HStack(spacing: 6) {
                        ForEach(PolarityType.allCases, id: \.self) { polarity in
                            polaritySelectorButton(
                                polarity: polarity,
                                isSelected: state.selectedRightPolarity == polarity,
                                action: { viewModel.onEvent(.selectRightPolarity(polarity)) }
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text(state.polarityRadarStatusTextTr)
                .font(.caption.weight(.bold))
                .foregroundStyle(state.isPolarityRadarVerified ? AppTheme.emeraldSuccess : AppTheme.amberMainVerb)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    (state.isPolarityRadarVerified ? AppTheme.emeraldSuccess : AppTheme.amberMainVerb)
                        .opacity(0.14)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(16)
        .background(AppTheme.surfaceCard)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    state.isPolarityRadarVerified ? AppTheme.emeraldSuccess : AppTheme.coralConjunction.opacity(0.45),
                    lineWidth: state.isPolarityRadarVerified ? 2 : 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func polaritySelectorButton(
        polarity: PolarityType,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        let color: Color
        switch polarity {
        case .positive:
            color = AppTheme.emeraldSuccess
        case .negative:
            color = AppTheme.coralConjunction
        case .neutral:
            color = AppTheme.cyanMainSubject
        }

        return Button(action: action) {
            Text("[\(polarity.symbol)]")
                .font(.subheadline.weight(.heavy))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? color.opacity(0.28) : AppTheme.surfaceElevated)
                .foregroundStyle(isSelected ? color : AppTheme.textSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? color : AppTheme.borderSubtle, lineWidth: isSelected ? 1.5 : 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    // MARK: - 7. 5 Şıklı Seçenek Listesi (A..E)

    private func optionsListSection(state: MicroSprintViewState, question: SprintQuestion) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(question.options) { option in
                optionRowButton(state: state, question: question, option: option)
            }
        }
    }

    private func optionRowButton(
        state: MicroSprintViewState,
        question: SprintQuestion,
        option: QuestionOption
    ) -> some View {
        let isSelected = state.selectedOptionId == option.id
        let isCorrect = option.id == question.correctOptionId

        let borderColor: Color
        let badgeBackground: Color
        if state.isQuestionSubmitted {
            if isCorrect {
                borderColor = AppTheme.emeraldSuccess
                badgeBackground = AppTheme.emeraldSuccess
            } else if isSelected {
                borderColor = AppTheme.coralConjunction
                badgeBackground = AppTheme.coralConjunction
            } else {
                borderColor = AppTheme.borderSubtle
                badgeBackground = AppTheme.surfaceElevated
            }
        } else {
            borderColor = isSelected ? AppTheme.cyanMainSubject : AppTheme.borderSubtle
            badgeBackground = isSelected ? AppTheme.cyanMainSubject : AppTheme.surfaceElevated
        }

        return Button {
            viewModel.onEvent(.selectOption(option.id))
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Text(option.id)
                    .font(.subheadline.weight(.heavy))
                    .frame(width: 30, height: 30)
                    .background(badgeBackground)
                    .foregroundStyle(Color.white)
                    .clipShape(Circle())

                Text(option.text)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                if state.isQuestionSubmitted {
                    if isCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppTheme.emeraldSuccess)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppTheme.coralConjunction)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                state.isQuestionSubmitted && isCorrect
                    ? AppTheme.emeraldSuccess.opacity(0.12)
                    : (state.isQuestionSubmitted && isSelected ? AppTheme.coralConjunction.opacity(0.12) : AppTheme.surfaceCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: state.isQuestionSubmitted && (isCorrect || isSelected) ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .disabled(state.isQuestionSubmitted)
    }

    // MARK: - 8. Doğru Cevap Tebrik ve Kural Özeti Kartı

    private func correctAnswerCelebrationCard(option: QuestionOption) -> some View {
        let feedback = option.distractorCoachFeedback

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(AppTheme.emeraldSuccess)
                    Text("TAM İSABET! • +0.15 PUAN EKLENDİ")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(AppTheme.emeraldSuccess)
                }

                Spacer()

                Text(feedback.grammarRuleTag)
                    .font(.system(size: 9, weight: .heavy, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.emeraldSuccess.opacity(0.20))
                    .foregroundStyle(AppTheme.emeraldSuccess)
                    .clipShape(Capsule())
            }

            Text(feedback.praiseTextTr)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 8) {
                Text("🎯")
                Text(feedback.winningRuleTr)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.amberMainVerb)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.amberMainVerb.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Button {
                viewModel.onEvent(.nextQuestion)
            } label: {
                HStack(spacing: 8) {
                    Text("Sıradaki Sprint Sorusuna Geç")
                        .font(.subheadline.weight(.bold))
                    Image(systemName: "arrow.right.circle.fill")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.primaryActionGradient)
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(AppTheme.surfaceCard)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.emeraldSuccess.opacity(0.65), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct MicroSprintScreen_Previews: PreviewProvider {
    static var previews: some View {
        MicroSprintScreen(
            viewModel: MicroSprintViewModel(container: AppDependencyContainer())
        )
    }
}
