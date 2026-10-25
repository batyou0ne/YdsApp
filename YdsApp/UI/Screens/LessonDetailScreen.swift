import SwiftUI

/// 5.2 Ders/Konu Detayı (Glow Nature Referans Sağ Ekran)
/// - Üst bar (Geri butonu, ortalanmış "Detay", sağda kaydet ikonu)
/// - Büyük Hero görsel (Radius 24, botanik/eğitim illüstrasyonu) + nokta göstergesi
/// - Gri kategori etiketi ("Gramer")
/// - Konu başlığı + sağda 32px kalp butonu
/// - Eğitmen satırı (Yeşil kare logo, isim + onay rozeti, "Resmî içerik" alt etiketi, sağda siyah "Takip Ediliyor" pill)
/// - "Zorluk Seç" chip'leri + sağda "Soru Sayısı" stepper
/// - "Açıklama" başlığı ve metin
/// - Yüzen alt bar ("Tahmini süre 25 dk" + "Derse Başla" PrimaryButton)
public struct LessonDetailScreen: View {
    @Environment(\.dismiss) private var dismiss
    public let lesson: LessonItem
    public let onStartPractice: (LessonItem, LessonDifficulty, Int) -> Void

    @State private var selectedDifficulty: LessonDifficulty
    @State private var questionCount: Int
    @State private var isBookmarked: Bool
    @State private var isFollowingInstructor: Bool
    @State private var activeImageIndex: Int = 0

    public init(
        lesson: LessonItem,
        onStartPractice: @escaping (LessonItem, LessonDifficulty, Int) -> Void
    ) {
        self.lesson = lesson
        self.onStartPractice = onStartPractice
        self._selectedDifficulty = State(initialValue: lesson.difficulty)
        self._questionCount = State(initialValue: lesson.questionCount)
        self._isBookmarked = State(initialValue: lesson.isBookmarked)
        self._isFollowingInstructor = State(initialValue: lesson.isFollowingInstructor)
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Kaydırılabilir İçerik
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    // 1. Üst Bar: Geri Butonu + "Detay" Başlığı + Kaydet Butonu
                    topBarView

                    // 2. Büyük Hero Görsel Kartı + Sayfa Nokta Göstergesi
                    heroVisualView

                    // 3. Kategori, Başlık ve Kalp Butonu Satırı
                    titleAndBookmarkRow

                    // 4. Eğitmen / Kaynak Satırı (Yeşil Logo + İsim + Onay Rozeti + Takip Ediliyor Butonu)
                    instructorRowView

                    // 5. Zorluk Seçimi (Chip'ler) ve Soru Sayısı Stepper'ı
                    difficultyAndStepperRow

                    // 6. Açıklama ve Sınav Taktikleri Bölümü
                    descriptionSectionView

                    // Alt aksiyon çubuğunun altında kaybolmaması için güvenlik payı
                    Spacer(minLength: 110)
                }
                .padding(.horizontal, AppTheme.Spacing.screenPadding)
                .padding(.top, 12)
            }

            // 7. Yüzen Alt Aksiyon Çubuğu (BottomActionBar)
            BottomActionBar(
                label: "Tahmini süre",
                value: "\(lesson.durationMinutes) dk",
                buttonTitle: "Derse Başla",
                buttonIcon: "play.fill",
                onButtonTapped: {
                    onStartPractice(lesson, selectedDifficulty, questionCount)
                }
            )
        }
        .background(AppTheme.Colors.appBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - 1. Üst Bar
    private var topBarView: some View {
        HStack {
            CircleIconButton(
                iconSystemName: "chevron.left",
                iconSize: 18,
                action: { dismiss() }
            )

            Spacer()

            Text("Detay")
                .font(AppTheme.Typography.titleLarge)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.neutral900)

            Spacer()

            CircleIconButton(
                iconSystemName: isBookmarked ? "bookmark.fill" : "bookmark",
                iconSize: 18,
                tintColor: isBookmarked ? AppTheme.Colors.primary700 : AppTheme.Colors.neutral900,
                action: {
                    isBookmarked.toggle()
                }
            )
        }
    }

    // MARK: - 2. Büyük Hero Görseli & İndikatör
    private var heroVisualView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .fill(AppTheme.Colors.muted)
                    .frame(height: 260)

                // Organik Kaide ve Botanik İllüstrasyon (Glow Nature Referans Şişesi)
                AcademicBotanicalIllustrationView(style: .detailHero, height: 240)
                    .padding(.top, 10)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
            .glowShadow(AppTheme.Shadows.card)

            // Görsel Altında Sayfa Nokta Göstergesi (Aktif siyah uzun pill, pasif gri nokta)
            ImageIndicator(count: 3, activeIndex: activeImageIndex)
        }
    }

    // MARK: - 3. Başlık & Kalp Satırı
    private var titleAndBookmarkRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Kategori Etiketi
            Text(lesson.category.titleTr)
                .font(AppTheme.Typography.caption)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.Colors.neutral500)

            // Başlık + Favori Kalp Butonu
            HStack(alignment: .top) {
                Text(lesson.title)
                    .font(AppTheme.Typography.titleLarge)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.Colors.neutral900)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    isBookmarked.toggle()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                            .glowShadow(AppTheme.Shadows.soft)

                        Image(systemName: isBookmarked ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(isBookmarked ? AppTheme.Colors.error : AppTheme.Colors.neutral700)
                            .scaleEffect(isBookmarked ? 1.2 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: isBookmarked)
                    }
                }
                .bouncyPressEffect()
            }
        }
    }

    // MARK: - 4. Eğitmen / Kaynak Satırı (Doğrulama Rozeti + Takip Ediliyor Butonu)
    private var instructorRowView: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Yeşil Kare Logo Kutusu
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.Colors.primary500)
                    .frame(width: 44, height: 44)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.white)
            }

            // Eğitmen Adı + Onay Rozeti + Alt Etiket
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text(lesson.instructorName)
                        .font(AppTheme.Typography.bodyLarge)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.Colors.neutral900)

                    VerifiedBadge(size: 15)
                }

                Text(lesson.instructorSubtitle)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.neutral500)
            }

            Spacer()

            // Siyah Pill "Takip Ediliyor" Butonu
            DarkPillButton(
                title: isFollowingInstructor ? "Takip Ediliyor" : "Takip Et",
                iconSystemName: isFollowingInstructor ? "checkmark" : "plus",
                isFollowed: isFollowingInstructor,
                action: {
                    isFollowingInstructor.toggle()
                }
            )
        }
        .padding(.vertical, 4)
    }

    // MARK: - 5. Zorluk Seçimi & Soru Sayısı Stepper'ı
    private var difficultyAndStepperRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Zorluk Seç")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.neutral500)

                Spacer()

                Text("Soru Sayısı")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.neutral500)
            }

            HStack(spacing: AppTheme.Spacing.sm) {
                // Zorluk Chip'leri
                HStack(spacing: 6) {
                    ForEach(LessonDifficulty.allCases, id: \.rawValue) { diff in
                        SelectableChip(
                            title: diff.titleTr,
                            isSelected: selectedDifficulty == diff,
                            action: {
                                withAnimation(AppTheme.quickAnimation) {
                                    selectedDifficulty = diff
                                }
                            }
                        )
                    }
                }

                Spacer()

                // Soru Sayısı Stepper'ı
                QuantityStepper(
                    value: $questionCount,
                    step: 5,
                    minValue: 5,
                    maxValue: 50
                )
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - 6. Açıklama ve Stratejiler
    private var descriptionSectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Açıklama & Strateji")
                .font(AppTheme.Typography.titleMedium)
                .foregroundStyle(AppTheme.Colors.neutral900)

            Text(lesson.summaryTr)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundStyle(AppTheme.Colors.neutral700)
                .lineSpacing(4)

            Text("YDS & YÖKDİL Soru Çözüm İpuçları:")
                .font(AppTheme.Typography.label)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.Colors.neutral900)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(lesson.examTipsTr, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(AppTheme.Colors.primary500)
                            .padding(.top, 2)

                        Text(tip)
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundStyle(AppTheme.Colors.neutral700)
                            .lineSpacing(2)
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.base)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .glowShadow(AppTheme.Shadows.card)
    }
}
