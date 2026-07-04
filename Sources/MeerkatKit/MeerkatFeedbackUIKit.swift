#if canImport(UIKit) && !os(watchOS)
import UIKit

/// UIKit helpers for triggering MeerkatKit feedback outside SwiftUI.
@MainActor
public enum MeerkatFeedbackUIKit {
    /// Presents the feedback flow for ``screen`` (picker → form → delivery).
    public static func requestFeedback(screen: String) {
        MeerkatFeedback.requestFeedback(screen: screen)
    }

    /// Creates a bar button that triggers feedback for ``screen``.
    public static func makeBarButtonItem(
        screen: String,
        title: String? = nil,
        systemImage: String = "bubble.left.and.text.bubble.right"
    ) -> UIBarButtonItem {
        MeerkatFeedbackBarButtonItem(screen: screen, title: title, systemImage: systemImage)
    }
}

@MainActor
public final class MeerkatFeedbackBarButtonItem: UIBarButtonItem {
    private let screen: String

    public init(screen: String, title: String? = nil, systemImage: String = "bubble.left.and.text.bubble.right") {
        self.screen = screen
        super.init()
        if let title {
            self.title = title
        } else {
            self.image = UIImage(systemName: systemImage)
        }
        target = self
        action = #selector(tapped)
        accessibilityLabel = title ?? "Feedback"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    @objc private func tapped() {
        MeerkatFeedback.requestFeedback(screen: screen)
    }
}

public extension UIViewController {
    /// Presents MeerkatKit feedback for ``screen``.
    func meerkatRequestFeedback(screen: String) {
        MeerkatFeedbackUIKit.requestFeedback(screen: screen)
    }
}
#endif
