import Foundation

/// REST endpoint configuration for API feedback delivery.
public struct FeedbackAPIConfiguration: Sendable, Equatable {
    public let endpoint: URL
    public var headers: [String: String]
    public var offlineRetryEnabled: Bool

    public init(
        endpoint: URL,
        headers: [String: String] = [:],
        offlineRetryEnabled: Bool = true
    ) {
        self.endpoint = endpoint
        self.headers = headers
        self.offlineRetryEnabled = offlineRetryEnabled
    }
}
