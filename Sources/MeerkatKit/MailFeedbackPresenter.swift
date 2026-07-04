#if os(iOS)
import UIKit
import MessageUI

enum MailFeedbackPresenter {
    @MainActor
    static func present(payload: FeedbackPayload, recipients: [String]) {
        if MFMailComposeViewController.canSendMail() {
            guard let presenter = TopViewControllerFinder.topViewController() else {
                attemptMailtoThenFallback(payload: payload, recipients: recipients)
                return
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

            presenter.present(composer, animated: true)
            return
        }

        attemptMailtoThenFallback(payload: payload, recipients: recipients)
    }

    @MainActor
    private static func attemptMailtoThenFallback(
        payload: FeedbackPayload,
        recipients: [String]
    ) {
        let opened = MailtoFeedbackPresenter.presentIfPossible(
            payload: payload,
            recipients: recipients
        )
        if !opened {
            presentFallback(payload: payload, recipients: recipients)
        }
    }

    @MainActor
    private static func presentFallback(
        payload: FeedbackPayload,
        recipients: [String]
    ) {
        switch MeerkatFeedback.mailUnavailableFallback {
        case .shareSheet:
            ShareFeedbackPresenter.present(payload: payload, recipients: recipients)
        case .none:
            print("MeerkatKit: Mail unavailable and no fallback configured.")
        }
    }
}

private final class MailComposeDelegate: NSObject, MFMailComposeViewControllerDelegate, @unchecked Sendable {
    static let shared = MailComposeDelegate()

    nonisolated func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        Task { @MainActor in
            controller.dismiss(animated: true)
        }
    }
}

enum TopViewControllerFinder {
    @MainActor
    static func topViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    ) -> UIViewController? {
        if let navigation = base as? UINavigationController {
            return topViewController(base: navigation.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
#endif
