import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var aiAPIKey: String

    private let storage: StorageService
    private let keychain: KeychainService

    init(
        storage: StorageService = .shared,
        keychain: KeychainService = .shared
    ) {
        self.storage = storage
        self.keychain = keychain
        self.settings = storage.loadSettings()
        self.aiAPIKey = keychain.loadString(for: SecureStorageKeys.kimiAPIKey) ?? ""
    }

    var hasSavedAIAPIKey: Bool {
        !aiAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save() {
        storage.save(settings: settings)
    }

    func saveAIAPIKey(_ value: String) {
        aiAPIKey = value
        keychain.save(value, for: SecureStorageKeys.kimiAPIKey)
    }

    func clearAIAPIKey() {
        aiAPIKey = ""
        keychain.deleteValue(for: SecureStorageKeys.kimiAPIKey)
    }

    func resetToDefaults() {
        settings = SampleData.defaultSettings()
        save()
    }
}
