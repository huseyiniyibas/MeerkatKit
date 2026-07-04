import SwiftUI

struct FeedbackStarRatingRow: View {
    let label: String
    @Binding var rating: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(1 ... 5, id: \.self) { value in
                    FeedbackStarButton(
                        isFilled: (rating ?? 0) >= value,
                        accessibilityLabel: "\(value)"
                    ) {
                        rating = value == rating ? nil : value
                    }
                }
            }
            .accessibilityElement(children: .contain)
        }
    }
}

private struct FeedbackStarButton: View {
    let isFilled: Bool
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isFilled ? "star.fill" : "star")
                .font(.title2)
                .foregroundStyle(isFilled ? .yellow : .secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}
