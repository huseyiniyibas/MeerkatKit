import Foundation

/// Ensures ``FeedbackEventDispatcher/appeared(screen:)`` fires once per visible stretch.
@MainActor
struct MeerkatFeedbackAppearanceTracker {
    private var didReportCurrentAppearance = false

    mutating func reset() {
        didReportCurrentAppearance = false
    }

    mutating func handleVisibilityChange(isVisible: Bool, screen: String) {
        if isVisible {
            reportIfNeeded(isVisible: true, screen: screen)
        } else {
            didReportCurrentAppearance = false
        }
    }

    mutating func reportIfNeeded(isVisible: Bool, screen: String) {
        guard isVisible, !didReportCurrentAppearance else { return }
        didReportCurrentAppearance = true
        FeedbackEventDispatcher.appeared(screen: screen)
    }
}
