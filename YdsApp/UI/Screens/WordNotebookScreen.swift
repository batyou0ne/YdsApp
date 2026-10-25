import SwiftUI

/// 5.5 Kelime Defteri (FlashCard & Akademik Kelime Öğrenimi)
/// - FlashCard (Büyük beyaz kart, radius 28, 3D flip animasyonu)
/// - "Biliyorum / Tekrar" iki pill buton
/// - Kategori chip'leri (Akademik, Fen, Sağlık, Sosyal)
/// - İlerleme ve pekiştirme sayacı
public struct WordNotebookScreen: View {
    public let words: [GlowMockData.MockVocabWord]

    @State private var selectedTrack: String = "Tümü"
    @State private var currentIndex: Int = 0
    @State private var isCardFlipped: Bool = false
    @State private var masteredWordIds: Set<String> = []
    @State private var reviewWordIds: Set<String> = []

    public init(words: [GlowMockData.MockVocabWord] = GlowMockData.academicWords) {
        self.words = words
    }

    private var filteredWords: [GlowMockData.MockVocabWord] {
        if selectedTrack == "Tümü" {
            return words
        }
        return words.filter { $0.categoryTrackTr == selectedTrack }
    }

    private var currentWord: GlowMockData.MockVocabWord {
        guard !filteredWords.isEmpty else { return words[0] }
        let safeIndex = min(currentIndex, filteredWords.count - 1)
        return filteredWords[safeIndex]
    }

    private let tracks = ["Tümü", "Akademik", "Sağlık", "Fen", "Sosyal"]

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppTheme.Spacing.lg) {
                // 1. Üst Bar: Başlık ve İlerleme
                topHeaderView

                // 2. Alan Kategori Chip'leri (Tümü, Sağlık, Fen, Sosyal)
                trackChipsScrollView

                // 3. 3D Çevirmeli FlashCard
                FlashCardView(
                    wordItem: currentWord,
                    isFlipped: $isCardFlipped
                )
                .padding(.top, 4)

                // 4. "Tekrar" ve "Biliyorum" Butonları
                actionButtonsRow

                // 5. Öğrenilen Kelimeler Listesi Özeti
                recentWordsSummarySection

                Spacer(minLength: 84)
            }
            .padding(.horizontal, AppTheme.Spacing.screenPadding)
            .padding(.top, 12)
        }
        .background(AppTheme.Colors.appBackground.ignoresSafeArea())
    }

    // MARK: - 1. Üst Bar & Sayaç
    private var topHeaderView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Kelime Defteri")
                    .font(AppTheme.Typography.titleLarge)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.Colors.neutral900)

                Text("\(masteredWordIds.count) / \(words.count) Kelime Pekiştirildi")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.primary700)
                    .fontWeight(.semibold)
            }

            Spacer()

            // İlerleme Rozeti
            HStack(spacing: 4) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.Colors.primary500)
                Text("%\(Int((Double(masteredWordIds.count) / Double(max(words.count, 1)) * 100).rounded()))")
                    .font(AppTheme.Typography.label)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.Colors.neutral900)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.Colors.surface)
            .clipShape(Capsule())
            .glowShadow(AppTheme.Shadows.soft)
        }
    }

    // MARK: - 2. Alan Kategori Chip'leri
    private var trackChipsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tracks, id: \.self) { track in
                    SelectableChip(
                        title: track,
                        isSelected: selectedTrack == track,
                        action: {
                            withAnimation(AppTheme.quickAnimation) {
                                selectedTrack = track
                                currentIndex = 0
                                isCardFlipped = false
                            }
                        }
                    )
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - 4. Aksiyon Butonları (Tekrar / Biliyorum)
    private var actionButtonsRow: some View {
        HStack(spacing: 14) {
            // "Tekrar" Butonu (Muted Pill)
            Button {
                advanceCard(mastered: false)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .bold))
                    Text("Tekrar Et")
                        .font(AppTheme.Typography.bodyLarge)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(AppTheme.Colors.neutral900)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(AppTheme.Colors.muted)
                .clipShape(Capsule())
            }
            .bouncyPressEffect()

            // "Biliyorum" Butonu (Primary Pill)
            Button {
                advanceCard(mastered: true)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                    Text("Biliyorum")
                        .font(AppTheme.Typography.bodyLarge)
                        .fontWeight(.bold)
                }
                .foregroundStyle(AppTheme.Colors.textOnPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(AppTheme.Colors.primary500)
                .clipShape(Capsule())
                .glowShadow(AppTheme.ShadowConfig(color: AppTheme.Colors.primary500.opacity(0.35), radius: 8, x: 0, y: 4))
            }
            .bouncyPressEffect()
        }
    }

    private func advanceCard(mastered: Bool) {
        if mastered {
            masteredWordIds.insert(currentWord.id)
            reviewWordIds.remove(currentWord.id)
        } else {
            reviewWordIds.insert(currentWord.id)
            masteredWordIds.remove(currentWord.id)
        }

        withAnimation(AppTheme.standardAnimation) {
            isCardFlipped = false
            if currentIndex + 1 < filteredWords.count {
                currentIndex += 1
            } else {
                currentIndex = 0
            }
        }
    }

    // MARK: - 5. Kelime Listesi Özeti
    private var recentWordsSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Listedeki Kelimeler (\(filteredWords.count))", seeAllText: nil)

            VStack(spacing: 8) {
                ForEach(filteredWords.prefix(6)) { word in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(word.word)
                                .font(AppTheme.Typography.bodyLarge)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.Colors.neutral900)

                            Text(word.meaningTr)
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.neutral500)
                        }

                        Spacer()

                        if masteredWordIds.contains(word.id) {
                            Text("Öğrenildi")
                                .font(AppTheme.Typography.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.Colors.primary700)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppTheme.Colors.primary100)
                                .clipShape(Capsule())
                        } else {
                            Text(word.categoryTrackTr)
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.neutral500)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppTheme.Colors.muted)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(12)
                    .background(AppTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }
}
