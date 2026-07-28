import SwiftUI

struct MeerkatSurveyResponseButtons: View {
    let locale: FeedbackLocale
    let onRespond: (SatisfactionResponse) -> Void

    var body: some View {
        HStack(spacing: 28) {
            MeerkatSurveyResponseButton(
                title: MeerkatLocalizer.text(.surveyLike, locale: locale),
                systemImage: "hand.thumbsup.fill",
                accent: Color(red: 0.18, green: 0.72, blue: 0.45),
                accessibilityID: "meerkat_survey_like",
                action: { onRespond(.like) }
            )
            MeerkatSurveyResponseButton(
                title: MeerkatLocalizer.text(.surveyDislike, locale: locale),
                systemImage: "hand.thumbsdown.fill",
                accent: Color(red: 0.92, green: 0.38, blue: 0.35),
                accessibilityID: "meerkat_survey_dislike",
                action: { onRespond(.dislike) }
            )
        }
    }
}

private struct MeerkatSurveyResponseButton: View {
    let title: String
    let systemImage: String
    let accent: Color
    let accessibilityID: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(accent)
                    .frame(width: 76, height: 76)
                    .background(accent.opacity(0.14), in: Circle())
                    .overlay {
                        Circle()
                            .strokeBorder(accent.opacity(0.28), lineWidth: 1)
                    }

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 110)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(MeerkatSurveyPressButtonStyle())
        .accessibilityIdentifier(accessibilityID)
    }
}

private struct MeerkatSurveyPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
