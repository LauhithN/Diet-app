import Charts
import SwiftUI

struct CalorieTrendChartView: View {
    let plans: [DailyPlan]
    let targetCalories: Int

    private var orderedPlans: [DailyPlan] {
        plans.sorted { $0.date < $1.date }
    }

    var body: some View {
        if orderedPlans.isEmpty {
            ContentUnavailableView("No calorie data yet", systemImage: "flame")
                .frame(maxWidth: .infinity, minHeight: 220)
        } else {
            Chart {
                ForEach(orderedPlans) { plan in
                    BarMark(
                        x: .value("Day", plan.date, unit: .day),
                        y: .value("Calories", plan.totalConsumedCalories)
                    )
                    .foregroundStyle(Theme.Palette.rose.opacity(0.88))
                    .cornerRadius(8)
                }

                RuleMark(y: .value("Target", targetCalories))
                    .foregroundStyle(Theme.Palette.sage)
                    .lineStyle(.init(lineWidth: 2, dash: [6, 5]))
                    .annotation(position: .topTrailing) {
                        Text("Target \(targetCalories.calorieText)")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Palette.cocoa)
                    }
            }
            .chartXAxis {
                AxisMarks(values: orderedPlans.map(\.date)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Theme.Palette.border.opacity(0.6))
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date.shortDateLabel)
                                .font(Theme.Typography.caption)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Theme.Palette.border.opacity(0.6))
                    AxisValueLabel()
                        .font(Theme.Typography.caption)
                }
            }
            .chartLegend(.hidden)
            .frame(height: 250)
        }
    }
}

#Preview {
    CalorieTrendChartView(
        plans: SampleData.weeklyPlan().days,
        targetCalories: AppConstants.defaultCalorieTarget
    )
    .padding()
}
