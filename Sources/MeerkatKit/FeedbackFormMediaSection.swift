import SwiftUI

struct FeedbackFormMediaSection: View {
    let locale: FeedbackLocale
    let offerScreenshot: Bool
    @Binding var includeScreenshot: Bool
    let offerPhotoLibrary: Bool
    let maxPhotos: Int
    @Binding var photos: [Data]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if offerScreenshot {
                FeedbackScreenshotToggle(
                    label: MeerkatLocalizer.text(.formIncludeScreenshot, locale: locale),
                    isOn: $includeScreenshot
                )
            }
            if offerPhotoLibrary {
                FeedbackPhotoAttachmentsSection(
                    locale: locale,
                    maxCount: maxPhotos,
                    images: $photos
                )
            }
        }
    }
}