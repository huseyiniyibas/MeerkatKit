import Foundation

@MainActor
enum MeerkatFeedbackPresentationRegistry {
    private static var presentations: [String: MeerkatFeedbackPresentation] = [:]

    static func register(screen: String, presentation: MeerkatFeedbackPresentation) {
        presentations[screen] = presentation
    }

    static func unregister(screen: String) {
        presentations.removeValue(forKey: screen)
    }

    static func presentation(for screen: String) -> MeerkatFeedbackPresentation? {
        presentations[screen]
    }

    #if DEBUG
    static func resetAll() {
        presentations.removeAll()
    }
    #endif
}
