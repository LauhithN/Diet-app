import SwiftUI

struct MealCardView: View {
    let meal: Meal
    let alternatives: [Meal]
    let onToggleComplete: () -> Void
    let onCompletionChange: (Double) -> Void
    let onPortionChange: (Double) -> Void
    let onSwap: (Meal) -> Void

    private let completionOptions: [Double] = [0, 0.25, 0.5, 0.75, 1]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(meal.type.rawValue.uppercased())
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Palette.rose)
                        .tracking(1.1)

                    Text(meal.name)
                        .font(Theme.Typography.section)
                        .foregroundStyle(Theme.Palette.cocoa)

                    Text("\(meal.ingredients.count) ingredients")
                        .font(Theme.Typography.footnote)
                        .foregroundStyle(Theme.Palette.mist)
                }

                Spacer()

                Button(action: onToggleComplete) {
                    Label(meal.isCompleted ? "Reset" : "Mark eaten", systemImage: meal.isCompleted ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(meal.isCompleted ? Theme.Palette.cocoa : Theme.Palette.onAccent)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, Theme.Spacing.xs)
                        .background(
                            Capsule(style: .continuous)
                                .fill(
                                    meal.isCompleted
                                    ? AnyShapeStyle(Theme.Palette.surfaceRaised)
                                    : AnyShapeStyle(Theme.Gradients.accent)
                                )
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Theme.Palette.border, lineWidth: meal.isCompleted ? 1 : 0)
                        )
                }
                .buttonStyle(.plain)
            }

            ingredientList

            HStack(spacing: Theme.Spacing.xs) {
                BubuMetricPill(title: "Calories", value: meal.adjustedCalories.calorieText, icon: "flame.fill")
                BubuMetricPill(title: "Protein", value: "\(meal.adjustedProteinGrams.oneDecimalText) g", icon: "bolt.heart.fill", accent: Theme.Palette.sage)
                BubuMetricPill(title: "Cost", value: meal.adjustedCostCAD.asCurrencyCAD, icon: "dollarsign.circle.fill", accent: Theme.Palette.roseDeep)
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack {
                    Text("Completion")
                        .font(Theme.Typography.bodyStrong)
                        .foregroundStyle(Theme.Palette.cocoa)
                    Spacer()
                    Text(meal.completionText)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Palette.rose)
                }

                ProgressView(value: meal.completionPercentage)
                    .tint(Theme.Palette.rose)
                    .scaleEffect(x: 1, y: 1.35, anchor: .center)
            }

            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Stepper {
                    Text("Portion: \(meal.portionMultiplier.formatted(.number.precision(.fractionLength(0...2))))x")
                        .font(Theme.Typography.bodyStrong)
                        .foregroundStyle(Theme.Palette.cocoa)
                } onIncrement: {
                    onPortionChange(min(meal.portionMultiplier + 0.25, 2))
                } onDecrement: {
                    onPortionChange(max(meal.portionMultiplier - 0.25, 0.5))
                }

                HStack(spacing: Theme.Spacing.xs) {
                    Menu {
                        ForEach(completionOptions, id: \.self) { option in
                            Button("\(Int(option * 100))%") {
                                onCompletionChange(option)
                            }
                        }
                    } label: {
                        menuLabel(title: "Eaten", value: meal.completionText, icon: "fork.knife.circle")
                    }

                    Menu {
                        ForEach(alternatives) { replacement in
                            Button(replacement.name) {
                                onSwap(replacement)
                            }
                        }
                    } label: {
                        menuLabel(title: "Swap", value: "Choose another", icon: "arrow.left.arrow.right.circle")
                    }
                }
            }

            if meal.completionPercentage > 0 {
                Text("Logged \(meal.consumedCalories) calories from this meal.")
                    .font(Theme.Typography.footnote)
                    .foregroundStyle(Theme.Palette.rose)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Theme.Palette.blush.opacity(0.45))
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard(tint: Theme.Palette.surface)
    }

    private var ingredientList: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Ingredients")
                .font(Theme.Typography.bodyStrong)
                .foregroundStyle(Theme.Palette.cocoa)

            ForEach(Array(meal.ingredients.prefix(5))) { item in
                HStack(alignment: .top, spacing: Theme.Spacing.xs) {
                    Circle()
                        .fill(Theme.Palette.rose.opacity(0.65))
                        .frame(width: 6, height: 6)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(Theme.Typography.body)
                            .foregroundStyle(Theme.Palette.cocoa)
                        Text(item.quantityText)
                            .font(Theme.Typography.footnote)
                            .foregroundStyle(Theme.Palette.mist)
                    }
                }
            }
        }
    }

    private func menuLabel(title: String, value: String, icon: String) -> some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: icon)
                .foregroundStyle(Theme.Palette.rose)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Palette.mist)
                Text(value)
                    .font(Theme.Typography.bodyStrong)
                    .foregroundStyle(Theme.Palette.cocoa)
            }
            Spacer()
            Image(systemName: "chevron.down")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.Palette.mist)
        }
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xs)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(Theme.Palette.surfaceRaised)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .stroke(Theme.Palette.border, lineWidth: 1)
        )
    }
}

#Preview {
    MealCardView(
        meal: SampleData.breakfastMeals().first!,
        alternatives: Array(SampleData.breakfastMeals().dropFirst()),
        onToggleComplete: {},
        onCompletionChange: { _ in },
        onPortionChange: { _ in },
        onSwap: { _ in }
    )
    .padding()
    .background(BubuScreenBackground())
}
