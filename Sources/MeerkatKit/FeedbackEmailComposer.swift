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
        orderedKeys: [String],
        template: FeedbackTemplate,
        userInput: FeedbackUserInput?,
        extraLabels: [String: String] = [:],
        footerKeys: [String] = []
    ) -> String {
        var consumedKeys = Set<String>()
        let infoBlock = FeedbackEmailMetadataLines.render(
            keys: orderedKeys,
            metadata: metadata,
            locale: locale,
            extraLabels: extraLabels,
            consumedKeys: &consumedKeys
        )
        let separator = String(repeating: "=", count: 40)
        var sections: [String] = []
        if !infoBlock.isEmpty {
            sections.append(infoBlock)
        }

        appendUserInputSections(
            to: &sections,
            userInput: userInput,
            template: template,
            locale: locale,
            separator: separator,
            consumedKeys: &consumedKeys
        )

        let footerBlock = FeedbackEmailMetadataLines.render(
            keys: footerKeys,
            metadata: metadata,
            locale: locale,
            extraLabels: extraLabels,
            consumedKeys: &consumedKeys
        )
        if !footerBlock.isEmpty {
            sections.append(footerBlock)
        }

        return sections.joined(separator: "\n\n") + "\n"
    }

    private static func appendUserInputSections(
        to sections: inout [String],
        userInput: FeedbackUserInput?,
        template: FeedbackTemplate,
        locale: FeedbackLocale,
        separator: String,
        consumedKeys: inout Set<String>
    ) {
        guard let userInput else {
            sections.append(MeerkatLocalizer.text(.promptTypeBelow, locale: locale))
            sections.append(separator)
            sections.append("")
            sections.append("")
            return
        }
        if let rating = userInput.rating {
            sections.append(
                "\(MeerkatLocalizer.text(.labelRating, locale: locale)): \(rating)/5"
            )
        }
        if let email = userInput.email, !email.isEmpty, !consumedKeys.contains("email") {
            sections.append("\(MeerkatLocalizer.text(.labelEmail, locale: locale)): \(email)")
            consumedKeys.insert("email")
        }
        for (key, value) in userInput.customFields.sorted(by: { $0.key < $1.key }) where !value.isEmpty {
            sections.append("\(key): \(value)")
        }
        let prefix = template.bodyPrefix(for: locale)
        sections.append("\(prefix)\(userInput.message)")
    }
}
