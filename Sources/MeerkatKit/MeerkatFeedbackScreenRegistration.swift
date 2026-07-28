import Foundation

@MainActor
enum MeerkatFeedbackScreenRegistration {
    static func register(
        screen: String,
        presentation: MeerkatFeedbackPresentation,
        enableShake: Bool,
        mailRecipients: [String]?,
        apiEndpoint: URL?,
        session: MeerkatFeedbackScreenSession
    ) {
        MeerkatFeedbackPresentationRegistry.register(screen: screen, presentation: presentation)
        MeerkatFeedbackShakeRegistry.register(screen: screen, enableShake: enableShake)
        MeerkatFeedbackRecipientRegistry.register(screen: screen, recipients: mailRecipients)
        MeerkatFeedbackAPIEndpointRegistry.register(screen: screen, endpoint: apiEndpoint)
        MeerkatFeedbackSessionRegistry.register(session)
    }

    static func unregister(screen: String) {
        MeerkatFeedbackSessionRegistry.unregister(screen: screen)
        MeerkatFeedbackPresentationRegistry.unregister(screen: screen)
        MeerkatFeedbackShakeRegistry.unregister(screen: screen)
        MeerkatFeedbackRecipientRegistry.unregister(screen: screen)
        MeerkatFeedbackAPIEndpointRegistry.unregister(screen: screen)
    }
}
