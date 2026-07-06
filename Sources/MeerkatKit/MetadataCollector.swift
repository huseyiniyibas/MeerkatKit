import Foundation

#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

@MainActor
enum MetadataCollector {
    private static var configuredAppStoreID: String?
    private static var userIdentity: FeedbackUserIdentity = .anonymous

    static func setAppStoreID(_ appStoreID: String?) {
        configuredAppStoreID = appStoreID?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func setUserIdentity(_ identity: FeedbackUserIdentity) {
        userIdentity = identity
    }

    static var currentUserIdentity: FeedbackUserIdentity {
        userIdentity
    }

    #if DEBUG
    static func resetUserIdentity() {
        userIdentity = .anonymous
    }
    #endif

    static var includesConfiguredAppStoreID: Bool {
        guard let configuredAppStoreID else { return false }
        return !configuredAppStoreID.isEmpty
    }

    static func collect(
        headerKeys: [String],
        footerKeys: [String],
        placement: String
    ) -> [String: String] {
        var metadata: [String: String] = [
            "screen": placement,
            "placement": placement
        ]

        let keys = Set(headerKeys + footerKeys)
        for key in keys {
            let normalized = key.lowercased()
            if userIdentity.isAnonymous, normalized == "userid" || normalized == "email" {
                continue
            }
            metadata[key] = resolveValue(for: key)
        }

        if let appStoreID = configuredAppStoreID, !appStoreID.isEmpty {
            metadata["appStoreID"] = appStoreID
        }

        if !userIdentity.isAnonymous {
            if let userId = userIdentity.userId, !userId.isEmpty {
                metadata["userId"] = userId
            }
            if let email = userIdentity.email, !email.isEmpty {
                metadata["email"] = email
            }
        }

        return metadata
    }

    static func orderedKeys(
        headerKeys: [String],
        footerKeys: [String],
        includesAppStoreID: Bool
    ) -> [String] {
        var keys = headerKeys.isEmpty ? FeedbackEmailComposer.defaultMetadataKeys : headerKeys
        if includesAppStoreID, !keys.contains(where: { $0.lowercased() == "appstoreid" }) {
            keys.append("appStoreID")
        }
        if !keys.contains(where: { $0.lowercased() == "screen" }) {
            keys.insert("screen", at: min(3, keys.count))
        }
        return keys
    }

    private static func resolveValue(for key: String) -> String {
        switch key.lowercased() {
        case "appname":
            return appName
        case "appversion":
            return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        case "buildnumber":
            return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        case "devicemodel":
            return DeviceModelCatalog.displayName()
        case "osversion":
            return formattedOSVersion
        case "appstoreid":
            return configuredAppStoreID ?? "—"
        case "userid":
            return userIdentity.isAnonymous ? "—" : (userIdentity.userId ?? "—")
        case "email":
            return userIdentity.isAnonymous ? "—" : (userIdentity.email ?? "—")
        case "devicename":
            return deviceName
        case "screen", "placement":
            return "—"
        case "bundleid":
            return Bundle.main.bundleIdentifier ?? "unknown"
        default:
            return "—"
        }
    }

    private static var appName: String {
        let bundle = Bundle.main
        if let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
           !displayName.isEmpty {
            return displayName
        }
        if let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String,
           !name.isEmpty {
            return name
        }
        return "unknown"
    }

    private static var formattedOSVersion: String {
        let version = rawOSVersion
        return "\(platformName) \(version)"
    }

    private static var platformName: String {
        #if os(iOS)
        return "iOS"
        #elseif os(visionOS)
        return "visionOS"
        #elseif os(tvOS)
        return "tvOS"
        #elseif os(macOS)
        return "macOS"
        #else
        return "OS"
        #endif
    }

    private static var rawOSVersion: String {
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
