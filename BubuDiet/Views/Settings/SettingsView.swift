import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var notificationViewModel: NotificationViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal") {
                    TextField("Name shown in app", text: binding(\.displayName))
                }

                Section("Goals") {
                    Stepper(
                        "Starting weight: \(settingsViewModel.settings.startingWeight.oneDecimalText) lbs",
                        value: binding(\.startingWeight),
                        in: 100...400,
                        step: 0.5
                    )
                    Stepper(
                        "Goal weight: \(settingsViewModel.settings.goalWeight.oneDecimalText) lbs",
                        value: binding(\.goalWeight),
                        in: 100...300,
                        step: 0.5
                    )
                    Stepper(
                        "Daily calorie target: \(settingsViewModel.settings.dailyCalorieTarget) cal",
                        value: binding(\.dailyCalorieTarget),
                        in: 1200...2500,
                        step: 50
                    )
                }

                Section("AI") {
                    Toggle("Enable AI suggestions", isOn: binding(\.aiSuggestionsEnabled))
                    Text("If off, the AI screen stays local and won’t call Kimi.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Notifications") {
                    Toggle("Enable notifications", isOn: notificationBinding(\.notificationsEnabled))
                    Toggle("Breakfast reminder", isOn: notificationBinding(\.breakfastEnabled))
                    DatePicker("Breakfast time", selection: notificationBinding(\.breakfastTime), displayedComponents: .hourAndMinute)

                    Toggle("Lunch reminder", isOn: notificationBinding(\.lunchEnabled))
                    DatePicker("Lunch time", selection: notificationBinding(\.lunchTime), displayedComponents: .hourAndMinute)

                    Toggle("Dinner reminder", isOn: notificationBinding(\.dinnerEnabled))
                    DatePicker("Dinner time", selection: notificationBinding(\.dinnerTime), displayedComponents: .hourAndMinute)

                    Toggle("Evening weigh-in", isOn: notificationBinding(\.weighInEnabled))
                    DatePicker("Weigh-in time", selection: notificationBinding(\.weighInTime), displayedComponents: .hourAndMinute)

                    Button("Request Permission") {
                        Task {
                            await notificationViewModel.requestPermission()
                        }
                    }

                    Button("Schedule Local Reminders") {
                        Task {
                            await notificationViewModel.scheduleNotifications(using: settingsViewModel.settings)
                        }
                    }

                    Text(notificationViewModel.statusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Reset") {
                    Button("Restore sample defaults", role: .destructive) {
                        settingsViewModel.resetToDefaults()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func binding<Value>(_ keyPath: WritableKeyPath<AppSettings, Value>) -> Binding<Value> {
        Binding(
            get: { settingsViewModel.settings[keyPath: keyPath] },
            set: {
                settingsViewModel.settings[keyPath: keyPath] = $0
                settingsViewModel.save()
            }
        )
    }

    private func notificationBinding<Value>(_ keyPath: WritableKeyPath<NotificationPreferences, Value>) -> Binding<Value> {
        Binding(
            get: { settingsViewModel.settings.notificationPreferences[keyPath: keyPath] },
            set: {
                settingsViewModel.settings.notificationPreferences[keyPath: keyPath] = $0
                settingsViewModel.save()
            }
        )
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
        .environmentObject(NotificationViewModel())
}
