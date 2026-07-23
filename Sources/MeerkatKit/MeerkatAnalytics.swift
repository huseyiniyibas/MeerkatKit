import Foundation

/// Bridges MeerkatKit events to Firebase Analytics **without** a Firebase dependency.
///
/// Firebase is resolved at runtime via the Objective-C runtime. When the host app
/// does not link Firebase, or `FirebaseApp.configure()` was never called (for example
/// because `GoogleService-Info.plist` is missing), every call is a silent no-op —
/// MeerkatKit never crashes the host app.
enum MeerkatAnalytics {
    /// `true` when Firebase is linked *and* a default app is configured.
    static var isFirebaseConfigured: Bool {
        guard let appClass = NSClassFromString("FIRApp") as? NSObjectProtocol else {
            return false
        }
        let selector = NSSelectorFromString("defaultApp")
        guard appClass.responds(to: selector) else { return false }
        return appClass.perform(selector)?.takeUnretainedValue() != nil
    }

    static func logEvent(_ name: String, parameters: [String: String]) {
        guard isFirebaseConfigured,
              let analyticsClass = NSClassFromString("FIRAnalytics") as? NSObjectProtocol else {
            return
        }
        let selector = NSSelectorFromString("logEventWithName:parameters:")
        guard analyticsClass.responds(to: selector) else { return }
        _ = analyticsClass.perform(
            selector,
            with: name as NSString,
            with: parameters as NSDictionary
        )
    }
}

/// Names and dispatch for satisfaction survey analytics events.
@MainActor
enum MeerkatSurveyAnalytics {
    private static var continuationScreen: String?

    /// Logs `meerkatkit_like` / `meerkatkit_dislike` with the screen name.
    static func logResponse(_ response: SatisfactionResponse, screen: String) {
        let name: String
        switch response {
        case .like: name = "meerkatkit_like"
        case .dislike: name = "meerkatkit_dislike"
        }
        MeerkatAnalytics.logEvent(name, parameters: ["screen": screen])
    }

    /// Marks that the next feedback flow on `screen` originates from the survey modal.
    static func noteContinuation(screen: String) {
        continuationScreen = screen
    }

    static func clearContinuation() {
        continuationScreen = nil
    }

    #if DEBUG
    static var pendingContinuationScreen: String? {
        continuationScreen
    }
    #endif

    /// Logs `meerkatkit_bugreport` / `meerkatkit_feedback` / … when the user picks a
    /// template in a feedback flow started from the survey modal.
    static func templateCommitted(screen: String, template: FeedbackTemplate) {
        guard continuationScreen == screen else { return }
        continuationScreen = nil
        MeerkatAnalytics.logEvent(eventName(for: template), parameters: ["screen": screen])
    }

    static func eventName(for template: FeedbackTemplate) -> String {
        let suffix: String
        switch template {
        case .bugReport:
            suffix = "bugreport"
        case .featureRequest:
            suffix = "featurerequest"
        case .general:
            suffix = "feedback"
        case let .custom(custom):
            suffix = sanitizedEventComponent(custom.id)
        }
        return "meerkatkit_" + suffix
    }

    /// Firebase event names allow `[a-z0-9_]` and at most 40 characters.
    static func sanitizedEventComponent(_ raw: String) -> String {
        let mapped = raw.lowercased().map { character -> Character in
            let isAllowed = character.isASCII && (character.isLetter || character.isNumber)
            return isAllowed ? character : "_"
        }
        let component = String(mapped.prefix(29))
        return component.isEmpty ? "custom" : component
    }
}
