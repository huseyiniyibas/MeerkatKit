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

    public static var shouldShowStickyButton: Bool {
        canShowStickyButton
    }

    public static var isShakeEnabled: Bool {
        guard let bootstrap, bootstrap.isEnabled else { return false }
        return bootstrap.enableShake
    }

    public static var shouldCollectUserInput: Bool {
        bootstrap?.collectUserInput ?? true
    }

    public static var shouldOfferScreenshotInForm: Bool {
        bootstrap?.offerScreenshotInForm ?? false
    }

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
        mailUnavailableFallback: MailUnavailableFallback = .shareSheet,
        offerScreenshotInForm: Bool = false,
        crashLogPath: String? = nil,
        userIdentity: FeedbackUserIdentity = .anonymous
    ) {
        MetadataCollector.setAppStoreID(appStoreID)
        MetadataCollector.setUserIdentity(userIdentity)
        bootstrap = .mail(
            recipients: recipients,
            headerMetadata: headerMetadata.isEmpty
                ? FeedbackEmailComposer.defaultMetadataKeys
                : headerMetadata,
            footerMetadata: footerMetadata,
            templates: templates,
            locale: locale,
            buttonPosition: buttonPosition,
            enableShake: enableShake,
            isEnabled: isEnabled,
            dismissCooldown: dismissCooldown,
            collectUserInput: collectUserInput,
            mailUnavailableFallback: mailUnavailableFallback,
            offerScreenshotInForm: offerScreenshotInForm,
            crashLogPath: crashLogPath,
            userIdentity: userIdentity
        )
        startOfflineQueueFlushIfNeeded()
    }

    public static func bootstrap(
        api endpoint: URL,
        headers: [String: String] = [:],
        offlineRetryEnabled: Bool = true,
        appStoreID: String? = nil,
        templates: [FeedbackTemplate] = [.general],
        locale: FeedbackLocale = .current,
        buttonPosition: FeedbackPosition = .bottomTrailing,
        enableShake: Bool = false,
        isEnabled: Bool = true,
        dismissCooldown: Duration = .seconds(86_400),
        collectUserInput: Bool = true,
        offerScreenshotInForm: Bool = true,
        crashLogPath: String? = nil,
        userIdentity: FeedbackUserIdentity = .anonymous
    ) {
        MetadataCollector.setAppStoreID(appStoreID)
        MetadataCollector.setUserIdentity(userIdentity)
        bootstrap = .api(
            endpoint: endpoint,
            headers: headers,
            offlineRetryEnabled: offlineRetryEnabled,
            templates: templates,
            locale: locale,
            buttonPosition: buttonPosition,
            enableShake: enableShake,
            isEnabled: isEnabled,
            dismissCooldown: dismissCooldown,
            collectUserInput: collectUserInput,
            offerScreenshotInForm: offerScreenshotInForm,
            crashLogPath: crashLogPath,
            userIdentity: userIdentity
        )
        startOfflineQueueFlushIfNeeded()
    }

    public static func bootstrap(
        customDelivery: @escaping @MainActor (FeedbackPayload) -> Void,
        appStoreID: String? = nil,
        templates: [FeedbackTemplate] = [.general],
        locale: FeedbackLocale = .current,
        buttonPosition: FeedbackPosition = .bottomTrailing,
        enableShake: Bool = false,
        isEnabled: Bool = true,
        dismissCooldown: Duration = .seconds(86_400),
        collectUserInput: Bool = true,
        offerScreenshotInForm: Bool = false,
        crashLogPath: String? = nil,
        userIdentity: FeedbackUserIdentity = .anonymous
    ) {
        MetadataCollector.setAppStoreID(appStoreID)
        MetadataCollector.setUserIdentity(userIdentity)
        bootstrap = .custom(
            customDelivery,
            templates: templates,
            locale: locale,
            buttonPosition: buttonPosition,
            enableShake: enableShake,
            isEnabled: isEnabled,
            dismissCooldown: dismissCooldown,
            collectUserInput: collectUserInput,
            offerScreenshotInForm: offerScreenshotInForm,
            crashLogPath: crashLogPath,
            userIdentity: userIdentity
        )
    }

    public static func setUserIdentity(_ identity: FeedbackUserIdentity) {
        bootstrap?.userIdentity = identity
        MetadataCollector.setUserIdentity(identity)
    }

    public static func setLogProvider(_ provider: (() -> String?)?) {
        bootstrap?.logProvider = provider
    }

    /// Override mail recipients for ``screen``. Pass `nil` to use the bootstrap default.
    public static func setMailRecipients(_ recipients: [String]?, forScreen screen: String) {
        MeerkatFeedbackRecipientRegistry.register(screen: screen, recipients: recipients)
    }

    public static func setEnabled(_ enabled: Bool) {
        bootstrap?.isEnabled = enabled
    }

    public static var isEnabled: Bool {
        bootstrap?.isEnabled ?? false
    }

    public static func requestFeedback(screen: String) {
        MeerkatFeedbackSessionRegistry.requestFeedback(screen: screen)
    }

    public static func present(screen: String, template: FeedbackTemplate? = nil) {
        guard isEnabled else { return }
        let resolvedTemplate = template ?? configuredTemplates.first ?? .general
        MeerkatFeedbackSessionRegistry.beginFeedbackForm(screen: screen, template: resolvedTemplate)
    }

    /// Retries queued API submissions. Called automatically on API bootstrap.
    public static func flushOfflineQueue() {
        Task { await FeedbackOfflineQueue.flush() }
    }

    public static var offlineQueueCount: Int {
        FeedbackOfflineQueue.pendingCount()
    }

    static func beginFeedbackWithoutSession(screen: String, template: FeedbackTemplate) {
        guard let bootstrap, bootstrap.isEnabled else { return }

        if bootstrap.collectUserInput {
            MeerkatFeedbackStandaloneFormPresenter.present(
                screen: screen,
                template: template,
                locale: bootstrap.locale,
                offerScreenshot: bootstrap.offerScreenshotInForm,
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
        let attachments = FeedbackAttachmentCollector.collect(
            userInput: userInput,
            offerScreenshot: bootstrap.offerScreenshotInForm,
            logProvider: bootstrap.logProvider,
            crashLogPath: bootstrap.crashLogPath
        )
        let payload = FeedbackPayloadBuilder.build(
            configuration: configuration,
            placementOverride: screen,
            templateOverride: template,
            userInput: userInput,
            attachments: attachments,
            userIdentity: bootstrap.userIdentity
        )
        deliver(payload, configuration: configuration, identity: bootstrap.userIdentity)
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

    private static func startOfflineQueueFlushIfNeeded() {
        guard bootstrap?.apiConfiguration != nil else { return }
        flushOfflineQueue()
    }

    private static func deliver(
        _ payload: FeedbackPayload,
        configuration: MeerkatConfiguration,
        identity: FeedbackUserIdentity
    ) {
        switch configuration.delivery {
        case .mailComposer:
            FeedbackMailDelivery.present(payload: payload, configuration: configuration)
        case let .api(apiConfig):
            APIFeedbackDelivery.deliver(
                payload: payload,
                configuration: apiConfig,
                identity: identity
            )
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
        userInput: FeedbackUserInput? = nil,
        attachments: [FeedbackAttachment] = [],
        userIdentity: FeedbackUserIdentity = .anonymous
    ) -> FeedbackPayload {
        MetadataCollector.setUserIdentity(userIdentity)
        let template = templateOverride ?? configuration.templates.first ?? .general
        let placement = placementOverride ?? configuration.placement
        let headerKeys = headerKeys(from: configuration)
        let footerKeys = footerKeys(from: configuration)
        let includesAppStoreID = MetadataCollector.includesConfiguredAppStoreID
        var metadata = MetadataCollector.collect(
            headerKeys: headerKeys,
            footerKeys: footerKeys,
            placement: placement
        )
        appendIdentityMetadata(&metadata, identity: userIdentity)

        var orderedKeys = MetadataCollector.orderedKeys(
            headerKeys: headerKeys,
            footerKeys: footerKeys,
            includesAppStoreID: includesAppStoreID
        )
        appendIdentityKeys(&orderedKeys, identity: userIdentity)

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
            userInput: userInput,
            attachments: attachments
        )
    }

    private static func appendIdentityMetadata(
        _ metadata: inout [String: String],
        identity: FeedbackUserIdentity
    ) {
        guard !identity.isAnonymous else { return }
        if let userId = identity.userId, !userId.isEmpty {
            metadata["userId"] = userId
        }
        if let email = identity.email, !email.isEmpty {
            metadata["email"] = email
        }
    }

    private static func appendIdentityKeys(
        _ keys: inout [String],
        identity: FeedbackUserIdentity
    ) {
        guard !identity.isAnonymous else { return }
        if identity.userId != nil, !keys.contains(where: { $0.lowercased() == "userid" }) {
            keys.append("userId")
        }
        if identity.email != nil, !keys.contains(where: { $0.lowercased() == "email" }) {
            keys.append("email")
        }
    }

    private static func headerKeys(from configuration: MeerkatConfiguration) -> [String] {
        switch configuration.delivery {
        case let .mailComposer(_, header, _):
            return header
        case .api:
            return FeedbackEmailComposer.defaultMetadataKeys
        case .custom:
            return []
        }
    }

    private static func footerKeys(from configuration: MeerkatConfiguration) -> [String] {
        guard case let .mailComposer(_, _, footer) = configuration.delivery else { return [] }
        return footer
    }
}
