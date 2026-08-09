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

    /// Collects attachments after optionally hiding MeerkatKit chrome for a clean screenshot.
    ///
    /// Call this after the feedback form / sheets have dismissed. Prefers a pending
    /// screenshot (from a system screenshot) when available.
    static func collectAsync(
        userInput: FeedbackUserInput?,
        offerScreenshot: Bool,
        logProvider: (() -> String?)?,
        crashLogPath: String?,
        sheetDismissDelay: Duration = .milliseconds(400)
    ) async -> [FeedbackAttachment] {
        var attachments: [FeedbackAttachment] = []

        if offerScreenshot, userInput?.includeScreenshot == true {
            let png: Data?
            if let pending = MeerkatFeedbackPendingScreenshot.consumePNG() {
                png = pending
            } else {
                // Hide chrome immediately so the floating button does not flash back
                // while the form sheet finishes dismissing.
                png = await MeerkatFeedbackChromeSuppressor.shared.withSuppressed(
                    settleDelay: sheetDismissDelay
                ) {
                    FeedbackScreenshotCapture.capturePNG()
                }
            }
            if let png {
                attachments.append(
                    FeedbackAttachment(filename: "screenshot.png", mimeType: "image/png", data: png)
                )
            }
        } else {
            MeerkatFeedbackPendingScreenshot.clear()
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
