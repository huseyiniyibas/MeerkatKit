import Foundation

@MainActor
enum FeedbackAttachmentCollector {
    static func collect(
        userInput: FeedbackUserInput?,
        offerScreenshot: Bool,
        logProvider: (() -> String?)?,
        crashLogPath: String?
    ) -> [FeedbackAttachment] {
        var attachments: [FeedbackAttachment] = []

        if offerScreenshot, userInput?.includeScreenshot == true,
           let png = FeedbackScreenshotCapture.capturePNG() {
            attachments.append(
                FeedbackAttachment(filename: "screenshot.png", mimeType: "image/png", data: png)
            )
        }

        if let logAttachment = FeedbackLogAttachment.makeAttachment(
            logProvider: logProvider,
            crashLogPath: crashLogPath
        ) {
            attachments.append(logAttachment)
        }

        return attachments
    }
}
