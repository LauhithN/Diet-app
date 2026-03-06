import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var currentWeight: Double = 0
    @Published var goalWeight: Double = 0
    @Published var poundsLost: Double = 0
    @Published var remainingPounds: Double = 0
    @Published var calorieTarget: Int = AppConstants.defaultCalorieTarget
    @Published var caloriesConsumedToday: Int = 0
    @Published var caloriesRemainingToday: Int = AppConstants.defaultCalorieTarget
    @Published var progressFraction: Double = 0
    @Published var todayMealsSummary = "No meals planned yet."
    @Published var nextReminderText = "Notifications off"
    @Published var motivationalMessage = RomanticMessageGenerator.randomMessage(for: "Bubu")
    @Published var mealsCompletedText = "0 of 3 meals completed"
    @Published var displayName = "Bubu"

    private let planner = MealPlannerService()

    func refresh(settings: AppSettings, weeklyPlan: WeeklyPlan, weightEntries: [WeightEntry]) {
        displayName = settings.displayName
        calorieTarget = settings.dailyCalorieTarget
        goalWeight = settings.goalWeight
        currentWeight = weightEntries.sorted { $0.date < $1.date }.last?.weight ?? settings.startingWeight
        poundsLost = max(settings.startingWeight - currentWeight, 0)
        remainingPounds = max(currentWeight - settings.goalWeight, 0)

        let today = planner.dayPlan(for: Date(), in: weeklyPlan) ?? weeklyPlan.days.first
        caloriesConsumedToday = today?.totalConsumedCalories ?? 0
        caloriesRemainingToday = max(settings.dailyCalorieTarget - caloriesConsumedToday, 0)
        progressFraction = min(max(Double(caloriesConsumedToday) / Double(max(settings.dailyCalorieTarget, 1)), 0), 1)

        if let today {
            let names = today.orderedMeals.map { "\($0.type.rawValue): \($0.name)" }
            todayMealsSummary = names.joined(separator: " • ")
            mealsCompletedText = "\(today.mealsCompletedCount) of \(today.meals.count) meals completed"
        } else {
            todayMealsSummary = "No meals planned yet."
            mealsCompletedText = "0 of 3 meals completed"
        }

        if let reminder = settings.notificationPreferences.nextReminder() {
            nextReminderText = "\(reminder.title) at \(reminder.date.timeLabel)"
        } else {
            nextReminderText = "Notifications off"
        }

        motivationalMessage = message(for: today)
    }

    private func message(for today: DailyPlan?) -> String {
        guard let today else {
            return RomanticMessageGenerator.randomMessage(for: displayName)
        }

        return RomanticMessageGenerator.homeMessage(
            for: displayName,
            mealsCompleted: today.mealsCompletedCount,
            totalMeals: today.meals.count
        )
    }
}
