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

    /// Deprecated alias for ``canShowStickyButton``.
    @available(*, deprecated, renamed: "canShowStickyButton")
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
        effectiveOfferScreenshotInForm
    }

    public static var effectiveOfferScreenshotInForm: Bool {
        let configured = bootstrap?.offerScreenshotInForm ?? false
        return configured && FeedbackScreenshotCapture.isSupported
    }

    public static var formConfiguration: FeedbackFormConfiguration {
        bootstrap?.formConfiguration ?? .default
    }

    static var eventHandler: FeedbackEventHandler? {
        bootstrap?.eventHandler
    }

    static var apiResultPresentation: FeedbackAPIResultPresentation {
        bootstrap?.apiResultPresentation ?? .none
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
        userIdentity: FeedbackUserIdentity = .anonymous,
        formConfiguration: FeedbackFormConfiguration = .default,
        eventHandler: FeedbackEventHandler? = nil
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
            userIdentity: userIdentity,
            formConfiguration: formConfiguration,
            eventHandler: eventHandler
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
        userIdentity: FeedbackUserIdentity = .anonymous,
        formConfiguration: FeedbackFormConfiguration = .default,
        eventHandler: FeedbackEventHandler? = nil,
        apiResultPresentation: FeedbackAPIResultPresentation = .alert
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
            userIdentity: userIdentity,
            formConfiguration: formConfiguration,
            eventHandler: eventHandler,
            apiResultPresentation: apiResultPresentation
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
        userIdentity: FeedbackUserIdentity = .anonymous,
        formConfiguration: FeedbackFormConfiguration = .default,
        eventHandler: FeedbackEventHandler? = nil
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
            userIdentity: userIdentity,
            formConfiguration: formConfiguration,
            eventHandler: eventHandler
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

    /// Override API endpoint for ``screen``. Pass `nil` to use the bootstrap default.
    public static func setAPIEndpoint(_ endpoint: URL?, forScreen screen: String) {
        MeerkatFeedbackAPIEndpointRegistry.register(screen: screen, endpoint: endpoint)
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

    /// Clears stored satisfaction survey state (view count, shown flag, response) for `screen`.
    ///
    /// Useful after major content changes when you want to ask the user again.
    public static func resetSatisfactionSurvey(forScreen screen: String) {
        MeerkatSurveyStore.reset(screen: screen)
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

        MeerkatSurveyAnalytics.templateCommitted(screen: screen, template: template)

        if bootstrap.collectUserInput {
            MeerkatFeedbackStandaloneFormPresenter.present(
                screen: screen,
                template: template,
                locale: bootstrap.locale,
                formConfiguration: bootstrap.formConfiguration,
                offerScreenshot: effectiveOfferScreenshotInForm,
                onSubmit: { userInput in
                    submitFeedback(screen: screen, template: template, userInput: userInput)
                },
                onCancel: {
                    FeedbackEventDispatcher.cancelled(screen: screen, stage: .form)
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
            offerScreenshot: effectiveOfferScreenshotInForm,
            logProvider: bootstrap.logProvider,
            crashLogPath: bootstrap.crashLogPath
        )
        let resolvedIdentity = resolvedUserIdentity(
            bootstrapIdentity: bootstrap.userIdentity,
            userInput: userInput
        )
        let payload = FeedbackPayloadBuilder.build(
            configuration: configuration,
            placementOverride: screen,
            templateOverride: template,
            userInput: userInput,
            attachments: attachments,
            userIdentity: resolvedIdentity
        )
        deliver(
            payload,
            screen: screen,
            template: template,
            configuration: configuration,
            identity: resolvedIdentity
        )
    }

    private static func resolvedUserIdentity(
        bootstrapIdentity: FeedbackUserIdentity,
        userInput: FeedbackUserInput?
    ) -> FeedbackUserIdentity {
        guard let email = userInput?.email?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else {
            return bootstrapIdentity
        }

        if bootstrapIdentity.isAnonymous {
            return FeedbackUserIdentity(email: email)
        }

        if bootstrapIdentity.email == nil || bootstrapIdentity.email?.isEmpty == true {
            return FeedbackUserIdentity(
                userId: bootstrapIdentity.userId,
                email: email
            )
        }

        return bootstrapIdentity
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
        screen: String,
        template: FeedbackTemplate,
        configuration: MeerkatConfiguration,
        identity: FeedbackUserIdentity
    ) {
        switch configuration.delivery {
        case .mailComposer:
            let result = FeedbackMailDelivery.present(
                payload: payload,
                configuration: configuration,
                screen: screen,
                template: template
            )
            switch result {
            case .composerPresented:
                break
            case .deliveredImmediately:
                FeedbackEventDispatcher.submitted(
                    screen: screen,
                    template: template,
                    payload: payload,
                    channel: .mail
                )
            case .failed:
                FeedbackEventDispatcher.failed(
                    screen: screen,
                    template: template,
                    error: .mailUnavailable,
                    queuedOffline: false
                )
            }
        case let .api(apiConfig):
            APIFeedbackDelivery.deliver(
                payload: payload,
                configuration: apiConfig,
                identity: identity,
                screen: screen,
                template: template
            )
        case let .custom(handler):
            handler(payload)
            FeedbackEventDispatcher.submitted(
                screen: screen,
                template: template,
                payload: payload,
                channel: .custom
            )
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
        appendUserInputMetadata(&metadata, userInput: userInput)

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

    private static func appendUserInputMetadata(
        _ metadata: inout [String: String],
        userInput: FeedbackUserInput?
    ) {
        guard let userInput else { return }
        if let email = userInput.email, !email.isEmpty {
            metadata["email"] = email
        }
        for (key, value) in userInput.customFields where !value.isEmpty {
            metadata[key] = value
        }
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
