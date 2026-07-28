import SwiftUI

/// Configuration and action wiring for ``MeerkatFeedbackModifier``.
struct MeerkatFeedbackModifierContext<CustomFloating: View> {
    let screen: String
    let mailRecipients: [String]?
    let apiEndpoint: URL?
    let minimumDwell: Duration?
    let revealAfter: Duration?
    let enableShake: Bool
    let dismissCooldown: Duration?
    let presentation: MeerkatFeedbackPresentation
    let customFloatingButton: (
        (@escaping MeerkatFeedbackRequestAction, @escaping MeerkatFeedbackDismissAction) -> CustomFloating
    )?

    var usesShakeTrigger: Bool {
        MeerkatFeedbackShakeRegistry.isShakeEnabled(
            for: screen,
            bootstrapDefault: MeerkatFeedback.isShakeEnabled
        )
    }

    func isFloatingVisible(
        isReady: Bool,
        isDismissedThisVisit: Bool
    ) -> Bool {
        presentation == .floating
            && !usesShakeTrigger
            && MeerkatFeedback.canShowStickyButton
            && isReady
            && !isDismissedThisVisit
            && !MeerkatDismissCooldown.isActive(
                screen: screen,
                cooldown: MeerkatFeedback.effectiveDismissCooldown(override: dismissCooldown)
            )
    }

    func recordDismiss() {
        MeerkatDismissCooldown.recordDismiss(
            screen: screen,
            cooldown: MeerkatFeedback.effectiveDismissCooldown(override: dismissCooldown)
        )
    }
}
