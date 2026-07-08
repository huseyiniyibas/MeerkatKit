#if os(macOS)
import AppKit
import SwiftUI

@MainActor
enum MeerkatFeedbackStandaloneWindowRegistry {
    private struct Entry {
        let window: NSWindow
        let closeHandler: MeerkatFeedbackWindowCloseHandler
    }

    private static var entries: [ObjectIdentifier: Entry] = [:]

    @discardableResult
    static func present(
        title: String,
        rootView: some View,
        preferredSize: NSSize,
        onClose: @escaping @MainActor () -> Void
    ) -> ObjectIdentifier {
        let closeHandler = MeerkatFeedbackWindowCloseHandler()
        let host = NSHostingController(rootView: AnyView(rootView))
        host.preferredContentSize = preferredSize

        let window = NSWindow(contentViewController: host)
        window.title = title
        window.styleMask = [.titled, .closable]
        window.delegate = closeHandler
        window.center()

        let windowID = ObjectIdentifier(window)
        entries[windowID] = Entry(window: window, closeHandler: closeHandler)
        closeHandler.onClose = {
            entries.removeValue(forKey: windowID)
            onClose()
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        return windowID
    }

    static func closeWindow(id windowID: ObjectIdentifier, markHandled: Bool = true) {
        if markHandled {
            entries[windowID]?.closeHandler.markHandled()
        }
        entries[windowID]?.window.close()
        entries.removeValue(forKey: windowID)
    }

    #if DEBUG
    static func resetAll() {
        entries.values.forEach { $0.window.close() }
        entries.removeAll()
    }
    #endif
}
#endif
