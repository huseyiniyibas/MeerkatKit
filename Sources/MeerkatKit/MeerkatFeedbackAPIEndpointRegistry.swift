import Foundation

@MainActor
enum MeerkatFeedbackAPIEndpointRegistry {
    private static var overrides: [String: URL] = [:]

    static func register(screen: String, endpoint: URL?) {
        guard let endpoint else {
            overrides.removeValue(forKey: screen)
            return
        }
        overrides[screen] = endpoint
    }

    static func unregister(screen: String) {
        overrides.removeValue(forKey: screen)
    }

    static func resolvedConfiguration(
        default defaultConfiguration: FeedbackAPIConfiguration,
        screen: String
    ) -> FeedbackAPIConfiguration {
        guard let endpoint = overrides[screen] else {
            return defaultConfiguration
        }
        return FeedbackAPIConfiguration(
            endpoint: endpoint,
            headers: defaultConfiguration.headers,
            offlineRetryEnabled: defaultConfiguration.offlineRetryEnabled
        )
    }

    #if DEBUG
    static func resetAll() {
        overrides.removeAll()
    }
    #endif
}
