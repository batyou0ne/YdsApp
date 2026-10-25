import SwiftUI

/// İnteraktif Cümle Röntgeni (Sentence X-Ray) Ekranı
/// KURAL: Görünüm (View) içinde iş mantığı veya freemium hesabı bulunmaz; yalnızca `viewModel.state` gözlemlenir ve `viewModel.onEvent(...)` tetiklenir.
public struct SentenceXRayScreen: View {
    @ObservedObject private var viewModel: SentenceXRayViewModel

    public init(viewModel: SentenceXRayViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        let state = viewModel.state
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerSection(state: state)

                if let toast = state.scoreToastMessageTr {
                    scoreToastBanner(message: toast)
                }

                trackFilterBar(state: state)

                if let item = state.currentItem {
                    sentenceProgressAndToggleBar(state: state, item: item)

                    VStack(alignment: .leading, spacing: 16) {
                        XRayTokenFlowView(
                            item: item,
                            isXRayActive: state.isXRayActive,
                            selectedSegmentId: state.selectedSegment?.id,
                            onSelectSegment: { segmentId in
                                viewModel.onEvent(.selectSegment(segmentId))
                            }
                        )
                    }
                    .padding(18)
                    .background(AppTheme.surfaceCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                state.isXRayActive ? AppTheme.cyanMainSubject.opacity(0.55) : AppTheme.borderSubtle,
                                lineWidth: state.isXRayActive ? 1.5 : 1.0
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    if state.isXRayActive {
                        skeletonSummaryCard(item: item)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))

                        if let selectedSegment = state.selectedSegment {
                            examLogicCoachingCard(segment: selectedSegment)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }

                    fullTranslationSection(state: state, item: item)

                    navigationAndMasteryFooter(state: state)
                }
            }
            .padding(18)
            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: state.isXRayActive)
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

    private func headerSection(state: SentenceXRayViewState) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "waveform.path.ecg.rectangle.fill")
                            .foregroundStyle(AppTheme.cyanMainSubject)
                        Text("İnteraktif Cümle Röntgeni")
                            .font(.title3.weight(.heavy))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    Text("5 satırlık akademik cümlelerde yan cümlecikleri [ ... ] gizle, Özne ve Ana Yüklemi yakala.")
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

            HStack {
                HStack(spacing: 6) {
                    Image(systemName: state.profile.subscriptionTier.isPro ? "crown.fill" : "bolt.shield.fill")
                        .font(.caption2)
                        .foregroundStyle(state.profile.subscriptionTier.isPro ? AppTheme.proGold : AppTheme.amberMainVerb)
                    Text(state.freeXRayQuotaBadgeText)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(state.profile.subscriptionTier.isPro ? AppTheme.proGold : AppTheme.amberMainVerb)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    (state.profile.subscriptionTier.isPro ? AppTheme.proGold : AppTheme.amberMainVerb)
                        .opacity(0.15)
                )
                .clipShape(Capsule())

                Spacer()

                Text(state.progressPositionText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }

    private func scoreToastBanner(message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(AppTheme.emeraldSuccess)
            Text(message)
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
        }
        .padding(12)
        .background(AppTheme.emeraldSuccess.opacity(0.18))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppTheme.emeraldSuccess.opacity(0.45), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func trackFilterBar(state: SentenceXRayViewState) -> some View {
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

    private func sentenceProgressAndToggleBar(state: SentenceXRayViewState, item: SentenceXRayItem) -> some View {
        HStack {
            HStack(spacing: 4) {
                Text("Zorluk:")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= item.difficultyLevel ? "star.fill" : "star")
                        .font(.system(size: 10))
                        .foregroundStyle(star <= item.difficultyLevel ? AppTheme.amberMainVerb : AppTheme.textMuted)
                }
            }

            Spacer()

            Button {
                viewModel.onEvent(.toggleXRayMode)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: state.isXRayActive ? "eye.slash.fill" : "waveform.path.ecg")
                        .font(.subheadline.weight(.bold))
                    Text(state.isXRayActive ? "Röntgeni Kapat" : "Röntgeni Aç (X-Ray)")
                        .font(.subheadline.weight(.heavy))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    state.isXRayActive
                        ? AnyShapeStyle(AppTheme.surfaceElevated)
                        : AnyShapeStyle(AppTheme.primaryActionGradient)
                )
                .foregroundStyle(Color.white)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private func skeletonSummaryCard(item: SentenceXRayItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .foregroundStyle(AppTheme.amberMainVerb)
                    Text("ANA İSKELET ÇEVİRİSİ (YAN CÜMLECİKSİZ)")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(AppTheme.amberMainVerb)
                }

                Spacer()

                HStack(spacing: 6) {
                    polarityCapsule(label: "Sol", polarity: item.clausePolarityLeft)
                    Image(systemName: "arrow.left.and.right")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textSecondary)
                    polarityCapsule(label: "Sağ", polarity: item.clausePolarityRight)
                }
            }

            Text(item.skeletonSummaryTr)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(AppTheme.surfaceElevated)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.amberMainVerb.opacity(0.45), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func polarityCapsule(label: String, polarity: PolarityType) -> some View {
        let color: Color
        switch polarity {
        case .positive:
            color = AppTheme.emeraldSuccess
        case .negative:
            color = AppTheme.coralConjunction
        case .neutral:
            color = AppTheme.textSecondary
        }

        return Text("\(label): \(polarity.symbol)")
            .font(.system(size: 10, weight: .heavy))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.20))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private func examLogicCoachingCard(segment: SentenceSegment) -> some View {
        let roleColor = AppTheme.roleColor(for: segment.role)
        let tipText = segment.examLogicTipTr
            ?? "Bu parça cümlenin tamamlayıcı öğesidir. Çeviri sorularında önce Turkuaz (Özne) ve Kehribar (Ana Yüklem) parçalarını eşleştir."

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.max.fill")
                        .foregroundStyle(roleColor)
                    Text("SINAV MANTIĞI & ŞIK ELEME KISAYOLU")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(roleColor)
                }

                Spacer()

                Text(segment.role.titleTr)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(roleColor.opacity(0.18))
                    .foregroundStyle(roleColor)
                    .clipShape(Capsule())
            }

            Text("\"\(segment.text)\"")
                .font(.caption.italic().weight(.semibold))
                .foregroundStyle(AppTheme.textSecondary)

            Text(tipText)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.textPrimary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(AppTheme.surfaceCard)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(roleColor.opacity(0.55), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func fullTranslationSection(state: SentenceXRayViewState, item: SentenceXRayItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                viewModel.onEvent(.toggleFullTranslation)
            } label: {
                HStack {
                    Image(systemName: "character.book.closed.fill")
                        .foregroundStyle(AppTheme.purplePreposition)
                    Text(state.isTranslationVisible ? "Tam Akademik Türkçe Çeviriyi Gizle" : "Tam Akademik Türkçe Çeviriyi Göster")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Image(systemName: state.isTranslationVisible ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(14)
                .background(AppTheme.surfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)

            if state.isTranslationVisible {
                Text(item.fullTranslationTr)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(4)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.surfaceCard.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private func navigationAndMasteryFooter(state: SentenceXRayViewState) -> some View {
        VStack(spacing: 12) {
            Button {
                viewModel.onEvent(.markSentenceMastered)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: state.isCurrentSentenceMastered ? "checkmark.circle.fill" : "bolt.Badge.checkmark")
                    Text(
                        state.isCurrentSentenceMastered
                            ? "Bu Cümlenin İskeleti Karnene İşlendi (+0.08 Puan)"
                            : "Cümle İskeletini Çözdüm (+0.08 Puan Ekle)"
                    )
                    .font(.subheadline.weight(.bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    state.isCurrentSentenceMastered
                        ? AppTheme.emeraldSuccess.opacity(0.22)
                        : AppTheme.emeraldSuccess
                )
                .foregroundStyle(state.isCurrentSentenceMastered ? AppTheme.emeraldSuccess : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)

            HStack(spacing: 12) {
                Button {
                    viewModel.onEvent(.previousSentence)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Önceki Cümle")
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
                    viewModel.onEvent(.nextSentence)
                } label: {
                    HStack(spacing: 6) {
                        Text("Sonraki Cümle")
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
}
