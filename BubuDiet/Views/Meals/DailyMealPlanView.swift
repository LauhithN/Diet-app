import SwiftUI

private enum MealPlannerMode: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"

    var id: String { rawValue }
}

struct DailyMealPlanView: View {
    @EnvironmentObject private var mealPlanViewModel: MealPlanViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    @State private var mode: MealPlannerMode = .daily

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    Picker("Mode", selection: $mode) {
                        ForEach(MealPlannerMode.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)

                    if mode == .daily {
                        dailyContent
                    } else {
                        WeeklyMealPlanView(weeklyPlan: mealPlanViewModel.weeklyPlan)
                    }
                }
                .padding()
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Meal Planner")
        }
    }

    @ViewBuilder
    private var dailyContent: some View {
        if let selectedDay = mealPlanViewModel.selectedDay {
            VStack(spacing: 16) {
                dayPicker

                VStack(alignment: .leading, spacing: 12) {
                    Text(selectedDay.date.dayLabel)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.cocoa)
                    Text("Target \(settingsViewModel.settings.dailyCalorieTarget) calories • \(selectedDay.mealsCompletedCount) of \(selectedDay.meals.count) meals completed")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack {
                        summaryPill(title: "Consumed", value: "\(selectedDay.totalConsumedCalories) cal")
                        summaryPill(title: "Remaining", value: "\(max(settingsViewModel.settings.dailyCalorieTarget - selectedDay.totalConsumedCalories, 0)) cal")
                        summaryPill(title: "Cost", value: selectedDay.totalEstimatedCostCAD.asCurrencyCAD)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .bubuCard()

                ForEach(selectedDay.orderedMeals) { meal in
                    MealCardView(
                        meal: meal,
                        alternatives: mealPlanViewModel.alternatives(for: meal),
                        onToggleComplete: {
                            mealPlanViewModel.toggleCompleted(for: meal.id, in: selectedDay.id)
                        },
                        onCompletionChange: { value in
                            mealPlanViewModel.setCompletion(for: meal.id, in: selectedDay.id, percentage: value)
                        },
                        onPortionChange: { value in
                            mealPlanViewModel.setPortion(for: meal.id, in: selectedDay.id, portionMultiplier: value)
                        },
                        onSwap: { replacement in
                            mealPlanViewModel.swapMeal(in: selectedDay.id, mealID: meal.id, with: replacement)
                        }
                    )
                }

                manualCaloriesCard(day: selectedDay)
            }
        } else {
            Text("No plan available yet.")
                .frame(maxWidth: .infinity, minHeight: 200)
                .bubuCard()
        }
    }

    private var dayPicker: some View {
        Picker(
            "Day",
            selection: Binding(
                get: { mealPlanViewModel.selectedDayID ?? mealPlanViewModel.weeklyPlan.days.first?.id ?? UUID() },
                set: { mealPlanViewModel.select(dayID: $0) }
            )
        ) {
            ForEach(Array(mealPlanViewModel.weeklyPlan.days.enumerated()), id: \.element.id) { index, day in
                Text("Day \(index + 1) • \(day.date.shortDateLabel)").tag(day.id)
            }
        }
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func manualCaloriesCard(day: DailyPlan) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Manual calories")
                .font(.headline)
                .foregroundStyle(Theme.cocoa)

            Text("Add a snack or adjust today’s total if a meal needed correction.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField(
                "Snack calories",
                value: Binding(
                    get: { day.manualSnackCalories },
                    set: { mealPlanViewModel.setManualSnackCalories(for: day.id, value: $0) }
                ),
                format: .number
            )
            .keyboardType(.numberPad)
            .textFieldStyle(.roundedBorder)

            TextField(
                "Correction calories",
                value: Binding(
                    get: { day.manualCorrectionCalories },
                    set: { mealPlanViewModel.setManualCorrectionCalories(for: day.id, value: $0) }
                ),
                format: .number
            )
            .keyboardType(.numbersAndPunctuation)
            .textFieldStyle(.roundedBorder)

            if day.mealsCompletedCount == day.meals.count {
                Text("Daily target completed.")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.rose)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard()
    }

    private func summaryPill(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.cocoa)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.cream)
        )
    }
}

#Preview {
    DailyMealPlanView()
        .environmentObject(MealPlanViewModel())
        .environmentObject(SettingsViewModel())
}
