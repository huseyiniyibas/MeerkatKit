import Foundation

/// User-provided content collected in the in-app feedback form.
public struct FeedbackUserInput: Sendable, Equatable {
    public let message: String
    public let rating: Int?

    public init(message: String, rating: Int?) {
        self.message = message
        self.rating = rating
    }
}
