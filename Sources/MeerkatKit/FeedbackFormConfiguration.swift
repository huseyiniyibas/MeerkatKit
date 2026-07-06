import Foundation

/// Optional field rendered in the in-app feedback form.
public struct FeedbackCustomField: Sendable, Equatable, Identifiable {
    public let id: String
    public let label: String
    public let placeholder: String?
    public let isRequired: Bool

    public init(
        id: String,
        label: String,
        placeholder: String? = nil,
        isRequired: Bool = false
    ) {
        self.id = id
        self.label = label
        self.placeholder = placeholder
        self.isRequired = isRequired
    }
}

/// Controls which inputs the in-app feedback form collects.
public struct FeedbackFormConfiguration: Sendable, Equatable {
    public var collectRating: Bool
    public var collectEmail: Bool
    public var customFields: [FeedbackCustomField]

    public init(
        collectRating: Bool = true,
        collectEmail: Bool = false,
        customFields: [FeedbackCustomField] = []
    ) {
        self.collectRating = collectRating
        self.collectEmail = collectEmail
        self.customFields = customFields
    }

    public static let `default` = FeedbackFormConfiguration()
}
