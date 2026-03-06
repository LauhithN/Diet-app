import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private let manager: NotificationManager

    private init(manager: NotificationManager = .shared) {
        self.manager = manager
    }

    func currentSettings() async -> UNNotificationSettings {
        await manager.currentSettings()
    }

    func requestPermission() async -> Bool {
        await manager.requestPermission()
    }

    func scheduleNotifications(preferences: NotificationPreferences, displayName: String) async throws {
        try await manager.scheduleNotifications(preferences: preferences, displayName: displayName)
    }
}
