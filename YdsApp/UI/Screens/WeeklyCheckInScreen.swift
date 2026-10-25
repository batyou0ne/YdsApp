import SwiftUI

/// Haftalık Check-In (15 Soru • 20 Dakika) Mini Deneme Ekranı
/// Gerçek sınav kuralları: Süre sayacı, soru paleti ızgarası, anında geri bildirim yok, bitişte Soru Tipi Karnesi ve Çeldirici Koçu.
public struct WeeklyCheckInScreen: View {
    @ObservedObject private var viewModel: WeeklyCheckInViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: WeeklyCheckInViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        let state = viewModel.state

        ZStack {
            AppTheme.Colors.appBackground.ignoresSafeArea()

            switch state.phase {
            case .intro:
                introView(state: state)

            case .inProgress:
                inProgressView(state: state)

            case .report, .review:
                if let report = state.report {
                    reportView(report: report, state: state)
                } else {
                    ProgressView("Rapor hazırlanıyor...")
                }
            }
        }
        .sheet(
            isPresented: Binding(
                get: { viewModel.state.activeDistractorQuestion != nil },
                set: { if !$0 { viewModel.onEvent(.dismissMistakeCoach) } }
            )
        ) {
            if let question = viewModel.state.activeDistractorQuestion,
               let wrongOpt = viewModel.state.activeDistractorWrongOption {
                DistractorCoachSheetView(
                    selectedWrongOption: wrongOpt,
                    correctOption: question.correctOption,
                    category: question.category,
                    isDetailsBlurred: viewModel.state.isPaywallBlurActive,
                    onUnlockProCoach: {
                        viewModel.onEvent(.dismissMistakeCoach)
                        viewModel.onEvent(.openPaywall(reasonTr: "Çeldirici Koçunun tuzak kuralı ve stratejik çözüm adımlarını açmak için Pro'ya geç."))
                    },
                    onContinueNextQuestion: {
                        viewModel.onEvent(.dismissMistakeCoach)
                    }
                )
            }
        }
        .sheet(
            isPresented: Binding(
                get: { viewModel.state.isPaywallSheetPresented },
                set: { if !$0 { viewModel.onEvent(.dismissPaywall) } }
            )
        ) {
            StrategicPaywallSheetView(
                reasonMessageTr: viewModel.state.paywallTriggerReasonTr,
                currentScoreText: String(format: "%.2f", viewModel.state.report?.scoreAfter ?? 53.75),
                targetScoreText: "70.00",
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
        .onChange(of: viewModel.state.isDismissed) { isDismissed in
            if isDismissed {
                dismiss()
            }
        }
    }

    // MARK: - 1. Intro Ekranı
    private func introView(state: WeeklyCheckInViewState) -> some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Tepe rozet & Kapat
                HStack {
                    Button {
                        viewModel.onEvent(.dismiss)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.neutral700)
                            .padding(10)
                            .background(AppTheme.Colors.surface)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundStyle(AppTheme.Colors.primary700)
                        Text("HAFTALIK MİNİ DENEME")
                            .font(AppTheme.Typography.caption)
                            .fontWeight(.heavy)
                            .foregroundStyle(AppTheme.Colors.primary700)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.Colors.primary100)
                    .clipShape(Capsule())
                }

                // Başlık & Slogan
                VStack(spacing: 8) {
                    Text("Haftalık Check-In")
                        .font(AppTheme.Typography.display)
                        .foregroundStyle(AppTheme.Colors.neutral900)

                    Text("Bu haftaki çalışmaların sınav puanını artırdı mı?")
                        .font(AppTheme.Typography.bodyLarge)
                        .foregroundStyle(AppTheme.Colors.primary700)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)

                // Kural Özeti Kartı
                VStack(alignment: .leading, spacing: 14) {
                    Text("Gerçek Sınav Kuralları")
                        .font(AppTheme.Typography.titleMedium)
                        .foregroundStyle(AppTheme.Colors.neutral900)

                    ruleRow(
                        icon: "list.number",
                        title: "15 Stratejik Soru",
                        subtitle: "YDS/YÖKDİL soru dağılımına tam oranlı: Kelime, Edat, Bağlaç, Tense, Çeviri, Cümle Tamamlama, Cloze ve Paragraf."
                    )
                    ruleRow(
                        icon: "timer",
                        title: "20 Dakika Toplam Süre",
                        subtitle: "Soru başına ~80 saniye. İstediğin soruya geri dönebilir, şıkkını değiştirebilir veya boş bırakabilirsin."
                    )
                    ruleRow(
                        icon: "eye.slash.fill",
                        title: "Anında Geri Bildirim Yok",
                        subtitle: "Gerçek sınav refleksini ölçmek için doğru/yanlış cevaplar yalnızca sınav bitiminde detaylı karne ile gösterilir."
                    )
                    ruleRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Canlı Tahmini Puan Kalibrasyonu",
                        subtitle: "Sonucun, mevcut tahmini sınav puanını doğrudan kalibre eder ve güven aralığını daraltır."
                    )
                }
                .padding(18)
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                .glowShadow(AppTheme.Shadows.card)

                Spacer(minLength: 24)

                // Başlat Butonu
                Button {
                    viewModel.onEvent(.start)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Check-In'i Başlat (20 Dk)")
                            .font(AppTheme.Typography.bodyLarge)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.primaryActionGradient)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.pill))
                    .glowShadow(AppTheme.Shadows.soft)
                }
                .buttonStyle(.plain)
            }
            .padding(AppTheme.Spacing.screenPadding)
        }
    }

    private func ruleRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppTheme.Colors.primary700)
                .frame(width: 28, height: 28)
                .background(AppTheme.Colors.primary100)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.Typography.bodyMedium)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.Colors.neutral900)
                Text(subtitle)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.neutral500)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - 2. Soru Çözüm Ekranı
    private func inProgressView(state: WeeklyCheckInViewState) -> some View {
        VStack(spacing: 0) {
            // Tepe Çubuğu: Sayaç + Soru No + Bitir
            HStack {
                Button {
                    viewModel.onEvent(.dismiss)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.neutral700)
                        .padding(8)
                        .background(AppTheme.Colors.surface)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                // Sayaç
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .foregroundStyle(state.isTimeCritical ? AppTheme.Colors.error : AppTheme.Colors.primary700)
                    Text(state.formattedTimer)
                        .font(AppTheme.Typography.numeric)
                        .foregroundStyle(state.isTimeCritical ? AppTheme.Colors.error : AppTheme.Colors.neutral900)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(state.isTimeCritical ? AppTheme.Colors.error.opacity(0.12) : AppTheme.Colors.surface)
                .clipShape(Capsule())

                Spacer()

                Button {
                    viewModel.onEvent(.submitAll)
                } label: {
                    Text("Bitir")
                        .font(AppTheme.Typography.label)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.Colors.error)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.Colors.error.opacity(0.12))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppTheme.Spacing.base)
            .padding(.top, 10)
            .padding(.bottom, 8)

            // Soru Paleti Izgarası (1..15)
            questionPaletteBar(state: state)
                .padding(.bottom, 10)

            Divider()
                .background(AppTheme.Colors.neutral300)

            // Aktif Soru İçeriği
            if let question = state.currentQuestion {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Kategori & Zorluk Etiketleri
                        HStack(spacing: 8) {
                            Text(question.category.titleTr)
                                .font(AppTheme.Typography.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.Colors.primary700)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(AppTheme.Colors.primary100)
                                .clipShape(Capsule())

                            Text(question.difficultyBand.titleTr)
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.neutral500)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.Colors.muted)
                                .clipShape(Capsule())

                            Spacer()

                            if state.isCurrentFlagged {
                                HStack(spacing: 4) {
                                    Image(systemName: "flag.fill")
                                    Text("İşaretli")
                                }
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.warning)
                            }
                        }

                        // Soru Kökü
                        Text(question.stemText)
                            .font(AppTheme.Typography.bodyLarge)
                            .foregroundStyle(AppTheme.Colors.neutral900)
                            .lineSpacing(6)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.Colors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                            .glowShadow(AppTheme.Shadows.card)

                        // 5 Şıklı Seçenekler
                        VStack(spacing: 10) {
                            ForEach(question.options) { option in
                                let isSelected = state.selectedAnswers[question.id] == option.id
                                QuestionOptionTile(
                                    optionLetter: option.id,
                                    optionText: option.text,
                                    tileState: isSelected ? .selected : .normal,
                                    action: {
                                        viewModel.onEvent(.selectOption(questionId: question.id, optionId: option.id))
                                    }
                                )
                            }
                        }
                    }
                    .padding(AppTheme.Spacing.base)
                }
            } else {
                Spacer()
                Text("Soru yükleniyor...")
                    .foregroundStyle(AppTheme.Colors.neutral500)
                Spacer()
            }

            // Alt Gezinme & Aksiyon Çubuğu
            bottomControlBar(state: state)
        }
    }

    // Soru Paleti (1..15)
    private func questionPaletteBar(state: WeeklyCheckInViewState) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<state.questions.count, id: \.self) { idx in
                    let q = state.questions[idx]
                    let isCurrent = idx == state.currentQuestionIndex
                    let isAnswered = (state.selectedAnswers[q.id]?.isEmpty == false)
                    let isFlagged = state.flaggedQuestionIds.contains(q.id)

                    Button {
                        viewModel.onEvent(.jumpToQuestion(index: idx))
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Text("\(idx + 1)")
                                .font(AppTheme.Typography.label)
                                .fontWeight(isCurrent ? .heavy : .semibold)
                                .frame(width: 36, height: 36)
                                .background(
                                    isAnswered
                                        ? AppTheme.Colors.primary500
                                        : (isCurrent ? AppTheme.Colors.primary100 : AppTheme.Colors.surface)
                                )
                                .foregroundStyle(
                                    isAnswered ? Color.white : (isCurrent ? AppTheme.Colors.primary700 : AppTheme.Colors.neutral700)
                                )
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isCurrent ? AppTheme.Colors.primary700 : AppTheme.Colors.neutral300,
                                            lineWidth: isCurrent ? 2 : 1
                                        )
                                )

                            if isFlagged {
                                Circle()
                                    .fill(AppTheme.Colors.warning)
                                    .frame(width: 9, height: 9)
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.base)
        }
    }

    // Alt Gezinme Çubuğu
    private func bottomControlBar(state: WeeklyCheckInViewState) -> some View {
        HStack(spacing: 12) {
            // Önceki
            Button {
                viewModel.onEvent(.previousQuestion)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Önceki")
                }
                .font(AppTheme.Typography.bodyMedium)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(AppTheme.Colors.surface)
                .foregroundStyle(state.canGoPrevious ? AppTheme.Colors.neutral900 : AppTheme.Colors.neutral300)
                .clipShape(Capsule())
            }
            .disabled(!state.canGoPrevious)
            .buttonStyle(.plain)

            // Boş Bırak
            if let current = state.currentQuestion, state.selectedAnswers[current.id] != nil {
                Button {
                    viewModel.onEvent(.leaveBlank(questionId: current.id))
                } label: {
                    Text("Boş Bırak")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.neutral500)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }

            // İşaretle / Kaldır (Flag)
            if let current = state.currentQuestion {
                Button {
                    viewModel.onEvent(.flagQuestion(questionId: current.id))
                } label: {
                    Image(systemName: state.isCurrentFlagged ? "flag.fill" : "flag")
                        .font(.system(size: 16))
                        .foregroundStyle(state.isCurrentFlagged ? AppTheme.Colors.warning : AppTheme.Colors.neutral500)
                        .padding(12)
                        .background(AppTheme.Colors.surface)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            Spacer()

            // Sonraki veya Sınavı Bitir
            if state.canGoNext {
                Button {
                    viewModel.onEvent(.nextQuestion)
                } label: {
                    HStack(spacing: 4) {
                        Text("Sonraki")
                        Image(systemName: "chevron.right")
                    }
                    .font(AppTheme.Typography.bodyMedium)
                    .fontWeight(.bold)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(AppTheme.Colors.neutral900)
                    .foregroundStyle(Color.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    viewModel.onEvent(.submitAll)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Sınavı Bitir")
                    }
                    .font(AppTheme.Typography.bodyMedium)
                    .fontWeight(.bold)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(AppTheme.Colors.success)
                    .foregroundStyle(Color.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.base)
        .padding(.vertical, 10)
        .background(AppTheme.Colors.surface)
    }

    // MARK: - 3. Rapor Ekranı
    private func reportView(report: CheckInReport, state: WeeklyCheckInViewState) -> some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Tepe Kapat
                HStack {
                    Spacer()
                    Button {
                        viewModel.onEvent(.dismiss)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.neutral700)
                            .padding(10)
                            .background(AppTheme.Colors.surface)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                // 1. Canlı Puan Değişim Hero Kartı (Sade, asil vurgu)
                VStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "waveform.path.ecg")
                            .foregroundStyle(AppTheme.Colors.primary700)
                        Text("HAFTALIK PUAN KALİBRASYONU")
                            .font(AppTheme.Typography.caption)
                            .fontWeight(.heavy)
                            .foregroundStyle(AppTheme.Colors.primary700)
                    }

                    Text(report.scoreTransitionDisplayTr)
                        .font(AppTheme.Typography.display)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.Colors.neutral900)

                    HStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Text("Ölçülen Deneme")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.neutral500)
                            Text("\(report.formattedMeasuredScoreTr) puan")
                                .font(AppTheme.Typography.bodyMedium)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.Colors.neutral700)
                        }

                        Divider().frame(height: 24)

                        VStack(spacing: 2) {
                            Text("Güven Aralığı")
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.neutral500)
                            Text(report.formattedConfidenceIntervalTr)
                                .font(AppTheme.Typography.bodyMedium)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.Colors.neutral700)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                .glowShadow(AppTheme.Shadows.card)

                // 2. Doğru / Yanlış / Boş / Süre Satırı
                HStack(spacing: 10) {
                    statPill(title: "Doğru", value: "\(report.correctCount)", color: AppTheme.Colors.success)
                    statPill(title: "Yanlış", value: "\(report.wrongCount)", color: AppTheme.Colors.error)
                    statPill(title: "Boş", value: "\(report.blankCount)", color: AppTheme.Colors.neutral500)
                    statPill(title: "Süre", value: report.timeSpentFormatted, color: AppTheme.Colors.primary700)
                }

                // 3. Stratejik Odak Önerisi Kartı
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(AppTheme.Colors.warning)
                        Text("Gelecek Hafta Stratejisi")
                            .font(AppTheme.Typography.titleMedium)
                            .foregroundStyle(AppTheme.Colors.neutral900)
                    }

                    Text(report.nextWeekFocusRecommendationTr)
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundStyle(AppTheme.Colors.neutral700)
                        .lineSpacing(4)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                .glowShadow(AppTheme.Shadows.card)

                // 4. Kategori Karnesi (Freemium Blur ile)
                categoryScorecardSection(report: report, state: state)

                // 5. Yanlışları İncele Butonu (Çeldirici Koçu)
                if report.wrongCount > 0 || report.blankCount > 0 {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Neden Yanlış Yaptım? • Çeldirici Koçu")
                            .font(AppTheme.Typography.titleMedium)
                            .foregroundStyle(AppTheme.Colors.neutral900)

                        Text("Yanlış veya boş bıraktığın sorular Hata Kumbarana kaydedildi. Sınav tuzaklarını ve kazanım kurallarını tek dokunuşla incele.")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.neutral500)

                        ForEach(state.questions.filter { q in
                            let ans = state.selectedAnswers[q.id]
                            return ans == nil || ans != q.correctOptionId
                        }) { q in
                            Button {
                                viewModel.onEvent(.openMistakeCoach(questionId: q.id))
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(q.category.titleTr)
                                            .font(AppTheme.Typography.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(AppTheme.Colors.error)
                                        Text(q.stemText.prefix(80) + "...")
                                            .font(AppTheme.Typography.bodyMedium)
                                            .foregroundStyle(AppTheme.Colors.neutral900)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.Colors.neutral500)
                                }
                                .padding(12)
                                .background(AppTheme.Colors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppTheme.Colors.neutral300, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(18)
                    .background(AppTheme.Colors.muted)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                }

                // Kapat Butonu
                Button {
                    viewModel.onEvent(.dismiss)
                } label: {
                    Text("Dashboard'a Dön")
                        .font(AppTheme.Typography.bodyLarge)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.Colors.neutral900)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.pill))
                }
                .buttonStyle(.plain)
            }
            .padding(AppTheme.Spacing.screenPadding)
        }
    }

    private func statPill(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(AppTheme.Typography.titleMedium)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.neutral500)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .glowShadow(AppTheme.Shadows.card)
    }

    private func categoryScorecardSection(report: CheckInReport, state: WeeklyCheckInViewState) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Soru Tipi Karnesi")
                    .font(AppTheme.Typography.titleMedium)
                    .foregroundStyle(AppTheme.Colors.neutral900)

                Spacer()

                if state.isPaywallBlurActive {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                        Text("PRO KİLİTLİ")
                    }
                    .font(AppTheme.Typography.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.Colors.primary700)
                }
            }

            ZStack {
                VStack(spacing: 10) {
                    ForEach(report.categoryReports) { catReport in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(catReport.category.shortTitleTr)
                                    .font(AppTheme.Typography.bodyMedium)
                                    .fontWeight(.bold)
                                    .foregroundStyle(AppTheme.Colors.neutral900)
                                Text("\(catReport.correctCount) / \(catReport.totalQuestions) Doğru")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundStyle(AppTheme.Colors.neutral500)
                            }

                            Spacer()

                            Text(catReport.formattedEarnedPointsTr)
                                .font(AppTheme.Typography.label)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    catReport.accuracyRatio >= 0.6 ? AppTheme.Colors.success : AppTheme.Colors.error
                                )
                        }
                        .padding(12)
                        .background(AppTheme.Colors.muted)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .blur(radius: state.isPaywallBlurActive ? 6 : 0)

                if state.isPaywallBlurActive {
                    VStack(spacing: 10) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(AppTheme.Colors.primary700)
                        Text("Soru Tipi Karnesi ve Tuzak Analizi Pro'ya Özeldir")
                            .font(AppTheme.Typography.bodyMedium)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.Colors.neutral900)
                            .multilineTextAlignment(.center)

                        Button {
                            viewModel.onEvent(.openPaywall(reasonTr: "Soru tipi karnesi, kategori deltaları ve Çeldirici Koçu kural detaylarını açmak için Pro'ya geç."))
                        } label: {
                            Text("Pro'ya Geç ve Analizi Aç")
                                .font(AppTheme.Typography.label)
                                .fontWeight(.bold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppTheme.primaryActionGradient)
                                .foregroundStyle(Color.white)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                    .background(AppTheme.Colors.surface.opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                    .glowShadow(AppTheme.Shadows.card)
                }
            }
        }
        .padding(18)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .glowShadow(AppTheme.Shadows.card)
    }
}
