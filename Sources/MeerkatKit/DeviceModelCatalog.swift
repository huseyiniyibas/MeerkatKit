import Foundation

enum DeviceModelCatalog {
    static func marketingName(for identifier: String) -> String? {
        map[identifier]
    }

    static func resolvedIdentifier() -> String {
        #if targetEnvironment(simulator)
        if let simulatorID = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"],
           !simulatorID.isEmpty {
            return simulatorID
        }
        #endif

        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) { pointer in
            pointer.withMemoryRebound(to: CChar.self, capacity: 1) { charPointer in
                String(cString: charPointer)
            }
        }
    }

    static func displayName() -> String {
        let identifier = resolvedIdentifier()
        if let marketingName = marketingName(for: identifier) {
            return marketingName
        }
        return fallbackName(for: identifier)
    }

    private static func fallbackName(for identifier: String) -> String {
        if identifier == "arm64" || identifier == "x86_64" {
            #if canImport(UIKit) && !os(watchOS)
            return UIDevice.current.model
            #else
            return "Unknown Device"
            #endif
        }
        if identifier.hasPrefix("iPhone") {
            return "iPhone"
        }
        if identifier.hasPrefix("iPad") {
            return "iPad"
        }
        if identifier.hasPrefix("AppleTV") {
            return "Apple TV"
        }
        return identifier
    }

    private static let map: [String: String] = [
        "iPhone11,2": "iPhone XS",
        "iPhone11,4": "iPhone XS Max",
        "iPhone11,6": "iPhone XS Max",
        "iPhone11,8": "iPhone XR",
        "iPhone12,1": "iPhone 11",
        "iPhone12,3": "iPhone 11 Pro",
        "iPhone12,5": "iPhone 11 Pro Max",
        "iPhone12,8": "iPhone SE (2nd generation)",
        "iPhone13,1": "iPhone 12 mini",
        "iPhone13,2": "iPhone 12",
        "iPhone13,3": "iPhone 12 Pro",
        "iPhone13,4": "iPhone 12 Pro Max",
        "iPhone14,2": "iPhone 13 Pro",
        "iPhone14,3": "iPhone 13 Pro Max",
        "iPhone14,4": "iPhone 13 mini",
        "iPhone14,5": "iPhone 13",
        "iPhone14,6": "iPhone SE (3rd generation)",
        "iPhone14,7": "iPhone 14",
        "iPhone14,8": "iPhone 14 Plus",
        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
        "iPhone17,1": "iPhone 16 Pro",
        "iPhone17,2": "iPhone 16 Pro Max",
        "iPhone17,3": "iPhone 16",
        "iPhone17,4": "iPhone 16 Plus",
        "iPhone17,5": "iPhone 16e",
        "iPhone18,1": "iPhone 17 Pro",
        "iPhone18,2": "iPhone 17 Pro Max",
        "iPhone18,3": "iPhone 17",
        "iPhone18,4": "iPhone 17 Plus",
        "iPad13,1": "iPad Air (4th generation)",
        "iPad13,18": "iPad (10th generation)",
        "iPad14,1": "iPad mini (6th generation)",
        "iPad14,3": "iPad Pro 11-inch (4th generation)",
        "iPad14,5": "iPad Pro 12.9-inch (6th generation)",
        "iPad16,3": "iPad Pro 11-inch (M4)",
        "iPad16,4": "iPad Pro 13-inch (M4)",
        "AppleTV14,1": "Apple TV 4K (3rd generation)"
    ]
}

#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif
