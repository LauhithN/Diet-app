import Foundation

enum FoodCategory: String, Codable, CaseIterable, Identifiable {
    case protein = "Protein"
    case carbs = "Carbs"
    case produce = "Produce"
    case dairy = "Dairy"
    case pantry = "Pantry"

    var id: String { rawValue }
}

struct FoodItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var quantity: Double
    var unit: String
    var category: FoodCategory
    var estimatedPriceCAD: Double
    var calories: Int
    var proteinGrams: Double

    init(
        id: UUID = UUID(),
        name: String,
        quantity: Double,
        unit: String,
        category: FoodCategory,
        estimatedPriceCAD: Double,
        calories: Int,
        proteinGrams: Double
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.category = category
        self.estimatedPriceCAD = estimatedPriceCAD
        self.calories = calories
        self.proteinGrams = proteinGrams
    }

    var quantityText: String {
        if quantity.rounded() == quantity {
            return "\(Int(quantity)) \(unit)"
        }

        return "\(quantity.formatted(.number.precision(.fractionLength(0...2)))) \(unit)"
    }
}
