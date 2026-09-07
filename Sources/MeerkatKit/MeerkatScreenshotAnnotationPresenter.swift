import SwiftUI

#if os(iOS) || os(visionOS)
import UIKit

@MainActor
enum MeerkatScreenshotAnnotationPresenter {
    static func present(png: Data, locale: FeedbackLocale) async -> Data {
        await withCheckedContinuation { continuation in
            var resumed = false
            let finish: (Data) -> Void = { data in
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: data)
            }

            let sheet = MeerkatScreenshotAnnotationSheet(png: png, locale: locale) { data in
                TopViewControllerFinder.topViewController()?.dismiss(animated: true)
                finish(data)
            }
            let host = UIHostingController(rootView: sheet)
            host.modalPresentationStyle = .fullScreen
            guard let presenter = TopViewControllerFinder.topViewController() else {
                finish(png)
                return
            }
            presenter.present(host, animated: true)
        }
    }
}

#elseif os(macOS)
import AppKit

@MainActor
enum MeerkatScreenshotAnnotationPresenter {
    static func present(png: Data, locale: FeedbackLocale) async -> Data {
        await withCheckedContinuation { continuation in
            var resumed = false
            let finish: (Data) -> Void = { data in
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: data)
            }
            var windowID: ObjectIdentifier?
            windowID = MeerkatFeedbackStandaloneWindowRegistry.present(
                title: MeerkatLocalizer.text(.annotationTitle, locale: locale),
                rootView: MeerkatScreenshotAnnotationSheet(png: png, locale: locale) { data in
                    if let windowID {
                        MeerkatFeedbackStandaloneWindowRegistry.closeWindow(id: windowID)
                    }
                    finish(data)
                },
                preferredSize: NSSize(width: 720, height: 640),
                onClose: { finish(png) }
            )
        }
    }
}

#else
@MainActor
enum MeerkatScreenshotAnnotationPresenter {
    static func present(png: Data, locale: FeedbackLocale) async -> Data {
        png
    }
}
#endif