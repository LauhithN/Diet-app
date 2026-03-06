import Foundation

final class StorageService {
    static let shared = StorageService()

    private let defaults: UserDefaults
    private let sharedDefaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init() {
        defaults = .standard
        sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier) ?? .standard

        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func seedIfNeeded(referenceDate: Date = Date()) {
        if loadValue(AppSettings.self, forKey: StorageKeys.settings, from: defaults) == nil {
            save(SampleData.defaultSettings(), forKey: StorageKeys.settings, to: defaults)
        }

        if loadValue(WeeklyPlan.self, forKey: StorageKeys.weeklyPlan, from: defaults) == nil {
            save(SampleData.weeklyPlan(startingAt: referenceDate), forKey: StorageKeys.weeklyPlan, to: defaults)
        }

        if loadValue([WeightEntry].self, forKey: StorageKeys.weightEntries, from: defaults) == nil {
            save(SampleData.weightEntries(referenceDate: referenceDate), forKey: StorageKeys.weightEntries, to: defaults)
        }

        if loadValue([ExerciseTask].self, forKey: StorageKeys.exerciseTasks, from: defaults) == nil {
            save(SampleData.exerciseTasks(), forKey: StorageKeys.exerciseTasks, to: defaults)
        }
    }

    func loadSettings() -> AppSettings {
        loadValue(AppSettings.self, forKey: StorageKeys.settings, from: defaults) ?? SampleData.defaultSettings()
    }

    func save(settings: AppSettings) {
        save(settings, forKey: StorageKeys.settings, to: defaults)
    }

    func loadWeeklyPlan() -> WeeklyPlan {
        loadValue(WeeklyPlan.self, forKey: StorageKeys.weeklyPlan, from: defaults) ?? SampleData.weeklyPlan()
    }

    func save(weeklyPlan: WeeklyPlan) {
        save(weeklyPlan, forKey: StorageKeys.weeklyPlan, to: defaults)
    }

    func loadWeightEntries() -> [WeightEntry] {
        (loadValue([WeightEntry].self, forKey: StorageKeys.weightEntries, from: defaults) ?? SampleData.weightEntries())
            .sorted { $0.date < $1.date }
    }

    func save(weightEntries: [WeightEntry]) {
        save(weightEntries.sorted { $0.date < $1.date }, forKey: StorageKeys.weightEntries, to: defaults)
    }

    func loadExerciseTasks() -> [ExerciseTask] {
        loadValue([ExerciseTask].self, forKey: StorageKeys.exerciseTasks, from: defaults) ?? SampleData.exerciseTasks()
    }

    func save(exerciseTasks: [ExerciseTask]) {
        save(exerciseTasks, forKey: StorageKeys.exerciseTasks, to: defaults)
    }

    func loadWidgetSnapshot() -> WidgetSnapshot {
        loadValue(WidgetSnapshot.self, forKey: StorageKeys.widgetSnapshot, from: sharedDefaults) ?? .placeholder
    }

    func save(widgetSnapshot: WidgetSnapshot) {
        save(widgetSnapshot, forKey: StorageKeys.widgetSnapshot, to: sharedDefaults)
    }

    private func loadValue<T: Decodable>(_ type: T.Type, forKey key: String, from defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    private func save<T: Encodable>(_ value: T, forKey key: String, to defaults: UserDefaults) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }
}
