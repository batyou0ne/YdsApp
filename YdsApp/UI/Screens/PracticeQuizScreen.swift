import SwiftUI

/// 5.3 Soru Çözme Ekranı (Practice Quiz Screen)
/// - Üstte kapat (X) + LinearProgress + soru sayacı
/// - Soru kartı (Beyaz, radius 24, shadow.card)
/// - A–E şık kartları (QuestionOptionTile: tam pill/radius 16)
/// - Anında pedagojik geri bildirim (Çeldirici analizi ve kazanım kuralı)
/// - Altta yüzen "Kontrol Et" / "Sonraki" PrimaryButton
public struct PracticeQuizScreen: View {
    @Environment(\.dismiss) private var dismiss

    public let questions: [GlowMockData.MockQuizQuestion]
    public let onFinishQuiz: (Int, Int, Int) -> Void // correct, wrong, total

    @State private var currentIndex: Int = 0
    @State private var selectedOptionIndex: Int? = nil
    @State private var isAnswerChecked: Bool = false
    @State private var correctAnswersCount: Int = 0
    @State private var wrongAnswersCount: Int = 0

    public init(
        questions: [GlowMockData.MockQuizQuestion] = GlowMockData.practiceQuestions,
        onFinishQuiz: @escaping (Int, Int, Int) -> Void
    ) {
        self.questions = questions
        self.onFinishQuiz = onFinishQuiz
    }

    private var currentQuestion: GlowMockData.MockQuizQuestion {
        guard currentIndex < questions.count else { return questions[0] }
        return questions[currentIndex]
    }

    private var progressFraction: Double {
        Double(currentIndex + 1) / Double(max(questions.count, 1))
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    // 1. Üst Bar: Kapat Butonu + Doğrusal İlerleme + Soru Sayacı
                    topHeaderView

                    // 2. Kategori & Akademik Alan Rozeti
                    academicTopicBadgeView

                    // 3. Soru Kartı
                    questionCardView

                    // 4. A-E Seçenek Kartları
                    optionsListView

                    // 5. Cevap Kontrol Edildikten Sonraki Pedagojik Açıklama (Çeldirici Tuzağı)
                    if isAnswerChecked {
                        explanationFeedbackCard
                    }

                    // Alt aksiyon butonunun altında kalmaması için boşluk
                    Spacer(minLength: 90)
                }
                .padding(.horizontal, AppTheme.Spacing.screenPadding)
                .padding(.top, 12)
            }

            // 6. Yüzen Alt Aksiyon Butonu
            floatingBottomActionButton
        }
        .background(AppTheme.Colors.appBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - 1. Üst Başlık & İlerleme
    private var topHeaderView: some View {
        HStack(spacing: AppTheme.Spacing.base) {
            CircleIconButton(
                iconSystemName: "xmark",
                iconSize: 16,
                action: { dismiss() }
            )

            VStack(spacing: 6) {
                LinearProgressBar(progressFraction: progressFraction, height: 6)

                HStack {
                    Text("Soru \(currentIndex + 1) / \(questions.count)")
                        .font(AppTheme.Typography.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.neutral500)

                    Spacer()

                    HStack(spacing: 8) {
                        Text("✓ \(correctAnswersCount)")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.success)
                            .fontWeight(.bold)

                        Text("✕ \(wrongAnswersCount)")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.error)
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }

    // MARK: - 2. Akademik Alan Rozeti
    private var academicTopicBadgeView: some View {
        HStack(spacing: 8) {
            Text(currentQuestion.grammarTopicTr)
                .font(AppTheme.Typography.caption)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.Colors.primary700)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppTheme.Colors.primary100)
                .clipShape(Capsule())

            Text(currentQuestion.academicDomainTr)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.neutral500)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.Colors.muted)
                .clipShape(Capsule())
        }
    }

    // MARK: - 3. Soru Kartı
    private var questionCardView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(currentQuestion.questionText)
                .font(AppTheme.Typography.bodyLarge)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.Colors.neutral900)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .glowShadow(AppTheme.Shadows.card)
    }

    // MARK: - 4. Seçenekler Listesi (A-E)
    private var optionsListView: some View {
        VStack(spacing: 10) {
            let letters = ["A", "B", "C", "D", "E"]
            ForEach(0..<currentQuestion.options.count, id: \.self) { index in
                let letter = letters[index]
                let optionText = currentQuestion.options[index]
                let tileState = resolveOptionState(for: index)

                QuestionOptionTile(
                    optionLetter: letter,
                    optionText: optionText,
                    tileState: tileState,
                    action: {
                        if !isAnswerChecked {
                            selectedOptionIndex = index
                        }
                    }
                )
            }
        }
    }

    private func resolveOptionState(for index: Int) -> OptionTileState {
        guard let selectedOptionIndex else { return .normal }

        if !isAnswerChecked {
            return selectedOptionIndex == index ? .selected : .normal
        }

        // Kontrol edildikten sonra:
        if index == currentQuestion.correctOptionIndex {
            return .correct
        } else if selectedOptionIndex == index && index != currentQuestion.correctOptionIndex {
            return .wrong
        } else {
            return .normal
        }
    }

    // MARK: - 5. Pedagojik Açıklama Kartı
    private var explanationFeedbackCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                let isCorrect = selectedOptionIndex == currentQuestion.correctOptionIndex
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(isCorrect ? AppTheme.Colors.success : AppTheme.Colors.error)

                Text(isCorrect ? "Tebrikler! Doğru Cevap" : "Dikkat: Çeldirici Tuzağı")
                    .font(AppTheme.Typography.bodyLarge)
                    .fontWeight(.bold)
                    .foregroundStyle(isCorrect ? AppTheme.Colors.success : AppTheme.Colors.error)
            }

            Text(currentQuestion.explanationTr)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundStyle(AppTheme.Colors.neutral900)
                .lineSpacing(3)

            VStack(alignment: .leading, spacing: 4) {
                Text("ÖSYM Çeldirici Analizi:")
                    .font(AppTheme.Typography.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.Colors.neutral500)

                Text(currentQuestion.distractorTrapTr)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.neutral700)
            }
            .padding(10)
            .background(AppTheme.Colors.muted)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(AppTheme.Spacing.base)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .glowShadow(AppTheme.Shadows.card)
    }

    // MARK: - 6. Yüzen Aksiyon Butonu
    private var floatingBottomActionButton: some View {
        VStack {
            if !isAnswerChecked {
                PrimaryButton(
                    title: "Kontrol Et",
                    iconSystemName: "checkmark",
                    height: 56,
                    action: {
                        guard selectedOptionIndex != nil else { return }
                        withAnimation(AppTheme.standardAnimation) {
                            isAnswerChecked = true
                            if selectedOptionIndex == currentQuestion.correctOptionIndex {
                                correctAnswersCount += 1
                            } else {
                                wrongAnswersCount += 1
                            }
                        }
                    }
                )
                .opacity(selectedOptionIndex != nil ? 1.0 : 0.6)
                .disabled(selectedOptionIndex == nil)
            } else {
                PrimaryButton(
                    title: currentIndex + 1 < questions.count ? "Sonraki Soru" : "Sonuçları Gör",
                    iconSystemName: "arrow.right",
                    height: 56,
                    action: {
                        withAnimation(AppTheme.standardAnimation) {
                            if currentIndex + 1 < questions.count {
                                currentIndex += 1
                                selectedOptionIndex = nil
                                isAnswerChecked = false
                            } else {
                                onFinishQuiz(correctAnswersCount, wrongAnswersCount, questions.count)
                            }
                        }
                    }
                )
            }
        }
        .padding(.horizontal, AppTheme.Spacing.screenPadding)
        .padding(.bottom, 16)
    }
}
