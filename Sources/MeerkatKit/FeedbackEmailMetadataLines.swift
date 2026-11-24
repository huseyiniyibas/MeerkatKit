import Foundation

enum FeedbackEmailMetadataLines {
    static func render(
        keys: [String],
        metadata: [String: String],
        locale: FeedbackLocale,
        extraLabels: [String: String],
        consumedKeys: inout Set<String>
    ) -> String {
        keys.compactMap { key -> String? in
            line(
                for: key,
                metadata: metadata,
                locale: locale,
                extraLabels: extraLabels,
                consumedKeys: &consumedKeys
            )
        }
        .joined(separator: "\n")
    }

    private static func line(
        for key: String,
        metadata: [String: String],
        locale: FeedbackLocale,
        extraLabels: [String: String],
        consumedKeys: inout Set<String>
    ) -> String? {
        // `placement` is an alias of `screen`: both render the same "Screen" line.
        let normalized = key.lowercased() == "placement" ? "screen" : key.lowercased()
        if consumedKeys.contains(normalized) {
            return nil
        }

        if normalized == "appversion" {
            consumedKeys.insert("appversion")
            consumedKeys.insert("buildnumber")
            guard let version = value(for: "appversion", in: metadata), !version.isEmpty else {
                return nil
            }
            let build = value(for: "buildnumber", in: metadata)
            let value: String
            if let build, !build.isEmpty, build != "unknown", build != "—" {
                value = "\(version) (\(build))"
            } else {
                value = version
            }
            return "\(label(for: key, locale: locale, extraLabels: extraLabels)): \(value)"
        }

        if normalized == "buildnumber" {
            return nil
        }

        let resolvedValue = metadata[key] ?? metadata.first { $0.key.lowercased() == normalized }?.value
        guard let value = resolvedValue, !value.isEmpty, value != "—" else { return nil }
        consumedKeys.insert(normalized)
        return "\(label(for: key, locale: locale, extraLabels: extraLabels)): \(value)"
    }

    /// Case-insensitive lookup, so `headerMetadata: ["appversion"]` still finds its value.
    private static func value(for normalizedKey: String, in metadata: [String: String]) -> String? {
        metadata.first { $0.key.lowercased() == normalizedKey }?.value
    }

    private static func label(
        for key: String,
        locale: FeedbackLocale,
        extraLabels: [String: String]
    ) -> String {
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
        case "userid":
            return MeerkatLocalizer.text(.labelUserID, locale: locale)
        case "email":
            return MeerkatLocalizer.text(.labelEmail, locale: locale)
        default:
            return extraLabel(for: key, extraLabels: extraLabels) ?? key
        }
    }

    private static func extraLabel(for key: String, extraLabels: [String: String]) -> String? {
        if let custom = extraLabels[key]?.trimmingCharacters(in: .whitespacesAndNewlines),
           !custom.isEmpty {
            return custom
        }
        if let custom = extraLabels.first(where: { $0.key.lowercased() == key.lowercased() })?.value
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !custom.isEmpty {
            return custom
        }
        return nil
    }
}
