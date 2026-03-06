import Foundation

struct WeeklyPlan: Identifiable, Codable, Equatable {
    let id: UUID
    var startDate: Date
    var days: [DailyPlan]

    init(id: UUID = UUID(), startDate: Date, days: [DailyPlan]) {
        self.id = id
        self.startDate = startDate
        self.days = days
    }

    var totalEstimatedCostCAD: Double {
        days.reduce(0) { $0 + $1.totalEstimatedCostCAD }
    }

    func contains(_ date: Date) -> Bool {
        days.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
}
