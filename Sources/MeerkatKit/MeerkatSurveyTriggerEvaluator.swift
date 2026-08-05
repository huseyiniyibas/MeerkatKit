import Foundation

/// Outcome of evaluating a ``SatisfactionSurveyTrigger`` when a screen appears.
enum MeerkatSurveyPresentationDecision: Equatable {
    case present
    case presentAfterDwell(Duration)
    case skip
}

/// Pure decision logic for when the satisfaction survey should be presented.
enum MeerkatSurveyTriggerEvaluator {
    /// - Parameter viewCount: Total number of views for the screen, including the current visit.
    static func decision(
        trigger: SatisfactionSurveyTrigger,
        viewCount: Int,
        hasPresented: Bool,
        hasResponded: Bool
    ) -> MeerkatSurveyPresentationDecision {
        switch trigger {
        case .firstView:
            guard !hasResponded else { return .skip }
            return hasPresented ? .skip : .present
        case .everyView:
            guard !hasResponded else { return .skip }
            return .present
        case let .afterViews(threshold):
            guard !hasResponded else { return .skip }
            guard !hasPresented else { return .skip }
            return viewCount >= max(1, threshold) ? .present : .skip
        case let .everyNthView(interval):
            let step = max(1, interval)
            return viewCount > 0 && viewCount.isMultiple(of: step) ? .present : .skip
        case let .afterDwell(duration):
            guard !hasResponded else { return .skip }
            guard !hasPresented else { return .skip }
            return .presentAfterDwell(duration)
        }
    }
}
