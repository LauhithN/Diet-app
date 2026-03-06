import Foundation

enum SampleData {
    static func defaultSettings() -> AppSettings {
        .default
    }

    static func weightEntries(referenceDate: Date = Date()) -> [WeightEntry] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: referenceDate)
        let samples: [(Int, Double)] = [
            (-56, 225.0),
            (-49, 223.8),
            (-42, 222.4),
            (-35, 221.1),
            (-28, 220.0),
            (-21, 218.9),
            (-14, 218.0),
            (-7, 217.2),
            (0, 216.4)
        ]

        return samples.compactMap { offset, weight in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            return WeightEntry(date: date, weight: weight)
        }
    }

    static func exerciseTasks() -> [ExerciseTask] {
        [
            ExerciseTask(
                title: "After-dinner walk",
                detail: "Walk at an easy pace for 15 to 20 minutes after dinner.",
                category: .walking,
                durationMinutes: 20
            ),
            ExerciseTask(
                title: "Chair squats",
                detail: "2 sets of 10 slow reps using a chair for support.",
                category: .strength,
                durationMinutes: 5
            ),
            ExerciseTask(
                title: "Wall push-ups",
                detail: "2 sets of 8 to 10 reps against a wall.",
                category: .strength,
                durationMinutes: 5
            ),
            ExerciseTask(
                title: "Light stretches",
                detail: "Loosen hips, hamstrings, shoulders, and calves for a gentle reset.",
                category: .mobility,
                durationMinutes: 8
            )
        ]
    }

    static func weeklyPlan(startingAt date: Date = Date()) -> WeeklyPlan {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)

        let breakfasts = breakfastMeals()
        let lunches = lunchMeals()
        let dinners = dinnerMeals()

        let days = (0..<7).compactMap { index -> DailyPlan? in
            guard let currentDate = calendar.date(byAdding: .day, value: index, to: startDate) else { return nil }
            let meals = [
                breakfasts[index % breakfasts.count],
                lunches[index % lunches.count],
                dinners[index % dinners.count]
            ]
            return DailyPlan(date: currentDate, meals: meals)
        }

        return WeeklyPlan(startDate: startDate, days: days)
    }

    static func breakfastMeals() -> [Meal] {
        [
            meal(
                type: .breakfast,
                name: "Protein Oats Bowl",
                ingredients: [
                    food("Rolled oats", 0.5, "cup", .carbs, 0.35, 150, 5),
                    food("Greek yogurt", 0.75, "cup", .dairy, 1.10, 130, 17),
                    food("Banana", 1, "piece", .produce, 0.35, 105, 1),
                    food("Peanut butter", 1, "tbsp", .pantry, 0.28, 95, 4),
                    food("Chia seeds", 1, "tbsp", .pantry, 0.22, 60, 2)
                ]
            ),
            meal(
                type: .breakfast,
                name: "Eggs, Toast & Cottage Cheese",
                ingredients: [
                    food("Eggs", 3, "pieces", .protein, 1.05, 210, 18),
                    food("Whole wheat bread", 2, "slices", .carbs, 0.50, 180, 8),
                    food("Cottage cheese", 0.5, "cup", .dairy, 0.95, 110, 14),
                    food("Apple", 1, "piece", .produce, 0.60, 95, 0)
                ]
            ),
            meal(
                type: .breakfast,
                name: "Berry Yogurt Parfait",
                ingredients: [
                    food("Greek yogurt", 1, "cup", .dairy, 1.45, 170, 22),
                    food("Frozen berries", 1, "cup", .produce, 1.10, 80, 1),
                    food("Rolled oats", 0.5, "cup", .carbs, 0.35, 150, 5),
                    food("Honey", 1, "tbsp", .pantry, 0.18, 64, 0),
                    food("Almonds", 20, "g", .pantry, 0.55, 116, 4)
                ]
            ),
            meal(
                type: .breakfast,
                name: "Breakfast Burrito",
                ingredients: [
                    food("Eggs", 2, "pieces", .protein, 0.70, 140, 12),
                    food("Whole wheat tortilla", 1, "piece", .carbs, 0.80, 190, 6),
                    food("Cottage cheese", 0.5, "cup", .dairy, 0.95, 110, 14),
                    food("Salsa", 2, "tbsp", .pantry, 0.25, 20, 0),
                    food("Bell pepper", 0.5, "piece", .produce, 0.60, 20, 1)
                ]
            ),
            meal(
                type: .breakfast,
                name: "Apple Cinnamon Oats",
                ingredients: [
                    food("Rolled oats", 0.75, "cup", .carbs, 0.45, 225, 8),
                    food("Milk", 1, "cup", .dairy, 0.55, 100, 8),
                    food("Apple", 1, "piece", .produce, 0.60, 95, 0),
                    food("Peanut butter", 1, "tbsp", .pantry, 0.28, 95, 4),
                    food("Greek yogurt", 0.5, "cup", .dairy, 0.80, 85, 11)
                ]
            ),
            meal(
                type: .breakfast,
                name: "Paneer Breakfast Wrap",
                ingredients: [
                    food("Paneer", 80, "g", .protein, 1.80, 210, 14),
                    food("Whole wheat tortilla", 1, "piece", .carbs, 0.80, 190, 6),
                    food("Bell pepper", 0.5, "piece", .produce, 0.60, 20, 1),
                    food("Greek yogurt", 0.25, "cup", .dairy, 0.40, 45, 5),
                    food("Apple", 1, "piece", .produce, 0.60, 95, 0)
                ]
            ),
            meal(
                type: .breakfast,
                name: "Peanut Butter Banana Toast Set",
                ingredients: [
                    food("Whole wheat bread", 3, "slices", .carbs, 0.75, 270, 12),
                    food("Peanut butter", 1.5, "tbsp", .pantry, 0.42, 143, 6),
                    food("Banana", 1, "piece", .produce, 0.35, 105, 1),
                    food("Greek yogurt", 0.5, "cup", .dairy, 0.80, 85, 11)
                ]
            )
        ]
    }

    static func lunchMeals() -> [Meal] {
        [
            meal(
                type: .lunch,
                name: "Chicken Rice Bowl",
                ingredients: [
                    food("Chicken breast", 140, "g", .protein, 2.85, 231, 43),
                    food("Cooked rice", 1, "cup", .carbs, 0.45, 205, 4),
                    food("Frozen vegetables", 1.5, "cup", .produce, 1.05, 90, 4),
                    food("Soy sauce", 1, "tbsp", .pantry, 0.12, 10, 1)
                ]
            ),
            meal(
                type: .lunch,
                name: "Lentil Soup & Toast",
                ingredients: [
                    food("Cooked lentils", 1.5, "cup", .protein, 0.95, 345, 27),
                    food("Whole wheat bread", 2, "slices", .carbs, 0.50, 180, 8),
                    food("Carrots", 1, "cup", .produce, 0.55, 50, 1),
                    food("Onion", 0.5, "piece", .produce, 0.20, 22, 1)
                ]
            ),
            meal(
                type: .lunch,
                name: "Chicken Cottage Cheese Wrap",
                ingredients: [
                    food("Chicken breast", 110, "g", .protein, 2.25, 181, 34),
                    food("Whole wheat tortilla", 1, "piece", .carbs, 0.80, 190, 6),
                    food("Cottage cheese", 0.5, "cup", .dairy, 0.95, 110, 14),
                    food("Lettuce", 1, "cup", .produce, 0.35, 10, 1),
                    food("Tomato", 0.5, "piece", .produce, 0.35, 11, 1)
                ]
            ),
            meal(
                type: .lunch,
                name: "Paneer Veggie Bowl",
                ingredients: [
                    food("Paneer", 100, "g", .protein, 2.20, 265, 18),
                    food("Cooked rice", 0.75, "cup", .carbs, 0.34, 154, 3),
                    food("Frozen vegetables", 1.5, "cup", .produce, 1.05, 90, 4),
                    food("Greek yogurt", 0.25, "cup", .dairy, 0.40, 45, 5)
                ]
            ),
            meal(
                type: .lunch,
                name: "Egg Salad Sandwich Plate",
                ingredients: [
                    food("Eggs", 3, "pieces", .protein, 1.05, 210, 18),
                    food("Whole wheat bread", 3, "slices", .carbs, 0.75, 270, 12),
                    food("Greek yogurt", 0.25, "cup", .dairy, 0.40, 45, 5),
                    food("Celery", 0.5, "cup", .produce, 0.35, 8, 0)
                ]
            ),
            meal(
                type: .lunch,
                name: "Chicken Potato Plate",
                ingredients: [
                    food("Chicken breast", 120, "g", .protein, 2.45, 198, 37),
                    food("Potatoes", 250, "g", .carbs, 0.70, 215, 5),
                    food("Frozen vegetables", 1, "cup", .produce, 0.70, 60, 3),
                    food("Greek yogurt", 0.25, "cup", .dairy, 0.40, 45, 5)
                ]
            ),
            meal(
                type: .lunch,
                name: "Lentil Burrito Bowl",
                ingredients: [
                    food("Cooked lentils", 1, "cup", .protein, 0.65, 230, 18),
                    food("Cooked rice", 0.75, "cup", .carbs, 0.34, 154, 3),
                    food("Whole wheat tortilla", 0.5, "piece", .carbs, 0.40, 95, 3),
                    food("Salsa", 2, "tbsp", .pantry, 0.25, 20, 0),
                    food("Cottage cheese", 0.5, "cup", .dairy, 0.95, 110, 14)
                ]
            )
        ]
    }

    static func dinnerMeals() -> [Meal] {
        [
            meal(
                type: .dinner,
                name: "Sheet Pan Chicken & Potatoes",
                ingredients: [
                    food("Chicken breast", 130, "g", .protein, 2.65, 214, 40),
                    food("Potatoes", 250, "g", .carbs, 0.70, 215, 5),
                    food("Frozen vegetables", 1.5, "cup", .produce, 1.05, 90, 4)
                ]
            ),
            meal(
                type: .dinner,
                name: "Turkey Rice Skillet",
                ingredients: [
                    food("Lean ground turkey", 125, "g", .protein, 2.50, 220, 29),
                    food("Cooked rice", 1, "cup", .carbs, 0.45, 205, 4),
                    food("Bell pepper", 1, "piece", .produce, 1.20, 40, 1),
                    food("Onion", 0.5, "piece", .produce, 0.20, 22, 1)
                ]
            ),
            meal(
                type: .dinner,
                name: "Lentil Curry with Rice",
                ingredients: [
                    food("Cooked lentils", 1.25, "cup", .protein, 0.80, 288, 22),
                    food("Cooked rice", 0.75, "cup", .carbs, 0.34, 154, 3),
                    food("Greek yogurt", 0.25, "cup", .dairy, 0.40, 45, 5),
                    food("Frozen vegetables", 1, "cup", .produce, 0.70, 60, 3)
                ]
            ),
            meal(
                type: .dinner,
                name: "Chicken Stir-Fry Bowl",
                ingredients: [
                    food("Chicken breast", 120, "g", .protein, 2.45, 198, 37),
                    food("Cooked rice", 0.75, "cup", .carbs, 0.34, 154, 3),
                    food("Frozen vegetables", 2, "cup", .produce, 1.40, 120, 6),
                    food("Soy sauce", 1, "tbsp", .pantry, 0.12, 10, 1)
                ]
            ),
            meal(
                type: .dinner,
                name: "Paneer Veggie Wraps",
                ingredients: [
                    food("Paneer", 100, "g", .protein, 2.20, 265, 18),
                    food("Whole wheat tortillas", 2, "pieces", .carbs, 1.60, 380, 12),
                    food("Lettuce", 1, "cup", .produce, 0.35, 10, 1),
                    food("Salsa", 2, "tbsp", .pantry, 0.25, 20, 0)
                ]
            ),
            meal(
                type: .dinner,
                name: "Loaded Potato with Cottage Cheese",
                ingredients: [
                    food("Potatoes", 300, "g", .carbs, 0.84, 258, 6),
                    food("Cottage cheese", 1, "cup", .dairy, 1.90, 220, 28),
                    food("Frozen vegetables", 1, "cup", .produce, 0.70, 60, 3)
                ]
            ),
            meal(
                type: .dinner,
                name: "Chicken Pasta Bowl",
                ingredients: [
                    food("Chicken breast", 110, "g", .protein, 2.25, 181, 34),
                    food("Whole wheat pasta", 75, "g", .carbs, 0.80, 260, 10),
                    food("Tomato sauce", 0.5, "cup", .pantry, 0.65, 70, 2),
                    food("Frozen vegetables", 1, "cup", .produce, 0.70, 60, 3)
                ]
            )
        ]
    }

    static func sampleGroceryItems(from weeklyPlan: WeeklyPlan) -> [GroceryItem] {
        GroceryGeneratorService().generateGroceryList(from: weeklyPlan)
    }

    private static func food(
        _ name: String,
        _ quantity: Double,
        _ unit: String,
        _ category: FoodCategory,
        _ price: Double,
        _ calories: Int,
        _ protein: Double
    ) -> FoodItem {
        FoodItem(
            name: name,
            quantity: quantity,
            unit: unit,
            category: category,
            estimatedPriceCAD: price,
            calories: calories,
            proteinGrams: protein
        )
    }

    private static func meal(type: MealType, name: String, ingredients: [FoodItem]) -> Meal {
        let estimatedCalories = ingredients.reduce(0) { $0 + $1.calories }
        Meal(
            type: type,
            name: name,
            ingredients: ingredients,
            baseCalories: min(500, max(460, estimatedCalories)),
            estimatedCostCAD: ingredients.reduce(0) { $0 + $1.estimatedPriceCAD },
            proteinGrams: ingredients.reduce(0) { $0 + $1.proteinGrams }
        )
    }
}
