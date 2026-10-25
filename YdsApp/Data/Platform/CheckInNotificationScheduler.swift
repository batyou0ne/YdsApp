import Foundation
import UserNotifications

/// Haftalık Check-In bildirim planlayıcı platform adaptörü
/// KURAL: `UNUserNotificationCenter` çağrıları bu adaptör içinde izole edilir; Domain katmanına sızmaz.
public final class CheckInNotificationScheduler: Sendable {
    private let reminderPolicy: CheckInReminderPolicy

    public init(reminderPolicy: CheckInReminderPolicy = CheckInReminderPolicy()) {
        self.reminderPolicy = reminderPolicy
    }

    /// Kullanıcı çalışma profili ve uygunluğuna göre hafta sonu bildirimini planlar
    public func scheduleWeekendCheckInReminder(
        profile: UserStudyProfile,
        eligibility: CheckInEligibility,
        preferredHour: Int = CheckInReminderPolicy.defaultPreferredHour
    ) async {
        guard reminderPolicy.shouldScheduleReminder(profile: profile, eligibility: eligibility) else {
            return
        }

        let center = UNUserNotificationCenter.current()

        // İzin kontrolü
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            return
        }

        let targetDate = reminderPolicy.nextReminderDate(from: Date(), preferredHour: preferredHour)
        let calendar = Calendar.current
        let triggerComponents = calendar.dateComponents([.weekday, .hour, .minute], from: targetDate)

        let content = UNMutableNotificationContent()
        content.title = CheckInReminderPolicy.notificationTitleTr
        content.body = CheckInReminderPolicy.notificationBodyTr
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "yds.app.weekly_check_in.reminder",
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    public func cancelPendingReminders() async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["yds.app.weekly_check_in.reminder"])
    }
}
