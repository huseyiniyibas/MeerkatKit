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
            VStack(spacing: 32) {
                Text(titleText)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)

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
                        .transition(.scale(scale: 0.88).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 36)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)
                    .background(.fill.tertiary, in: Circle())
            }
            .buttonStyle(.plain)
            .padding(16)
            .accessibilityIdentifier("meerkat_survey_close")
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.84), value: response)
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

struct MeerkatSurveyFollowUpContent: View {
    let response: SatisfactionResponse
    let locale: FeedbackLocale
    let offersFeedback: Bool
    let onSendFeedback: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: iconName)
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 88, height: 88)
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
