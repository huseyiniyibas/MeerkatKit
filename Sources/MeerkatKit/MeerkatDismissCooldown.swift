import Foundation

enum MeerkatDismissCooldown {
    private static let defaultsKeyPrefix = "MeerkatKit.dismissUntil."

    static func isActive(screen: String, cooldown: Duration) -> Bool {
        guard cooldown > .zero, let until = suppressedUntil(for: screen) else {
            return false
        }
        if until > Date() {
            return true
        }
        clear(screen: screen)
        return false
    }

    static func recordDismiss(screen: String, cooldown: Duration) {
        guard cooldown > .zero else { return }
        let until = Date().addingTimeInterval(cooldown.timeInterval)
        UserDefaults.standard.set(until.timeIntervalSince1970, forKey: key(for: screen))
    }

    static func clear(screen: String) {
        UserDefaults.standard.removeObject(forKey: key(for: screen))
    }

    #if DEBUG
    static func resetAll() {
        UserDefaults.standard.dictionaryRepresentation().keys
            .filter { $0.hasPrefix(defaultsKeyPrefix) }
            .forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }
    #endif

    private static func suppressedUntil(for screen: String) -> Date? {
        let stamp = UserDefaults.standard.double(forKey: key(for: screen))
        guard stamp > 0 else { return nil }
        return Date(timeIntervalSince1970: stamp)
    }

    private static func key(for screen: String) -> String {
        defaultsKeyPrefix + screen
    }
}

private extension Duration {
    var timeInterval: TimeInterval {
        let components = components
        return Double(components.seconds)
            + Double(components.attoseconds) / 1_000_000_000_000_000_000
    }
}
