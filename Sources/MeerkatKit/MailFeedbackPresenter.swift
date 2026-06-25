#if canImport(UIKit)
import UIKit
import MessageUI

enum MailFeedbackPresenter {
    @MainActor
    static func present(payload: FeedbackPayload, configuration: MeerkatConfiguration) {
        guard case let .mailComposer(recipients, _, _) = configuration.delivery else { return }
        guard MFMailComposeViewController.canSendMail() else {
            print("MeerkatKit: Mail is not configured on this device.")
            return
        }
        guard let presenter = TopViewControllerFinder.topViewController() else {
            print("MeerkatKit: Could not find a view controller to present mail composer.")
            return
        }

        let composer = MFMailComposeViewController()
        composer.setToRecipients(recipients)
        composer.setSubject("[\(payload.placement)] \(payload.subject)")
        composer.setMessageBody(payload.body, isHTML: false)
        composer.mailComposeDelegate = MailComposeDelegate.shared

        presenter.present(composer, animated: true)
    }
}

private final class MailComposeDelegate: NSObject, MFMailComposeViewControllerDelegate {
    static let shared = MailComposeDelegate()

    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
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
