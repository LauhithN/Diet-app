import Foundation

enum MealType: String, Codable, CaseIterable, Identifiable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"

    var id: String { rawValue }

    var sortOrder: Int {
        switch self {
        case .breakfast: 0
        case .lunch: 1
        case .dinner: 2
        }
    }
}

struct Meal: Identifiable, Codable, Equatable {
    let id: UUID
    var type: MealType
    var name: String
    var ingredients: [FoodItem]
    var baseCalories: Int
    var estimatedCostCAD: Double
    var proteinGrams: Double
    var portionMultiplier: Double
    var completionPercentage: Double

    init(
        id: UUID = UUID(),
        type: MealType,
        name: String,
        ingredients: [FoodItem],
        baseCalories: Int,
        estimatedCostCAD: Double,
        proteinGrams: Double,
        portionMultiplier: Double = 1,
        completionPercentage: Double = 0
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.ingredients = ingredients
        self.baseCalories = baseCalories
        self.estimatedCostCAD = estimatedCostCAD
        self.proteinGrams = proteinGrams
        self.portionMultiplier = portionMultiplier
        self.completionPercentage = completionPercentage
    }

    var adjustedCalories: Int {
        Int((Double(baseCalories) * portionMultiplier).rounded())
    }

    var consumedCalories: Int {
        Int((Double(baseCalories) * portionMultiplier * completionPercentage).rounded())
    }

    var adjustedCostCAD: Double {
        estimatedCostCAD * portionMultiplier
    }

    var adjustedProteinGrams: Double {
        proteinGrams * portionMultiplier
    }

    var completionText: String {
        "\(Int((completionPercentage * 100).rounded()))%"
    }

    var isCompleted: Bool {
        completionPercentage >= 1
    }
}
