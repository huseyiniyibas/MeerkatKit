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
        // `enableShake` defaults to `false` on the modifier, so only an explicit opt-in is an
        // override. Otherwise `bootstrap(enableShake: true)` would be masked on every screen
        // and the screen would end up with neither a shake trigger nor a sticky button.
        if enableShake {
            MeerkatFeedbackShakeRegistry.register(screen: screen, enableShake: true)
        } else {
            MeerkatFeedbackShakeRegistry.unregister(screen: screen)
        }
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
