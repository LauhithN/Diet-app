import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var navigationModel: AppNavigationModel

    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.sm),
        GridItem(.flexible(), spacing: Theme.Spacing.sm)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    heroCard
                    quickActionsCard
                    calorieCard

                    LazyVGrid(columns: columns, spacing: Theme.Spacing.sm) {
                        SummaryCardView(
                            title: "Current Weight",
                            value: "\(homeViewModel.currentWeight.oneDecimalText) lbs",
                            detail: "\(homeViewModel.poundsLost.oneDecimalText) lbs down since the start",
                            systemImage: "scalemass.fill"
                        )
                        SummaryCardView(
                            title: "Goal Weight",
                            value: "\(homeViewModel.goalWeight.oneDecimalText) lbs",
                            detail: "\(homeViewModel.remainingPounds.oneDecimalText) lbs left to reach it",
                            systemImage: "flag.checkered.2.crossed"
                        )
                        SummaryCardView(
                            title: "Calorie Target",
                            value: homeViewModel.calorieTarget.calorieText,
                            detail: "\(homeViewModel.caloriesRemainingToday) calories still open",
                            systemImage: "target"
                        )
                        SummaryCardView(
                            title: "Today’s Meals",
                            value: homeViewModel.mealsCompletedText,
                            detail: homeViewModel.nextReminderText,
                            systemImage: "bell.badge.fill"
                        )
                    }

                    todayMealsCard
                    encouragementCard
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.lg)
            }
            .bubuScreenBackground()
            .navigationTitle("BubuDiet")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("For \(homeViewModel.displayName)")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Palette.rose)
                .tracking(1.2)

            Text("A softer daily rhythm for feeling nourished, calm, and gently on track.")
                .font(Theme.Typography.hero)
                .foregroundStyle(Theme.Palette.cocoa)
                .fixedSize(horizontal: false, vertical: true)

            Text("Today already has structure: keep the plan simple, let the reminders do the nudging, and protect the feeling of ease.")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Palette.mist)

            HStack(spacing: Theme.Spacing.xs) {
                heroBadge(text: "\(homeViewModel.caloriesConsumedToday) eaten", icon: "fork.knife")
                heroBadge(text: homeViewModel.nextReminderText, icon: "clock.fill")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.hero, style: .continuous)
                .fill(Theme.Gradients.hero)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.hero, style: .continuous)
                .stroke(Theme.Palette.border.opacity(0.8), lineWidth: 1)
        )
        .shadow(color: Theme.Palette.shadow, radius: 24, x: 0, y: 14)
    }

    private var quickActionsCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            BubuSectionHeader(
                eyebrow: "Quick actions",
                title: "Move through the day",
                subtitle: "Jump straight into the part of the routine you want to focus on."
            )

            HStack(spacing: Theme.Spacing.xs) {
                quickActionButton(
                    title: "Meals",
                    subtitle: "Plan and grocery flow",
                    icon: "fork.knife.circle.fill"
                ) {
                    navigationModel.openMeals()
                }

                quickActionButton(
                    title: "Progress",
                    subtitle: "See the trend",
                    icon: "chart.line.uptrend.xyaxis.circle.fill"
                ) {
                    navigationModel.openProgress()
                }
            }

            HStack(spacing: Theme.Spacing.xs) {
                quickActionButton(
                    title: "Movement",
                    subtitle: "Light exercise",
                    icon: "figure.walk.circle.fill"
                ) {
                    navigationModel.openExercise()
                }

                quickActionButton(
                    title: "AI idea",
                    subtitle: "Swap a meal gently",
                    icon: "sparkles"
                ) {
                    navigationModel.openAI()
                }
            }
        }
        .bubuCard(tint: Theme.Palette.surface)
    }

    private var calorieCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            BubuSectionHeader(
                eyebrow: "Daily overview",
                title: "Calorie balance",
                subtitle: "A warm snapshot of what has already been handled today."
            )

            ViewThatFits(in: .horizontal) {
                HStack(spacing: Theme.Spacing.lg) {
                    CalorieRingView(
                        progress: homeViewModel.progressFraction,
                        consumed: homeViewModel.caloriesConsumedToday,
                        remaining: homeViewModel.caloriesRemainingToday
                    )

                    VStack(spacing: Theme.Spacing.sm) {
                        BubuMetricPill(title: "Consumed", value: homeViewModel.caloriesConsumedToday.calorieText, icon: "flame.fill")
                        BubuMetricPill(title: "Remaining", value: homeViewModel.caloriesRemainingToday.calorieText, icon: "moon.stars.fill", accent: Theme.Palette.sage)
                        BubuMetricPill(title: "Meals completed", value: homeViewModel.mealsCompletedText, icon: "checkmark.circle.fill", accent: Theme.Palette.roseDeep)
                    }
                }

                VStack(spacing: Theme.Spacing.md) {
                    CalorieRingView(
                        progress: homeViewModel.progressFraction,
                        consumed: homeViewModel.caloriesConsumedToday,
                        remaining: homeViewModel.caloriesRemainingToday
                    )
                    HStack(spacing: Theme.Spacing.xs) {
                        BubuMetricPill(title: "Consumed", value: homeViewModel.caloriesConsumedToday.calorieText, icon: "flame.fill")
                        BubuMetricPill(title: "Remaining", value: homeViewModel.caloriesRemainingToday.calorieText, icon: "moon.stars.fill", accent: Theme.Palette.sage)
                    }
                    BubuMetricPill(title: "Meals completed", value: homeViewModel.mealsCompletedText, icon: "checkmark.circle.fill", accent: Theme.Palette.roseDeep)
                }
            }
        }
        .bubuCard(tint: Theme.Palette.surface)
    }

    private var todayMealsCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            BubuSectionHeader(
                eyebrow: "Today’s meals",
                title: "What’s on the plate",
                subtitle: "A clean read on the current plan, with each meal kept simple and easy to follow."
            )

            ForEach(todayMealLines, id: \.self) { line in
                HStack(alignment: .top, spacing: Theme.Spacing.xs) {
                    Image(systemName: "leaf.circle.fill")
                        .foregroundStyle(Theme.Palette.rose)
                    Text(line)
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Palette.cocoa)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surface)
    }

    private var encouragementCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Gentle note")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Palette.rose)

            Text(homeViewModel.motivationalMessage)
                .font(Theme.Typography.section)
                .foregroundStyle(Theme.Palette.cocoa)

            Text("Small, repeatable choices are the whole point. The app should always feel like support, not pressure.")
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Palette.mist)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surfaceRaised)
    }

    private var todayMealLines: [String] {
        let lines = homeViewModel.todayMealsSummary
            .split(separator: "•")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return lines.isEmpty ? ["No meals planned yet."] : lines
    }

    private func heroBadge(text: String, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(Theme.Typography.caption)
            .foregroundStyle(Theme.Palette.cocoa)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(
                Capsule(style: .continuous)
                    .fill(Theme.Palette.surface.opacity(0.72))
            )
    }

    private func quickActionButton(
        title: String,
        subtitle: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Theme.Palette.rose)
                Text(title)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Palette.cocoa)
                Text(subtitle)
                    .font(Theme.Typography.footnote)
                    .foregroundStyle(Theme.Palette.mist)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 128, alignment: .leading)
            .padding(Theme.Spacing.sm)
        }
        .buttonStyle(BubuSecondaryButtonStyle())
    }
}

#Preview {
    HomeView()
        .environmentObject(HomeViewModel())
        .environmentObject(AppNavigationModel())
}
