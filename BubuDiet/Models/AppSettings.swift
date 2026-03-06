import Foundation

struct AppSettings: Codable, Equatable {
    var displayName: String
    var startingWeight: Double
    var goalWeight: Double
    var dailyCalorieTarget: Int
    var aiSuggestionsEnabled: Bool
    var notificationPreferences: NotificationPreferences

    static var `default`: AppSettings {
        AppSettings(
            displayName: "Bubu",
            startingWeight: 225,
            goalWeight: 180,
            dailyCalorieTarget: 1500,
            aiSuggestionsEnabled: true,
            notificationPreferences: .default
        )
    }
}
