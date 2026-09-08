import SwiftUI

struct MeerkatSurveyNegativeFollowUp: View {
    let locale: FeedbackLocale
    let starRating: Int
    let offersFeedback: Bool
    let onSendFeedback: (String) -> Void
    let onSkip: () -> Void

    @State private var message = ""

    var body: some View {
        VStack(spacing: 14) {
            MeerkatSurveyStarDisplay(filled: starRating)

            Text(MeerkatLocalizer.text(.surveyNegativeBody, locale: locale))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if offersFeedback {
                MeerkatSurveyFeedbackEditor(
                    locale: locale,
                    text: $message
                )

                Button {
                    onSendFeedback(message)
                } label: {
                    Text(MeerkatLocalizer.text(.surveySendFeedback, locale: locale))
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .foregroundStyle(MeerkatSurveyPrimaryButton.foreground)
                .background(MeerkatSurveyPrimaryButton.background, in: Capsule())
                .opacity(canSend ? 1 : 0.45)
                .disabled(!canSend)
                .accessibilityIdentifier("meerkat_survey_feedback")

                Button(MeerkatLocalizer.text(.surveySkip, locale: locale), action: onSkip)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("meerkat_survey_skip")
            }
        }
    }

    private var canSend: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private struct MeerkatSurveyStarDisplay: View {
    let filled: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= filled ? "star.fill" : "star")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct MeerkatSurveyFeedbackEditor: View {
    let locale: FeedbackLocale
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(MeerkatLocalizer.text(.surveyFeedbackPlaceholder, locale: locale))
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                    .allowsHitTesting(false)
            }

            #if os(tvOS)
            TextField("", text: $text)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .accessibilityIdentifier("meerkat_survey_feedback_text")
            #else
            TextEditor(text: $text)
                .font(.subheadline)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .accessibilityIdentifier("meerkat_survey_feedback_text")
            #endif
        }
        .frame(minHeight: 88)
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(.separator, lineWidth: 1)
        }
    }
}
