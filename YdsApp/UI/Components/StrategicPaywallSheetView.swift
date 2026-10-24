import SwiftUI

/// Stratejik Paywall Görünümü (Hem Onboarding Adım 5 hem de Freemium Kilit Sheet'i için)
public struct StrategicPaywallSheetView: View {
    public let reasonMessageTr: String
    public let currentScoreText: String
    public let targetScoreText: String
    public let selectedTier: SubscriptionTier
    public let onSelectTier: (SubscriptionTier) -> Void
    public let onActivatePro: (SubscriptionTier) -> Void
    public let onContinueFree: () -> Void

    public init(
        reasonMessageTr: String,
        currentScoreText: String,
        targetScoreText: String,
        selectedTier: SubscriptionTier,
        onSelectTier: @escaping (SubscriptionTier) -> Void,
        onActivatePro: @escaping (SubscriptionTier) -> Void,
        onContinueFree: @escaping () -> Void
    ) {
        self.reasonMessageTr = reasonMessageTr
        self.currentScoreText = currentScoreText
        self.targetScoreText = targetScoreText
        self.selectedTier = selectedTier
        self.onSelectTier = onSelectTier
        self.onActivatePro = onActivatePro
        self.onContinueFree = onContinueFree
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(AppTheme.proGold)
                        Text("YDS & YÖKDİL PRO KOÇLUK")
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(AppTheme.proGold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.proGold.opacity(0.16))
                    .clipShape(Capsule())

                    Text("\(currentScoreText) -> \(targetScoreText) Puan Sıçramasını Kilitleme")
                        .font(.title2.weight(.heavy))
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(reasonMessageTr)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 14) {
                    featureRow(
                        icon: "checklist.checked",
                        title: "Günlük 15 Dakikalık Tam Reçete (14/14 Adım)",
                        subtitle: "Ücretsiz %50 (7 adım) sınırını kaldır, her gün +0.55 puana kadar ekle."
                    )
                    featureRow(
                        icon: "waveform.path.ecg.rectangle.fill",
                        title: "Sınırsız Cümle Röntgeni (Sentence X-Ray)",
                        subtitle: "Günde 1 cümle sınırını kaldır; 5 satırlık tüm akademik cümlelerin iskeletini aç."
                    )
                    featureRow(
                        icon: "eye.fill",
                        title: "Bulanık Olmayan 'Neden Yanlış Yaptım?' Koçu",
                        subtitle: "Düştüğün sınav tuzağını (trapReason) ve doğru cevap kısa yolunu (winningRule) net gör."
                    )
                    featureRow(
                        icon: "slider.horizontal.3",
                        title: "YÖKDİL Sağlık • Fen • Sosyal Alan Filtreleri",
                        subtitle: "Kendi alanındaki 3 boyutlu kelime paketlerine ve Hata Kumbarasına tam eriş."
                    )
                }
                .padding(16)
                .background(AppTheme.surfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                VStack(spacing: 12) {
                    planOptionCard(
                        tier: .proAnnual,
                        title: "Yıllık Sınav Paketi (En Popüler)",
                        priceText: "₺149,90 / ay (Yıllık faturalandırılır)",
                        badge: "%50 TASARRUF"
                    )

                    planOptionCard(
                        tier: .proMonthly,
                        title: "Aylık Hızlandırma Paketi",
                        priceText: "₺299,90 / ay (İstediğin an iptal et)",
                        badge: "ESNEK"
                    )
                }

                Button {
                    onActivatePro(selectedTier.isPro ? selectedTier : .proAnnual)
                } label: {
                    HStack {
                        Image(systemName: "bolt.shield.fill")
                        Text("YDS Pro'yu Başlat ve Tüm Kilitleri Aç")
                            .font(.headline.weight(.bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.primaryActionGradient)
                    .foregroundStyle(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)

                Button {
                    onContinueFree()
                } label: {
                    Text("Şimdilik Ücretsiz Planla (%50 Günlük Reçete Sınırı) Devam Et")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .background(AppTheme.backgroundDark.ignoresSafeArea())
    }

    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AppTheme.emeraldSuccess)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }

    private func planOptionCard(
        tier: SubscriptionTier,
        title: String,
        priceText: String,
        badge: String
    ) -> some View {
        let isSelected = selectedTier == tier
        return Button {
            onSelectTier(tier)
        } label: {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? AppTheme.emeraldSuccess : AppTheme.textSecondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(priceText)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                Text(badge)
                    .font(.caption2.weight(.heavy))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isSelected ? AppTheme.emeraldSuccess.opacity(0.22) : AppTheme.surfaceElevated)
                    .foregroundStyle(isSelected ? AppTheme.emeraldSuccess : AppTheme.textSecondary)
                    .clipShape(Capsule())
            }
            .padding(14)
            .background(AppTheme.surfaceCard)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppTheme.emeraldSuccess : AppTheme.borderSubtle, lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
