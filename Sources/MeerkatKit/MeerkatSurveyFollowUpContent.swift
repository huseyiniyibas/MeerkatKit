import SwiftUI

struct MeerkatSurveyFollowUpContent: View {
    let response: SatisfactionResponse
    let locale: FeedbackLocale
    let offersFeedback: Bool
    let onSendFeedback: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: iconName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 52, height: 52)
                .background(accent.opacity(0.14), in: Circle())

            if offersFeedback {
                Button(action: onSendFeedback) {
                    Label(
                        MeerkatLocalizer.text(.surveySendFeedback, locale: locale),
                        systemImage: "envelope.fill"
                    )
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(accent)
                .accessibilityIdentifier("meerkat_survey_feedback")

                Button(MeerkatLocalizer.text(.surveyNotNow, locale: locale), action: onClose)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("meerkat_survey_not_now")
            }
        }
    }

    private var accent: Color {
        switch response {
        case .like: return Color(red: 0.18, green: 0.72, blue: 0.45)
        case .dislike: return Color(red: 0.92, green: 0.38, blue: 0.35)
        }
    }

    private var iconName: String {
        switch response {
        case .like: return "hand.thumbsup.fill"
        case .dislike: return "hand.thumbsdown.fill"
        }
    }
}