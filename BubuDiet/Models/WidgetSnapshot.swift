import Foundation

struct WidgetSnapshot: Codable, Equatable {
    var displayName: String
    var consumedCalories: Int
    var remainingCalories: Int
    var mealsCompleted: Int
    var totalMeals: Int
    var currentWeight: Double
    var goalWeight: Double
    var poundsLost: Double
    var updatedAt: Date

    static var placeholder: WidgetSnapshot {
        WidgetSnapshot(
            displayName: "Bubu",
            consumedCalories: 960,
            remainingCalories: 540,
            mealsCompleted: 2,
            totalMeals: 3,
            currentWeight: 218,
            goalWeight: 180,
            poundsLost: 7,
            updatedAt: Date()
        )
    }
}
