import SwiftUI

@MainActor
final class MeerkatFeedbackScreenSession: ObservableObject {
    let screen: String

    @Published var showTemplatePicker = false
    @Published var showFeedbackForm = false
    @Published private(set) var pendingTemplate: FeedbackTemplate?
    @Published private(set) var defaultIncludeScreenshot = false

    private var didSubmitFeedbackForm = false
    private var pendingSubmitInput: FeedbackUserInput?

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
        didSubmitFeedbackForm = false
        pendingSubmitInput = nil
        defaultIncludeScreenshot = MeerkatFeedbackPendingScreenshot.shouldPreferInclude
        showFeedbackForm = true
    }

    func submitForm(_ userInput: FeedbackUserInput) {
        didSubmitFeedbackForm = true
        pendingSubmitInput = userInput
        defaultIncludeScreenshot = false
        showFeedbackForm = false
    }

    func handleFeedbackFormDismissed() {
        defaultIncludeScreenshot = false
        if let userInput = pendingSubmitInput {
            pendingSubmitInput = nil
            didSubmitFeedbackForm = false
            deliverSubmittedForm(userInput)
            return
        }
        guard !didSubmitFeedbackForm else {
            didSubmitFeedbackForm = false
            return
        }
        MeerkatFeedbackPendingScreenshot.clear()
        FeedbackEventDispatcher.cancelled(screen: screen, stage: .form)
    }

    private func deliverSubmittedForm(_ userInput: FeedbackUserInput) {
        let template = pendingTemplate ?? MeerkatFeedback.configuredTemplates.first ?? .general
        let screen = self.screen
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(100))
            MeerkatFeedback.submitFeedback(
                screen: screen,
                template: template,
                userInput: userInput
            )
        }
    }
}

@MainActor
enum MeerkatFeedbackSessionRegistry {
    private static var sessions: [String: MeerkatFeedbackScreenSession] = [:]
    private static var activeScreenOrder: [String] = []

    static func register(_ session: MeerkatFeedbackScreenSession) {
        sessions[session.screen] = session
        markActive(session.screen)
    }

    static func unregister(screen: String) {
        sessions.removeValue(forKey: screen)
        activeScreenOrder.removeAll { $0 == screen }
    }

    static func markActive(_ screen: String) {
        activeScreenOrder.removeAll { $0 == screen }
        activeScreenOrder.append(screen)
    }

    static var activeScreen: String? {
        if let last = activeScreenOrder.last, sessions[last] != nil {
            return last
        }
        return sessions.keys.sorted().last
    }

    static var isPresentingFeedbackUI: Bool {
        sessions.values.contains { $0.showFeedbackForm || $0.showTemplatePicker }
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
        activeScreenOrder.removeAll()
    }
    #endif
}
