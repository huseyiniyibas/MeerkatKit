import Foundation

@MainActor
public enum MeerkatFeedback {
    private static var configuration: MeerkatConfiguration?
    private static var isDismissedByUser = false
    private static var presentationHandler: ((FeedbackPayload) -> Void)?

    public static var currentConfiguration: MeerkatConfiguration? {
        configuration
    }

    public static var shouldShowStickyButton: Bool {
        guard let configuration, configuration.isEnabled, !isDismissedByUser else {
            return false
        }
        if case .stickyButton = configuration.trigger {
            return true
        }
        return false
    }

    public static var isShakeEnabled: Bool {
        guard let configuration, configuration.isEnabled else { return false }
        if case .shake = configuration.trigger { return true }
        return false
    }

    public static func configure(_ config: MeerkatConfiguration) {
        configuration = config
        isDismissedByUser = false
        wireDeliveryHandler(for: config)
    }

    public static func setEnabled(_ enabled: Bool) {
        configuration?.isEnabled = enabled
    }

    public static func dismissByUser() {
        isDismissedByUser = true
    }

    public static func resetUserDismissal() {
        isDismissedByUser = false
    }

    public static func present(
        from placement: String? = nil,
        template: FeedbackTemplate? = nil
    ) {
        guard let configuration, configuration.isEnabled else { return }
        let payload = FeedbackPayloadBuilder.build(
            configuration: configuration,
            placementOverride: placement,
            templateOverride: template
        )
        presentationHandler?(payload)
    }

    public static func stickyButtonPosition() -> FeedbackPosition {
        guard let configuration,
              case let .stickyButton(position) = configuration.trigger else {
            return .bottomTrailing
        }
        return position
    }

    private static func wireDeliveryHandler(for config: MeerkatConfiguration) {
        switch config.delivery {
        case .mailComposer:
            presentationHandler = { payload in
                FeedbackMailDelivery.present(payload: payload, configuration: config)
            }
        case let .custom(handler):
            presentationHandler = handler
        }
    }
}

enum FeedbackPayloadBuilder {
    static func build(
        configuration: MeerkatConfiguration,
        placementOverride: String?,
        templateOverride: FeedbackTemplate?
    ) -> FeedbackPayload {
        let template = templateOverride ?? configuration.templates.first ?? .general
        let placement = placementOverride ?? configuration.placement
        let metadata = MetadataCollector.collect(
            headerKeys: headerKeys(from: configuration),
            footerKeys: footerKeys(from: configuration),
            placement: placement
        )
        let headerBlock = MetadataCollector.formatBlock(metadata: metadata, title: "Info")
        let subject = template.subject(for: configuration.locale)
        let body = headerBlock
            + "\n\n"
            + template.bodyPrefix(for: configuration.locale)

        return FeedbackPayload(
            placement: placement,
            template: template,
            subject: subject,
            body: body,
            metadata: metadata
        )
    }

    private static func headerKeys(from configuration: MeerkatConfiguration) -> [String] {
        guard case let .mailComposer(_, header, _) = configuration.delivery else { return [] }
        return header
    }

    private static func footerKeys(from configuration: MeerkatConfiguration) -> [String] {
        guard case let .mailComposer(_, _, footer) = configuration.delivery else { return [] }
        return footer
    }
}
