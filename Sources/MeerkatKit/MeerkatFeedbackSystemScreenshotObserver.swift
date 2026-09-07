import Foundation

#if canImport(UIKit) && !os(watchOS) && !os(tvOS)
import UIKit

/// Opens feedback (with screenshot preferred) when the user takes a system screenshot.
@MainActor
enum MeerkatFeedbackSystemScreenshotObserver {
    private static var token: NSObjectProtocol?

    static func startIfNeeded() {
        guard token == nil else { return }
        token = NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                handleSystemScreenshot()
            }
        }
    }

    static func stop() {
        if let token {
            NotificationCenter.default.removeObserver(token)
        }
        token = nil
    }

    private static func handleSystemScreenshot() {
        guard MeerkatFeedback.isEnabled,
              MeerkatFeedback.effectiveOfferScreenshotInForm else {
            return
        }

        if MeerkatFeedbackSessionRegistry.isPresentingFeedbackUI {
            MeerkatFeedbackPendingScreenshot.markPreferInclude()
            NotificationCenter.default.post(name: .meerkatPreferIncludeScreenshot, object: nil)
            return
        }

        Task { @MainActor in
            guard let screen = MeerkatFeedbackSessionRegistry.activeScreen else {
                return
            }

            if let png = await FeedbackScreenshotCapture.capturePNGHidingChrome() {
                guard MeerkatFeedbackSessionRegistry.activeScreen == screen else {
                    return
                }
                MeerkatFeedbackPendingScreenshot.store(png)
            } else {
                guard MeerkatFeedbackSessionRegistry.activeScreen == screen else {
                    return
                }
                MeerkatFeedbackPendingScreenshot.markPreferInclude()
            }
            MeerkatFeedback.requestFeedback(screen: screen)
        }
    }
}
#endif
