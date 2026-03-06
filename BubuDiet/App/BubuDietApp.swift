import SwiftUI

enum AppTab: Hashable {
    case home
    case meals
    case progress
    case coach
    case settings
}

enum CoachMode: String, CaseIterable, Identifiable {
    case exercise = "Movement"
    case ai = "AI Suggestions"

    var id: String { rawValue }
}

@MainActor
final class AppNavigationModel: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var selectedCoachMode: CoachMode = .exercise

    func openMeals() {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedTab = .meals
        }
    }

    func openProgress() {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedTab = .progress
        }
    }

    func openExercise() {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedCoachMode = .exercise
            selectedTab = .coach
        }
    }

    func openAI() {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedCoachMode = .ai
            selectedTab = .coach
        }
    }
}

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
    @StateObject private var navigationModel = AppNavigationModel()

    private let widgetSyncService = WidgetSyncService()

    init() {
        StorageService.shared.seedIfNeeded()
        Theme.configureSystemAppearance()
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
            .environmentObject(navigationModel)
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

    @EnvironmentObject private var navigationModel: AppNavigationModel

    let widgetSyncService: WidgetSyncService

    var body: some View {
        TabView(selection: $navigationModel.selectedTab) {
            HomeView()
                .tag(AppTab.home)
                .tabItem {
                    Label("Home", systemImage: "heart.text.square.fill")
                }

            DailyMealPlanView()
                .tag(AppTab.meals)
                .tabItem {
                    Label("Meals", systemImage: "fork.knife.circle.fill")
                }

            BubuProgressView()
                .tag(AppTab.progress)
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis.circle.fill")
                }

            CoachHubView()
                .tag(AppTab.coach)
                .tabItem {
                    Label("Coach", systemImage: "sparkles.rectangle.stack.fill")
                }

            SettingsView()
                .tag(AppTab.settings)
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
        }
        .tint(Theme.Palette.rose)
        .animation(.easeInOut(duration: 0.25), value: navigationModel.selectedTab)
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

private struct CoachHubView: View {
    @EnvironmentObject private var navigationModel: AppNavigationModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    BubuSectionHeader(
                        eyebrow: "Gentle support",
                        title: "Coach",
                        subtitle: "Keep movement and meal ideas in one calm space, with the mood staying encouraging rather than clinical."
                    )

                    HStack(spacing: Theme.Spacing.xs) {
                        ForEach(CoachMode.allCases) { mode in
                            Button(mode.rawValue) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    navigationModel.selectedCoachMode = mode
                                }
                            }
                            .buttonStyle(BubuChipButtonStyle(isSelected: navigationModel.selectedCoachMode == mode))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Group {
                        switch navigationModel.selectedCoachMode {
                        case .exercise:
                            ExercisePlanContent()
                        case .ai:
                            AIMealSuggestionContent()
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.lg)
            }
            .bubuScreenBackground()
            .navigationTitle("Coach")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
