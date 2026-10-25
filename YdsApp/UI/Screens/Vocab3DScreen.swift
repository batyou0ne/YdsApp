import SwiftUI

/// 3 Boyutlu Kelime, Zorunlu Edat ve YDS İkizleri Antrenman Ekranı
/// KURAL: Görünüm (View) içinde 3 boyutlu ustalık (`isFullyLearned`) veya puan hesabı bulunmaz; yalnızca `viewModel.state` gözlemlenir ve `viewModel.onEvent(...)` tetiklenir.
public struct Vocab3DScreen: View {
    @ObservedObject private var viewModel: Vocab3DViewModel

    public init(viewModel: Vocab3DViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        let state = viewModel.state
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerSection(state: state)

                masterySummaryBanner(state: state)

                trackFilterBar(state: state)

                interactionModeSelector(state: state)

                if let card = state.currentCard {
                    switch state.interactionMode {
                    case .explore3DCard:
                        Vocab3DCardView(
                            card: card,
                            onSelectDimensionQuiz: { dimension in
                                viewModel.onEvent(.switchInteractionMode(.dimensionQuiz))
                                viewModel.onEvent(.selectDimensionTab(dimension))
                            }
                        )

                        Button {
                            viewModel.onEvent(.switchInteractionMode(.dimensionQuiz))
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.shield.fill")
                                Text("3 Boyutlu Ustalık Testine Geç (+0.15 Puan Kazan)")
                                    .font(.subheadline.weight(.bold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(AppTheme.primaryActionGradient)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)

                    case .dimensionQuiz:
                        dimensionQuizView(state: state, card: card)
                    }

                    cardNavigationFooter(state: state)
                }
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

    // MARK: - Subviews

    private func headerSection(state: Vocab3DViewState) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "cube.transparent.fill")
                        .foregroundStyle(AppTheme.purplePreposition)
                    Text("3 Boyutlu Kelime & Edat")
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                Text("1. Anlam • 2. Zorunlu Edat • 3. YDS İkizleri doğrulanmadan kelime öğrenildi sayılmaz.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("TAHMİNİ PUAN")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(AppTheme.textSecondary)
                Text(state.formattedCurrentScore)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(AppTheme.emeraldSuccess)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func masterySummaryBanner(state: Vocab3DViewState) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundStyle(AppTheme.emeraldSuccess)
            Text(state.masterySummaryBannerTr)
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Text(state.progressPositionText)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(12)
        .background(AppTheme.surfaceCard)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func trackFilterBar(state: Vocab3DViewState) -> some View {
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
                        .background(isSelected ? AppTheme.purplePreposition.opacity(0.24) : AppTheme.surfaceCard)
                        .foregroundStyle(isSelected ? AppTheme.purplePreposition : AppTheme.textSecondary)
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? AppTheme.purplePreposition : AppTheme.borderSubtle, lineWidth: 1)
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func interactionModeSelector(state: Vocab3DViewState) -> some View {
        HStack(spacing: 10) {
            ForEach(Vocab3DInteractionMode.allCases, id: \.self) { mode in
                let isSelected = state.interactionMode == mode
                Button {
                    viewModel.onEvent(.switchInteractionMode(mode))
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: mode.iconSystemName)
                        Text(mode.titleTr)
                            .font(.caption.weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isSelected ? AppTheme.cyanMainSubject.opacity(0.22) : AppTheme.surfaceCard)
                    .foregroundStyle(isSelected ? AppTheme.cyanMainSubject : AppTheme.textSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? AppTheme.cyanMainSubject : AppTheme.borderSubtle, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 3D Dimension Quiz View

    private func dimensionQuizView(state: Vocab3DViewState, card: Vocab3DCard) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Text(card.headword)
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(state.activeDimensionTab == .preposition ? "___" : card.mandatoryPreposition.uppercased())
                        .font(.caption.weight(.heavy))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.purplePreposition.opacity(0.22))
                        .foregroundStyle(AppTheme.purplePreposition)
                        .clipShape(Capsule())
                }

                Spacer()

                if card.isFullyLearned {
                    Text("TAM ÖĞRENİLDİ (3/3)")
                        .font(.system(size: 10, weight: .heavy))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppTheme.emeraldSuccess.opacity(0.22))
                        .foregroundStyle(AppTheme.emeraldSuccess)
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 8) {
                quizDimensionTabButton(
                    dimension: .meaning,
                    title: "1. Anlam",
                    isMastered: card.masteryProgress.isMeaningMastered,
                    isActive: state.activeDimensionTab == .meaning
                )
                quizDimensionTabButton(
                    dimension: .preposition,
                    title: "2. Edat",
                    isMastered: card.masteryProgress.isPrepositionMastered,
                    isActive: state.activeDimensionTab == .preposition
                )
                quizDimensionTabButton(
                    dimension: .synonym,
                    title: "3. YDS İkizi",
                    isMastered: card.masteryProgress.isSynonymMastered,
                    isActive: state.activeDimensionTab == .synonym
                )
            }

            if let quiz = state.currentQuizState {
                VStack(alignment: .leading, spacing: 14) {
                    Text(quiz.promptTitleTr.uppercased())
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(AppTheme.cyanMainSubject)

                    Text(quiz.promptStem)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 10) {
                        ForEach(quiz.options, id: \.self) { option in
                            quizOptionButton(quiz: quiz, option: option)
                        }
                    }
                }
                .padding(16)
                .background(AppTheme.backgroundDark.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            if let feedback = state.lastEvaluationFeedbackTr {
                HStack(alignment: .top, spacing: 10) {
                    Image(
                        systemName: state.currentQuizState?.isCorrect == true
                            ? "checkmark.seal.fill"
                            : "exclamationmark.triangle.fill"
                    )
                    .foregroundStyle(
                        state.currentQuizState?.isCorrect == true
                            ? AppTheme.emeraldSuccess
                            : AppTheme.coralConjunction
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        if let delta = state.lastEarnedScoreDeltaText {
                            Text("PUAN ARTIŞI: \(delta)")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundStyle(AppTheme.emeraldSuccess)
                        }
                        Text(feedback)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()
                }
                .padding(14)
                .background(
                    (state.currentQuizState?.isCorrect == true ? AppTheme.emeraldSuccess : AppTheme.coralConjunction)
                        .opacity(0.16)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            if state.currentQuizState?.isAnswered == true {
                Button {
                    viewModel.onEvent(.advanceToNextQuizOrCard)
                } label: {
                    HStack(spacing: 8) {
                        Text(
                            card.isFullyLearned
                                ? "Tam Öğrenildi! Sıradaki Kelimeye Geç"
                                : "Sıradaki Boyut Testine Geç"
                        )
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
        }
        .padding(18)
        .background(AppTheme.surfaceCard)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private func quizDimensionTabButton(
        dimension: VocabQuizDimension,
        title: String,
        isMastered: Bool,
        isActive: Bool
    ) -> some View {
        Button {
            viewModel.onEvent(.selectDimensionTab(dimension))
        } label: {
            HStack(spacing: 5) {
                Image(systemName: isMastered ? "checkmark.circle.fill" : "circle")
                    .font(.caption2)
                    .foregroundStyle(isMastered ? AppTheme.emeraldSuccess : AppTheme.textSecondary)
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isActive ? AppTheme.textPrimary : AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isActive ? AppTheme.surfaceElevated : AppTheme.backgroundDark.opacity(0.45))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isActive ? AppTheme.cyanMainSubject : AppTheme.borderSubtle, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private func quizOptionButton(quiz: Vocab3DQuizQuestionState, option: String) -> some View {
        let isSelected = quiz.selectedOption == option
        let isCorrectOption = option == quiz.correctOption

        let borderColor: Color
        let backgroundColor: Color
        if quiz.isAnswered {
            if isCorrectOption {
                borderColor = AppTheme.emeraldSuccess
                backgroundColor = AppTheme.emeraldSuccess.opacity(0.20)
            } else if isSelected {
                borderColor = AppTheme.coralConjunction
                backgroundColor = AppTheme.coralConjunction.opacity(0.20)
            } else {
                borderColor = AppTheme.borderSubtle
                backgroundColor = AppTheme.surfaceCard
            }
        } else {
            borderColor = isSelected ? AppTheme.cyanMainSubject : AppTheme.borderSubtle
            backgroundColor = AppTheme.surfaceCard
        }

        return Button {
            viewModel.onEvent(.selectQuizOption(option))
        } label: {
            HStack {
                Text(option)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer()

                if quiz.isAnswered {
                    if isCorrectOption {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppTheme.emeraldSuccess)
                    } else if isSelected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.coralConjunction)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: quiz.isAnswered && (isCorrectOption || isSelected) ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(quiz.isAnswered)
    }

    private func cardNavigationFooter(state: Vocab3DViewState) -> some View {
        HStack(spacing: 12) {
            Button {
                viewModel.onEvent(.previousCard)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Önceki Kelime")
                }
                .font(.caption.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.surfaceCard)
                .foregroundStyle(state.canGoPrevious ? AppTheme.textPrimary : AppTheme.textMuted)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(!state.canGoPrevious)

            Button {
                viewModel.onEvent(.nextCard)
            } label: {
                HStack(spacing: 6) {
                    Text("Sonraki Kelime")
                    Image(systemName: "chevron.right")
                }
                .font(.caption.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.surfaceCard)
                .foregroundStyle(state.canGoNext ? AppTheme.textPrimary : AppTheme.textMuted)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(!state.canGoNext)
        }
    }
}
