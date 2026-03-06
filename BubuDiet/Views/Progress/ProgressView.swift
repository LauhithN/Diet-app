import SwiftUI

struct BubuProgressView: View {
    @EnvironmentObject private var progressViewModel: ProgressViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    @State private var isPresentingEditor = false
    @State private var editingEntry: WeightEntry?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 14) {
                        WeightChartView(
                            entries: progressViewModel.weightEntries,
                            goalWeight: settingsViewModel.settings.goalWeight
                        )

                        HStack {
                            statView(
                                title: "Latest",
                                value: "\(progressViewModel.latestWeight?.oneDecimalText ?? "--") lbs"
                            )
                            statView(
                                title: "Lost",
                                value: "\(progressViewModel.totalLost(from: settingsViewModel.settings.startingWeight).oneDecimalText) lbs"
                            )
                            statView(
                                title: "Goal",
                                value: "\(Int(progressViewModel.progressFraction(startingWeight: settingsViewModel.settings.startingWeight, goalWeight: settingsViewModel.settings.goalWeight) * 100))%"
                            )
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Weight progress")
                }

                Section("Weekly averages") {
                    ForEach(progressViewModel.weeklyAverages) { average in
                        HStack {
                            Text(average.weekStart.fullDateLabel)
                            Spacer()
                            Text("\(average.averageWeight.oneDecimalText) lbs")
                                .foregroundStyle(Theme.rose)
                        }
                    }
                }

                Section("Entries") {
                    ForEach(progressViewModel.weightEntries.sorted { $0.date > $1.date }) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.date.fullDateLabel)
                                Text("Manual weigh-in")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(entry.weight.oneDecimalText) lbs")
                                .font(.subheadline.weight(.semibold))
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                progressViewModel.delete(entry: entry)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                editingEntry = entry
                                isPresentingEditor = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(Theme.rose)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Progress")
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

    private func statView(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.headline)
                .foregroundStyle(Theme.cocoa)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
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
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Weight in lbs", text: $weightText)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle(entry == nil ? "Add Weight" : "Edit Weight")
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
