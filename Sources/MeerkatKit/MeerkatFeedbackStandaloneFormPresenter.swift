#if os(iOS) || os(visionOS)
import SwiftUI
import UIKit

@MainActor
enum MeerkatFeedbackStandaloneFormPresenter {
    static func present(
        screen: String,
        template: FeedbackTemplate,
        locale: FeedbackLocale,
        formConfiguration: FeedbackFormConfiguration,
        offerScreenshot: Bool,
        onSubmit: @escaping @MainActor (FeedbackUserInput) -> Void,
        onCancel: @escaping @MainActor () -> Void
    ) {
        guard let presenter = TopViewControllerFinder.topViewController() else {
            MeerkatFeedback.submitFeedback(screen: screen, template: template, userInput: nil)
            return
        }

        let sheet = MeerkatFeedbackFormSheet(
            template: template,
            locale: locale,
            formConfiguration: formConfiguration,
            offerScreenshot: offerScreenshot,
            onSubmit: onSubmit,
            onCancel: onCancel
        )
        let host = UIHostingController(rootView: sheet)
        host.modalPresentationStyle = .pageSheet
        if let sheetController = host.sheetPresentationController {
            sheetController.detents = [.medium(), .large()]
            sheetController.prefersGrabberVisible = true
        }
        presenter.present(host, animated: true)
    }
}
#elseif os(tvOS)
import SwiftUI
import UIKit

@MainActor
enum MeerkatFeedbackStandaloneFormPresenter {
    static func present(
        screen: String,
        template: FeedbackTemplate,
        locale: FeedbackLocale,
        formConfiguration: FeedbackFormConfiguration,
        offerScreenshot: Bool,
        onSubmit: @escaping @MainActor (FeedbackUserInput) -> Void,
        onCancel: @escaping @MainActor () -> Void
    ) {
        guard let presenter = TopViewControllerFinder.topViewController() else {
            MeerkatFeedback.submitFeedback(screen: screen, template: template, userInput: nil)
            return
        }

        let sheet = MeerkatFeedbackFormSheet(
            template: template,
            locale: locale,
            formConfiguration: formConfiguration,
            offerScreenshot: offerScreenshot,
            onSubmit: onSubmit,
            onCancel: onCancel
        )
        let host = UIHostingController(rootView: sheet)
        host.modalPresentationStyle = .fullScreen
        presenter.present(host, animated: true)
    }
}
#elseif os(macOS)
import AppKit
import SwiftUI

@MainActor
enum MeerkatFeedbackStandaloneFormPresenter {
    static func present(
        screen: String,
        template: FeedbackTemplate,
        locale: FeedbackLocale,
        formConfiguration: FeedbackFormConfiguration,
        offerScreenshot: Bool,
        onSubmit: @escaping @MainActor (FeedbackUserInput) -> Void,
        onCancel: @escaping @MainActor () -> Void
    ) {
        let sheet = MeerkatFeedbackFormSheet(
            template: template,
            locale: locale,
            formConfiguration: formConfiguration,
            offerScreenshot: offerScreenshot,
            onSubmit: onSubmit,
            onCancel: onCancel
        )
        let host = NSHostingController(rootView: sheet)
        host.preferredContentSize = NSSize(width: 420, height: 420)

        let window = NSWindow(contentViewController: host)
        window.title = MeerkatLocalizer.text(.formTitle, locale: locale)
        window.styleMask = [.titled, .closable]
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
#endif
