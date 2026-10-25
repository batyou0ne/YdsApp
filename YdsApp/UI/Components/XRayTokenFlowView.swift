import SwiftUI

/// 4-5 satırlık akademik cümleleri interaktif parçalara (Özne, Ana Yüklem, Bağlaç, Yan Cümlecik, Edat) ayıran Röntgen Görünümü
public struct XRayTokenFlowView: View {
    public let item: SentenceXRayItem
    public let isXRayActive: Bool
    public let selectedSegmentId: String?
    public let onSelectSegment: (String) -> Void

    public init(
        item: SentenceXRayItem,
        isXRayActive: Bool,
        selectedSegmentId: String?,
        onSelectSegment: @escaping (String) -> Void
    ) {
        self.item = item
        self.isXRayActive = isXRayActive
        self.selectedSegmentId = selectedSegmentId
        self.onSelectSegment = onSelectSegment
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if isXRayActive {
                roleLegendBar
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if isXRayActive {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(item.segments) { segment in
                        xraySegmentRow(segment: segment)
                    }
                }
                .transition(.opacity)
            } else {
                plainAcademicReadingView
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: isXRayActive)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: selectedSegmentId)
    }

    // MARK: - Plain Reading Mode (isXRayActive == false)

    private var plainAcademicReadingView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.fullEnglishSentence)
                .font(.system(.body, design: .serif).weight(.medium))
                .foregroundStyle(AppTheme.textPrimary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                Image(systemName: "hand.tap.fill")
                    .font(.caption)
                    .foregroundStyle(AppTheme.cyanMainSubject)
                Text("Ana Özne, Ana Yüklem, Bağlaç Kutupları ve [Yan Cümlecikleri] görmek için 'Röntgeni Aç' butonuna dokun.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(10)
            .background(AppTheme.backgroundDark.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Interactive X-Ray Segment Card (isXRayActive == true)

    private func xraySegmentRow(segment: SentenceSegment) -> some View {
        let isSelected = selectedSegmentId == segment.id
        let roleColor = AppTheme.roleColor(for: segment.role)
        let isNonEssential = segment.role == .nonEssentialClause
        let displayText = isNonEssential ? "[ \(segment.text) ]" : segment.text

        return Button {
            onSelectSegment(segment.id)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    roleBadge(for: segment)

                    if let direction = segment.conjunctionDirection {
                        Text("\(direction.iconSymbol) \(direction == .contrast ? "ZITLIK" : "PARALEL")")
                            .font(.system(size: 10, weight: .heavy))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(AppTheme.coralConjunction.opacity(0.24))
                            .foregroundStyle(AppTheme.coralConjunction)
                            .clipShape(Capsule())
                    }

                    if let polarity = segment.segmentPolarity {
                        polarityBadge(polarity: polarity)
                    }

                    Spacer()

                    if segment.examLogicTipTr != nil {
                        HStack(spacing: 3) {
                            Image(systemName: isSelected ? "lightbulb.fill" : "lightbulb")
                            Text(isSelected ? "İpucu Açık" : "İpucunu Gör")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(isSelected ? AppTheme.emeraldSuccess : AppTheme.textSecondary)
                    }
                }

                Text(displayText)
                    .font(.system(.subheadline, design: .serif).weight(segmentFontWeight(for: segment.role)))
                    .foregroundStyle(segmentTextColor(for: segment.role))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(segmentBackgroundColor(for: segment.role, isSelected: isSelected))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? roleColor : roleColor.opacity(isNonEssential ? 0.20 : 0.45),
                        lineWidth: isSelected ? 2.0 : 1.0
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(isNonEssential ? 0.40 : 1.0)
        }
        .buttonStyle(.plain)
    }

    private func roleBadge(for segment: SentenceSegment) -> some View {
        let badgeTitle: String
        switch segment.role {
        case .mainSubject:
            badgeTitle = "ÖZNE"
        case .mainVerb:
            badgeTitle = "ANA YÜKLEM"
        case .conjunction:
            badgeTitle = "BAĞLAÇ"
        case .nonEssentialClause:
            badgeTitle = "[YAN CÜMLECİK / ATLA]"
        case .prepositionTrigger:
            badgeTitle = "ZORUNLU EDAT KALIBI"
        case .standard:
            badgeTitle = "TAMAMLAYICI"
        }

        let color = AppTheme.roleColor(for: segment.role)
        return Text(badgeTitle)
            .font(.system(size: 10, weight: .heavy))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.22))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private func polarityBadge(polarity: PolarityType) -> some View {
        let color: Color
        switch polarity {
        case .positive:
            color = AppTheme.emeraldSuccess
        case .negative:
            color = AppTheme.coralConjunction
        case .neutral:
            color = AppTheme.textSecondary
        }

        return Text("KUTUP: \(polarity.symbol)")
            .font(.system(size: 10, weight: .heavy))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color.opacity(0.20))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var roleLegendBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                legendChip(title: "ÖZNE", color: AppTheme.cyanMainSubject)
                legendChip(title: "ANA YÜKLEM", color: AppTheme.amberMainVerb)
                legendChip(title: "BAĞLAÇ (⇄/⇉)", color: AppTheme.coralConjunction)
                legendChip(title: "EDAT KALIBI", color: AppTheme.purplePreposition)
                legendChip(title: "[YAN CÜMLECİK %40]", color: AppTheme.textSecondary)
            }
        }
    }

    private func legendChip(title: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.14))
        .clipShape(Capsule())
    }

    private func segmentFontWeight(for role: SegmentRole) -> Font.Weight {
        switch role {
        case .mainSubject, .mainVerb, .conjunction, .prepositionTrigger:
            return .bold
        case .nonEssentialClause, .standard:
            return .regular
        }
    }

    private func segmentTextColor(for role: SegmentRole) -> Color {
        switch role {
        case .mainSubject:
            return AppTheme.cyanMainSubject
        case .mainVerb:
            return AppTheme.amberMainVerb
        case .conjunction:
            return AppTheme.coralConjunction
        case .prepositionTrigger:
            return AppTheme.purplePreposition
        case .nonEssentialClause:
            return AppTheme.textSecondary
        case .standard:
            return AppTheme.textPrimary
        }
    }

    private func segmentBackgroundColor(for role: SegmentRole, isSelected: Bool) -> Color {
        let baseColor = AppTheme.roleColor(for: role)
        switch role {
        case .mainSubject, .mainVerb, .conjunction, .prepositionTrigger:
            return baseColor.opacity(isSelected ? 0.22 : 0.12)
        case .nonEssentialClause:
            return AppTheme.backgroundDark.opacity(0.45)
        case .standard:
            return AppTheme.backgroundDark.opacity(isSelected ? 0.85 : 0.55)
        }
    }
}
