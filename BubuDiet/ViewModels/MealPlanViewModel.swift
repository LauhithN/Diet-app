import Foundation

@MainActor
final class MealPlanViewModel: ObservableObject {
    @Published var weeklyPlan: WeeklyPlan
    @Published var selectedDayID: UUID?

    private let storage: StorageService
    private let planner: MealPlannerService

    init(storage: StorageService = .shared, planner: MealPlannerService = MealPlannerService()) {
        self.storage = storage
        self.planner = planner

        let storedPlan = storage.loadWeeklyPlan()
        let currentPlan = planner.ensureCurrentWeek(storedPlan)
        self.weeklyPlan = currentPlan
        self.selectedDayID = planner.dayPlan(for: Date(), in: currentPlan)?.id ?? currentPlan.days.first?.id

        if currentPlan != storedPlan {
            storage.save(weeklyPlan: currentPlan)
        }
    }

    var selectedDay: DailyPlan? {
        if let selectedDayID, let selected = weeklyPlan.days.first(where: { $0.id == selectedDayID }) {
            return selected
        }

        return todayPlan
    }

    var todayPlan: DailyPlan? {
        planner.dayPlan(for: Date(), in: weeklyPlan) ?? weeklyPlan.days.first
    }

    func refreshCurrentWeekIfNeeded() {
        let refreshed = planner.ensureCurrentWeek(weeklyPlan)
        guard refreshed != weeklyPlan else { return }
        weeklyPlan = refreshed
        selectedDayID = planner.dayPlan(for: Date(), in: refreshed)?.id ?? refreshed.days.first?.id
        persist()
    }

    func select(dayID: UUID) {
        selectedDayID = dayID
    }

    func alternatives(for meal: Meal) -> [Meal] {
        planner.alternatives(for: meal.type, excluding: meal)
    }

    func setCompletion(for mealID: UUID, in dayID: UUID, percentage: Double) {
        updateMeal(mealID: mealID, dayID: dayID) { meal in
            meal.completionPercentage = min(max(percentage, 0), 1)
        }
    }

    func toggleCompleted(for mealID: UUID, in dayID: UUID) {
        updateMeal(mealID: mealID, dayID: dayID) { meal in
            meal.completionPercentage = meal.isCompleted ? 0 : 1
        }
    }

    func setPortion(for mealID: UUID, in dayID: UUID, portionMultiplier: Double) {
        updateMeal(mealID: mealID, dayID: dayID) { meal in
            meal.portionMultiplier = min(max(portionMultiplier, 0.5), 2.0)
        }
    }

    func swapMeal(in dayID: UUID, mealID: UUID, with replacement: Meal) {
        guard let dayIndex = weeklyPlan.days.firstIndex(where: { $0.id == dayID }) else { return }
        guard let mealIndex = weeklyPlan.days[dayIndex].meals.firstIndex(where: { $0.id == mealID }) else { return }
        weeklyPlan.days[dayIndex].meals[mealIndex] = replacement
        persist()
    }

    func setManualSnackCalories(for dayID: UUID, value: Int) {
        guard let dayIndex = weeklyPlan.days.firstIndex(where: { $0.id == dayID }) else { return }
        weeklyPlan.days[dayIndex].manualSnackCalories = max(value, 0)
        persist()
    }

    func setManualCorrectionCalories(for dayID: UUID, value: Int) {
        guard let dayIndex = weeklyPlan.days.firstIndex(where: { $0.id == dayID }) else { return }
        weeklyPlan.days[dayIndex].manualCorrectionCalories = min(max(value, -500), 500)
        persist()
    }

    private func updateMeal(mealID: UUID, dayID: UUID, update: (inout Meal) -> Void) {
        guard let dayIndex = weeklyPlan.days.firstIndex(where: { $0.id == dayID }) else { return }
        guard let mealIndex = weeklyPlan.days[dayIndex].meals.firstIndex(where: { $0.id == mealID }) else { return }
        update(&weeklyPlan.days[dayIndex].meals[mealIndex])
        persist()
    }

    private func persist() {
        storage.save(weeklyPlan: weeklyPlan)
    }
}
