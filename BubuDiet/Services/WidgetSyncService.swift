import Foundation
import WidgetKit

struct WidgetSyncService {
    func sync(settings: AppSettings, weeklyPlan: WeeklyPlan, weightEntries: [WeightEntry]) {
        let planner = MealPlannerService()
        let today = planner.dayPlan(for: Date(), in: weeklyPlan) ?? weeklyPlan.days.first
        let currentWeight = weightEntries.sorted { $0.date < $1.date }.last?.weight ?? settings.startingWeight
        let nextReminder = settings.notificationPreferences.nextMealReminder()
        let motivationLine = motivationalLine(for: today, displayName: settings.displayName)

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

    private func motivationalLine(for today: DailyPlan?, displayName: String) -> String {
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
