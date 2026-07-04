import Foundation

/// User-provided content collected in the in-app feedback form.
public struct FeedbackUserInput: Sendable, Equatable {
    public let message: String
    public let rating: Int?
    public let includeScreenshot: Bool

    public init(message: String, rating: Int?, includeScreenshot: Bool = false) {
        self.message = message
        self.rating = rating
        self.includeScreenshot = includeScreenshot
    }
}
