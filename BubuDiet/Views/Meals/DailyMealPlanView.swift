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
                VStack(spacing: Theme.Spacing.lg) {
                    headerCard

                    Picker("Mode", selection: $mode) {
                        ForEach(MealPlannerMode.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, Theme.Spacing.xxs)

                    if mode == .daily {
                        dailyContent
                    } else {
                        WeeklyMealPlanView(weeklyPlan: mealPlanViewModel.weeklyPlan)
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.lg)
            }
            .bubuScreenBackground()
            .navigationTitle("Meals")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            BubuSectionHeader(
                eyebrow: "Planner",
                title: "A calm plan for the week",
                subtitle: "Meals are structured with enough guidance to feel supportive, without turning the day into a rigid checklist."
            )

            HStack(spacing: Theme.Spacing.xs) {
                BubuMetricPill(
                    title: "Weekly cost",
                    value: mealPlanViewModel.weeklyPlan.totalEstimatedCostCAD.asCurrencyCAD,
                    icon: "cart.fill"
                )
                BubuMetricPill(
                    title: "Daily target",
                    value: settingsViewModel.settings.dailyCalorieTarget.calorieText,
                    icon: "target",
                    accent: Theme.Palette.sage
                )
            }

            NavigationLink {
                GroceryListView(showsNavigationShell: false)
                    .navigationTitle("Groceries")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(.hidden, for: .tabBar)
            } label: {
                Label("Open grocery list", systemImage: "cart.circle.fill")
            }
            .buttonStyle(BubuSecondaryButtonStyle())
        }
        .bubuCard(tint: Theme.Palette.surface)
    }

    @ViewBuilder
    private var dailyContent: some View {
        if let selectedDay = mealPlanViewModel.selectedDay {
            VStack(spacing: Theme.Spacing.md) {
                dayPicker
                dayOverviewCard(for: selectedDay)

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
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Palette.mist)
                .frame(maxWidth: .infinity, minHeight: 200)
                .bubuCard(tint: Theme.Palette.surface)
        }
    }

    private var dayPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.xs) {
                ForEach(Array(mealPlanViewModel.weeklyPlan.days.enumerated()), id: \.element.id) { index, day in
                    Button {
                        mealPlanViewModel.select(dayID: day.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Day \(index + 1)")
                            Text(day.date.shortDateLabel)
                        }
                    }
                    .buttonStyle(BubuChipButtonStyle(isSelected: mealPlanViewModel.selectedDayID == day.id))
                }
            }
            .padding(.horizontal, Theme.Spacing.xxs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func dayOverviewCard(for day: DailyPlan) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(day.date.dayLabel)
                .font(Theme.Typography.largeTitle)
                .foregroundStyle(Theme.Palette.cocoa)

            Text("Target \(settingsViewModel.settings.dailyCalorieTarget.calorieText) • \(day.mealsCompletedCount) of \(day.meals.count) meals completed")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Palette.mist)

            HStack(spacing: Theme.Spacing.xs) {
                BubuMetricPill(title: "Consumed", value: day.totalConsumedCalories.calorieText, icon: "flame.fill")
                BubuMetricPill(
                    title: "Remaining",
                    value: max(settingsViewModel.settings.dailyCalorieTarget - day.totalConsumedCalories, 0).calorieText,
                    icon: "moon.stars.fill",
                    accent: Theme.Palette.sage
                )
                BubuMetricPill(title: "Cost", value: day.totalEstimatedCostCAD.asCurrencyCAD, icon: "dollarsign.circle.fill", accent: Theme.Palette.roseDeep)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surfaceRaised)
    }

    private func manualCaloriesCard(day: DailyPlan) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            BubuSectionHeader(
                eyebrow: "Adjustments",
                title: "Manual calories",
                subtitle: "Keep corrections easy for snacks, restaurant swaps, or anything that drifted slightly off plan."
            )

            TextField(
                "Snack calories",
                value: Binding(
                    get: { day.manualSnackCalories },
                    set: { mealPlanViewModel.setManualSnackCalories(for: day.id, value: $0) }
                ),
                format: .number
            )
            .keyboardType(.numberPad)
            .bubuField()

            TextField(
                "Correction calories",
                value: Binding(
                    get: { day.manualCorrectionCalories },
                    set: { mealPlanViewModel.setManualCorrectionCalories(for: day.id, value: $0) }
                ),
                format: .number
            )
            .keyboardType(.numbersAndPunctuation)
            .bubuField()

            if day.mealsCompletedCount == day.meals.count {
                Text("Daily target completed.")
                    .font(Theme.Typography.bodyStrong)
                    .foregroundStyle(Theme.Palette.rose)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surface)
    }
}

#Preview {
    DailyMealPlanView()
        .environmentObject(MealPlanViewModel())
        .environmentObject(SettingsViewModel())
}
