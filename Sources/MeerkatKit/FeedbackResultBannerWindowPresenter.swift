#if canImport(SwiftUI)
import SwiftUI
#endif

#if os(iOS) || os(visionOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@MainActor
enum FeedbackResultBannerWindowPresenter {
    #if canImport(SwiftUI)
    #if os(iOS) || os(visionOS) || os(tvOS)
    private static weak var installedOverlayView: UIView?
    private static weak var installedWindow: UIWindow?
    #elseif os(macOS)
    private static weak var installedOverlayView: NSView?
    private static weak var installedWindow: NSWindow?
    #endif
    #endif

    static func ensureOverlayInstalledIfNeeded() {
        #if canImport(SwiftUI)
        if needsReinstall {
            removeInstalledOverlay()
            installOverlay()
        }
        #endif
    }

    #if canImport(SwiftUI)
    private static var needsReinstall: Bool {
        #if os(iOS) || os(visionOS) || os(tvOS)
        guard let window = keyWindow else { return false }
        return installedOverlayView == nil || installedWindow !== window
        #elseif os(macOS)
        guard let window = NSApp.keyWindow else { return false }
        return installedOverlayView == nil || installedWindow !== window
        #else
        return false
        #endif
    }

    private static func removeInstalledOverlay() {
        #if os(iOS) || os(visionOS) || os(tvOS)
        installedOverlayView?.removeFromSuperview()
        installedOverlayView = nil
        installedWindow = nil
        #elseif os(macOS)
        installedOverlayView?.removeFromSuperview()
        installedOverlayView = nil
        installedWindow = nil
        #endif
    }

    private static func installOverlay() {
        let overlay = FeedbackResultBannerOverlay()
            .accessibilityIdentifier("meerkat_feedback_banner_overlay")

        #if os(iOS) || os(visionOS) || os(tvOS)
        guard let window = keyWindow else { return }
        let host = UIHostingController(rootView: overlay)
        host.view.backgroundColor = .clear
        host.view.isUserInteractionEnabled = false
        host.view.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: window.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        ])
        installedOverlayView = host.view
        installedWindow = window
        #elseif os(macOS)
        guard let window = NSApp.keyWindow, let contentView = window.contentView else { return }
        let host = NSHostingController(rootView: overlay)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        installedOverlayView = host.view
        installedWindow = window
        #endif
    }

    #if os(iOS) || os(visionOS) || os(tvOS)
    private static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }
    #endif
    #endif
}
