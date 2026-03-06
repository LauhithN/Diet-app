import Foundation

enum AppConstants {
    static let appName = "BubuDiet"
    static let appGroupIdentifier = "group.com.bubudiet.shared"
    static let defaultCalorieTarget = 1500
    static let kimiEndpoint = "https://api.moonshot.cn/v1/chat/completions"
    static let kimiDefaultModel = "moonshot-v1-8k"
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
}

enum MotivationalCopy {
    static let messages = [
        "Small choices add up to big changes.",
        "Consistency beats perfection.",
        "A calm routine is still progress.",
        "You are building this one day at a time.",
        "Steady habits can carry the whole year."
    ]
}
