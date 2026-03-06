import Foundation

struct GroceryGeneratorService {
    func generateGroceryList(from weeklyPlan: WeeklyPlan) -> [GroceryItem] {
        var bucket: [String: GroceryItem] = [:]

        for ingredient in weeklyPlan.days.flatMap({ $0.meals }).flatMap(\.ingredients) {
            let key = "\(ingredient.name.lowercased())|\(ingredient.unit.lowercased())|\(ingredient.category.rawValue)"
            if var existing = bucket[key] {
                existing.quantity += ingredient.quantity
                existing.estimatedPriceCAD += ingredient.estimatedPriceCAD
                bucket[key] = existing
            } else {
                bucket[key] = GroceryItem(
                    name: ingredient.name,
                    quantity: ingredient.quantity,
                    unit: ingredient.unit,
                    category: ingredient.category,
                    estimatedPriceCAD: ingredient.estimatedPriceCAD
                )
            }
        }

        return bucket.values.sorted {
            if $0.category == $1.category {
                return $0.name < $1.name
            }
            return $0.category.rawValue < $1.category.rawValue
        }
    }
}
