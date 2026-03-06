import SwiftUI

struct ExercisePlanView: View {
    @EnvironmentObject private var exerciseViewModel: ExerciseViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Minimal movement plan")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Theme.cocoa)
                        Text("Keep it realistic: one easy walk, a few supported bodyweight moves, and short stretches.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bubuCard()

                    ForEach(ExerciseCategory.allCases) { category in
                        categorySection(for: category)
                    }
                }
                .padding()
            }
            .background(Theme.cream.ignoresSafeArea())
            .navigationTitle("Exercise")
        }
    }

    @ViewBuilder
    private func categorySection(for category: ExerciseCategory) -> some View {
        let tasks = exerciseViewModel.tasks.filter { $0.category == category }
        if !tasks.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(category.rawValue)
                    .font(.headline)
                    .foregroundStyle(Theme.cocoa)

                ForEach(tasks) { task in
                    Button {
                        exerciseViewModel.toggle(taskID: task.id)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(task.isCompleted ? Theme.rose : .secondary)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(task.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Theme.cocoa)
                                Text(task.detail)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                Text("\(task.durationMinutes) min")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Theme.rose)
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .bubuCard()
        }
    }
}

#Preview {
    ExercisePlanView()
        .environmentObject(ExerciseViewModel())
}
