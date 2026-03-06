import Foundation

struct AIProviderSettings: Codable, Equatable {
    var baseURL: String
    var model: String

    static var `default`: AIProviderSettings {
        AIProviderSettings(
            baseURL: AppConstants.kimiEndpoint,
            model: AppConstants.kimiDefaultModel
        )
    }
}

struct AppSettings: Codable, Equatable {
    var displayName: String
    var startingWeight: Double
    var goalWeight: Double
    var dailyCalorieTarget: Int
    var aiSuggestionsEnabled: Bool
    var aiConfiguration: AIProviderSettings
    var notificationPreferences: NotificationPreferences

    enum CodingKeys: String, CodingKey {
        case displayName
        case startingWeight
        case goalWeight
        case dailyCalorieTarget
        case aiSuggestionsEnabled
        case aiConfiguration
        case notificationPreferences
    }

    static var `default`: AppSettings {
        AppSettings(
            displayName: "Bubu",
            startingWeight: 225,
            goalWeight: 180,
            dailyCalorieTarget: 1500,
            aiSuggestionsEnabled: true,
            aiConfiguration: .default,
            notificationPreferences: .default
        )
    }

    init(
        displayName: String,
        startingWeight: Double,
        goalWeight: Double,
        dailyCalorieTarget: Int,
        aiSuggestionsEnabled: Bool,
        aiConfiguration: AIProviderSettings,
        notificationPreferences: NotificationPreferences
    ) {
        self.displayName = displayName
        self.startingWeight = startingWeight
        self.goalWeight = goalWeight
        self.dailyCalorieTarget = dailyCalorieTarget
        self.aiSuggestionsEnabled = aiSuggestionsEnabled
        self.aiConfiguration = aiConfiguration
        self.notificationPreferences = notificationPreferences
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? "Bubu"
        startingWeight = try container.decodeIfPresent(Double.self, forKey: .startingWeight) ?? 225
        goalWeight = try container.decodeIfPresent(Double.self, forKey: .goalWeight) ?? 180
        dailyCalorieTarget = try container.decodeIfPresent(Int.self, forKey: .dailyCalorieTarget) ?? AppConstants.defaultCalorieTarget
        aiSuggestionsEnabled = try container.decodeIfPresent(Bool.self, forKey: .aiSuggestionsEnabled) ?? true
        aiConfiguration = try container.decodeIfPresent(AIProviderSettings.self, forKey: .aiConfiguration) ?? .default
        notificationPreferences = try container.decodeIfPresent(NotificationPreferences.self, forKey: .notificationPreferences) ?? .default
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(startingWeight, forKey: .startingWeight)
        try container.encode(goalWeight, forKey: .goalWeight)
        try container.encode(dailyCalorieTarget, forKey: .dailyCalorieTarget)
        try container.encode(aiSuggestionsEnabled, forKey: .aiSuggestionsEnabled)
        try container.encode(aiConfiguration, forKey: .aiConfiguration)
        try container.encode(notificationPreferences, forKey: .notificationPreferences)
    }
}
