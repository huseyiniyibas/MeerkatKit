import Foundation

#if canImport(UIKit)
import UIKit
#endif

enum MetadataCollector {
    static func collect(
        headerKeys: [String],
        footerKeys: [String],
        placement: String
    ) -> [String: String] {
        var metadata: [String: String] = ["placement": placement]
        for key in headerKeys {
            metadata[key] = resolveValue(for: key)
        }
        for key in footerKeys where metadata[key] == nil {
            metadata[key] = resolveValue(for: key)
        }
        return metadata
    }

    static func formatBlock(metadata: [String: String], title: String) -> String {
        let lines = metadata.map { key, value in
            "\(key): \(value)"
        }.sorted()
        return ([title + ":"] + lines).joined(separator: "\n")
    }

    private static func resolveValue(for key: String) -> String {
        switch key.lowercased() {
        case "appversion":
            return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        case "buildnumber":
            return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        case "devicemodel":
            #if canImport(UIKit)
            return UIDevice.current.model
            #else
            return "unknown"
            #endif
        case "osversion":
            #if canImport(UIKit)
            return UIDevice.current.systemVersion
            #else
            return ProcessInfo.processInfo.operatingSystemVersionString
            #endif
        case "devicename":
            #if canImport(UIKit)
            return UIDevice.current.name
            #else
            return Host.current().localizedName ?? "unknown"
            #endif
        case "bundleid":
            return Bundle.main.bundleIdentifier ?? "unknown"
        default:
            return "—"
        }
    }
}
