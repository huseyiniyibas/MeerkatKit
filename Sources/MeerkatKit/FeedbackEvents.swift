import Foundation

public enum FeedbackDeliveryChannel: Sendable, Equatable {
    case mail
    case api
    case custom
}

public enum FeedbackCancellationStage: Sendable, Equatable {
    case templatePicker
    case form
}

public enum FeedbackDeliveryError: Error, Sendable, Equatable {
    case encodingFailed
    case networkFailure(String)
    case unsuccessfulStatus(Int)
    case mailUnavailable
}

public struct FeedbackSubmissionEvent: Sendable {
    public let screen: String
    public let template: FeedbackTemplate
    public let payload: FeedbackPayload
    public let channel: FeedbackDeliveryChannel
}

public struct FeedbackFailureEvent: Sendable {
    public let screen: String
    public let template: FeedbackTemplate
    public let error: FeedbackDeliveryError
    public let queuedOffline: Bool
}

public struct FeedbackCancellationEvent: Sendable {
    public let screen: String
    public let stage: FeedbackCancellationStage
}

/// Fired when the sticky / custom floating feedback control becomes visible on a screen.
public struct FeedbackAppearanceEvent: Sendable {
    public let screen: String

    public init(screen: String) {
        self.screen = screen
    }
}

/// Hooks for observing the feedback lifecycle.
public struct FeedbackEventHandler {
    public var onAppeared: (@MainActor (FeedbackAppearanceEvent) -> Void)?
    public var onSubmitted: (@MainActor (FeedbackSubmissionEvent) -> Void)?
    public var onFailed: (@MainActor (FeedbackFailureEvent) -> Void)?
    public var onCancelled: (@MainActor (FeedbackCancellationEvent) -> Void)?

    public init(
        onAppeared: (@MainActor (FeedbackAppearanceEvent) -> Void)? = nil,
        onSubmitted: (@MainActor (FeedbackSubmissionEvent) -> Void)? = nil,
        onFailed: (@MainActor (FeedbackFailureEvent) -> Void)? = nil,
        onCancelled: (@MainActor (FeedbackCancellationEvent) -> Void)? = nil
    ) {
        self.onAppeared = onAppeared
        self.onSubmitted = onSubmitted
        self.onFailed = onFailed
        self.onCancelled = onCancelled
    }
}

public enum FeedbackAPIResultPresentation: Sendable, Equatable {
    case none
    case alert
    case banner
}

public enum FeedbackAPIOutcome: Sendable, Equatable {
    case success
    case queuedOffline
    case failed
}
