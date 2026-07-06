#if os(macOS)
import AppKit

/// AppKit helpers for triggering MeerkatKit feedback outside SwiftUI on macOS.
@MainActor
public enum MeerkatFeedbackAppKit {
    /// Presents the feedback flow for ``screen`` (picker → form → delivery).
    public static func requestFeedback(screen: String) {
        MeerkatFeedback.requestFeedback(screen: screen)
    }

    /// Creates a toolbar item that triggers feedback for ``screen``.
    public static func makeToolbarItem(
        screen: String,
        label: String? = nil,
        systemImage: String = "bubble.left.and.text.bubble.right"
    ) -> NSToolbarItem {
        MeerkatFeedbackToolbarItem(screen: screen, label: label, systemImage: systemImage)
    }
}

@MainActor
public final class MeerkatFeedbackToolbarItem: NSToolbarItem {
    private let screen: String

    public init(screen: String, label: String? = nil, systemImage: String = "bubble.left.and.text.bubble.right") {
        self.screen = screen
        super.init(itemIdentifier: NSToolbarItem.Identifier("MeerkatFeedback.\(screen)"))

        if let label {
            self.label = label
        } else if let image = NSImage(systemSymbolName: systemImage, accessibilityDescription: "Feedback") {
            self.image = image
            self.label = "Feedback"
        } else {
            self.label = "Feedback"
        }

        target = self
        action = #selector(tapped)
        toolTip = label ?? "Feedback"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    @objc private func tapped() {
        MeerkatFeedback.requestFeedback(screen: screen)
    }
}

public extension NSViewController {
    /// Presents MeerkatKit feedback for ``screen``.
    func meerkatRequestFeedback(screen: String) {
        MeerkatFeedbackAppKit.requestFeedback(screen: screen)
    }
}
#endif
