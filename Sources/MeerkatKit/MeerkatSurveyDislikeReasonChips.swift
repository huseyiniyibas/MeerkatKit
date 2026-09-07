import SwiftUI

struct MeerkatSurveyDislikeReasonChips: View {
    let locale: FeedbackLocale
    let onSelect: (SatisfactionDislikeReason) -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(MeerkatLocalizer.text(.surveyDislikeReasonPrompt, locale: locale))
                .font(.subheadline.weight(.medium))
                .multilineTextAlignment(.center)

            let reasons = SatisfactionDislikeReason.allCases
            FlexibleReasonWrap(reasons: reasons) { reason in
                Button {
                    onSelect(reason)
                } label: {
                    Text(reason.localizedTitle(locale: locale))
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.fill.tertiary, in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("meerkat_survey_reason_\(reason.rawValue)")
            }
        }
    }
}

struct FlexibleReasonWrap<Item: Identifiable, Content: View>: View {
    let reasons: [Item]
    let content: (Item) -> Content

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(reasons.chunked(into: 2).enumerated()), id: \.offset) { _, row in
                HStack(spacing: 8) {
                    ForEach(row) { item in
                        content(item)
                    }
                }
            }
        }
    }
}

extension SatisfactionDislikeReason: Identifiable {
    public var id: String { rawValue }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}