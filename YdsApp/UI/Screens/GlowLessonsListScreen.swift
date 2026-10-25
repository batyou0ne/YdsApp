import SwiftUI

/// 5.1-B Dersler Kataloğu Ekranı (Tab 2: "Dersler")
/// - Tüm 8 dersin kategorilere göre filtrelenmesi
/// - Kolay / Orta / Zor filtreleme
/// - Arama desteği
public struct GlowLessonsListScreen: View {
    public let lessons: [LessonItem]
    public let onSelectLesson: (LessonItem) -> Void

    @State private var searchText: String = ""
    @State private var selectedCategory: LessonCategoryType? = nil
    @State private var selectedDifficulty: LessonDifficulty? = nil
    @State private var bookmarkedLessonIds: Set<String> = ["lesson_1", "lesson_3"]

    public init(
        lessons: [LessonItem] = GlowMockData.lessons,
        onSelectLesson: @escaping (LessonItem) -> Void
    ) {
        self.lessons = lessons
        self.onSelectLesson = onSelectLesson
    }

    private var filteredLessons: [LessonItem] {
        var result = lessons
        if let selectedCategory {
            result = result.filter { $0.category == selectedCategory }
        }
        if let selectedDifficulty {
            result = result.filter { $0.difficulty == selectedDifficulty }
        }
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.summaryTr.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
    ]

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                // Başlık
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ders Kataloğu")
                        .font(AppTheme.Typography.display)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.Colors.neutral900)

                    Text("ÖSYM YDS & YÖKDİL soru tiplerine göre yapılandırılmış 8 modül")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.neutral500)
                }

                // Arama
                AppSearchBar(
                    text: $searchText,
                    placeholder: "Konu veya ders ara…",
                    onFilterTapped: {
                        withAnimation(AppTheme.quickAnimation) {
                            selectedCategory = nil
                            selectedDifficulty = nil
                        }
                    }
                )

                // Kategori Kapsülleri
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(
                            title: "Tümü",
                            iconSystemName: "square.grid.2x2.fill",
                            isSelected: selectedCategory == nil,
                            action: {
                                withAnimation(AppTheme.quickAnimation) {
                                    selectedCategory = nil
                                }
                            }
                        )

                        ForEach(LessonCategoryType.allCases, id: \.rawValue) { cat in
                            CategoryChip(
                                title: cat.titleTr,
                                iconSystemName: cat.iconSystemName,
                                isSelected: selectedCategory == cat,
                                action: {
                                    withAnimation(AppTheme.quickAnimation) {
                                        selectedCategory = (selectedCategory == cat ? nil : cat)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }

                // Ders Grid'i
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

                Spacer(minLength: 84)
            }
            .padding(.horizontal, AppTheme.Spacing.screenPadding)
            .padding(.top, 12)
        }
        .background(AppTheme.Colors.appBackground.ignoresSafeArea())
    }
}
