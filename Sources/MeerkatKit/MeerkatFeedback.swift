import Foundation

@MainActor
public enum MeerkatFeedback {
    private static var bootstrap: MeerkatBootstrap?

    public static var isBootstrapped: Bool {
        bootstrap != nil
    }

    public static var canShowStickyButton: Bool {
        guard let bootstrap, bootstrap.isEnabled else { return false }
        return !bootstrap.enableShake
    }

    /// Backward-compatible alias.
    public static var shouldShowStickyButton: Bool {
        canShowStickyButton
    }

    public static var isShakeEnabled: Bool {
        guard let bootstrap, bootstrap.isEnabled else { return false }
        return bootstrap.enableShake
    }

    /// Call once at app launch (e.g. `AppDelegate` or `@main` `App` `init`).
    public static func bootstrap(
        recipients: [String],
        appStoreID: String? = nil,
        headerMetadata: [String] = [],
        footerMetadata: [String] = [],
        templates: [FeedbackTemplate] = [.general],
        locale: FeedbackLocale = .current,
        buttonPosition: FeedbackPosition = .bottomTrailing,
        enableShake: Bool = false,
        isEnabled: Bool = true,
        dismissCooldown: Duration = .seconds(86_400)
    ) {
        MetadataCollector.setAppStoreID(appStoreID)
        let resolvedHeader = headerMetadata.isEmpty
            ? FeedbackEmailComposer.defaultMetadataKeys
            : headerMetadata

        bootstrap = .mail(
            recipients: recipients,
            headerMetadata: resolvedHeader,
            footerMetadata: footerMetadata,
            templates: templates,
            locale: locale,
            buttonPosition: buttonPosition,
            enableShake: enableShake,
            isEnabled: isEnabled,
            dismissCooldown: dismissCooldown
        )
    }

    /// Custom delivery instead of Mail.
    public static func bootstrap(
        customDelivery: @escaping @MainActor (FeedbackPayload) -> Void,
        appStoreID: String? = nil,
        templates: [FeedbackTemplate] = [.general],
        locale: FeedbackLocale = .current,
        buttonPosition: FeedbackPosition = .bottomTrailing,
        enableShake: Bool = false,
        isEnabled: Bool = true,
        dismissCooldown: Duration = .seconds(86_400)
    ) {
        MetadataCollector.setAppStoreID(appStoreID)
        bootstrap = .custom(
            customDelivery,
            templates: templates,
            locale: locale,
            buttonPosition: buttonPosition,
            enableShake: enableShake,
            isEnabled: isEnabled,
            dismissCooldown: dismissCooldown
        )
    }

    public static func setEnabled(_ enabled: Bool) {
        bootstrap?.isEnabled = enabled
    }

    public static func present(
        screen: String,
        template: FeedbackTemplate? = nil
    ) {
        guard let bootstrap, bootstrap.isEnabled else { return }
        let configuration = bootstrap.configuration(placement: screen)
        let payload = FeedbackPayloadBuilder.build(
            configuration: configuration,
            placementOverride: screen,
            templateOverride: template
        )
        deliver(payload, configuration: configuration)
    }

    public static func stickyButtonPosition() -> FeedbackPosition {
        bootstrap?.buttonPosition ?? .bottomTrailing
    }

    /// Templates configured at ``bootstrap(recipients:appStoreID:...)``. Used by the template picker.
    public static var configuredTemplates: [FeedbackTemplate] {
        bootstrap?.templates ?? [.general]
    }

    /// When `true`, the UI should show a template picker before delivery.
    public static var shouldShowTemplatePicker: Bool {
        configuredTemplates.count > 1
    }

    /// Locale from bootstrap; used by template picker labels.
    public static var configuredLocale: FeedbackLocale {
        bootstrap?.locale ?? .current
    }

    static func effectiveDismissCooldown(override: Duration?) -> Duration {
        override ?? bootstrap?.dismissCooldown ?? .zero
    }

    private static func deliver(_ payload: FeedbackPayload, configuration: MeerkatConfiguration) {
        switch configuration.delivery {
        case .mailComposer:
            FeedbackMailDelivery.present(payload: payload, configuration: configuration)
        case let .custom(handler):
            handler(payload)
        }
    }
}

@MainActor
enum FeedbackPayloadBuilder {
    static func build(
        configuration: MeerkatConfiguration,
        placementOverride: String?,
        templateOverride: FeedbackTemplate?
    ) -> FeedbackPayload {
        let template = templateOverride ?? configuration.templates.first ?? .general
        let placement = placementOverride ?? configuration.placement
        let headerKeys = headerKeys(from: configuration)
        let footerKeys = footerKeys(from: configuration)
        let includesAppStoreID = MetadataCollector.includesConfiguredAppStoreID
        let metadata = MetadataCollector.collect(
            headerKeys: headerKeys,
            footerKeys: footerKeys,
            placement: placement
        )
        let orderedKeys = MetadataCollector.orderedKeys(
            headerKeys: headerKeys,
            footerKeys: footerKeys,
            includesAppStoreID: includesAppStoreID
        )
        let subject = template.subject(for: configuration.locale)
        let body = FeedbackEmailComposer.composeBody(
            metadata: metadata,
            locale: configuration.locale,
            orderedKeys: orderedKeys
        )

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
