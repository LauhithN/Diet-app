import Foundation

struct DailyPlan: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var meals: [Meal]
    var manualSnackCalories: Int
    var manualCorrectionCalories: Int

    init(
        id: UUID = UUID(),
        date: Date,
        meals: [Meal],
        manualSnackCalories: Int = 0,
        manualCorrectionCalories: Int = 0
    ) {
        self.id = id
        self.date = date
        self.meals = meals
        self.manualSnackCalories = manualSnackCalories
        self.manualCorrectionCalories = manualCorrectionCalories
    }

    var orderedMeals: [Meal] {
        meals.sorted { $0.type.sortOrder < $1.type.sortOrder }
    }

    var totalPlannedCalories: Int {
        meals.reduce(0) { $0 + $1.adjustedCalories }
    }

    var totalConsumedCalories: Int {
        meals.reduce(0) { $0 + $1.consumedCalories } + manualSnackCalories + manualCorrectionCalories
    }

    var totalEstimatedCostCAD: Double {
        meals.reduce(0) { $0 + $1.adjustedCostCAD }
    }

    var mealsCompletedCount: Int {
        meals.filter(\.isCompleted).count
    }
}
