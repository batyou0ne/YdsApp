import SwiftUI

/// "Neden Yanlış Yaptım?" Çeldirici Koçu Kartı & Sheet Bileşeni
/// PEDAGOJİK KURAL: Kullanıcı yanlış yaptığında ASLA sadece doğru şık harfi ve ham çeviri gösterilmez!
/// FREEMIUM KURALI: `isDetailsBlurred == true` ise `praiseTextTr` açık, `trapReasonTr` ve `winningRuleTr` `.blur(radius: 6)` ile kilitlidir.
public struct DistractorCoachSheetView: View {
    public let selectedWrongOption: QuestionOption
    public let correctOption: QuestionOption?
    public let category: QuestionCategory
    public let isDetailsBlurred: Bool
    public let onUnlockProCoach: () -> Void
    public let onContinueNextQuestion: () -> Void

    public init(
        selectedWrongOption: QuestionOption,
        correctOption: QuestionOption?,
        category: QuestionCategory,
        isDetailsBlurred: Bool,
        onUnlockProCoach: @escaping () -> Void,
        onContinueNextQuestion: @escaping () -> Void
    ) {
        self.selectedWrongOption = selectedWrongOption
        self.correctOption = correctOption
        self.category = category
        self.isDetailsBlurred = isDetailsBlurred
        self.onUnlockProCoach = onUnlockProCoach
        self.onContinueNextQuestion = onContinueNextQuestion
    }

    public var body: some View {
        let feedback = selectedWrongOption.distractorCoachFeedback

        VStack(alignment: .leading, spacing: 16) {
            // 1. Başlık ve Hata Kumbarası Kayıt Rozeti
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "brain.head.profile")
                            .foregroundStyle(AppTheme.amberMainVerb)
                        Text("NEDEN YANLIŞ YAPTIM? • ÇELDİRİCİ KOÇU")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(AppTheme.amberMainVerb)
                    }
                    Text("\(category.titleTr) Tuzak Analizi")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                }

                Spacer()

                Text(feedback.grammarRuleTag)
                    .font(.system(size: 9, weight: .heavy, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.purplePreposition.opacity(0.20))
                    .foregroundStyle(AppTheme.purplePreposition)
                    .clipShape(Capsule())
            }

            // 2. Seçilen Yanlış Şık <-> Doğru Şık Karşılaştırma Çubuğu
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("SEÇTİĞİN ÇELDİRİCİ (\(selectedWrongOption.id))")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(AppTheme.coralConjunction)
                    Text(selectedWrongOption.text)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(2)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.coralConjunction.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                if let correct = correctOption {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("DOĞRU ŞIK (\(correct.id))")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(AppTheme.emeraldSuccess)
                        Text(correct.text)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineLimit(2)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.emeraldSuccess.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            // 3. 🟢 Neyi Doğru Yakaladın? (praiseTextTr - Herkese Açık)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text("🟢 Neyi Doğru Yakaladın?")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(AppTheme.emeraldSuccess)
                    Spacer()
                    Text("AÇIK")
                        .font(.system(size: 9, weight: .heavy))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppTheme.emeraldSuccess.opacity(0.18))
                        .foregroundStyle(AppTheme.emeraldSuccess)
                        .clipShape(Capsule())
                }

                Text(feedback.praiseTextTr)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.emeraldSuccess.opacity(0.10))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppTheme.emeraldSuccess.opacity(0.35), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))

            // 4. ⚠️ Düştüğün Sınav Tuzağı (trapReasonTr) & 🎯 Sınav Kısa Yolu (winningRuleTr)
            // Free kullanıcıda .blur(radius: 6) ve üzerinde Pro Kilit Butonu yer alır!
            ZStack {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("⚠️ Düştüğün Sınav Tuzağı")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(AppTheme.coralConjunction)

                        Text(feedback.trapReasonTr)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.coralConjunction.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(AppTheme.coralConjunction.opacity(0.35), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 6) {
                        Text("🎯 Sınav Kısa Yolu")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(AppTheme.amberMainVerb)

                        Text(feedback.winningRuleTr)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.amberMainVerb.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(AppTheme.amberMainVerb.opacity(0.40), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .blur(radius: isDetailsBlurred ? 6 : 0)

                if isDetailsBlurred {
                    VStack(spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.shield.fill")
                                .foregroundStyle(AppTheme.proGold)
                            Text("PRO ÇELDİRİCİ KOÇU KİLİDİ")
                                .font(.caption2.weight(.heavy))
                                .foregroundStyle(AppTheme.proGold)
                        }

                        Text("Neden bu çeldiriciye düştüğünü ve 5 saniyelik şık eleme kuralını net gör.")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)

                        Button {
                            onUnlockProCoach()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "crown.fill")
                                Text("Tuzağı ve Sınav Kısa Yolunu Aç (Pro)")
                                    .font(.caption.weight(.heavy))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(AppTheme.proCrownGradient)
                            .foregroundStyle(Color.white)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)
                    .background(AppTheme.backgroundDark.opacity(0.88))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.proGold.opacity(0.55), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }

            // 5. 📥 Hata Kumbarası Kayıt Bildirimi
            HStack(spacing: 10) {
                Text("📥")
                    .font(.subheadline)
                Text("Bu kural (\(feedback.grammarRuleTag)) Hata Kumbarana eklendi, hafta sonu tekrar sınanacaksın.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.cyanMainSubject)
                Spacer()
            }
            .padding(12)
            .background(AppTheme.cyanMainSubject.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // 6. Sıradaki Soruya Geç Aksiyonu
            Button {
                onContinueNextQuestion()
            } label: {
                HStack(spacing: 8) {
                    Text("Anladım, Sıradaki Sprint Sorusuna Geç")
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
                .stroke(AppTheme.coralConjunction.opacity(0.50), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct DistractorCoachSheetView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleQuestion = SprintQuestionSeedData.translationHuntQuestions[0]
        DistractorCoachSheetView(
            selectedWrongOption: sampleQuestion.options[0],
            correctOption: sampleQuestion.correctOption,
            category: sampleQuestion.category,
            isDetailsBlurred: true,
            onUnlockProCoach: {},
            onContinueNextQuestion: {}
        )
        .padding()
        .background(AppTheme.backgroundDark)
    }
}
