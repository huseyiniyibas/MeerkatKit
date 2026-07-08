#if os(macOS)
import AppKit

@MainActor
final class MeerkatFeedbackWindowCloseHandler: NSObject, NSWindowDelegate {
    var onClose: (() -> Void)?
    private var didHandleClose = false

    func windowWillClose(_ notification: Notification) {
        guard !didHandleClose else { return }
        didHandleClose = true
        onClose?()
    }

    func markHandled() {
        didHandleClose = true
    }
}
#endif
