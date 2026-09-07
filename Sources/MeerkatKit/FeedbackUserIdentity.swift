import Foundation

/// Optional user identity included in metadata and API payloads.
public struct FeedbackUserIdentity: Sendable, Equatable {
    public var userId: String?
    public var email: String?
    /// When `true`, `userId` and `email` are omitted from outbound payloads.
    public var isAnonymous: Bool

    public init(userId: String? = nil, email: String? = nil, isAnonymous: Bool = false) {
        let trimmedUserId = Self.trimmedOrNil(userId)
        let trimmedEmail = Self.trimmedOrNil(email)
        self.userId = trimmedUserId
        self.email = trimmedEmail
        self.isAnonymous = isAnonymous || (trimmedUserId == nil && trimmedEmail == nil)
    }

    private static func trimmedOrNil(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    public static let anonymous = FeedbackUserIdentity(isAnonymous: true)
}
