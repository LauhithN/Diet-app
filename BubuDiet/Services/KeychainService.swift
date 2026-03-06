import Foundation
import Security

final class KeychainService {
    static let shared = KeychainService()

    private let serviceName: String

    private init(serviceName: String = Bundle.main.bundleIdentifier ?? AppConstants.appName) {
        self.serviceName = serviceName
    }

    func loadString(for key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        guard let data = item as? Data else { return nil }

        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    func save(_ value: String, for key: String) -> Bool {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedValue.isEmpty {
            return deleteValue(for: key)
        }

        guard let data = trimmedValue.data(using: .utf8) else { return false }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: key
        ]

        let attributes: [CFString: Any] = [
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess {
            return true
        }

        var newItem = query
        attributes.forEach { newItem[$0.key] = $0.value }
        return SecItemAdd(newItem as CFDictionary, nil) == errSecSuccess
    }

    @discardableResult
    func deleteValue(for key: String) -> Bool {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: serviceName,
            kSecAttrAccount: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
