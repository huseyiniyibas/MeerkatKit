import SwiftUI

@MainActor
final class MeerkatFeedbackScreenSession: ObservableObject {
    let screen: String

    @Published var showTemplatePicker = false

    init(screen: String) {
        self.screen = screen
    }

    func requestFeedback() {
        guard MeerkatFeedback.isEnabled else { return }
        if MeerkatFeedback.shouldShowTemplatePicker {
            showTemplatePicker = true
        } else {
            MeerkatFeedback.present(screen: screen)
        }
    }
}

@MainActor
enum MeerkatFeedbackSessionRegistry {
    private static var sessions: [String: MeerkatFeedbackScreenSession] = [:]

    static func register(_ session: MeerkatFeedbackScreenSession) {
        sessions[session.screen] = session
    }

    static func unregister(screen: String) {
        sessions.removeValue(forKey: screen)
    }

    static func requestFeedback(screen: String) {
        if let session = sessions[screen] {
            session.requestFeedback()
        } else {
            MeerkatFeedback.present(screen: screen)
        }
    }

    #if DEBUG
    static func resetAll() {
        sessions.removeAll()
    }
    #endif
}
