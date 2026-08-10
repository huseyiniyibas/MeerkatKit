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

    /// Waits until `presenter` has no presented child, then presents `viewController`.
    @MainActor
    static func presentAfterDismissalsIfNeeded(
        _ viewController: UIViewController,
        from presenter: UIViewController,
        animated: Bool = true
    ) {
        Task { @MainActor in
            for _ in 0..<40 {
                if presenter.presentedViewController == nil {
                    break
                }
                if let presented = presenter.presentedViewController, presented.isBeingDismissed {
                    try? await Task.sleep(for: .milliseconds(50))
                    continue
                }
                // Something else is presented and not dismissing — present on top of it.
                presentedTopMost(from: presenter).present(viewController, animated: animated)
                return
            }
            presenter.present(viewController, animated: animated)
        }
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
