import Foundation

public enum FeedbackPosition: Sendable {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
}

public enum FeedbackTrigger: Sendable {
    case stickyButton(position: FeedbackPosition)
    case shake
    case manual
}

public enum FeedbackLocale: Sendable {
    case english
    case turkish
    case current
}

public enum FeedbackTemplate: String, Sendable, CaseIterable {
    case bugReport
    case featureRequest
    case general

    func subject(for locale: FeedbackLocale) -> String {
        switch self {
        case .bugReport:
            return MeerkatLocalizer.text(.subjectBugReport, locale: locale)
        case .featureRequest:
            return MeerkatLocalizer.text(.subjectFeatureRequest, locale: locale)
        case .general:
            return MeerkatLocalizer.text(.subjectFeedback, locale: locale)
        }
    }

    func bodyPrefix(for locale: FeedbackLocale) -> String {
        switch self {
        case .bugReport:
            return MeerkatLocalizer.text(.bodyPrefixBugReport, locale: locale)
        case .featureRequest:
            return MeerkatLocalizer.text(.bodyPrefixFeatureRequest, locale: locale)
        case .general:
            return MeerkatLocalizer.text(.bodyPrefixFeedback, locale: locale)
        }
    }
}

public enum FeedbackDelivery {
    case mailComposer(
        recipients: [String],
        headerMetadata: [String] = [],
        footerMetadata: [String] = []
    )
    case custom(@MainActor (FeedbackPayload) -> Void)
}

public struct MeerkatConfiguration {
    public var trigger: FeedbackTrigger
    public var delivery: FeedbackDelivery
    public var placement: String
    public var templates: [FeedbackTemplate]
    public var locale: FeedbackLocale
    public var isEnabled: Bool

    public init(
        trigger: FeedbackTrigger = .stickyButton(position: .bottomTrailing),
        delivery: FeedbackDelivery,
        placement: String = "Default",
        templates: [FeedbackTemplate] = [.general],
        locale: FeedbackLocale = .current,
        isEnabled: Bool = true
    ) {
        self.trigger = trigger
        self.delivery = delivery
        self.placement = placement
        self.templates = templates
        self.locale = locale
        self.isEnabled = isEnabled
    }
}

public struct FeedbackPayload: Sendable {
    public let placement: String
    public let template: FeedbackTemplate
    public let subject: String
    public let body: String
    public let metadata: [String: String]
}
