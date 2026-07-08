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
        MeerkatFeedbackStandalonePresentation.presentFormOrCancel(
            screen: screen,
            template: template,
            onCancel: onCancel
        ) {
            guard let presenter = TopViewControllerFinder.topViewController() else { return }

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
            #if os(iOS)
            if let sheetController = host.sheetPresentationController {
                sheetController.detents = [.medium(), .large()]
                sheetController.prefersGrabberVisible = true
            }
            #endif
            presenter.present(host, animated: true)
        }
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
        MeerkatFeedbackStandalonePresentation.presentFormOrCancel(
            screen: screen,
            template: template,
            onCancel: onCancel
        ) {
            guard let presenter = TopViewControllerFinder.topViewController() else { return }

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
        final class WindowIDBox: @unchecked Sendable {
            var id: ObjectIdentifier?
        }
        let windowIDBox = WindowIDBox()

        windowIDBox.id = MeerkatFeedbackStandaloneWindowRegistry.present(
            title: MeerkatLocalizer.text(.formTitle, locale: locale),
            rootView: MeerkatFeedbackFormSheet(
                template: template,
                locale: locale,
                formConfiguration: formConfiguration,
                offerScreenshot: offerScreenshot,
                onSubmit: { userInput in
                    if let windowID = windowIDBox.id {
                        MeerkatFeedbackStandaloneWindowRegistry.closeWindow(id: windowID)
                    }
                    onSubmit(userInput)
                },
                onCancel: {
                    if let windowID = windowIDBox.id {
                        MeerkatFeedbackStandaloneWindowRegistry.closeWindow(id: windowID)
                    }
                    onCancel()
                }
            ),
            preferredSize: NSSize(width: 420, height: 420),
            onClose: onCancel
        )
    }
}
#endif
