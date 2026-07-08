import Foundation

#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

enum FeedbackScreenshotCapture {
    static var isSupported: Bool {
        #if canImport(UIKit) && !os(watchOS) && !os(tvOS)
        return true
        #elseif os(macOS)
        return true
        #else
        return false
        #endif
    }

    @MainActor
    static func capturePNG() -> Data? {
        #if canImport(UIKit) && !os(watchOS)
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow) else {
            return nil
        }
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let image = renderer.image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        }
        return image.pngData()
        #elseif os(macOS)
        guard let window = NSApp.keyWindow, let contentView = window.contentView else {
            return nil
        }
        let bounds = contentView.bounds
        guard let rep = contentView.bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        contentView.cacheDisplay(in: bounds, to: rep)
        return rep.representation(using: .png, properties: [:])
        #else
        return nil
        #endif
    }
}
