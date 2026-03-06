import Foundation
import UserNotifications

@MainActor
final class NotificationViewModel: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var statusMessage = "Notifications not checked yet."

    private let service: NotificationService

    init(service: NotificationService = .shared) {
        self.service = service
    }

    func refreshAuthorizationStatus() async {
        let settings = await service.currentSettings()
        authorizationStatus = settings.authorizationStatus
        statusMessage = switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            "Notifications are allowed."
        case .denied:
            "Notifications are denied in iPhone Settings."
        case .notDetermined:
            "Permission has not been requested yet."
        @unknown default:
            "Notification status is unknown."
        }
    }

    func requestPermission() async {
        let granted = await service.requestPermission()
        await refreshAuthorizationStatus()
        statusMessage = granted ? "Permission granted. You can schedule reminders now." : "Permission was not granted."
    }

    func scheduleNotifications(using settings: AppSettings) async {
        do {
            try await service.scheduleNotifications(
                preferences: settings.notificationPreferences,
                displayName: settings.displayName
            )
            statusMessage = "Meal, water, weigh-in, and motivational reminders are scheduled on this iPhone."
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}
