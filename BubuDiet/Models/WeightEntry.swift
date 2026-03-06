import Foundation

struct WeightEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var weight: Double

    init(id: UUID = UUID(), date: Date, weight: Double) {
        self.id = id
        self.date = date
        self.weight = weight
    }
}
