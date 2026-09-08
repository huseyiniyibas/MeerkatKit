import SwiftUI

struct MeerkatSurveyPositiveFollowUp: View {
    let locale: FeedbackLocale
    let onRateOnAppStore: () -> Void
    let onMaybeLater: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text(MeerkatLocalizer.text(.surveyPositiveBody, locale: locale))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: onRateOnAppStore) {
                Text(MeerkatLocalizer.text(.surveyRateOnAppStore, locale: locale))
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .foregroundStyle(MeerkatSurveyPrimaryButton.foreground)
            .background(MeerkatSurveyPrimaryButton.background, in: Capsule())
            .accessibilityIdentifier("meerkat_survey_rate_app_store")

            Button(MeerkatLocalizer.text(.surveyMaybeLater, locale: locale), action: onMaybeLater)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("meerkat_survey_maybe_later")
        }
    }
}
