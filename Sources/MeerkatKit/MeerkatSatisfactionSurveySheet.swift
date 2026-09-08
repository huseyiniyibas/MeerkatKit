import SwiftUI

struct MeerkatSatisfactionSurveySheet: View {
    let locale: FeedbackLocale
    let offersFeedback: Bool
    let onRespond: (SatisfactionResponse, Int) -> Void
    let onContinueToAppStore: () -> Void
    let onContinueToFeedback: (Int, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var phase: MeerkatSurveyPhase = .rating

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 20) {
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
        .animation(.spring(response: 0.42, dampingFraction: 0.84), value: phase)
        #if os(iOS)
        .presentationDetents([.height(MeerkatSurveySheetHeight.value(phase: phase, offersFeedback: offersFeedback))])
        .presentationDragIndicator(.visible)
        #endif
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .rating:
            MeerkatSurveyStarRating(
                locale: locale,
                onSelect: selectStars,
                onNotNow: { dismiss() }
            )
        case let .positive(stars):
            MeerkatSurveyPositiveFollowUp(
                locale: locale,
                onRateOnAppStore: {
                    _ = stars
                    onContinueToAppStore()
                    dismiss()
                },
                onMaybeLater: { dismiss() }
            )
        case let .negative(stars):
            MeerkatSurveyNegativeFollowUp(
                locale: locale,
                starRating: stars,
                offersFeedback: offersFeedback,
                onSendFeedback: { message in
                    onContinueToFeedback(stars, message)
                    dismiss()
                },
                onSkip: { dismiss() }
            )
        }
    }

    private var titleText: String {
        switch phase {
        case .rating:
            return MeerkatLocalizer.format(
                .surveyTitle,
                locale: locale,
                MetadataCollector.resolvedAppName
            )
        case .positive:
            return MeerkatLocalizer.text(.surveyPositiveTitle, locale: locale)
        case .negative:
            return MeerkatLocalizer.text(.surveyNegativeTitle, locale: locale)
        }
    }

    private func selectStars(_ stars: Int) {
        let response = SatisfactionResponse.from(starRating: stars)
        onRespond(response, stars)
        if response.isPositive {
            phase = .positive(stars: stars)
        } else {
            phase = .negative(stars: stars)
            if !offersFeedback {
                autoDismiss()
            }
        }
    }

    private func autoDismiss() {
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(1_400))
            dismiss()
        }
    }
}

enum MeerkatSurveyPhase: Equatable {
    case rating
    case positive(stars: Int)
    case negative(stars: Int)
}

enum MeerkatSurveySheetHeight {
    static func value(phase: MeerkatSurveyPhase, offersFeedback: Bool) -> CGFloat {
        switch phase {
        case .rating:
            return 320
        case .positive:
            return 300
        case .negative:
            return offersFeedback ? 460 : 260
        }
    }
}
