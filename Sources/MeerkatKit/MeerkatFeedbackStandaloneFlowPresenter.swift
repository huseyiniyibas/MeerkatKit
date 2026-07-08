#if os(iOS) || os(visionOS)
import SwiftUI
import UIKit

@MainActor
enum MeerkatFeedbackStandaloneFlowPresenter {
    static func requestFeedback(screen: String) {
        guard MeerkatFeedback.isEnabled else { return }

        if MeerkatFeedback.shouldShowTemplatePicker {
            presentTemplatePicker(
                screen: screen,
                onSelect: { template in
                    MeerkatFeedback.beginFeedbackWithoutSession(screen: screen, template: template)
                },
                onCancel: {
                    FeedbackEventDispatcher.cancelled(screen: screen, stage: .templatePicker)
                }
            )
        } else {
            MeerkatFeedback.beginFeedbackWithoutSession(
                screen: screen,
                template: MeerkatFeedback.configuredTemplates.first ?? .general
            )
        }
    }

    static func presentTemplatePicker(
        screen: String,
        onSelect: @escaping @MainActor (FeedbackTemplate) -> Void,
        onCancel: @escaping @MainActor () -> Void
    ) {
        MeerkatFeedbackStandalonePresentation.presentTemplatePickerOrCancel(
            screen: screen,
            onCancel: onCancel
        ) {
            guard let presenter = TopViewControllerFinder.topViewController() else { return }

            let sheet = MeerkatTemplatePickerSheet(
                screen: screen,
                templates: MeerkatFeedback.configuredTemplates,
                locale: MeerkatFeedback.configuredLocale,
                onSelect: onSelect,
                onCancel: onCancel
            )
            let host = UIHostingController(rootView: sheet)
            host.modalPresentationStyle = .pageSheet
            #if os(iOS)
            if let sheetController = host.sheetPresentationController {
                sheetController.detents = [.medium()]
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
enum MeerkatFeedbackStandaloneFlowPresenter {
    static func requestFeedback(screen: String) {
        guard MeerkatFeedback.isEnabled else { return }

        if MeerkatFeedback.shouldShowTemplatePicker {
            presentTemplatePicker(
                screen: screen,
                onSelect: { template in
                    MeerkatFeedback.beginFeedbackWithoutSession(screen: screen, template: template)
                },
                onCancel: {
                    FeedbackEventDispatcher.cancelled(screen: screen, stage: .templatePicker)
                }
            )
        } else {
            MeerkatFeedback.beginFeedbackWithoutSession(
                screen: screen,
                template: MeerkatFeedback.configuredTemplates.first ?? .general
            )
        }
    }

    static func presentTemplatePicker(
        screen: String,
        onSelect: @escaping @MainActor (FeedbackTemplate) -> Void,
        onCancel: @escaping @MainActor () -> Void
    ) {
        MeerkatFeedbackStandalonePresentation.presentTemplatePickerOrCancel(
            screen: screen,
            onCancel: onCancel
        ) {
            guard let presenter = TopViewControllerFinder.topViewController() else { return }

            let sheet = MeerkatTemplatePickerSheet(
                screen: screen,
                templates: MeerkatFeedback.configuredTemplates,
                locale: MeerkatFeedback.configuredLocale,
                onSelect: onSelect,
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
enum MeerkatFeedbackStandaloneFlowPresenter {
    static func requestFeedback(screen: String) {
        guard MeerkatFeedback.isEnabled else { return }

        if MeerkatFeedback.shouldShowTemplatePicker {
            presentTemplatePicker(
                screen: screen,
                onSelect: { template in
                    MeerkatFeedback.beginFeedbackWithoutSession(screen: screen, template: template)
                },
                onCancel: {
                    FeedbackEventDispatcher.cancelled(screen: screen, stage: .templatePicker)
                }
            )
        } else {
            MeerkatFeedback.beginFeedbackWithoutSession(
                screen: screen,
                template: MeerkatFeedback.configuredTemplates.first ?? .general
            )
        }
    }

    static func presentTemplatePicker(
        screen: String,
        onSelect: @escaping @MainActor (FeedbackTemplate) -> Void,
        onCancel: @escaping @MainActor () -> Void
    ) {
        let locale = MeerkatFeedback.configuredLocale
        final class WindowIDBox: @unchecked Sendable {
            var id: ObjectIdentifier?
        }
        let windowIDBox = WindowIDBox()

        windowIDBox.id = MeerkatFeedbackStandaloneWindowRegistry.present(
            title: MeerkatLocalizer.text(.templatePickerTitle, locale: locale),
            rootView: MeerkatTemplatePickerSheet(
                screen: screen,
                templates: MeerkatFeedback.configuredTemplates,
                locale: locale,
                onSelect: { template in
                    if let windowID = windowIDBox.id {
                        MeerkatFeedbackStandaloneWindowRegistry.closeWindow(id: windowID)
                    }
                    onSelect(template)
                },
                onCancel: {
                    if let windowID = windowIDBox.id {
                        MeerkatFeedbackStandaloneWindowRegistry.closeWindow(id: windowID)
                    }
                    onCancel()
                }
            ),
            preferredSize: NSSize(width: 420, height: 360),
            onClose: onCancel
        )
    }
}
#endif
