import Foundation

/// Optional user identity included in metadata and API payloads.
public struct FeedbackUserIdentity: Sendable, Equatable {
    public var userId: String?
    public var email: String?
    /// When `true`, `userId` and `email` are omitted from outbound payloads.
    public var isAnonymous: Bool

    public init(userId: String? = nil, email: String? = nil, isAnonymous: Bool = false) {
        self.userId = userId
        self.email = email
        self.isAnonymous = isAnonymous
    }

    public static let anonymous = FeedbackUserIdentity(isAnonymous: true)
}
