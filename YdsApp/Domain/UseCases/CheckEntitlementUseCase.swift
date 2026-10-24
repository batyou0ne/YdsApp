import Foundation

/// Freemium ve Pro Sınırları Denetleyicisi (CheckEntitlementUseCase)
/// KURAL: Freemium limitleri View içinde değil, tamamen bu saf Domain UseCase'inde hesaplanır!
public struct CheckEntitlementUseCase: Sendable {
    public static let freeDailyPrescriptionStepLimit: Int = 7
    public static let freeDailySentenceXRayLimit: Int = 1

    public init() {}

    /// Ücretsiz kullanıcı günlük reçetenin sadece ilk yarısını (%50 - ilk 7 adım) tamamlayabilir; 8. adıma geçerken Paywall tetiklenir.
    public func isPrescriptionStepLocked(stepIndex: Int, tier: SubscriptionTier) -> Bool {
        guard !tier.isPro else { return false }
        return stepIndex > Self.freeDailyPrescriptionStepLimit
    }

    /// Ücretsiz kullanıcı günde sadece 1 adet Cümle Röntgeni açabilir.
    public func canOpenSentenceXRay(profile: UserStudyProfile) -> Bool {
        if profile.subscriptionTier.isPro {
            return true
        }
        return profile.dailyFreeXRayUsedCount < Self.freeDailySentenceXRayLimit
    }

    /// Ücretsiz kullanıcıda "Neden Yanlış Yaptım?" Çeldirici Koçu kartının `praiseTextTr` kısmı açık,
    /// `trapReasonTr` ve `winningRuleTr` detayları bulanık (blur) ve kilitlidir.
    public func shouldBlurDistractorCoachDetails(tier: SubscriptionTier) -> Bool {
        !tier.isPro
    }

    /// YÖKDİL alan filtrelerini değiştirme yetkisi kontrolü
    public func canSwitchAcademicTrackFilter(tier: SubscriptionTier) -> Bool {
        tier.isPro
    }
}
