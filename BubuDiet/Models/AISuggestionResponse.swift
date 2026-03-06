import Foundation

struct AISuggestionResponse: Identifiable, Codable, Equatable {
    let id: UUID
    var prompt: String
    var summary: String
    var suggestions: [AISuggestedMeal]
    var generatedAt: Date

    init(
        id: UUID = UUID(),
        prompt: String,
        summary: String,
        suggestions: [AISuggestedMeal],
        generatedAt: Date = Date()
    ) {
        self.id = id
        self.prompt = prompt
        self.summary = summary
        self.suggestions = suggestions
        self.generatedAt = generatedAt
    }
}

struct AISuggestedMeal: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var detail: String
    var estimatedCalories: Int?
    var estimatedProteinGrams: Double?
    var estimatedCostCAD: Double?

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        estimatedCalories: Int? = nil,
        estimatedProteinGrams: Double? = nil,
        estimatedCostCAD: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.estimatedCalories = estimatedCalories
        self.estimatedProteinGrams = estimatedProteinGrams
        self.estimatedCostCAD = estimatedCostCAD
    }
}
