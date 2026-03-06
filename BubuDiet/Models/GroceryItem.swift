import Foundation

struct GroceryItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var quantity: Double
    var unit: String
    var category: FoodCategory
    var estimatedPriceCAD: Double

    init(
        id: UUID = UUID(),
        name: String,
        quantity: Double,
        unit: String,
        category: FoodCategory,
        estimatedPriceCAD: Double
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.category = category
        self.estimatedPriceCAD = estimatedPriceCAD
    }

    var quantityText: String {
        if quantity.rounded() == quantity {
            return "\(Int(quantity)) \(unit)"
        }

        return "\(quantity.formatted(.number.precision(.fractionLength(0...2)))) \(unit)"
    }
}
