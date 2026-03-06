import Foundation

enum ExerciseCategory: String, Codable, CaseIterable, Identifiable {
    case walking = "Walking"
    case strength = "Strength"
    case mobility = "Mobility"

    var id: String { rawValue }
}

struct ExerciseTask: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var detail: String
    var category: ExerciseCategory
    var durationMinutes: Int
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        category: ExerciseCategory,
        durationMinutes: Int,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.category = category
        self.durationMinutes = durationMinutes
        self.isCompleted = isCompleted
    }
}
