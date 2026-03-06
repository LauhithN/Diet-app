import SwiftUI

struct BubuProgressView: View {
    @EnvironmentObject private var progressViewModel: ProgressViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var mealPlanViewModel: MealPlanViewModel

    @State private var isPresentingEditor = false
    @State private var editingEntry: WeightEntry?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    summaryCard
                    ProgressChartsView(
                        weightEntries: progressViewModel.weightEntries,
                        weeklyAverages: progressViewModel.weeklyAverages,
                        calorieTarget: settingsViewModel.settings.dailyCalorieTarget,
                        dailyPlans: mealPlanViewModel.weeklyPlan.days,
                        goalWeight: settingsViewModel.settings.goalWeight
                    )
                    entriesCard
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.lg)
            }
            .bubuScreenBackground()
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingEntry = nil
                        isPresentingEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingEditor) {
                WeightEntryEditorSheet(entry: editingEntry) { date, weight in
                    if let editingEntry {
                        progressViewModel.updateEntry(id: editingEntry.id, date: date, weight: weight)
                    } else {
                        progressViewModel.addEntry(date: date, weight: weight)
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            BubuSectionHeader(
                eyebrow: "Trend",
                title: "Weight progress",
                subtitle: "The visual language stays supportive here too: clear trend data, no harsh dashboards, and space to notice consistency."
            )

            HStack(spacing: Theme.Spacing.xs) {
                BubuMetricPill(
                    title: "Latest",
                    value: "\(progressViewModel.latestWeight?.oneDecimalText ?? "--") lbs",
                    icon: "scalemass.fill"
                )
                BubuMetricPill(
                    title: "Lost",
                    value: "\(progressViewModel.totalLost(from: settingsViewModel.settings.startingWeight).oneDecimalText) lbs",
                    icon: "arrow.down.circle.fill",
                    accent: Theme.Palette.sage
                )
                BubuMetricPill(
                    title: "Goal",
                    value: "\(Int(progressViewModel.progressFraction(startingWeight: settingsViewModel.settings.startingWeight, goalWeight: settingsViewModel.settings.goalWeight) * 100))%",
                    icon: "flag.checkered.2.crossed",
                    accent: Theme.Palette.roseDeep
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surface)
    }

    private var entriesCard: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Entries")
                .font(Theme.Typography.section)
                .foregroundStyle(Theme.Palette.cocoa)

            if progressViewModel.weightEntries.isEmpty {
                Text("No weigh-ins yet.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Palette.mist)
            } else {
                ForEach(progressViewModel.weightEntries.sorted { $0.date > $1.date }) { entry in
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.date.fullDateLabel)
                                    .font(Theme.Typography.bodyStrong)
                                    .foregroundStyle(Theme.Palette.cocoa)
                                Text("Manual weigh-in")
                                    .font(Theme.Typography.footnote)
                                    .foregroundStyle(Theme.Palette.mist)
                            }

                            Spacer()

                            Text("\(entry.weight.oneDecimalText) lbs")
                                .font(Theme.Typography.section)
                                .foregroundStyle(Theme.Palette.rose)
                        }

                        HStack(spacing: Theme.Spacing.xs) {
                            Button("Edit") {
                                editingEntry = entry
                                isPresentingEditor = true
                            }
                            .buttonStyle(BubuSecondaryButtonStyle())

                            Button("Delete", role: .destructive) {
                                progressViewModel.delete(entry: entry)
                            }
                            .buttonStyle(BubuSecondaryButtonStyle())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)

                    if entry.id != progressViewModel.weightEntries.sorted(by: { $0.date > $1.date }).last?.id {
                        Divider()
                            .overlay(Theme.Palette.border)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surface)
    }
}

private struct WeightEntryEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let entry: WeightEntry?
    let onSave: (Date, Double) -> Void

    @State private var date: Date
    @State private var weightText: String

    init(entry: WeightEntry?, onSave: @escaping (Date, Double) -> Void) {
        self.entry = entry
        self.onSave = onSave
        _date = State(initialValue: entry?.date ?? Date())
        _weightText = State(initialValue: entry.map { String(format: "%.1f", $0.weight) } ?? "")
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                BubuSectionHeader(
                    eyebrow: entry == nil ? "New log" : "Edit log",
                    title: entry == nil ? "Add weight" : "Update weight",
                    subtitle: "Quick, simple, and readable."
                )

                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Date")
                        .font(Theme.Typography.bodyStrong)
                        .foregroundStyle(Theme.Palette.cocoa)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }

                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Weight in lbs")
                        .font(Theme.Typography.bodyStrong)
                        .foregroundStyle(Theme.Palette.cocoa)
                    TextField("Weight in lbs", text: $weightText)
                        .keyboardType(.decimalPad)
                        .bubuField()
                }

                Spacer()
            }
            .padding(Theme.Spacing.lg)
            .bubuScreenBackground()
            .navigationTitle(entry == nil ? "Add Weight" : "Edit Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let parsed = Double(weightText) ?? 0
                        onSave(date, parsed)
                        dismiss()
                    }
                    .disabled((Double(weightText) ?? 0) <= 0)
                }
            }
        }
    }
}

#Preview {
    BubuProgressView()
        .environmentObject(ProgressViewModel())
        .environmentObject(SettingsViewModel())
}
