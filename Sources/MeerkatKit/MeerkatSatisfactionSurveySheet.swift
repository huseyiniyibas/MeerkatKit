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
            VStack(spacing: 24) {
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
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

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
        .presentationDetents([.height(sheetHeight)])
        .presentationDragIndicator(.visible)
        #endif
    }

    #if os(iOS)
    private var sheetHeight: CGFloat {
        let dragChrome: CGFloat = 20
        let topPadding: CGFloat = 28
        let bottomPadding: CGFloat = 24
        let titleBlock: CGFloat = 48
        let sectionSpacing: CGFloat = 24

        if response == nil {
            let responseButtons: CGFloat = 118
            return dragChrome + topPadding + titleBlock + sectionSpacing + responseButtons + bottomPadding
        }

        let icon: CGFloat = 52
        guard offersFeedback else {
            return dragChrome + topPadding + titleBlock + sectionSpacing + icon + bottomPadding
        }

        let followUpSpacing: CGFloat = 18
        let sendFeedbackButton: CGFloat = 46
        let notNowButton: CGFloat = 28
        return dragChrome
            + topPadding
            + titleBlock
            + sectionSpacing
            + icon
            + followUpSpacing
            + sendFeedbackButton
            + followUpSpacing
            + notNowButton
            + bottomPadding
    }
    #endif

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
