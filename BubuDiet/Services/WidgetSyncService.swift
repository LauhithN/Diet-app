import Foundation
import WidgetKit

struct WidgetSyncService {
    func sync(settings: AppSettings, weeklyPlan: WeeklyPlan, weightEntries: [WeightEntry]) {
        let planner = MealPlannerService()
        let today = planner.dayPlan(for: Date(), in: weeklyPlan) ?? weeklyPlan.days.first
        let currentWeight = weightEntries.sorted { $0.date < $1.date }.last?.weight ?? settings.startingWeight
        let nextReminder = settings.notificationPreferences.nextReminder()
        let motivationLine = motivationalLine(for: today)

        let snapshot = WidgetSnapshot(
            displayName: settings.displayName,
            consumedCalories: today?.totalConsumedCalories ?? 0,
            remainingCalories: max(settings.dailyCalorieTarget - (today?.totalConsumedCalories ?? 0), 0),
            mealsCompleted: today?.mealsCompletedCount ?? 0,
            totalMeals: today?.meals.count ?? 3,
            currentWeight: currentWeight,
            goalWeight: settings.goalWeight,
            poundsLost: max(settings.startingWeight - currentWeight, 0),
            nextReminderTitle: nextReminder?.title ?? "Gentle reset",
            nextReminderTimeText: nextReminder?.date.timeLabel ?? "Notifications off",
            motivationLine: motivationLine,
            updatedAt: Date()
        )

        StorageService.shared.save(widgetSnapshot: snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func motivationalLine(for today: DailyPlan?) -> String {
        guard let today else {
            return MotivationalCopy.messages.first ?? "A calm routine is still progress."
        }

        switch today.mealsCompletedCount {
        case today.meals.count:
            return "Everything planned for today has been cared for."
        case 2...:
            return "The day is almost complete. Keep the pace gentle."
        default:
            return MotivationalCopy.messages.randomElement() ?? "A calm routine is still progress."
        }
    }
}
