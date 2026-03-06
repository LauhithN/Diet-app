import Foundation

struct WeeklyAverage: Identifiable, Equatable {
    let id = UUID()
    let weekStart: Date
    let averageWeight: Double
}

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published var weightEntries: [WeightEntry]

    private let storage: StorageService

    init(storage: StorageService = .shared) {
        self.storage = storage
        self.weightEntries = storage.loadWeightEntries()
    }

    var latestWeight: Double? {
        weightEntries.sorted { $0.date < $1.date }.last?.weight
    }

    func totalLost(from startingWeight: Double) -> Double {
        max(startingWeight - (latestWeight ?? startingWeight), 0)
    }

    func progressFraction(startingWeight: Double, goalWeight: Double) -> Double {
        let totalNeeded = max(startingWeight - goalWeight, 1)
        let currentLoss = totalLost(from: startingWeight)
        return min(max(currentLoss / totalNeeded, 0), 1)
    }

    var weeklyAverages: [WeeklyAverage] {
        let grouped = Dictionary(grouping: weightEntries) { entry -> Date in
            let interval = Calendar.current.dateInterval(of: .weekOfYear, for: entry.date)
            return interval?.start ?? entry.date.startOfLocalDay
        }

        return grouped
            .map { weekStart, entries in
                let average = entries.reduce(0) { $0 + $1.weight } / Double(entries.count)
                return WeeklyAverage(weekStart: weekStart, averageWeight: average)
            }
            .sorted { $0.weekStart < $1.weekStart }
    }

    func addEntry(date: Date, weight: Double) {
        weightEntries.append(WeightEntry(date: date, weight: weight))
        persist()
    }

    func updateEntry(id: UUID, date: Date, weight: Double) {
        guard let index = weightEntries.firstIndex(where: { $0.id == id }) else { return }
        weightEntries[index].date = date
        weightEntries[index].weight = weight
        persist()
    }

    func delete(entry: WeightEntry) {
        weightEntries.removeAll { $0.id == entry.id }
        persist()
    }

    private func persist() {
        weightEntries.sort { $0.date < $1.date }
        storage.save(weightEntries: weightEntries)
    }
}
