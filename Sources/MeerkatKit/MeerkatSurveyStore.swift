import Foundation

/// Persists per-screen satisfaction survey state in `UserDefaults`.
enum MeerkatSurveyStore {
    private static let viewCountPrefix = "MeerkatKit.survey.viewCount."
    private static let presentedPrefix = "MeerkatKit.survey.presented."
    private static let responsePrefix = "MeerkatKit.survey.response."

    /// Increments and returns the view count for `screen`, including the current visit.
    @discardableResult
    static func registerView(screen: String) -> Int {
        let count = viewCount(screen: screen) + 1
        UserDefaults.standard.set(count, forKey: viewCountPrefix + screen)
        return count
    }

    static func viewCount(screen: String) -> Int {
        UserDefaults.standard.integer(forKey: viewCountPrefix + screen)
    }

    static func hasPresented(screen: String) -> Bool {
        UserDefaults.standard.bool(forKey: presentedPrefix + screen)
    }

    static func markPresented(screen: String) {
        UserDefaults.standard.set(true, forKey: presentedPrefix + screen)
    }

    static func response(screen: String) -> SatisfactionResponse? {
        guard let raw = UserDefaults.standard.string(forKey: responsePrefix + screen) else {
            return nil
        }
        return SatisfactionResponse(rawValue: raw)
    }

    static func recordResponse(_ response: SatisfactionResponse, screen: String) {
        UserDefaults.standard.set(response.rawValue, forKey: responsePrefix + screen)
    }

    /// Removes the stored view count, presented flag, and response for `screen`.
    static func reset(screen: String) {
        UserDefaults.standard.removeObject(forKey: viewCountPrefix + screen)
        UserDefaults.standard.removeObject(forKey: presentedPrefix + screen)
        UserDefaults.standard.removeObject(forKey: responsePrefix + screen)
    }

    #if DEBUG
    static func resetAll() {
        let prefixes = [viewCountPrefix, presentedPrefix, responsePrefix]
        UserDefaults.standard.dictionaryRepresentation().keys
            .filter { key in prefixes.contains { key.hasPrefix($0) } }
            .forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }
    #endif
}
