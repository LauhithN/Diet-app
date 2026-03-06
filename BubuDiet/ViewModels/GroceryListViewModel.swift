import Foundation

@MainActor
final class GroceryListViewModel: ObservableObject {
    @Published var items: [GroceryItem] = []

    private let generator: GroceryGeneratorService

    init(generator: GroceryGeneratorService = GroceryGeneratorService()) {
        self.generator = generator
    }

    func reload(from weeklyPlan: WeeklyPlan) {
        items = generator.generateGroceryList(from: weeklyPlan)
    }

    var groupedItems: [(FoodCategory, [GroceryItem])] {
        FoodCategory.allCases.map { category in
            (category, items.filter { $0.category == category })
        }
        .filter { !$0.1.isEmpty }
    }

    var totalCost: Double {
        items.reduce(0) { $0 + $1.estimatedPriceCAD }
    }
}
