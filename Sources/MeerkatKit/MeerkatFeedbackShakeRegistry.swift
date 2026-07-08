import Foundation

@MainActor
enum MeerkatFeedbackShakeRegistry {
    private static var overrides: [String: Bool] = [:]

    static func register(screen: String, enableShake: Bool) {
        overrides[screen] = enableShake
    }

    static func unregister(screen: String) {
        overrides.removeValue(forKey: screen)
    }

    static func isShakeEnabled(for screen: String, bootstrapDefault: Bool) -> Bool {
        overrides[screen] ?? bootstrapDefault
    }

    #if DEBUG
    static func resetAll() {
        overrides.removeAll()
    }
    #endif
}
