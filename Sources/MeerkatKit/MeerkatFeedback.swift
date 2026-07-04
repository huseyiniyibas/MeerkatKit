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

    /// When `true`, users fill an in-app form before feedback is delivered.
    public static var shouldCollectUserInput: Bool {
        bootstrap?.collectUserInput ?? true
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
        dismissCooldown: Duration = .seconds(86_400),
        collectUserInput: Bool = true,
        mailUnavailableFallback: MailUnavailableFallback = .shareSheet
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
            dismissCooldown: dismissCooldown,
            collectUserInput: collectUserInput,
            mailUnavailableFallback: mailUnavailableFallback
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
        dismissCooldown: Duration = .seconds(86_400),
        collectUserInput: Bool = true
    ) {
        MetadataCollector.setAppStoreID(appStoreID)
        bootstrap = .custom(
            customDelivery,
            templates: templates,
            locale: locale,
            buttonPosition: buttonPosition,
            enableShake: enableShake,
            isEnabled: isEnabled,
            dismissCooldown: dismissCooldown,
            collectUserInput: collectUserInput
        )
    }

    public static func setEnabled(_ enabled: Bool) {
        bootstrap?.isEnabled = enabled
    }

    public static var isEnabled: Bool {
        bootstrap?.isEnabled ?? false
    }

    /// Opens the feedback flow for ``screen`` — template picker when multiple templates are configured.
    public static func requestFeedback(screen: String) {
        MeerkatFeedbackSessionRegistry.requestFeedback(screen: screen)
    }

    /// Starts feedback for ``screen``. Shows the in-app form when ``shouldCollectUserInput`` is `true`.
    public static func present(
        screen: String,
        template: FeedbackTemplate? = nil
    ) {
        guard isEnabled else { return }
        let resolvedTemplate = template ?? configuredTemplates.first ?? .general
        MeerkatFeedbackSessionRegistry.beginFeedbackForm(
            screen: screen,
            template: resolvedTemplate
        )
    }

    static func beginFeedbackWithoutSession(
        screen: String,
        template: FeedbackTemplate
    ) {
        guard let bootstrap, bootstrap.isEnabled else { return }

        if bootstrap.collectUserInput {
            MeerkatFeedbackStandaloneFormPresenter.present(
                screen: screen,
                template: template,
                locale: bootstrap.locale,
                onSubmit: { userInput in
                    submitFeedback(screen: screen, template: template, userInput: userInput)
                }
            )
        } else {
            submitFeedback(screen: screen, template: template, userInput: nil)
        }
    }

    static func submitFeedback(
        screen: String,
        template: FeedbackTemplate,
        userInput: FeedbackUserInput?
    ) {
        guard let bootstrap, bootstrap.isEnabled else { return }
        let configuration = bootstrap.configuration(placement: screen)
        let payload = FeedbackPayloadBuilder.build(
            configuration: configuration,
            placementOverride: screen,
            templateOverride: template,
            userInput: userInput
        )
        deliver(payload, configuration: configuration)
    }

    public static func stickyButtonPosition() -> FeedbackPosition {
        bootstrap?.buttonPosition ?? .bottomTrailing
    }

    public static var configuredTemplates: [FeedbackTemplate] {
        bootstrap?.templates ?? [.general]
    }

    public static var shouldShowTemplatePicker: Bool {
        configuredTemplates.count > 1
    }

    public static var configuredLocale: FeedbackLocale {
        bootstrap?.locale ?? .current
    }

    static var mailUnavailableFallback: MailUnavailableFallback {
        bootstrap?.mailUnavailableFallback ?? .shareSheet
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
        templateOverride: FeedbackTemplate?,
        userInput: FeedbackUserInput? = nil
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
            orderedKeys: orderedKeys,
            template: template,
            userInput: userInput
        )

        return FeedbackPayload(
            placement: placement,
            template: template,
            subject: subject,
            body: body,
            metadata: metadata,
            userInput: userInput
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
