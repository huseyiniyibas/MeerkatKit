import SwiftUI

struct MeerkatSatisfactionSurveySheet: View {
    let locale: FeedbackLocale
    let offersFeedback: Bool
    let onRespond: (SatisfactionResponse, SatisfactionDislikeReason?) -> Void
    let onContinueToFeedback: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var response: SatisfactionResponse?
    @State private var needsDislikeReason = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 24) {
                Text(titleText)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)

                content
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
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
        .animation(.spring(response: 0.42, dampingFraction: 0.84), value: needsDislikeReason)
        #if os(iOS)
        .presentationDetents([.height(MeerkatSurveySheetHeight.value(
            hasResponse: response != nil,
            needsDislikeReason: needsDislikeReason,
            offersFeedback: offersFeedback
        ))])
        .presentationDragIndicator(.visible)
        #endif
    }

    @ViewBuilder
    private var content: some View {
        if needsDislikeReason {
            MeerkatSurveyDislikeReasonChips(locale: locale, onSelect: selectDislikeReason)
        } else if let response {
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
        } else {
            MeerkatSurveyResponseButtons(locale: locale, onRespond: respond)
        }
    }

    private var titleText: String {
        if needsDislikeReason {
            return MeerkatLocalizer.text(.surveyDislikeReasonPrompt, locale: locale)
        }
        let key: MeerkatLocalizedKey = response == nil ? .surveyTitle : .surveyThanks
        return MeerkatLocalizer.text(key, locale: locale)
    }

    private func respond(_ value: SatisfactionResponse) {
        switch value {
        case .like:
            response = value
            onRespond(value, nil)
            autoDismissIfNeeded()
        case .dislike:
            needsDislikeReason = true
        }
    }

    private func selectDislikeReason(_ reason: SatisfactionDislikeReason) {
        needsDislikeReason = false
        response = .dislike
        onRespond(.dislike, reason)
        autoDismissIfNeeded()
    }

    private func autoDismissIfNeeded() {
        guard !offersFeedback else { return }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(1_400))
            dismiss()
        }
    }
}

enum MeerkatSurveySheetHeight {
    static func value(
        hasResponse: Bool,
        needsDislikeReason: Bool,
        offersFeedback: Bool
    ) -> CGFloat {
        let chrome: CGFloat = 20 + 28 + 24 + 48 + 24
        if needsDislikeReason {
            return chrome + 132
        }
        if !hasResponse {
            return chrome + 118
        }
        if !offersFeedback {
            return chrome + 52
        }
        return chrome + 52 + 18 + 46 + 18 + 28
    }
}