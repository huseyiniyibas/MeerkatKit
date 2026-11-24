import Foundation

#if canImport(StoreKit)
import StoreKit
#endif
#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif

/// Opens the public App Store write-review page when an App Store ID is configured,
/// otherwise falls back to the native `SKStoreReviewController` prompt.
enum MeerkatAppStoreReview {
    static func writeReviewURL(appStoreID: String) -> URL? {
        var trimmed = appStoreID.trimmingCharacters(in: .whitespacesAndNewlines)
        // Accept the `id1234567890` form copied from an App Store URL.
        if trimmed.lowercased().hasPrefix("id") {
            trimmed = String(trimmed.dropFirst(2))
        }
        guard !trimmed.isEmpty, trimmed.allSatisfy({ $0.isASCII && $0.isNumber }) else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(trimmed)?action=write-review")
    }

    @MainActor
    static func request() {
        if let appStoreID = MetadataCollector.resolvedAppStoreID,
           let url = writeReviewURL(appStoreID: appStoreID) {
            open(url)
            return
        }
        requestNativeReview()
    }

    @MainActor
    private static func open(_ url: URL) {
        #if canImport(UIKit) && !os(watchOS)
        UIApplication.shared.open(url)
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }

    @MainActor
    private static func requestNativeReview() {
        #if canImport(StoreKit)
        #if os(iOS) || os(visionOS) || os(tvOS)
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        guard let scene = scenes.first(where: { $0.activationState == .foregroundActive })
            ?? scenes.first else {
            return
        }
        SKStoreReviewController.requestReview(in: scene)
        #elseif os(macOS)
        SKStoreReviewController.requestReview()
        #endif
        #endif
    }
}
