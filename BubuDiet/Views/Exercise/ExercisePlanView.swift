import SwiftUI

struct ExercisePlanView: View {
    var showsNavigationShell = true

    var body: some View {
        Group {
            if showsNavigationShell {
                NavigationStack {
                    ScrollView {
                        ExercisePlanContent()
                            .padding(.horizontal, Theme.Spacing.md)
                            .padding(.vertical, Theme.Spacing.lg)
                    }
                    .navigationTitle("Exercise")
                    .navigationBarTitleDisplayMode(.large)
                }
            } else {
                ExercisePlanContent()
            }
        }
        .bubuScreenBackground()
    }
}

struct ExercisePlanContent: View {
    @EnvironmentObject private var exerciseViewModel: ExerciseViewModel

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            overviewCard

            ForEach(ExerciseCategory.allCases) { category in
                categorySection(for: category)
            }
        }
    }

    private var overviewCard: some View {
        let completedCount = exerciseViewModel.tasks.filter(\.isCompleted).count
        let totalMinutes = exerciseViewModel.tasks.reduce(0) { $0 + $1.durationMinutes }

        return VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            BubuSectionHeader(
                eyebrow: "Movement",
                title: "Light exercise for consistency",
                subtitle: "The tone stays gentle here: simple walks, small strength prompts, and mobility that helps the day feel better rather than harder."
            )

            HStack(spacing: Theme.Spacing.xs) {
                BubuMetricPill(title: "Completed", value: "\(completedCount) of \(exerciseViewModel.tasks.count)", icon: "checkmark.circle.fill")
                BubuMetricPill(title: "Total minutes", value: "\(totalMinutes)", icon: "clock.fill", accent: Theme.Palette.sage)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surface)
    }

    @ViewBuilder
    private func categorySection(for category: ExerciseCategory) -> some View {
        let tasks = exerciseViewModel.tasks.filter { $0.category == category }

        if !tasks.isEmpty {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text(category.rawValue)
                    .font(Theme.Typography.section)
                    .foregroundStyle(Theme.Palette.cocoa)

                ForEach(tasks) { task in
                    Button {
                        exerciseViewModel.toggle(taskID: task.id)
                    } label: {
                        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(task.isCompleted ? Theme.Palette.rose : Theme.Palette.mist)

                            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                                Text(task.title)
                                    .font(Theme.Typography.bodyStrong)
                                    .foregroundStyle(Theme.Palette.cocoa)

                                Text(task.detail)
                                    .font(Theme.Typography.footnote)
                                    .foregroundStyle(Theme.Palette.mist)

                                Text("\(task.durationMinutes) min")
                                    .font(Theme.Typography.caption)
                                    .foregroundStyle(Theme.Palette.rose)
                            }

                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)

                    if task.id != tasks.last?.id {
                        Divider()
                            .overlay(Theme.Palette.border)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .bubuCard(tint: Theme.Palette.surface)
        }
    }
}

#Preview {
    ExercisePlanView()
        .environmentObject(ExerciseViewModel())
}
