import SwiftUI

struct WeeklyMealPlanView: View {
    let weeklyPlan: WeeklyPlan

    var body: some View {
        VStack(spacing: 16) {
            ForEach(Array(weeklyPlan.days.enumerated()), id: \.element.id) { index, day in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Day \(index + 1)")
                            .font(.headline)
                            .foregroundStyle(Theme.cocoa)
                        Spacer()
                        Text(day.date.fullDateLabel)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                    }

                    ForEach(day.orderedMeals) { meal in
                        HStack {
                            Text(meal.type.rawValue)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.rose)
                                .frame(width: 88, alignment: .leading)
                            Text(meal.name)
                                .font(.subheadline)
                                .foregroundStyle(Theme.cocoa)
                            Spacer()
                            Text("\(meal.adjustedCalories) cal")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()

                    HStack {
                        Label("\(day.totalPlannedCalories) cal", systemImage: "flame")
                        Spacer()
                        Label(day.totalEstimatedCostCAD.asCurrencyCAD, systemImage: "cart")
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.cocoa)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .bubuCard()
            }
        }
    }
}

#Preview {
    ScrollView {
        WeeklyMealPlanView(weeklyPlan: SampleData.weeklyPlan())
            .padding()
    }
    .background(Theme.cream)
}
