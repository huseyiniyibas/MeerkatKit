import Foundation

/// User-provided content collected in the in-app feedback form.
public struct FeedbackUserInput: Sendable, Equatable {
    public let message: String
    public let rating: Int?
    public let email: String?
    public let customFields: [String: String]
    public let includeScreenshot: Bool

    public init(
        message: String,
        rating: Int? = nil,
        email: String? = nil,
        customFields: [String: String] = [:],
        includeScreenshot: Bool = false
    ) {
        self.message = message
        self.rating = rating
        self.email = email
        self.customFields = customFields
        self.includeScreenshot = includeScreenshot
    }
}
