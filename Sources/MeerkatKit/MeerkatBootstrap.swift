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
    var customDelivery: (@MainActor (FeedbackPayload) -> Void)?

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
        mailUnavailableFallback: MailUnavailableFallback = .shareSheet
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
            customDelivery: nil
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
        collectUserInput: Bool = true
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
            customDelivery: handler
        )
    }

    func configuration(placement: String) -> MeerkatConfiguration {
        let delivery: FeedbackDelivery
        if let customDelivery {
            delivery = .custom(customDelivery)
        } else {
            delivery = .mailComposer(
                recipients: recipients,
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
