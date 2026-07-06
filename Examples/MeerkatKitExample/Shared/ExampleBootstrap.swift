import MeerkatKit
import SwiftUI

@MainActor
enum ExampleBootstrap {
    static func configure() {
        let billingTemplate = FeedbackCustomTemplate(
            id: "billing",
            title: "Billing issue",
            subject: "Billing issue",
            bodyPrefix: "Describe the billing problem:\n\n",
            systemImage: "creditcard.fill"
        )

        let formConfiguration = FeedbackFormConfiguration(
            collectRating: true,
            collectEmail: true,
            customFields: [
                FeedbackCustomField(
                    id: "appVersionNote",
                    label: "Anything else?",
                    placeholder: "Optional context"
                )
            ]
        )

        let eventHandler = FeedbackEventHandler(
            onSubmitted: { event in
                print("Example: feedback submitted on \(event.screen)")
            },
            onFailed: { event in
                print("Example: feedback failed — queued=\(event.queuedOffline)")
            },
            onCancelled: { event in
                print("Example: feedback cancelled at \(event.stage)")
            }
        )

        #if DEBUG
        MeerkatFeedback.bootstrap(
            api: URL(string: "https://httpbin.org/post")!,
            templates: [.bugReport, .featureRequest, .custom(billingTemplate), .general],
            offerScreenshotInForm: true,
            userIdentity: FeedbackUserIdentity(userId: "demo-user"),
            formConfiguration: formConfiguration,
            eventHandler: eventHandler,
            apiResultPresentation: .banner
        )
        MeerkatFeedback.setLogProvider { "Example log line\nSecond line" }
        #else
        MeerkatFeedback.bootstrap(
            recipients: ["feedback@example.com"],
            templates: [.bugReport, .general],
            offerScreenshotInForm: true,
            formConfiguration: formConfiguration,
            eventHandler: eventHandler
        )
        #endif
    }
}
