import SwiftUI
import WidgetKit

@main
struct BubuDietWidgetBundle: WidgetBundle {
    var body: some Widget {
        CalorieProgressWidget()
        DailyMealReminderWidget()
        WeightProgressWidget()
        RomanticMotivationalWidget()
    }
}
