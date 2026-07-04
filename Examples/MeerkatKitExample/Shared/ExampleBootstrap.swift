import MeerkatKit
import SwiftUI

@MainActor
enum ExampleBootstrap {
    static func configure() {
        #if DEBUG
        MeerkatFeedback.bootstrap(
            api: URL(string: "https://httpbin.org/post")!,
            templates: [.bugReport, .featureRequest, .general],
            offerScreenshotInForm: true,
            crashLogPath: nil,
            userIdentity: FeedbackUserIdentity(userId: "demo-user", email: "demo@example.com")
        )
        MeerkatFeedback.setLogProvider { "Example log line\nSecond line" }
        #else
        MeerkatFeedback.bootstrap(
            recipients: ["feedback@example.com"],
            templates: [.bugReport, .general],
            offerScreenshotInForm: true
        )
        #endif
    }
}
