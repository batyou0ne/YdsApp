import SwiftUI

/// 5.1 Ana Sayfa (Glow Nature Referans Sol Ekran)
/// - Üstte hamburger + bildirim ikon butonları
/// - AppSearchBar ("Kelime, konu veya soru ara…")
/// - PromoBanner Carousel (Sınırlı süre / günün hedefi, yeşil gradient zemin, organik dalgalar, CTA)
/// - StreakBadge (Günlük seri ve hedef kartı)
/// - Kategoriler (Gramer, Kelime, Okuma, Çeviri, Cloze Test)
/// - 2 Sütunlu Ders Grid'i (Sana Özel Dersler / Yeni Eklenen Konular)
public struct GlowHomeScreen: View {
    @State private var searchText: String = ""
    @State private var bannerIndex: Int = 0
    @State private var selectedCategory: LessonCategoryType? = nil
    @State private var bookmarkedLessonIds: Set<String> = ["lesson_1", "lesson_3"]
    @State private var showingNotificationsSheet: Bool = false
    @State private var showingDrawerSheet: Bool = false

    public let lessons: [LessonItem]
    public let onSelectLesson: (LessonItem) -> Void
    public let onStartPractice: () -> Void

    public init(
        lessons: [LessonItem] = GlowMockData.lessons,
        onSelectLesson: @escaping (LessonItem) -> Void,
        onStartPractice: @escaping () -> Void
    ) {
        self.lessons = lessons
        self.onSelectLesson = onSelectLesson
        self.onStartPractice = onStartPractice
    }

    private var filteredLessons: [LessonItem] {
        var list = lessons
        if let selectedCategory {
            list = list.filter { $0.category == selectedCategory }
        }
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            list = list.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.summaryTr.localizedCaseInsensitiveContains(searchText)
            }
        }
        return list
    }

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
    ]

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                // 1. Üst Bar: Hamburger Menü (Sol) & Bildirim/Hedef Çantası (Sağ)
                topBarView

                // 2. Arama Çubuğu (Full Pill + Sol Büyüteç + Dikey Çizgi + Filtre)
                AppSearchBar(
                    text: $searchText,
                    placeholder: "Kelime, konu veya soru ara…",
                    onFilterTapped: {
                        withAnimation(AppTheme.quickAnimation) {
                            selectedCategory = nil
                        }
                    }
                )

                // 3. Promo Banner Carousel (Yeşil Gradient + Siyah Mini Rozet + Başlık + CTA + İllüstrasyon)
                PromoBanner(
                    currentIndex: $bannerIndex,
                    onCtaTapped: { slide in
                        if slide.targetRoute == "practice" {
                            onStartPractice()
                        } else if let firstLesson = lessons.first {
                            onSelectLesson(firstLesson)
                        }
                    }
                )

                // 4. Günlük Seri & Puan Hedefi Şeridi (Soft Beyaz Kart)
                StreakBadge(
                    streakDays: 14,
                    todayScoreDelta: "+0.40",
                    completedQuestionsToday: 16,
                    targetQuestionsToday: 20
                )

                // 5. Kategoriler Bölümü (Yatay Scroll Kapsülleri)
                categoriesSectionView

                // 6. Sana Özel Dersler (2 Sütunlu Grid - Üst Organik Görsel + Kalp Butonu + Süre)
                recommendedLessonsSectionView

                // Yüzen alt navigasyonun altında kaybolmaması için güvenlik boşluğu
                Spacer(minLength: 84)
            }
            .padding(.horizontal, AppTheme.Spacing.screenPadding)
            .padding(.top, 12)
        }
        .background(AppTheme.Colors.appBackground.ignoresSafeArea())
        .sheet(isPresented: $showingNotificationsSheet) {
            notificationsSheet
        }
        .sheet(isPresented: $showingDrawerSheet) {
            drawerSheet
        }
    }

    // MARK: - 1. Üst Bar
    private var topBarView: some View {
        HStack {
            CircleIconButton(
                iconSystemName: "line.3.horizontal",
                iconSize: 20,
                action: { showingDrawerSheet = true }
            )

            Spacer()

            VStack(spacing: 2) {
                Text("YDS & YÖKDİL")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.primary700)
                    .tracking(1.2)
                Text("Strateji Masası")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.neutral500)
            }

            Spacer()

            CircleIconButton(
                iconSystemName: "bell",
                iconSize: 20,
                showBadge: true,
                action: { showingNotificationsSheet = true }
            )
        }
    }

    // MARK: - 5. Kategoriler Bölümü
    private var categoriesSectionView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            SectionHeader(
                title: "Kategoriler",
                seeAllText: "Tümünü gör",
                onSeeAllTapped: {
                    withAnimation(AppTheme.quickAnimation) {
                        selectedCategory = nil
                    }
                }
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.md) {
                    ForEach(LessonCategoryType.allCases, id: \.rawValue) { cat in
                        CategoryChip(
                            title: cat.titleTr,
                            iconSystemName: cat.iconSystemName,
                            isSelected: selectedCategory == cat,
                            action: {
                                withAnimation(AppTheme.quickAnimation) {
                                    if selectedCategory == cat {
                                        selectedCategory = nil
                                    } else {
                                        selectedCategory = cat
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - 6. Sana Özel Dersler (2 Sütunlu Grid)
    private var recommendedLessonsSectionView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            SectionHeader(
                title: "Sana Özel Dersler",
                seeAllText: "Tümünü gör",
                onSeeAllTapped: {
                    // Tüm dersleri filtre sıfırlayarak göster
                    selectedCategory = nil
                }
            )

            LazyVGrid(columns: columns, spacing: AppTheme.Spacing.md) {
                ForEach(filteredLessons) { lesson in
                    ContentCard(
                        lesson: lesson,
                        isBookmarked: bookmarkedLessonIds.contains(lesson.id),
                        onBookmarkTapped: {
                            if bookmarkedLessonIds.contains(lesson.id) {
                                bookmarkedLessonIds.remove(lesson.id)
                            } else {
                                bookmarkedLessonIds.insert(lesson.id)
                            }
                        },
                        onCardTapped: {
                            onSelectLesson(lesson)
                        }
                    )
                }
            }
        }
    }

    // MARK: - Bildirimler Sayfası
    private var notificationsSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Bildirimler & Hatırlatıcılar")
                        .font(AppTheme.Typography.titleLarge)
                        .foregroundStyle(AppTheme.Colors.neutral900)
                    Spacer()
                }

                VStack(spacing: 12) {
                    notificationRow(
                        icon: "target",
                        title: "Günlük Hedefine 4 Soru Kaldı",
                        subtitle: "Bugünkü 20 soru kotanı tamamlayarak serini 15 güne çıkar.",
                        timeAgo: "2 saat önce"
                    )

                    notificationRow(
                        icon: "clock.badge.checkmark",
                        title: "YDS İlkbahar Sınavı Geri Sayımı",
                        subtitle: "Sınava 47 gün kaldı. Haftalık deneme sınavın seni bekliyor.",
                        timeAgo: "Dün"
                    )

                    notificationRow(
                        icon: "sparkles",
                        title: "Yeni Ders: Cümle Tamamlama Eklendi",
                        subtitle: "ÖSYM'nin 10 soruluk kritik soru tipi için tüyolar yayında.",
                        timeAgo: "2 gün önce"
                    )
                }

                Spacer()
            }
            .padding(24)
            .background(AppTheme.Colors.appBackground.ignoresSafeArea())
        }
    }

    private func notificationRow(icon: String, title: String, subtitle: String, timeAgo: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primary100)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(AppTheme.Colors.primary700)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(AppTheme.Typography.bodyLarge)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.neutral900)
                Text(subtitle)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.neutral500)
                Text(timeAgo)
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.Colors.neutral500)
            }
        }
        .padding(14)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .glowShadow(AppTheme.Shadows.card)
    }

    // MARK: - Menü Çekmecesi
    private var drawerSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 14) {
                    Circle()
                        .fill(AppTheme.Colors.primary100)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(AppTheme.Colors.primary700)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("YDS & YÖKDİL Adayı")
                            .font(AppTheme.Typography.titleLarge)
                            .foregroundStyle(AppTheme.Colors.neutral900)
                        Text("Hedef: 85.00 • Sağlık Bilimleri")
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(AppTheme.Colors.neutral500)
                    }
                }
                .padding(.top, 10)

                Divider()

                VStack(spacing: 14) {
                    drawerItem(icon: "checkmark.seal.fill", title: "Resmî Sınav Takvimi")
                    drawerItem(icon: "chart.line.uptrend.xyaxis", title: "Puan Tahmin Raporu")
                    drawerItem(icon: "bookmark.fill", title: "Kaydedilen Konular")
                    drawerItem(icon: "gearshape.fill", title: "Uygulama Ayarları")
                }

                Spacer()
            }
            .padding(24)
            .background(AppTheme.Colors.appBackground.ignoresSafeArea())
        }
    }

    private func drawerItem(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.Colors.primary700)
                .frame(width: 24)

            Text(title)
                .font(AppTheme.Typography.bodyLarge)
                .foregroundStyle(AppTheme.Colors.neutral900)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.neutral300)
        }
        .padding(14)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
