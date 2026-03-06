import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func currentSettings() async -> UNNotificationSettings {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }

    func scheduleNotifications(preferences: NotificationPreferences, displayName: String) async throws {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [
            ReminderIdentifiers.breakfast,
            ReminderIdentifiers.lunch,
            ReminderIdentifiers.dinner,
            ReminderIdentifiers.weighIn
        ])

        guard preferences.notificationsEnabled else { return }

        try await schedule(
            identifier: ReminderIdentifiers.breakfast,
            title: "Breakfast time, \(displayName) 🌸",
            body: "A simple start keeps the day calm and on track.",
            enabled: preferences.breakfastEnabled,
            time: preferences.breakfastTime,
            center: center
        )

        try await schedule(
            identifier: ReminderIdentifiers.lunch,
            title: "Lunch is ready for your goal today 💪",
            body: "A steady high-protein lunch can make the evening easier.",
            enabled: preferences.lunchEnabled,
            time: preferences.lunchTime,
            center: center
        )

        try await schedule(
            identifier: ReminderIdentifiers.dinner,
            title: "Dinner time — stay consistent ❤️",
            body: "One balanced dinner is enough. No need to chase perfection.",
            enabled: preferences.dinnerEnabled,
            time: preferences.dinnerTime,
            center: center
        )

        try await schedule(
            identifier: ReminderIdentifiers.weighIn,
            title: "Log your progress for today ✨",
            body: "A quick weigh-in keeps the trend visible, not emotional.",
            enabled: preferences.weighInEnabled,
            time: preferences.weighInTime,
            center: center
        )
    }

    private func schedule(
        identifier: String,
        title: String,
        body: String,
        enabled: Bool,
        time: Date,
        center: UNUserNotificationCenter
    ) async throws {
        guard enabled else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        try await center.add(request)
    }
}
