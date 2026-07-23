import SwiftUI

@MainActor
final class MeerkatFeedbackScreenSession: ObservableObject {
    let screen: String

    @Published var showTemplatePicker = false
    @Published var showFeedbackForm = false
    @Published private(set) var pendingTemplate: FeedbackTemplate?

    init(screen: String) {
        self.screen = screen
    }

    func requestFeedback() {
        guard MeerkatFeedback.isEnabled else { return }
        if MeerkatFeedback.shouldShowTemplatePicker {
            showTemplatePicker = true
        } else {
            beginFeedbackForm(
                template: MeerkatFeedback.configuredTemplates.first ?? .general
            )
        }
    }

    func beginFeedbackForm(template: FeedbackTemplate) {
        MeerkatSurveyAnalytics.templateCommitted(screen: screen, template: template)
        pendingTemplate = template
        guard MeerkatFeedback.shouldCollectUserInput else {
            MeerkatFeedback.submitFeedback(
                screen: screen,
                template: template,
                userInput: nil
            )
            return
        }
        showFeedbackForm = true
    }

    func submitForm(_ userInput: FeedbackUserInput) {
        showFeedbackForm = false
        let template = pendingTemplate ?? MeerkatFeedback.configuredTemplates.first ?? .general
        MeerkatFeedback.submitFeedback(
            screen: screen,
            template: template,
            userInput: userInput
        )
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
            MeerkatFeedbackStandaloneFlowPresenter.requestFeedback(screen: screen)
        }
    }

    static func beginFeedbackForm(screen: String, template: FeedbackTemplate) {
        if let session = sessions[screen] {
            session.beginFeedbackForm(template: template)
        } else {
            MeerkatFeedback.beginFeedbackWithoutSession(screen: screen, template: template)
        }
    }

    #if DEBUG
    static func resetAll() {
        sessions.removeAll()
    }
    #endif
}
