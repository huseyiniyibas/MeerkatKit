import Foundation

enum ShareFeedbackPresenter {
    @MainActor
    static func present(payload: FeedbackPayload, recipients: [String]) {
        let subject = "[\(payload.placement)] \(payload.subject)"
        var shareText = payload.body
        if !recipients.isEmpty {
            shareText += "\n\n\(MeerkatLocalizer.text(.labelRecipients, locale: MeerkatFeedback.configuredLocale)): \(recipients.joined(separator: ", "))"
        }

        #if os(iOS)
        ShareFeedbackPresenterIOS.present(subject: subject, body: shareText)
        #elseif os(tvOS)
        ShareFeedbackPresenterTV.present(subject: subject, body: shareText)
        #elseif os(macOS)
        ShareFeedbackPresenterMac.present(subject: subject, body: shareText)
        #endif
    }
}

#if os(iOS)
import UIKit

private enum ShareFeedbackPresenterIOS {
    @MainActor
    static func present(subject: String, body: String) {
        guard let presenter = TopViewControllerFinder.topViewController() else {
            print("MeerkatKit: Could not find a view controller to present share sheet.")
            return
        }

        let items: [Any] = ["\(subject)\n\n\(body)"]
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let popover = controller.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(
                x: presenter.view.bounds.midX,
                y: presenter.view.bounds.midY,
                width: 0,
                height: 0
            )
        }
        presenter.present(controller, animated: true)
    }
}
#endif

#if os(tvOS)
import UIKit

private enum ShareFeedbackPresenterTV {
    @MainActor
    static func present(subject: String, body: String) {
        print("MeerkatKit: Mail unavailable on tvOS. Feedback text:\n\(subject)\n\n\(body)")
    }
}
#endif

#if os(macOS)
import AppKit

private enum ShareFeedbackPresenterMac {
    @MainActor
    static func present(subject: String, body: String) {
        let items: [Any] = ["\(subject)\n\n\(body)"]
        let picker = NSSharingServicePicker(items: items)
        if let window = NSApp.keyWindow, let contentView = window.contentView {
            picker.show(
                relativeTo: contentView.bounds,
                of: contentView,
                preferredEdge: .minY
            )
        } else {
            NSSharingService(named: .composeEmail)?
                .perform(withItems: items)
        }
    }
}
#endif
