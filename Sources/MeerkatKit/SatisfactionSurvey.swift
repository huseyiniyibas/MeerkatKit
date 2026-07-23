import Foundation

/// Rule that decides when the satisfaction survey modal appears on a screen.
public enum SatisfactionSurveyTrigger: Sendable, Equatable {
    /// Present the first time the screen appears after the survey is configured.
    case firstView
    /// Present on every appearance until the user responds with like or dislike.
    case everyView
    /// Present once the screen has appeared at least `count` times.
    case afterViews(Int)
    /// Present after the user stays on the screen for `duration` in a single visit.
    case afterDwell(Duration)
}

/// The user's answer to the like/dislike satisfaction survey.
public enum SatisfactionResponse: String, Sendable, Equatable {
    case like
    case dislike
}

/// Passed to the survey response callback when the user taps like or dislike.
public struct SatisfactionSurveyEvent: Sendable {
    public let screen: String
    public let response: SatisfactionResponse
}

/// Code block executed when the user answers the satisfaction survey.
public typealias SatisfactionSurveyResponseAction = @MainActor (SatisfactionSurveyEvent) -> Void
