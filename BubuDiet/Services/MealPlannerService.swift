import Foundation

struct MealPlannerService {
    func ensureCurrentWeek(_ weeklyPlan: WeeklyPlan, referenceDate: Date = Date()) -> WeeklyPlan {
        weeklyPlan.contains(referenceDate) ? weeklyPlan : SampleData.weeklyPlan(startingAt: referenceDate)
    }

    func dayPlan(for date: Date, in weeklyPlan: WeeklyPlan) -> DailyPlan? {
        weeklyPlan.days.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func dayIndex(for date: Date, in weeklyPlan: WeeklyPlan) -> Int? {
        weeklyPlan.days.firstIndex { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func alternatives(for type: MealType, excluding meal: Meal) -> [Meal] {
        let library: [Meal]
        switch type {
        case .breakfast:
            library = SampleData.breakfastMeals()
        case .lunch:
            library = SampleData.lunchMeals()
        case .dinner:
            library = SampleData.dinnerMeals()
        }

        return library.filter { $0.name != meal.name }
    }
}
