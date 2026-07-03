import SwiftUI

struct StickyFeedbackButton: View {
    let onTap: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onTap) {
                Label(MeerkatLocalizer.text(.feedbackButton, locale: .current), systemImage: "binoculars.fill")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
            }
            .accessibilityIdentifier("meerkat_feedback_button")

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .padding(10)
            }
            .accessibilityIdentifier("meerkat_feedback_dismiss")
        }
        .foregroundStyle(.white)
        .background(.black.opacity(0.82), in: Capsule())
        .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
    }
}
