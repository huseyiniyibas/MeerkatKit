import Foundation

struct MeerkatBootstrap {
    var recipients: [String]
    var headerMetadata: [String]
    var footerMetadata: [String]
    var templates: [FeedbackTemplate]
    var locale: FeedbackLocale
    var buttonPosition: FeedbackPosition
    var enableShake: Bool
    var isEnabled: Bool
    var dismissCooldown: Duration
    var collectUserInput: Bool
    var mailUnavailableFallback: MailUnavailableFallback
    var apiConfiguration: FeedbackAPIConfiguration?
    var offerScreenshotInForm: Bool
    var crashLogPath: String?
    var logProvider: (() -> String?)?
    var userIdentity: FeedbackUserIdentity
    var customDelivery: (@MainActor (FeedbackPayload) -> Void)?
    var formConfiguration: FeedbackFormConfiguration
    var eventHandler: FeedbackEventHandler?
    var apiResultPresentation: FeedbackAPIResultPresentation

    static func mail(
        recipients: [String],
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
    ) -> MeerkatBootstrap {
        MeerkatBootstrap(
            recipients: recipients,
            headerMetadata: headerMetadata,
            footerMetadata: footerMetadata,
            templates: templates,
            locale: locale,
            buttonPosition: buttonPosition,
            enableShake: enableShake,
            isEnabled: isEnabled,
            dismissCooldown: dismissCooldown,
            collectUserInput: collectUserInput,
            mailUnavailableFallback: mailUnavailableFallback,
            apiConfiguration: nil,
            offerScreenshotInForm: offerScreenshotInForm,
            crashLogPath: crashLogPath,
            logProvider: nil,
            userIdentity: userIdentity,
            customDelivery: nil,
            formConfiguration: formConfiguration,
            eventHandler: eventHandler,
            apiResultPresentation: .none
        )
    }

    static func api(
        endpoint: URL,
        headers: [String: String] = [:],
        offlineRetryEnabled: Bool = true,
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
    ) -> MeerkatBootstrap {
        MeerkatBootstrap(
            recipients: [],
            headerMetadata: FeedbackEmailComposer.defaultMetadataKeys,
            footerMetadata: [],
            templates: templates,
            locale: locale,
            buttonPosition: buttonPosition,
            enableShake: enableShake,
            isEnabled: isEnabled,
            dismissCooldown: dismissCooldown,
            collectUserInput: collectUserInput,
            mailUnavailableFallback: .none,
            apiConfiguration: FeedbackAPIConfiguration(
                endpoint: endpoint,
                headers: headers,
                offlineRetryEnabled: offlineRetryEnabled
            ),
            offerScreenshotInForm: offerScreenshotInForm,
            crashLogPath: crashLogPath,
            logProvider: nil,
            userIdentity: userIdentity,
            customDelivery: nil,
            formConfiguration: formConfiguration,
            eventHandler: eventHandler,
            apiResultPresentation: apiResultPresentation
        )
    }

    static func custom(
        _ handler: @escaping @MainActor (FeedbackPayload) -> Void,
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
    ) -> MeerkatBootstrap {
        MeerkatBootstrap(
            recipients: [],
            headerMetadata: [],
            footerMetadata: [],
            templates: templates,
            locale: locale,
            buttonPosition: buttonPosition,
            enableShake: enableShake,
            isEnabled: isEnabled,
            dismissCooldown: dismissCooldown,
            collectUserInput: collectUserInput,
            mailUnavailableFallback: .none,
            apiConfiguration: nil,
            offerScreenshotInForm: offerScreenshotInForm,
            crashLogPath: crashLogPath,
            logProvider: nil,
            userIdentity: userIdentity,
            customDelivery: handler,
            formConfiguration: formConfiguration,
            eventHandler: eventHandler,
            apiResultPresentation: .none
        )
    }

    @MainActor
    func configuration(placement: String) -> MeerkatConfiguration {
        let delivery: FeedbackDelivery
        if let customDelivery {
            delivery = .custom(customDelivery)
        } else if let apiConfiguration {
            delivery = .api(apiConfiguration)
        } else {
            let resolvedRecipients = MeerkatFeedbackRecipientRegistry.resolvedRecipients(
                for: placement,
                default: recipients
            )
            delivery = .mailComposer(
                recipients: resolvedRecipients,
                headerMetadata: headerMetadata,
                footerMetadata: footerMetadata
            )
        }

        let trigger: FeedbackTrigger = enableShake
            ? .shake
            : .stickyButton(position: buttonPosition)

        return MeerkatConfiguration(
            trigger: trigger,
            delivery: delivery,
            placement: placement,
            templates: templates,
            locale: locale,
            isEnabled: isEnabled
        )
    }
}
