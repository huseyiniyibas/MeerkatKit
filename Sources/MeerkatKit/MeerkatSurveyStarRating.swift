import SwiftUI

struct MeerkatSurveyStarRating: View {
    let locale: FeedbackLocale
    let onSelect: (Int) -> Void
    let onNotNow: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Text(MeerkatLocalizer.text(.surveySubtitle, locale: locale))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        onSelect(star)
                    } label: {
                        Image(systemName: "star")
                            .font(.system(size: 32, weight: .regular))
                            .foregroundStyle(.primary)
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("meerkat_survey_star_\(star)")
                    .accessibilityLabel(String(star))
                }
            }

            Button(MeerkatLocalizer.text(.surveyNotNow, locale: locale), action: onNotNow)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("meerkat_survey_not_now")
        }
    }
}
