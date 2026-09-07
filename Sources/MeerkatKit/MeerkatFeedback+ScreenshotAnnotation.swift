import Foundation

extension MeerkatFeedback {
    @MainActor
    static func annotateScreenshotIfNeeded(
        _ attachments: [FeedbackAttachment]
    ) async -> [FeedbackAttachment] {
        guard effectiveOfferScreenshotAnnotation,
              let index = attachments.firstIndex(where: { $0.filename == "screenshot.png" }) else {
            return attachments
        }
        let original = attachments[index].data
        let annotated = await MeerkatScreenshotAnnotationPresenter.present(
            png: original,
            locale: configuredLocale
        )
        var next = attachments
        next[index] = FeedbackAttachment(
            filename: "screenshot.png",
            mimeType: "image/png",
            data: annotated
        )
        return next
    }
}