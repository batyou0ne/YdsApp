import SwiftUI

/// 5.7 Profil Ekranı (User Profile Screen)
/// - Avatar, hedef sınav sayacı, hedef puan ve seri kartı
/// - Beyaz kartlar içinde ayarlar listesi (Sınav tercihi, alan, bildirimler, Pro üyelik)
public struct UserProfileScreen: View {
    @State private var dailyGoalCount: Int = 20
    @State private var notificationsEnabled: Bool = true
    @State private var selectedExam: String = "YDS İlkbahar"
    @State private var selectedTrack: String = "Sağlık Bilimleri"

    public init() {}

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                // 1. Profil Başlık Kartı
                profileHeaderCard

                // 2. Sınav Geri Sayımı & Hedef Puan Rozetleri
                examTargetHighlightsRow

                // 3. Çalışma & Tercih Ayarları (Beyaz Kartlar)
                studySettingsSection

                // 4. Pro Üyelik & Destek Kartı
                proMembershipCard

                Spacer(minLength: 84)
            }
            .padding(.horizontal, AppTheme.Spacing.screenPadding)
            .padding(.top, 12)
        }
        .background(AppTheme.Colors.appBackground.ignoresSafeArea())
    }

    // MARK: - 1. Profil Başlık Kartı
    private var profileHeaderCard: some View {
        HStack(spacing: AppTheme.Spacing.base) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primary100)
                    .frame(width: 64, height: 64)

                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(AppTheme.Colors.primary700)

                // Doğrulama Rozeti
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VerifiedBadge(size: 18)
                    }
                }
                .frame(width: 64, height: 64)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("Batuhan Keskin")
                        .font(AppTheme.Typography.titleLarge)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.Colors.neutral900)
                }

                Text("Akademik Kadro Adayı • Doçentlik Hazırlık")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.neutral500)

                HStack(spacing: 6) {
                    Text("Pro Üye")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppTheme.Colors.primary700)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppTheme.Colors.primary100)
                        .clipShape(Capsule())

                    Text("14 Günlük Seri 🔥")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.warning)
                }
                .padding(.top, 2)
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .glowShadow(AppTheme.Shadows.card)
    }

    // MARK: - 2. Sınav Geri Sayımı & Puan Rozetleri
    private var examTargetHighlightsRow: some View {
        HStack(spacing: 12) {
            StatCardView(
                title: "Sınav Geri Sayımı",
                value: "47 Gün",
                subtitle: "ÖSYM YDS İlkbahar",
                iconSystemName: "timer",
                accentColor: AppTheme.Colors.warning
            )

            StatCardView(
                title: "Hedef Puan",
                value: "85.00",
                subtitle: "Mevcut: 68.75 (+16.25)",
                iconSystemName: "flag.checkered",
                accentColor: AppTheme.Colors.primary500
            )
        }
    }

    // MARK: - 3. Tercihler Bölümü
    private var studySettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Çalışma Tercihleri", seeAllText: nil)

            VStack(spacing: 1) {
                settingsRow(
                    icon: "graduationcap.fill",
                    title: "Hedef Sınav",
                    value: selectedExam
                )

                Divider().padding(.horizontal, 14)

                settingsRow(
                    icon: "cross.case.fill",
                    title: "Akademik Alan",
                    value: selectedTrack
                )

                Divider().padding(.horizontal, 14)

                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: "target")
                            .font(.system(size: 18))
                            .foregroundStyle(AppTheme.Colors.primary700)
                            .frame(width: 24)

                        Text("Günlük Soru Hedefi")
                            .font(AppTheme.Typography.bodyMedium)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.Colors.neutral900)
                    }

                    Spacer()

                    QuantityStepper(value: $dailyGoalCount, step: 5, minValue: 10, maxValue: 60)
                }
                .padding(14)

                Divider().padding(.horizontal, 14)

                Toggle(isOn: $notificationsEnabled) {
                    HStack(spacing: 12) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(AppTheme.Colors.primary700)
                            .frame(width: 24)

                        Text("Çalışma Hatırlatıcıları")
                            .font(AppTheme.Typography.bodyMedium)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.Colors.neutral900)
                    }
                }
                .tint(AppTheme.Colors.primary500)
                .padding(14)
            }
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
            .glowShadow(AppTheme.Shadows.card)
        }
    }

    private func settingsRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.Colors.primary700)
                .frame(width: 24)

            Text(title)
                .font(AppTheme.Typography.bodyMedium)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.Colors.neutral900)

            Spacer()

            Text(value)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundStyle(AppTheme.Colors.neutral500)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.neutral300)
        }
        .padding(14)
    }

    // MARK: - 4. Pro Üyelik Kartı
    private var proMembershipCard: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.primary500)
                    .frame(width: 44, height: 44)

                Image(systemName: "crown.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("YDS Pro Strateji Paketi")
                    .font(AppTheme.Typography.bodyLarge)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.Colors.neutral900)

                Text("Tüm çıkmış soru tüyoları ve sınırsız çeldirici analizi aktif")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.neutral500)
            }

            Spacer()

            DarkPillButton(
                title: "Yönet",
                iconSystemName: nil,
                isFollowed: false,
                action: {}
            )
        }
        .padding(AppTheme.Spacing.base)
        .background(AppTheme.Colors.primary100.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                .stroke(AppTheme.Colors.primary500.opacity(0.4), lineWidth: 1)
        )
    }
}
