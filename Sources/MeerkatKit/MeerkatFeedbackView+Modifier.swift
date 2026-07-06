import SwiftUI

public extension View {
    /// Floating feedback button for this screen. Requires ``MeerkatFeedback/bootstrap(recipients:appStoreID:)`` once at launch.
    ///
    /// - Parameter mailRecipients: Optional per-screen mail override. When `nil`, bootstrap recipients are used.
    /// - Parameter apiEndpoint: Optional per-screen API endpoint override for API bootstrap.
    func meerkatFeedback(
        screen: String,
        mailRecipients: [String]? = nil,
        apiEndpoint: URL? = nil,
        minimumDwell: Duration? = nil,
        revealAfter: Duration? = nil,
        enableShake: Bool = false,
        dismissCooldown: Duration? = nil,
        presentation: MeerkatFeedbackPresentation = .floating
    ) -> some View {
        modifier(
            MeerkatFeedbackModifier<EmptyView>(
                screen: screen,
                mailRecipients: mailRecipients,
                apiEndpoint: apiEndpoint,
                minimumDwell: minimumDwell,
                revealAfter: revealAfter,
                enableShake: enableShake,
                dismissCooldown: dismissCooldown,
                presentation: presentation,
                customFloatingButton: nil
            )
        )
    }

    /// Replace the built-in floating button with your own SwiftUI view.
    func meerkatFeedback<Floating: View>(
        screen: String,
        mailRecipients: [String]? = nil,
        apiEndpoint: URL? = nil,
        minimumDwell: Duration? = nil,
        revealAfter: Duration? = nil,
        enableShake: Bool = false,
        dismissCooldown: Duration? = nil,
        @ViewBuilder floatingButton: @escaping (
            _ request: @escaping MeerkatFeedbackRequestAction,
            _ dismiss: @escaping MeerkatFeedbackDismissAction
        ) -> Floating
    ) -> some View {
        modifier(
            MeerkatFeedbackModifier(
                screen: screen,
                mailRecipients: mailRecipients,
                apiEndpoint: apiEndpoint,
                minimumDwell: minimumDwell,
                revealAfter: revealAfter,
                enableShake: enableShake,
                dismissCooldown: dismissCooldown,
                presentation: .floating,
                customFloatingButton: floatingButton
            )
        )
    }
}
