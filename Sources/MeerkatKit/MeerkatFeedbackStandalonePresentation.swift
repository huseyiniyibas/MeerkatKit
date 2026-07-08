import Foundation

@MainActor
enum MeerkatFeedbackStandalonePresentation {
    static func presentFormOrCancel(
        screen: String,
        template: FeedbackTemplate,
        onCancel: @escaping @MainActor () -> Void,
        present: @escaping @MainActor () -> Void
    ) {
        #if os(iOS) || os(visionOS) || os(tvOS)
        guard TopViewControllerFinder.topViewController() != nil else {
            print("MeerkatKit: No presenter available for feedback on screen \(screen).")
            FeedbackEventDispatcher.cancelled(screen: screen, stage: .form)
            onCancel()
            return
        }
        #endif
        present()
    }

    static func presentTemplatePickerOrCancel(
        screen: String,
        onCancel: @escaping @MainActor () -> Void,
        present: @escaping @MainActor () -> Void
    ) {
        #if os(iOS) || os(visionOS) || os(tvOS)
        guard TopViewControllerFinder.topViewController() != nil else {
            print("MeerkatKit: No presenter available for template picker on screen \(screen).")
            FeedbackEventDispatcher.cancelled(screen: screen, stage: .templatePicker)
            onCancel()
            return
        }
        #endif
        present()
    }
}

#if os(iOS) || os(visionOS) || os(tvOS)
import UIKit
#endif
