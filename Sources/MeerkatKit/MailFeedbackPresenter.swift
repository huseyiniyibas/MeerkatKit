#if os(iOS)
import UIKit
import MessageUI

enum MailFeedbackPresenter {
    @MainActor
    static func present(
        payload: FeedbackPayload,
        recipients: [String],
        screen: String,
        template: FeedbackTemplate
    ) -> MailPresentationResult {
        if MFMailComposeViewController.canSendMail() {
            guard let presenter = TopViewControllerFinder.topViewController() else {
                return attemptMailtoThenFallback(
                    payload: payload,
                    recipients: recipients
                )
            }

            let composer = MFMailComposeViewController()
            composer.setToRecipients(recipients)
            composer.setSubject("[\(payload.placement)] \(payload.subject)")
            composer.setMessageBody(payload.body, isHTML: false)
            for attachment in payload.attachments {
                composer.addAttachmentData(
                    attachment.data,
                    mimeType: attachment.mimeType,
                    fileName: attachment.filename
                )
            }
            composer.mailComposeDelegate = MailComposeDelegate.shared
            MailComposeDelegate.shared.register(
                context: MailComposeContext(screen: screen, template: template, payload: payload)
            )

            presenter.present(composer, animated: true)
            return .composerPresented
        }

        return attemptMailtoThenFallback(payload: payload, recipients: recipients)
    }

    @MainActor
    private static func attemptMailtoThenFallback(
        payload: FeedbackPayload,
        recipients: [String]
    ) -> MailPresentationResult {
        let opened = MailtoFeedbackPresenter.presentIfPossible(
            payload: payload,
            recipients: recipients
        )
        if !opened {
            return presentFallback(payload: payload, recipients: recipients)
        }
        return .deliveredImmediately
    }

    @MainActor
    private static func presentFallback(
        payload: FeedbackPayload,
        recipients: [String]
    ) -> MailPresentationResult {
        switch MeerkatFeedback.mailUnavailableFallback {
        case .shareSheet:
            ShareFeedbackPresenter.present(payload: payload, recipients: recipients)
            return .deliveredImmediately
        case .none:
            print("MeerkatKit: Mail unavailable and no fallback configured.")
            return .failed
        }
    }
}

private struct MailComposeContext {
    let screen: String
    let template: FeedbackTemplate
    let payload: FeedbackPayload
}

private final class MailComposeDelegate: NSObject, MFMailComposeViewControllerDelegate, @unchecked Sendable {
    static let shared = MailComposeDelegate()
    private var pendingContext: MailComposeContext?

    @MainActor
    func register(context: MailComposeContext) {
        pendingContext = context
    }

    nonisolated func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        Task { @MainActor in
            let context = pendingContext
            pendingContext = nil
            controller.dismiss(animated: true)

            guard let context else { return }
            switch result {
            case .sent, .saved:
                FeedbackEventDispatcher.submitted(
                    screen: context.screen,
                    template: context.template,
                    payload: context.payload,
                    channel: .mail
                )
            case .cancelled, .failed:
                FeedbackEventDispatcher.cancelled(screen: context.screen, stage: .form)
            @unknown default:
                FeedbackEventDispatcher.cancelled(screen: context.screen, stage: .form)
            }
        }
    }
}

#endif
