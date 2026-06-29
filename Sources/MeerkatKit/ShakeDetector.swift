#if os(iOS)
import SwiftUI
import UIKit

final class ShakeDetector {
    private var isMonitoring = false
    private var onShake: (() -> Void)?

    func start(onShake: @escaping () -> Void) {
        guard !isMonitoring else { return }
        self.onShake = onShake
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShake),
            name: .meerkatDeviceDidShake,
            object: nil
        )
        isMonitoring = true
    }

    func stop() {
        guard isMonitoring else { return }
        NotificationCenter.default.removeObserver(self)
        isMonitoring = false
        onShake = nil
    }

    @objc private func handleShake() {
        onShake?()
    }
}

extension Notification.Name {
    static let meerkatDeviceDidShake = Notification.Name("MeerkatKit.deviceDidShake")
}

struct ShakeResponderView: UIViewControllerRepresentable {
    let onShake: () -> Void

    func makeUIViewController(context: Context) -> ShakeResponderViewController {
        let controller = ShakeResponderViewController()
        controller.onShake = onShake
        return controller
    }

    func updateUIViewController(_ uiViewController: ShakeResponderViewController, context: Context) {
        uiViewController.onShake = onShake
    }
}

final class ShakeResponderViewController: UIViewController {
    var onShake: (() -> Void)?

    override var canBecomeFirstResponder: Bool { true }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            onShake?()
            NotificationCenter.default.post(name: .meerkatDeviceDidShake, object: nil)
        }
        super.motionEnded(motion, with: event)
    }
}
#endif
