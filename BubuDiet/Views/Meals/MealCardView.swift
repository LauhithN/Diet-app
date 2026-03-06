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
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(meal.type.rawValue.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.rose)
                    Text(meal.name)
                        .font(.headline)
                        .foregroundStyle(Theme.cocoa)
                }

                Spacer()

                Button(meal.isCompleted ? "Reset" : "Mark eaten", action: onToggleComplete)
                    .buttonStyle(.borderedProminent)
                    .tint(meal.isCompleted ? Theme.beige : Theme.rose)
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(meal.ingredients.prefix(5))) { item in
                    Text("• \(item.name) • \(item.quantityText)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Label("\(meal.adjustedCalories) cal", systemImage: "flame")
                Spacer()
                Label("\(meal.adjustedProteinGrams.oneDecimalText) g protein", systemImage: "bolt.heart")
                Spacer()
                Label(meal.adjustedCostCAD.asCurrencyCAD, systemImage: "dollarsign.circle")
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Theme.cocoa)

            VStack(alignment: .leading, spacing: 10) {
                Stepper {
                    Text("Portion: \(meal.portionMultiplier.formatted(.number.precision(.fractionLength(0...2))))x")
                        .font(.subheadline.weight(.medium))
                } onIncrement: {
                    onPortionChange(min(meal.portionMultiplier + 0.25, 2))
                } onDecrement: {
                    onPortionChange(max(meal.portionMultiplier - 0.25, 0.5))
                }

                HStack {
                    Menu("Eaten: \(meal.completionText)") {
                        ForEach(completionOptions, id: \.self) { option in
                            Button("\(Int(option * 100))%") {
                                onCompletionChange(option)
                            }
                        }
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Menu("Swap meal") {
                        ForEach(alternatives) { replacement in
                            Button(replacement.name) {
                                onSwap(replacement)
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }

            if meal.completionPercentage > 0 {
                Text("Logged \(meal.consumedCalories) calories from this meal.")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.rose)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bubuCard()
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
    .background(Theme.cream)
}
