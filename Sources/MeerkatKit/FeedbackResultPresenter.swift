import Foundation

#if canImport(SwiftUI)
import SwiftUI
#endif

@MainActor
enum FeedbackResultPresenter {
    static func present(
        outcome: FeedbackAPIOutcome,
        presentation: FeedbackAPIResultPresentation,
        locale: FeedbackLocale
    ) {
        switch presentation {
        case .none:
            return
        case .alert:
            presentAlert(outcome: outcome, locale: locale)
        case .banner:
            presentBanner(outcome: outcome, locale: locale)
        }
    }

    private static func presentAlert(outcome: FeedbackAPIOutcome, locale: FeedbackLocale) {
        let title = MeerkatLocalizer.text(titleKey(for: outcome), locale: locale)
        let message = MeerkatLocalizer.text(messageKey(for: outcome), locale: locale)

        #if os(iOS) || os(tvOS)
        guard let presenter = TopViewControllerFinder.topViewController() else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: MeerkatLocalizer.text(.apiResultDismiss, locale: locale),
            style: .default
        ))
        presenter.present(alert, animated: true)
        #elseif os(macOS)
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = outcome == .success ? .informational : .warning
        alert.addButton(withTitle: MeerkatLocalizer.text(.apiResultDismiss, locale: locale))
        alert.runModal()
        #endif
    }

    private static func presentBanner(outcome: FeedbackAPIOutcome, locale: FeedbackLocale) {
        #if canImport(SwiftUI)
        FeedbackResultBannerController.shared.show(
            title: MeerkatLocalizer.text(titleKey(for: outcome), locale: locale),
            message: MeerkatLocalizer.text(messageKey(for: outcome), locale: locale),
            isSuccess: outcome == .success
        )
        #endif
    }

    private static func titleKey(for outcome: FeedbackAPIOutcome) -> MeerkatLocalizedKey {
        switch outcome {
        case .success:
            return .apiSuccessTitle
        case .queuedOffline:
            return .apiOfflineTitle
        case .failed:
            return .apiFailureTitle
        }
    }

    private static func messageKey(for outcome: FeedbackAPIOutcome) -> MeerkatLocalizedKey {
        switch outcome {
        case .success:
            return .apiSuccessMessage
        case .queuedOffline:
            return .apiOfflineMessage
        case .failed:
            return .apiFailureMessage
        }
    }
}

#if canImport(SwiftUI)
@MainActor
final class FeedbackResultBannerController: ObservableObject {
    static let shared = FeedbackResultBannerController()

    @Published private(set) var banner: FeedbackResultBanner?

    func show(title: String, message: String, isSuccess: Bool) {
        banner = FeedbackResultBanner(title: title, message: message, isSuccess: isSuccess)
        Task {
            try? await Task.sleep(for: .seconds(3))
            if banner?.title == title {
                banner = nil
            }
        }
    }
}

struct FeedbackResultBanner: Equatable {
    let title: String
    let message: String
    let isSuccess: Bool
}

struct FeedbackResultBannerOverlay: View {
    @ObservedObject private var controller = FeedbackResultBannerController.shared

    var body: some View {
        VStack {
            if let banner = controller.banner {
                FeedbackResultBannerView(banner: banner)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
        .animation(.easeInOut, value: controller.banner)
        .allowsHitTesting(false)
    }
}

private struct FeedbackResultBannerView: View {
    let banner: FeedbackResultBanner

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: banner.isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(banner.isSuccess ? .green : .orange)
            VStack(alignment: .leading, spacing: 4) {
                Text(banner.title)
                    .font(.subheadline.bold())
                Text(banner.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
#endif

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
