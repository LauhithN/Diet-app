import SwiftUI

@main
struct BubuDietApp: App {
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var mealPlanViewModel = MealPlanViewModel()
    @StateObject private var groceryListViewModel = GroceryListViewModel()
    @StateObject private var progressViewModel = ProgressViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var notificationViewModel = NotificationViewModel()
    @StateObject private var aiViewModel = AIViewModel()
    @StateObject private var exerciseViewModel = ExerciseViewModel()

    private let widgetSyncService = WidgetSyncService()

    init() {
        StorageService.shared.seedIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(
                homeViewModel: homeViewModel,
                mealPlanViewModel: mealPlanViewModel,
                groceryListViewModel: groceryListViewModel,
                progressViewModel: progressViewModel,
                settingsViewModel: settingsViewModel,
                notificationViewModel: notificationViewModel,
                aiViewModel: aiViewModel,
                exerciseViewModel: exerciseViewModel,
                widgetSyncService: widgetSyncService
            )
            .environmentObject(homeViewModel)
            .environmentObject(mealPlanViewModel)
            .environmentObject(groceryListViewModel)
            .environmentObject(progressViewModel)
            .environmentObject(settingsViewModel)
            .environmentObject(notificationViewModel)
            .environmentObject(aiViewModel)
            .environmentObject(exerciseViewModel)
        }
    }
}

private struct AppRootView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var mealPlanViewModel: MealPlanViewModel
    @ObservedObject var groceryListViewModel: GroceryListViewModel
    @ObservedObject var progressViewModel: ProgressViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var notificationViewModel: NotificationViewModel
    @ObservedObject var aiViewModel: AIViewModel
    @ObservedObject var exerciseViewModel: ExerciseViewModel

    let widgetSyncService: WidgetSyncService

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "heart.text.square")
                }

            DailyMealPlanView()
                .tabItem {
                    Label("Meals", systemImage: "fork.knife")
                }

            GroceryListView()
                .tabItem {
                    Label("Grocery", systemImage: "cart")
                }

            BubuProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }

            ExercisePlanView()
                .tabItem {
                    Label("Exercise", systemImage: "figure.walk")
                }

            AIMealSuggestionView()
                .tabItem {
                    Label("AI", systemImage: "sparkles")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(Theme.rose)
        .task {
            await notificationViewModel.refreshAuthorizationStatus()
            refreshSharedState()
        }
        .onChange(of: mealPlanViewModel.weeklyPlan) { _, _ in
            refreshSharedState()
        }
        .onChange(of: settingsViewModel.settings) { _, _ in
            refreshSharedState()
        }
        .onChange(of: progressViewModel.weightEntries) { _, _ in
            refreshSharedState()
        }
    }

    private func refreshSharedState() {
        mealPlanViewModel.refreshCurrentWeekIfNeeded()
        groceryListViewModel.reload(from: mealPlanViewModel.weeklyPlan)
        homeViewModel.refresh(
            settings: settingsViewModel.settings,
            weeklyPlan: mealPlanViewModel.weeklyPlan,
            weightEntries: progressViewModel.weightEntries
        )
        widgetSyncService.sync(
            settings: settingsViewModel.settings,
            weeklyPlan: mealPlanViewModel.weeklyPlan,
            weightEntries: progressViewModel.weightEntries
        )
    }
}
