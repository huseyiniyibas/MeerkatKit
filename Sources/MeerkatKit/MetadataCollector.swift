import Foundation

#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

#if os(macOS)
import AppKit
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
            return deviceModel
        case "osversion":
            return osVersion
        case "devicename":
            return deviceName
        case "bundleid":
            return Bundle.main.bundleIdentifier ?? "unknown"
        default:
            return "—"
        }
    }

    private static var deviceModel: String {
        #if canImport(UIKit) && !os(watchOS)
        return UIDevice.current.model
        #elseif os(macOS)
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
        #else
        return "unknown"
        #endif
    }

    private static var osVersion: String {
        #if canImport(UIKit) && !os(watchOS)
        return UIDevice.current.systemVersion
        #elseif os(macOS)
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        #else
        return ProcessInfo.processInfo.operatingSystemVersionString
        #endif
    }

    private static var deviceName: String {
        #if canImport(UIKit) && !os(watchOS)
        return UIDevice.current.name
        #elseif os(macOS)
        return Host.current().localizedName ?? "Mac"
        #else
        return Host.current().localizedName ?? "unknown"
        #endif
    }
}
