import Foundation

enum FeedbackEmailComposer {
    static let defaultMetadataKeys = [
        "appName",
        "appVersion",
        "buildNumber",
        "deviceModel",
        "osVersion"
    ]

    static func composeBody(
        metadata: [String: String],
        locale: FeedbackLocale,
        orderedKeys: [String]
    ) -> String {
        var consumedKeys = Set<String>()
        let infoLines = orderedKeys.compactMap { key -> String? in
            let normalized = key.lowercased()
            if consumedKeys.contains(normalized) {
                return nil
            }

            if normalized == "appversion" {
                consumedKeys.insert("appversion")
                consumedKeys.insert("buildnumber")
                guard let version = metadata["appVersion"], !version.isEmpty else { return nil }
                let build = metadata["buildNumber"]
                let value: String
                if let build, !build.isEmpty, build != "unknown", build != "—" {
                    value = "\(version) (\(build))"
                } else {
                    value = version
                }
                return "\(label(for: key, locale: locale)): \(value)"
            }

            if normalized == "buildnumber" {
                return nil
            }

            guard let value = metadata[key], !value.isEmpty, value != "—" else { return nil }
            consumedKeys.insert(normalized)
            return "\(label(for: key, locale: locale)): \(value)"
        }

        let infoBlock = infoLines.joined(separator: "\n")
        let separator = String(repeating: "=", count: 40)

        return """
        \(infoBlock)

        \(MeerkatLocalizer.text(.promptTypeBelow, locale: locale))
        \(separator)



        """
    }

    private static func label(for key: String, locale: FeedbackLocale) -> String {
        switch key.lowercased() {
        case "appname":
            return MeerkatLocalizer.text(.labelApp, locale: locale)
        case "appversion", "buildnumber":
            return MeerkatLocalizer.text(.labelVersion, locale: locale)
        case "screen", "placement":
            return MeerkatLocalizer.text(.labelScreen, locale: locale)
        case "devicemodel", "devicename":
            return MeerkatLocalizer.text(.labelDevice, locale: locale)
        case "osversion":
            return MeerkatLocalizer.text(.labelOS, locale: locale)
        case "appstoreid":
            return MeerkatLocalizer.text(.labelAppStoreID, locale: locale)
        default:
            return key
        }
    }
}
