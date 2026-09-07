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

        attachments.append(contentsOf: photoAttachments(from: userInput))
        appendLog(to: &attachments, logProvider: logProvider, crashLogPath: crashLogPath)
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

        attachments.append(contentsOf: photoAttachments(from: userInput))
        appendLog(to: &attachments, logProvider: logProvider, crashLogPath: crashLogPath)
        return attachments
    }

    static func photoAttachments(from userInput: FeedbackUserInput?) -> [FeedbackAttachment] {
        let images: [Data]
        if let userInput {
            images = userInput.photoAttachments
            MeerkatFeedbackPendingPhotos.clear()
        } else {
            images = MeerkatFeedbackPendingPhotos.consume()
        }
        return images.enumerated().map { index, data in
            FeedbackAttachment(
                filename: "photo-\(index + 1).jpg",
                mimeType: "image/jpeg",
                data: FeedbackPhotoEncoder.jpegData(from: data)
            )
        }
    }

    private static func appendLog(
        to attachments: inout [FeedbackAttachment],
        logProvider: (() -> String?)?,
        crashLogPath: String?
    ) {
        if let logAttachment = FeedbackLogAttachment.makeAttachment(
            logProvider: logProvider,
            crashLogPath: crashLogPath
        ) {
            attachments.append(logAttachment)
        }
    }
}