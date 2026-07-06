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

final class ExampleAppKitController: NSViewController {
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 480, height: 240))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AppKit"

        let button = NSButton(title: "Send Feedback", target: self, action: #selector(feedbackTapped))
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func feedbackTapped() {
        meerkatRequestFeedback(screen: "AppKitDemo")
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
