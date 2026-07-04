import Foundation

/// Controls whether MeerkatKit draws a floating button or only wires up feedback for your own UI.
public enum MeerkatFeedbackPresentation: Sendable {
    /// Built-in sticky button, or a custom view via the `floatingButton` ViewBuilder overload.
    case floating
    /// No floating button — use ``MeerkatFeedback/requestFeedback(screen:)`` or ``EnvironmentValues/meerkatFeedbackRequest``.
    case integrated
}

/// Callback that opens the feedback flow (template picker or mail) for the current screen.
public typealias MeerkatFeedbackRequestAction = () -> Void

/// Callback that dismisses the floating feedback control for the current visit / cooldown window.
public typealias MeerkatFeedbackDismissAction = () -> Void

/// MainActor-bound feedback trigger stored in SwiftUI environment (Swift 6 Sendable-safe).
public struct MeerkatFeedbackRequest: @unchecked Sendable {
    private let action: @MainActor () -> Void

    public init(action: @escaping @MainActor () -> Void) {
        self.action = action
    }

    @MainActor
    public func callAsFunction() {
        action()
    }
}
