#if canImport(UIKit) && !os(watchOS)
import UIKit

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
            // Presenting onto a VC that is mid-dismiss fails silently.
            if presented.isBeingDismissed {
                return base
            }
            return topViewController(base: presented)
        }
        return base
    }

    /// Waits until mid-dismiss / mid-present controllers clear, then presents.
    ///
    /// Re-queries the top controller after waiting so the presented UI is not
    /// attached to a SwiftUI sheet that is about to dismiss.
    @MainActor
    static func presentAfterDismissalsIfNeeded(
        _ viewController: UIViewController,
        from presenter: UIViewController,
        animated: Bool = true
    ) {
        Task { @MainActor in
            await waitUntilPresentationStackSettles()
            resolvedPresenter(preferred: presenter).present(viewController, animated: animated)
        }
    }

    @MainActor
    static func waitUntilPresentationStackSettles() async {
        var stablePasses = 0
        for _ in 0..<60 {
            if isPresentationStackTransient() {
                stablePasses = 0
                try? await Task.sleep(for: .milliseconds(50))
                continue
            }
            stablePasses += 1
            if stablePasses >= 2 {
                return
            }
            try? await Task.sleep(for: .milliseconds(50))
        }
    }

    /// Dismisses `host` if it is still presented, then waits for a settled stack.
    @MainActor
    static func dismissThenPresentReady(
        _ host: UIViewController?,
        then work: @escaping @MainActor () -> Void
    ) {
        Task { @MainActor in
            if let host, host.presentingViewController != nil {
                await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                    host.dismiss(animated: true) {
                        continuation.resume()
                    }
                }
            }
            await waitUntilPresentationStackSettles()
            work()
        }
    }

    @MainActor
    private static func isPresentationStackTransient() -> Bool {
        guard let top = topViewController() else { return false }
        if top.isBeingDismissed || top.isBeingPresented {
            return true
        }
        if let presented = top.presentedViewController,
           presented.isBeingDismissed || presented.isBeingPresented {
            return true
        }
        return false
    }

    @MainActor
    private static func resolvedPresenter(preferred: UIViewController) -> UIViewController {
        if preferred.isBeingDismissed {
            return topViewController() ?? preferred
        }
        if let presented = preferred.presentedViewController, !presented.isBeingDismissed {
            return presentedTopMost(from: preferred)
        }
        return topViewController() ?? preferred
    }

    @MainActor
    private static func presentedTopMost(from base: UIViewController) -> UIViewController {
        var current = base
        while let presented = current.presentedViewController, !presented.isBeingDismissed {
            current = presented
        }
        return current
    }
}
#endif
