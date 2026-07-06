#if canImport(UIKit) && !os(watchOS)
import MeerkatKit
import SwiftUI
import UIKit

struct ExampleUIKitView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ExampleUIKitController {
        ExampleUIKitController()
    }

    func updateUIViewController(_ uiViewController: ExampleUIKitController, context: Context) {}
}

final class ExampleUIKitController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "UIKit"
        navigationItem.rightBarButtonItem = MeerkatFeedbackUIKit.makeBarButtonItem(screen: "UIKitDemo")
    }
}
#else
import SwiftUI

struct ExampleUIKitView: View {
    var body: some View {
        Text("UIKit demo is available on iOS and tvOS.")
            .foregroundStyle(.secondary)
            .navigationTitle("UIKit")
    }
}
#endif
