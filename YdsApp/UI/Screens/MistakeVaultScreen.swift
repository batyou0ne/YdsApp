import SwiftUI

/// Hata Kumbarası (Mistake Vault) Ekranı
/// Yanlış yapılan her soruyu `grammarRuleTag` ve `QuestionCategory` ile kaydeder,
/// Çeldirici Koçu notlarını gösterir ve kullanıcıya "+0.25 Puan Kurtarma Testi" sunar.
public struct MistakeVaultScreen: View {
    @ObservedObject private var viewModel: MistakeVaultViewModel

    public init(viewModel: MistakeVaultViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        let state = viewModel.state
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerSection(state: state)

                recoverableScoreBanner(state: state)

                categoryAndResolutionFilterBar(state: state)

                if let activeQuestion = state.activePracticeQuestion {
                    practiceReviewModalCard(state: state, question: activeQuestion)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                if state.filteredMistakes.isEmpty {
                    emptyVaultStateCard(state: state)
                } else {
                    VStack(spacing: 14) {
                        ForEach(state.filteredMistakes) { item in
                            mistakeVaultCard(state: state, item: item)
                        }
                    }
                }
            }
            .padding(18)
            .animation(.spring(response: 0.4, dampingFraction: 0.82), value: state.activePracticeQuestion?.id)
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
                reasonMessageTr: "Hata Kumbarasındaki tüm sınav tuzaklarını (trapReason) ve 5 saniyelik şık eleme kurallarını (winningRule) bulanıklık olmadan açmak için YDS Pro'ya geç.",
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

    // MARK: - 1. Üst Başlık ve Canlı Puan

    private func headerSection(state: MistakeVaultViewState) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "tray.full.fill")
                        .foregroundStyle(AppTheme.coralConjunction)
                    Text("Hata Kumbarası & Tuzak Arşivi")
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                Text("Yanlış yaptığın her soru dilbilgisi tuzağı etiketiyle kaydedilir; tekrar çözüp +0.25 puanını geri al.")
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

    // MARK: - 2. Kurtarılabilir Puan Banner'ı

    private func recoverableScoreBanner(state: MistakeVaultViewState) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.amberMainVerb.opacity(0.20))
                    .frame(width: 40, height: 40)
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .font(.title3)
                    .foregroundStyle(AppTheme.amberMainVerb)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(state.recoverableScorePointsText)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Açık Tuzak: \(state.unresolvedCount) • Çözülen Tuzak: \(state.resolvedCount)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()
        }
        .padding(14)
        .background(AppTheme.surfaceCard)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.amberMainVerb.opacity(0.40), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - 3. Kategori ve "Sadece Çözülmemişler" Filtre Çubuğu

    private func categoryAndResolutionFilterBar(state: MistakeVaultViewState) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    categoryChip(
                        title: "Tüm Kategoriler (\(state.allMistakes.count))",
                        isSelected: state.selectedCategoryFilter == nil,
                        action: { viewModel.onEvent(.selectCategoryFilter(nil)) }
                    )

                    ForEach(QuestionCategory.allCases, id: \.self) { category in
                        let count = state.allMistakes.filter { $0.category == category }.count
                        if count > 0 {
                            categoryChip(
                                title: "\(category.shortTitleTr) (\(count))",
                                isSelected: state.selectedCategoryFilter == category,
                                action: { viewModel.onEvent(.selectCategoryFilter(category)) }
                            )
                        }
                    }
                }
            }

            HStack {
                Button {
                    viewModel.onEvent(.toggleUnresolvedFilter)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: state.showOnlyUnresolved ? "checkmark.square.fill" : "square")
                            .foregroundStyle(state.showOnlyUnresolved ? AppTheme.emeraldSuccess : AppTheme.textSecondary)
                        Text("Sadece Çözülmemiş Hataları Göster")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
    }

    private func categoryChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.bold))
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

    // MARK: - 4. Canlı Kurtarma Testi Mini Kartı (activePracticeQuestion)

    private func practiceReviewModalCard(state: MistakeVaultViewState, question: SprintQuestion) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(AppTheme.amberMainVerb)
                    Text("KURAL KURTARMA TESTİ • +0.25 PUAN")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(AppTheme.amberMainVerb)
                }

                Spacer()

                Button {
                    viewModel.onEvent(.closePracticeModal)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Kapat")
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }

            Text(question.stemText)
                .font(.system(.subheadline, design: .serif).weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .lineSpacing(4)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.backgroundDark.opacity(0.65))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(spacing: 8) {
                ForEach(question.options) { option in
                    let isSelected = state.selectedPracticeOptionId == option.id
                    let isAnswered = state.selectedPracticeOptionId != nil
                    let isCorrect = option.id == question.correctOptionId

                    Button {
                        viewModel.onEvent(.submitPracticeOption(option.id))
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Text(option.id)
                                .font(.caption.weight(.heavy))
                                .frame(width: 26, height: 26)
                                .background(
                                    isAnswered
                                        ? (isCorrect ? AppTheme.emeraldSuccess : (isSelected ? AppTheme.coralConjunction : AppTheme.surfaceElevated))
                                        : AppTheme.surfaceElevated
                                )
                                .foregroundStyle(Color.white)
                                .clipShape(Circle())

                            Text(option.text)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(AppTheme.textPrimary)
                                .multilineTextAlignment(.leading)

                            Spacer()
                        }
                        .padding(12)
                        .background(AppTheme.backgroundDark.opacity(0.45))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isAnswered && isCorrect
                                        ? AppTheme.emeraldSuccess
                                        : (isAnswered && isSelected ? AppTheme.coralConjunction : AppTheme.borderSubtle),
                                    lineWidth: isAnswered && (isCorrect || isSelected) ? 2 : 1
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .disabled(isAnswered)
                }
            }

            if let feedbackBanner = state.practiceFeedbackBannerTr {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: state.isPracticeAnsweredCorrectly ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                        .foregroundStyle(state.isPracticeAnsweredCorrectly ? AppTheme.emeraldSuccess : AppTheme.coralConjunction)
                    Text(feedbackBanner)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                }
                .padding(12)
                .background(
                    (state.isPracticeAnsweredCorrectly ? AppTheme.emeraldSuccess : AppTheme.coralConjunction)
                        .opacity(0.18)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(18)
        .background(AppTheme.surfaceElevated)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.amberMainVerb, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - 5. Hata Kumbarası Kartları

    private func mistakeVaultCard(state: MistakeVaultViewState, item: MistakeVaultItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: item.category.iconName)
                            .font(.caption2)
                            .foregroundStyle(AppTheme.cyanMainSubject)
                        Text(item.category.shortTitleTr.uppercased())
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(AppTheme.cyanMainSubject)

                        Text("•")
                            .foregroundStyle(AppTheme.textMuted)

                        Text(item.grammarRuleTag)
                            .font(.system(size: 10, weight: .heavy, design: .monospaced))
                            .foregroundStyle(AppTheme.purplePreposition)
                    }

                    Text(item.grammarRuleTitleTr)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                }

                Spacer()

                if item.isResolved {
                    Text("ÇÖZÜLDÜ ✓")
                        .font(.system(size: 10, weight: .heavy))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppTheme.emeraldSuccess.opacity(0.22))
                        .foregroundStyle(AppTheme.emeraldSuccess)
                        .clipShape(Capsule())
                } else {
                    Text("\(item.failedCount)x Hata")
                        .font(.system(size: 10, weight: .heavy))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppTheme.coralConjunction.opacity(0.20))
                        .foregroundStyle(AppTheme.coralConjunction)
                        .clipShape(Capsule())
                }
            }

            Text("\"\(item.stemPreview)\"")
                .font(.caption.italic())
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(3)

            // Yanlış Seçilen Şık vs Doğru Şık
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("YANLIŞ ŞIK (\(item.selectedWrongOptionId))")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(AppTheme.coralConjunction)
                    Text(item.selectedWrongOptionText)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(2)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.coralConjunction.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text("DOĞRU ŞIK (\(item.correctOptionId))")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(AppTheme.emeraldSuccess)
                    Text(item.correctOptionText)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(2)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.emeraldSuccess.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // 🟢 Neyi Doğru Yakaladın? (Açık)
            HStack(alignment: .top, spacing: 8) {
                Text("🟢")
                    .font(.caption)
                Text(item.praiseTextTr)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.emeraldSuccess.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // ⚠️ Tuzak Nedeni & 🎯 Sınav Kısa Yolu (Free kullanıcıda .blur(radius: 6))
            ZStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Text("⚠️")
                            .font(.caption)
                        Text(item.trapReasonTr)
                            .font(.caption)
                            .foregroundStyle(AppTheme.textPrimary)
                    }

                    HStack(alignment: .top, spacing: 8) {
                        Text("🎯")
                            .font(.caption)
                        Text(item.winningRuleTr)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.amberMainVerb)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.backgroundDark.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .blur(radius: state.isDistractorBlurred ? 6 : 0)

                if state.isDistractorBlurred {
                    Button {
                        viewModel.onEvent(.openPaywall)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                            Text("Tuzağı ve Sınav Kısa Yolunu Aç (Pro)")
                                .font(.caption2.weight(.heavy))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppTheme.proCrownGradient)
                        .foregroundStyle(Color.white)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                viewModel.onEvent(.startMistakeReviewQuestion(item))
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: item.isResolved ? "arrow.clockwise.circle.fill" : "bolt.shield.fill")
                    Text(
                        item.isResolved
                            ? "Bu Kuralı Tekrar Pratik Et"
                            : "Bu Kuralı Şimdi Test Et (+0.25 Puan Kurtar)"
                    )
                    .font(.caption.weight(.bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    item.isResolved
                        ? AnyShapeStyle(AppTheme.surfaceElevated)
                        : AnyShapeStyle(AppTheme.primaryActionGradient)
                )
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(AppTheme.surfaceCard)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    item.isResolved ? AppTheme.emeraldSuccess.opacity(0.40) : AppTheme.borderSubtle,
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func emptyVaultStateCard(state: MistakeVaultViewState) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.largeTitle)
                .foregroundStyle(AppTheme.emeraldSuccess)
            Text("Bu Filtrede Açık Hata Bulunmuyor!")
                .font(.headline.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)
            Text("Mikro-Sprint veya Seviye Tespitinde yanlış yaptığın sorular otomatik olarak buraya eklenir.")
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(AppTheme.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct MistakeVaultScreen_Previews: PreviewProvider {
    static var previews: some View {
        MistakeVaultScreen(
            viewModel: MistakeVaultViewModel(container: AppDependencyContainer())
        )
    }
}
