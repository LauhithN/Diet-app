import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var notificationViewModel: NotificationViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    headerCard
                    personalCard
                    goalsCard
                    aiCard
                    notificationsCard
                    resetCard
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.lg)
            }
            .bubuScreenBackground()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            BubuSectionHeader(
                eyebrow: "Preferences",
                title: "Make the routine feel personal",
                subtitle: "Everything here is tuned for comfort: goals, reminders, and AI settings stay understandable and easy to adjust."
            )

            HStack(spacing: Theme.Spacing.xs) {
                BubuMetricPill(title: "Name", value: settingsViewModel.settings.displayName, icon: "heart.fill")
                BubuMetricPill(title: "Daily target", value: settingsViewModel.settings.dailyCalorieTarget.calorieText, icon: "target", accent: Theme.Palette.sage)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surface)
    }

    private var personalCard: some View {
        settingsCard(
            title: "Personal",
            subtitle: "How the app addresses and frames the experience."
        ) {
            TextField("Name shown in app", text: binding(\.displayName))
                .bubuField()
        }
    }

    private var goalsCard: some View {
        settingsCard(
            title: "Goals",
            subtitle: "Use gradual targets and generous spacing so the numbers feel calm, not intense."
        ) {
            goalStepper(
                title: "Starting weight",
                valueText: "\(settingsViewModel.settings.startingWeight.oneDecimalText) lbs"
            ) {
                Stepper(
                    "",
                    value: binding(\.startingWeight),
                    in: 100...400,
                    step: 0.5
                )
            }

            Divider().overlay(Theme.Palette.border)

            goalStepper(
                title: "Goal weight",
                valueText: "\(settingsViewModel.settings.goalWeight.oneDecimalText) lbs"
            ) {
                Stepper(
                    "",
                    value: binding(\.goalWeight),
                    in: 100...300,
                    step: 0.5
                )
            }

            Divider().overlay(Theme.Palette.border)

            goalStepper(
                title: "Daily calorie target",
                valueText: settingsViewModel.settings.dailyCalorieTarget.calorieText
            ) {
                Stepper(
                    "",
                    value: binding(\.dailyCalorieTarget),
                    in: 1200...2500,
                    step: 50
                )
            }
        }
    }

    private var aiCard: some View {
        settingsCard(
            title: "AI",
            subtitle: "The key remains local to the device and the configuration stays explicit."
        ) {
            Toggle("Enable AI suggestions", isOn: binding(\.aiSuggestionsEnabled))
                .tint(Theme.Palette.rose)

            SecureField("NVIDIA API key", text: aiAPIKeyBinding)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .bubuField()

            TextField("Model", text: aiBinding(\.model))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .bubuField()

            TextField("Base URL", text: aiBinding(\.baseURL))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .bubuField()

            Button("Clear saved API key", role: .destructive) {
                settingsViewModel.clearAIAPIKey()
            }
            .buttonStyle(BubuSecondaryButtonStyle())

            Text("The API key is stored locally in the device keychain. Model and base URL stay in app settings.")
                .font(Theme.Typography.footnote)
                .foregroundStyle(Theme.Palette.mist)

            Text("Default NVIDIA text model: \(AppConstants.kimiDefaultModel)")
                .font(Theme.Typography.footnote)
                .foregroundStyle(Theme.Palette.mist)
        }
    }

    private var notificationsCard: some View {
        settingsCard(
            title: "Notifications",
            subtitle: "Readable reminder controls with enough breathing room to tap comfortably."
        ) {
            Toggle("Enable notifications", isOn: notificationBinding(\.notificationsEnabled))
                .tint(Theme.Palette.rose)

            reminderRow(
                title: "Breakfast reminder",
                isOn: notificationBinding(\.breakfastEnabled),
                time: notificationBinding(\.breakfastTime)
            )

            reminderRow(
                title: "Lunch reminder",
                isOn: notificationBinding(\.lunchEnabled),
                time: notificationBinding(\.lunchTime)
            )

            reminderRow(
                title: "Dinner reminder",
                isOn: notificationBinding(\.dinnerEnabled),
                time: notificationBinding(\.dinnerTime)
            )

            reminderRow(
                title: "Evening weigh-in",
                isOn: notificationBinding(\.weighInEnabled),
                time: notificationBinding(\.weighInTime)
            )

            Button("Request Permission") {
                Task {
                    await notificationViewModel.requestPermission()
                }
            }
            .buttonStyle(BubuSecondaryButtonStyle())

            Button("Schedule Local Reminders") {
                Task {
                    await notificationViewModel.scheduleNotifications(using: settingsViewModel.settings)
                }
            }
            .buttonStyle(BubuPrimaryButtonStyle())

            Text(notificationViewModel.statusMessage)
                .font(Theme.Typography.footnote)
                .foregroundStyle(Theme.Palette.mist)
        }
    }

    private var resetCard: some View {
        settingsCard(
            title: "Reset",
            subtitle: "Restore the original sample defaults if you want a clean starting point."
        ) {
            Button("Restore sample defaults", role: .destructive) {
                settingsViewModel.resetToDefaults()
            }
            .buttonStyle(BubuSecondaryButtonStyle())
        }
    }

    private func settingsCard<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Typography.section)
                .foregroundStyle(Theme.Palette.cocoa)

            Text(subtitle)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Palette.mist)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surface)
    }

    private func goalStepper<Content: View>(
        title: String,
        valueText: String,
        @ViewBuilder stepper: () -> Content
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.Typography.bodyStrong)
                    .foregroundStyle(Theme.Palette.cocoa)
                Text(valueText)
                    .font(Theme.Typography.footnote)
                    .foregroundStyle(Theme.Palette.mist)
            }
            Spacer()
            stepper()
                .labelsHidden()
        }
    }

    private func reminderRow(
        title: String,
        isOn: Binding<Bool>,
        time: Binding<Date>
    ) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Toggle(title, isOn: isOn)
                .tint(Theme.Palette.rose)
            DatePicker("Time", selection: time, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
        }
        .padding(.vertical, 2)
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

    private func aiBinding<Value>(_ keyPath: WritableKeyPath<AIProviderSettings, Value>) -> Binding<Value> {
        Binding(
            get: { settingsViewModel.settings.aiConfiguration[keyPath: keyPath] },
            set: {
                settingsViewModel.settings.aiConfiguration[keyPath: keyPath] = $0
                settingsViewModel.save()
            }
        )
    }

    private var aiAPIKeyBinding: Binding<String> {
        Binding(
            get: { settingsViewModel.aiAPIKey },
            set: { settingsViewModel.saveAIAPIKey($0) }
        )
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
        .environmentObject(NotificationViewModel())
}
