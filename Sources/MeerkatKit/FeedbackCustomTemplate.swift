import Foundation

/// Developer-defined feedback category shown in the template picker and form.
public struct FeedbackCustomTemplate: Hashable, Sendable {
    public let id: String
    public let title: String
    public let subject: String
    public let bodyPrefix: String
    public let systemImage: String

    public init(
        id: String,
        title: String,
        subject: String,
        bodyPrefix: String,
        systemImage: String = "text.bubble.fill"
    ) {
        self.id = id
        self.title = title
        self.subject = subject
        self.bodyPrefix = bodyPrefix
        self.systemImage = systemImage
    }
}
