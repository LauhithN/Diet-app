import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings

    private let storage: StorageService

    init(storage: StorageService = .shared) {
        self.storage = storage
        self.settings = storage.loadSettings()
    }

    func save() {
        storage.save(settings: settings)
    }

    func resetToDefaults() {
        settings = SampleData.defaultSettings()
        save()
    }
}
