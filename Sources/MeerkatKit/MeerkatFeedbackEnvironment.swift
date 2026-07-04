import SwiftUI

private struct MeerkatFeedbackRequestKey: EnvironmentKey {
    static let defaultValue: MeerkatFeedbackRequest? = nil
}

public extension EnvironmentValues {
    /// Triggers the same feedback flow as the floating button (template picker → mail). Set by ``View/meerkatFeedback(screen:)``.
    var meerkatFeedbackRequest: MeerkatFeedbackRequest? {
        get { self[MeerkatFeedbackRequestKey.self] }
        set { self[MeerkatFeedbackRequestKey.self] = newValue }
    }
}
