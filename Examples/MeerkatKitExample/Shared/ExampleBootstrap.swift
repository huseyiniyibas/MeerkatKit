import MeerkatKit
import SwiftUI

@MainActor
enum ExampleBootstrap {
    static func configure() {
        let crashLogPath = makeDemoCrashLogPath()
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
            crashLogPath: crashLogPath,
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
            crashLogPath: crashLogPath,
            formConfiguration: formConfiguration,
            eventHandler: eventHandler
        )
        #endif
    }

    private static func makeDemoCrashLogPath() -> String? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("meerkat-example-crash.log")
        let content = "Example crash log\nThread: main\n"
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            return url.path
        } catch {
            print("Example: could not write demo crash log — \(error.localizedDescription)")
            return nil
        }
    }
}
