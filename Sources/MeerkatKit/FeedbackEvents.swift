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

/// Hooks for observing the feedback lifecycle.
public struct FeedbackEventHandler {
    public var onSubmitted: (@MainActor (FeedbackSubmissionEvent) -> Void)?
    public var onFailed: (@MainActor (FeedbackFailureEvent) -> Void)?
    public var onCancelled: (@MainActor (FeedbackCancellationEvent) -> Void)?

    public init(
        onSubmitted: (@MainActor (FeedbackSubmissionEvent) -> Void)? = nil,
        onFailed: (@MainActor (FeedbackFailureEvent) -> Void)? = nil,
        onCancelled: (@MainActor (FeedbackCancellationEvent) -> Void)? = nil
    ) {
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
