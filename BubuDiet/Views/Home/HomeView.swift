import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    heroCard

                    CalorieRingView(
                        progress: homeViewModel.progressFraction,
                        consumed: homeViewModel.caloriesConsumedToday,
                        remaining: homeViewModel.caloriesRemainingToday
                    )
                    .frame(maxWidth: .infinity)
                    .bubuCard()

                    LazyVGrid(columns: columns, spacing: 14) {
                        SummaryCardView(
                            title: "Current Weight",
                            value: "\(homeViewModel.currentWeight.oneDecimalText) lbs",
                            detail: "\(homeViewModel.poundsLost.oneDecimalText) lbs lost",
                            systemImage: "scalemass"
                        )
                        SummaryCardView(
                            title: "Goal Weight",
                            value: "\(homeViewModel.goalWeight.oneDecimalText) lbs",
                            detail: "\(homeViewModel.remainingPounds.oneDecimalText) lbs to go",
                            systemImage: "flag.checkered"
                        )
                        SummaryCardView(
                            title: "Calorie Target",
                            value: "\(homeViewModel.calorieTarget) cal",
                            detail: "\(homeViewModel.caloriesRemainingToday) remaining",
                            systemImage: "target"
                        )
                        SummaryCardView(
                            title: "Meals Today",
                            value: homeViewModel.mealsCompletedText,
                            detail: homeViewModel.nextReminderText,
                            systemImage: "bell.badge"
                        )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today’s meals")
                            .font(.headline)
                            .foregroundStyle(Theme.cocoa)
                        Text(homeViewModel.todayMealsSummary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Divider()
                        Text(homeViewModel.motivationalMessage)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.rose)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bubuCard()
                }
                .padding()
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("BubuDiet")
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Made with love for Bubu ❤️")
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.cocoa)
            Text("A gentle daily plan built around simple meals, steady progress, and a soft routine that actually fits real life.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                Label("\(homeViewModel.caloriesConsumedToday) eaten", systemImage: "flame")
                Label(homeViewModel.nextReminderText, systemImage: "clock")
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Theme.cocoa)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Theme.heroGradient)
                .shadow(color: .black.opacity(0.08), radius: 22, x: 0, y: 14)
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(HomeViewModel())
}
