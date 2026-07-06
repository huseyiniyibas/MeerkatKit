#if os(macOS)
import AppKit
import MeerkatKit
import SwiftUI

struct ExampleAppKitView: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> ExampleAppKitController {
        ExampleAppKitController()
    }

    func updateNSViewController(_ nsViewController: ExampleAppKitController, context: Context) {}
}

final class ExampleAppKitController: NSViewController, NSToolbarDelegate {
    private let toolbarIdentifier = NSToolbar.Identifier("ExampleAppKitToolbar")
    private lazy var feedbackItem = MeerkatFeedbackAppKit.makeToolbarItem(
        screen: "AppKitDemo",
        label: "Feedback"
    )

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 480, height: 240))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AppKit"

        let label = NSTextField(labelWithString: "Use the toolbar Feedback item or the button below.")
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        let button = NSButton(title: "Send Feedback", target: self, action: #selector(feedbackTapped))
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24),
            label.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -32),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16)
        ])
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        guard view.window?.toolbar == nil else { return }

        let toolbar = NSToolbar(identifier: toolbarIdentifier)
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        view.window?.toolbar = toolbar
    }

    @objc private func feedbackTapped() {
        meerkatRequestFeedback(screen: "AppKitDemo")
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [feedbackItem.itemIdentifier]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [feedbackItem.itemIdentifier]
    }

    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        itemIdentifier == feedbackItem.itemIdentifier ? feedbackItem : nil
    }
}
#else
import SwiftUI

struct ExampleAppKitView: View {
    var body: some View {
        Text("AppKit demo is available on macOS.")
            .foregroundStyle(.secondary)
            .navigationTitle("AppKit")
    }
}
#endif
