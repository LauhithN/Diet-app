import Foundation

enum AppConstants {
    static let appName = "BubuDiet"
    static let appGroupIdentifier = "group.com.bubudiet.shared"
    static let defaultCalorieTarget = 1500
    static let kimiEndpoint = "https://integrate.api.nvidia.com/v1/chat/completions"
    static let kimiDefaultModel = "moonshotai/kimi-k2-instruct-0905"
}

enum StorageKeys {
    static let settings = "bubudiet.settings"
    static let weeklyPlan = "bubudiet.weeklyPlan"
    static let weightEntries = "bubudiet.weightEntries"
    static let exerciseTasks = "bubudiet.exerciseTasks"
    static let widgetSnapshot = "bubudiet.widgetSnapshot"
}

enum ReminderIdentifiers {
    static let breakfast = "bubudiet.breakfast"
    static let lunch = "bubudiet.lunch"
    static let dinner = "bubudiet.dinner"
    static let weighIn = "bubudiet.weighin"
    static let water = "bubudiet.water"
    static let motivation = "bubudiet.motivation"

    static let allCases = [
        breakfast,
        lunch,
        dinner,
        weighIn,
        water,
        motivation
    ]
}

enum SecureStorageKeys {
    static let kimiAPIKey = "bubudiet.kimi.apiKey"
}

enum MotivationalCopy {
    static let messages = [
        "You're doing amazing today, Bubu.",
        "Every step brings you closer to your goal.",
        "Your future self will thank you.",
        "A calm routine is still progress.",
        "Consistency wrapped in kindness is enough."
    ]
}
