import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func currentSettings() async -> UNNotificationSettings {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }

    func scheduleNotifications(preferences: NotificationPreferences, displayName: String) async throws {
        center.removePendingNotificationRequests(withIdentifiers: ReminderIdentifiers.allCases)

        guard preferences.notificationsEnabled else { return }

        try await schedule(
            identifier: ReminderIdentifiers.breakfast,
            title: "Breakfast time, \(displayName) 🌸",
            body: "A simple start keeps the day calm and on track.",
            enabled: preferences.breakfastEnabled,
            time: preferences.breakfastTime
        )

        try await schedule(
            identifier: ReminderIdentifiers.lunch,
            title: "Lunch is ready for your goal today",
            body: "A steady, high-protein lunch can make the evening easier.",
            enabled: preferences.lunchEnabled,
            time: preferences.lunchTime
        )

        try await schedule(
            identifier: ReminderIdentifiers.dinner,
            title: "Dinner time, \(displayName)",
            body: "One balanced dinner is enough. No need to chase perfection.",
            enabled: preferences.dinnerEnabled,
            time: preferences.dinnerTime
        )

        try await schedule(
            identifier: ReminderIdentifiers.weighIn,
            title: "Log your progress for today",
            body: "A quick weigh-in keeps the trend visible, not emotional.",
            enabled: preferences.weighInEnabled,
            time: preferences.weighInTime
        )

        try await schedule(
            identifier: ReminderIdentifiers.water,
            title: "Water check for \(displayName) 💧",
            body: "A glass of water is a small act of care for the rest of the day.",
            enabled: preferences.waterReminderEnabled,
            time: preferences.waterReminderTime
        )

        try await schedule(
            identifier: ReminderIdentifiers.motivation,
            title: "A little note for \(displayName) 💖",
            body: RomanticMessageGenerator.notificationBody(for: displayName),
            enabled: preferences.motivationReminderEnabled,
            time: preferences.motivationReminderTime
        )
    }

    private func schedule(
        identifier: String,
        title: String,
        body: String,
        enabled: Bool,
        time: Date
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
