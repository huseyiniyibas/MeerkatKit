import SwiftUI

struct MeerkatSatisfactionSurveySheet: View {
    let locale: FeedbackLocale
    let offersFeedback: Bool
    let onRespond: (SatisfactionResponse) -> Void
    let onContinueToFeedback: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var response: SatisfactionResponse?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 28) {
                Text(titleText)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                if let response {
                    MeerkatSurveyFollowUpContent(
                        response: response,
                        locale: locale,
                        offersFeedback: offersFeedback,
                        onSendFeedback: {
                            onContinueToFeedback()
                            dismiss()
                        },
                        onClose: { dismiss() }
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    MeerkatSurveyResponseButtons(locale: locale, onRespond: respond)
                        .transition(.scale(scale: 0.7).combined(with: .opacity))
                }
            }
            .padding(28)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(16)
            .accessibilityIdentifier("meerkat_survey_close")
        }
        .animation(.spring(duration: 0.45), value: response)
        #if os(iOS)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        #endif
    }

    private var titleText: String {
        let key: MeerkatLocalizedKey = response == nil ? .surveyTitle : .surveyThanks
        return MeerkatLocalizer.text(key, locale: locale)
    }

    private func respond(_ value: SatisfactionResponse) {
        response = value
        onRespond(value)
        guard !offersFeedback else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(1_400))
            dismiss()
        }
    }
}

private struct MeerkatSurveyResponseButtons: View {
    let locale: FeedbackLocale
    let onRespond: (SatisfactionResponse) -> Void

    var body: some View {
        HStack(spacing: 24) {
            MeerkatSurveyResponseButton(
                title: MeerkatLocalizer.text(.surveyLike, locale: locale),
                systemImage: "hand.thumbsup.fill",
                tint: .green,
                accessibilityID: "meerkat_survey_like",
                action: { onRespond(.like) }
            )
            MeerkatSurveyResponseButton(
                title: MeerkatLocalizer.text(.surveyDislike, locale: locale),
                systemImage: "hand.thumbsdown.fill",
                tint: .red,
                accessibilityID: "meerkat_survey_dislike",
                action: { onRespond(.dislike) }
            )
        }
    }
}

private struct MeerkatSurveyResponseButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let accessibilityID: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 34))
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .frame(minWidth: 96)
            .padding(.vertical, 18)
            .padding(.horizontal, 14)
        }
        .buttonStyle(.bordered)
        .tint(tint)
        .accessibilityIdentifier(accessibilityID)
    }
}

private struct MeerkatSurveyFollowUpContent: View {
    let response: SatisfactionResponse
    let locale: FeedbackLocale
    let offersFeedback: Bool
    let onSendFeedback: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 44))
                .foregroundStyle(response == .like ? Color.green : Color.orange)
            if offersFeedback {
                Button(action: onSendFeedback) {
                    Label(
                        MeerkatLocalizer.text(.surveySendFeedback, locale: locale),
                        systemImage: "envelope.fill"
                    )
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("meerkat_survey_feedback")

                Button(MeerkatLocalizer.text(.surveyNotNow, locale: locale), action: onClose)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("meerkat_survey_not_now")
            }
        }
    }

    private var iconName: String {
        switch response {
        case .like: return "hand.thumbsup.fill"
        case .dislike: return "hand.thumbsdown.fill"
        }
    }
}
