import SwiftUI

struct WeeklyMealPlanView: View {
    let weeklyPlan: WeeklyPlan

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            ForEach(Array(weeklyPlan.days.enumerated()), id: \.element.id) { index, day in
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                            Text("Day \(index + 1)")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(Theme.Palette.rose)
                            Text(day.date.fullDateLabel)
                                .font(Theme.Typography.section)
                                .foregroundStyle(Theme.Palette.cocoa)
                        }

                        Spacer()

                        Text(day.totalPlannedCalories.calorieText)
                            .font(Theme.Typography.bodyStrong)
                            .foregroundStyle(Theme.Palette.cocoa)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .padding(.vertical, Theme.Spacing.xs)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Theme.Palette.surfaceRaised)
                            )
                    }

                    ForEach(day.orderedMeals) { meal in
                        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                            Text(meal.type.rawValue)
                                .font(Theme.Typography.caption)
                                .foregroundStyle(Theme.Palette.rose)
                                .frame(width: 74, alignment: .leading)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(meal.name)
                                    .font(Theme.Typography.bodyStrong)
                                    .foregroundStyle(Theme.Palette.cocoa)
                                Text("\(meal.adjustedCalories.calorieText) • \(meal.adjustedProteinGrams.oneDecimalText)g protein")
                                    .font(Theme.Typography.footnote)
                                    .foregroundStyle(Theme.Palette.mist)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }

                    HStack(spacing: Theme.Spacing.xs) {
                        BubuMetricPill(title: "Daily calories", value: day.totalPlannedCalories.calorieText, icon: "flame.fill")
                        BubuMetricPill(title: "Estimated cost", value: day.totalEstimatedCostCAD.asCurrencyCAD, icon: "cart.fill", accent: Theme.Palette.sage)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .bubuCard(tint: Theme.Palette.surface)
            }
        }
    }
}

#Preview {
    ScrollView {
        WeeklyMealPlanView(weeklyPlan: SampleData.weeklyPlan())
            .padding()
    }
    .background(BubuScreenBackground())
}
