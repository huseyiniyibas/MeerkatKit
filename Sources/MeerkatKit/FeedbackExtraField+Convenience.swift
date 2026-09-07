import Foundation

public extension FeedbackExtraField {
    /// Subscription / plan line (`plan`) for mail metadata and API `metadata`.
    static func subscription(_ plan: String) -> FeedbackExtraField {
        FeedbackExtraField(key: "plan", value: plan, label: "Plan")
    }

    /// Experiment assignment (`experiment`) as `name:variant`.
    static func experiment(_ name: String, variant: String) -> FeedbackExtraField {
        FeedbackExtraField(key: "experiment", value: "\(name):\(variant)", label: "Experiment")
    }

    /// App locale / language (`locale`).
    static func appLocale(_ code: String) -> FeedbackExtraField {
        FeedbackExtraField(key: "locale", value: code, label: "Locale")
    }
}