import Foundation

@MainActor
enum MeerkatFeedbackRecipientRegistry {
    private static var overrides: [String: [String]] = [:]

    static func register(screen: String, recipients: [String]?) {
        guard let recipients, !recipients.isEmpty else {
            overrides.removeValue(forKey: screen)
            return
        }
        overrides[screen] = recipients
    }

    static func unregister(screen: String) {
        overrides.removeValue(forKey: screen)
    }

    static func resolvedRecipients(for screen: String, default defaultRecipients: [String]) -> [String] {
        overrides[screen] ?? defaultRecipients
    }

    #if DEBUG
    static func resetAll() {
        overrides.removeAll()
    }
    #endif
}
