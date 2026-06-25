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
        switch (self, locale.resolved) {
        case (.bugReport, .english):
            return "Bug Report"
        case (.bugReport, .turkish):
            return "Hata Bildirimi"
        case (.featureRequest, .english):
            return "Feature Request"
        case (.featureRequest, .turkish):
            return "Özellik İsteği"
        case (.general, .english):
            return "Feedback"
        case (.general, .turkish):
            return "Geri Bildirim"
        case (_, .current):
            return subject(for: locale.resolved)
        }
    }

    func bodyPrefix(for locale: FeedbackLocale) -> String {
        switch (self, locale.resolved) {
        case (.bugReport, .english):
            return "Describe the bug:\n\n"
        case (.bugReport, .turkish):
            return "Hatayı açıklayın:\n\n"
        case (.featureRequest, .english):
            return "Describe your idea:\n\n"
        case (.featureRequest, .turkish):
            return "Fikrinizi açıklayın:\n\n"
        case (.general, .english):
            return "Your feedback:\n\n"
        case (.general, .turkish):
            return "Geri bildiriminiz:\n\n"
        case (_, .current):
            return bodyPrefix(for: locale.resolved)
        }
    }
}

private extension FeedbackLocale {
    var resolved: FeedbackLocale {
        switch self {
        case .current:
            let code = Locale.preferredLanguages.first?.prefix(2) ?? "en"
            return code == "tr" ? .turkish : .english
        case .english, .turkish:
            return self
        }
    }
}

public enum FeedbackDelivery {
    case mailComposer(
        recipients: [String],
        headerMetadata: [String] = [],
        footerMetadata: [String] = []
    )
    case custom((FeedbackPayload) -> Void)
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
        templates: [FeedbackTemplate] = [.bugReport, .featureRequest],
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
