import Foundation

/// Drives satisfaction survey presentation for a single screen:
/// counts views, evaluates the trigger, and runs the dwell timer.
@MainActor
final class MeerkatSurveyScreenController: ObservableObject {
    @Published var isPresentingSurvey = false

    private var pendingTask: Task<Void, Never>?

    private static let defaultAppearDelay: Duration = .milliseconds(600)

    #if DEBUG
    static var appearDelayOverride: Duration?
    #endif

    static var appearDelay: Duration {
        #if DEBUG
        if let appearDelayOverride {
            return appearDelayOverride
        }
        #endif
        return defaultAppearDelay
    }

    func begin(screen: String, trigger: SatisfactionSurveyTrigger) {
        guard MeerkatFeedback.isEnabled else { return }

        let viewCount = MeerkatSurveyStore.registerView(screen: screen)
        let decision = MeerkatSurveyTriggerEvaluator.decision(
            trigger: trigger,
            viewCount: viewCount,
            hasPresented: MeerkatSurveyStore.hasPresented(screen: screen),
            hasResponded: MeerkatSurveyStore.response(screen: screen) != nil
        )

        switch decision {
        case .present:
            schedulePresentation(screen: screen, after: Self.appearDelay)
        case let .presentAfterDwell(duration):
            schedulePresentation(screen: screen, after: duration)
        case .skip:
            break
        }
    }

    func end() {
        pendingTask?.cancel()
        pendingTask = nil
    }

    private func schedulePresentation(screen: String, after delay: Duration) {
        pendingTask?.cancel()
        pendingTask = Task { @MainActor in
            if delay > .zero {
                try? await Task.sleep(for: delay)
            }
            guard !Task.isCancelled else { return }
            MeerkatSurveyStore.markPresented(screen: screen)
            isPresentingSurvey = true
        }
    }
}
