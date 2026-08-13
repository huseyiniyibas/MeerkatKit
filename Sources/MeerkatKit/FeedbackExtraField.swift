import Foundation

/// Developer-supplied field appended to the mail metadata block
/// (after App, Version, Screen, Device, OS, App Store ID, and optional User ID).
///
/// Use ``MeerkatFeedback/setUserIdentity(_:)`` for the built-in User ID line.
/// Use extra fields for anything else — plan, locale, experiment, etc.
public struct FeedbackExtraField: Sendable, Equatable {
    public var key: String
    public var value: String
    /// Optional mail label. Defaults to a localized label for known keys (`userId`, `email`) or `key`.
    public var label: String?

    public init(key: String, value: String, label: String? = nil) {
        self.key = key
        self.value = value
        self.label = label
    }
}

@MainActor
enum ExtraMetadataStore {
    private static var fields: [FeedbackExtraField] = []
    private static var provider: (() -> [FeedbackExtraField])?

    static func setFields(_ fields: [FeedbackExtraField]) {
        self.fields = fields
    }

    static func setProvider(_ provider: (() -> [FeedbackExtraField])?) {
        self.provider = provider
    }

    static func resolved() -> [FeedbackExtraField] {
        merge(sanitized(fields), sanitized(provider?() ?? []))
    }

    static func labels(for fields: [FeedbackExtraField]) -> [String: String] {
        var labels: [String: String] = [:]
        for field in fields {
            guard let label = field.label?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !label.isEmpty else {
                continue
            }
            labels[field.key] = label
        }
        return labels
    }

    #if DEBUG
    static func resetAll() {
        fields = []
        provider = nil
    }
    #endif

    private static func merge(
        _ base: [FeedbackExtraField],
        _ overlay: [FeedbackExtraField]
    ) -> [FeedbackExtraField] {
        var result = base
        for field in overlay {
            if let index = result.firstIndex(where: { $0.key.lowercased() == field.key.lowercased() }) {
                result[index] = field
            } else {
                result.append(field)
            }
        }
        return result
    }

    private static func sanitized(_ fields: [FeedbackExtraField]) -> [FeedbackExtraField] {
        var result: [FeedbackExtraField] = []
        for field in fields {
            let key = field.key.trimmingCharacters(in: .whitespacesAndNewlines)
            let value = field.value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !key.isEmpty, !value.isEmpty else { continue }
            let cleaned = FeedbackExtraField(key: key, value: value, label: field.label)
            if let index = result.firstIndex(where: { $0.key.lowercased() == key.lowercased() }) {
                result[index] = cleaned
                continue
            }
            result.append(cleaned)
        }
        return result
    }
}
