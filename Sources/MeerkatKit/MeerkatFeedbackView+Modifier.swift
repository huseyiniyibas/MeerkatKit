import SwiftUI

public extension View {
    /// Floating feedback button for this screen. Requires ``MeerkatFeedback/bootstrap(recipients:appStoreID:)`` once at launch.
    func meerkatFeedback(
        screen: String,
        minimumDwell: Duration? = nil,
        revealAfter: Duration? = nil,
        enableShake: Bool = false,
        dismissCooldown: Duration? = nil,
        presentation: MeerkatFeedbackPresentation = .floating
    ) -> some View {
        modifier(
            MeerkatFeedbackModifier<EmptyView>(
                screen: screen,
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
