import Foundation

/// Rule that decides when the satisfaction survey modal appears on a screen.
public enum SatisfactionSurveyTrigger: Sendable, Equatable {
    /// Present the first time the screen appears after the survey is configured.
    case firstView
    /// Present on every appearance until the user responds with a star rating.
    case everyView
    /// Present once the screen has appeared at least `count` times.
    case afterViews(Int)
    /// Present on every *n*-th appearance (10, 20, 30…), including after a previous response.
    ///
    /// Use this for result / detail screens where you want periodic sampling
    /// (for example every 10th generation result) instead of asking on first open.
    case everyNthView(Int)
    /// Present after the user stays on the screen for `duration` in a single visit.
    case afterDwell(Duration)
}

/// The user's answer to the satisfaction survey.
///
/// Star ratings of 4–5 map to ``like`` (App Store path). Ratings of 1–3 map to
/// ``dislike`` (private feedback path). Raw values stay stable for persistence.
public enum SatisfactionResponse: String, Sendable, Equatable {
    case like
    case dislike

    /// `true` when the rating should be routed to the public App Store review.
    public var isPositive: Bool { self == .like }

    /// Maps a 1–5 star tap onto the gated review paths.
    public static func from(starRating: Int) -> SatisfactionResponse {
        starRating >= 4 ? .like : .dislike
    }
}

/// Passed to the survey response callback when the user picks a star rating.
public struct SatisfactionSurveyEvent: Sendable {
    public let screen: String
    public let response: SatisfactionResponse
    public let dislikeReason: SatisfactionDislikeReason?
    /// The 1–5 star value the user tapped. `0` only for legacy events with no stars.
    public let starRating: Int

    public init(
        screen: String,
        response: SatisfactionResponse,
        dislikeReason: SatisfactionDislikeReason? = nil,
        starRating: Int = 0
    ) {
        self.screen = screen
        self.response = response
        self.dislikeReason = dislikeReason
        self.starRating = starRating
    }
}

/// Code block executed when the user answers the satisfaction survey.
public typealias SatisfactionSurveyResponseAction = @MainActor (SatisfactionSurveyEvent) -> Void
