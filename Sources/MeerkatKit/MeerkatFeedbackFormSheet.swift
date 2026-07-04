import SwiftUI

struct MeerkatFeedbackFormSheet: View {
    let template: FeedbackTemplate
    let locale: FeedbackLocale
    let offerScreenshot: Bool
    let onSubmit: (FeedbackUserInput) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var message = ""
    @State private var rating: Int?
    @State private var includeScreenshot = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    FeedbackFormCategoryRow(template: template, locale: locale)
                    FeedbackStarRatingRow(
                        label: MeerkatLocalizer.text(.formRatingLabel, locale: locale),
                        rating: $rating
                    )
                    FeedbackFormMessageField(
                        placeholder: MeerkatLocalizer.text(.formMessagePlaceholder, locale: locale),
                        text: $message
                    )
                    if offerScreenshot {
                        FeedbackScreenshotToggle(
                            label: MeerkatLocalizer.text(.formIncludeScreenshot, locale: locale),
                            isOn: $includeScreenshot
                        )
                    }
                }
                .padding()
            }
            .navigationTitle(MeerkatLocalizer.text(.formTitle, locale: locale))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(MeerkatLocalizer.text(.formCancel, locale: locale)) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(MeerkatLocalizer.text(.formSubmit, locale: locale)) {
                        submit()
                    }
                    .disabled(!canSubmit)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var canSubmit: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func submit() {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        onSubmit(
            FeedbackUserInput(
                message: trimmed,
                rating: rating,
                includeScreenshot: includeScreenshot
            )
        )
        dismiss()
    }
}

private struct FeedbackFormCategoryRow: View {
    let template: FeedbackTemplate
    let locale: FeedbackLocale

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: template.systemImage)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(template.title(for: locale))
                .font(.headline)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct FeedbackScreenshotToggle: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Label(label, systemImage: "camera.viewfinder")
        }
    }
}

private struct FeedbackFormMessageField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextEditor(text: $text)
                .frame(minHeight: 120)
                .padding(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.quaternary, lineWidth: 1)
                }
                .overlay(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
}

private extension FeedbackTemplate {
    var systemImage: String {
        switch self {
        case .bugReport: return "ladybug.fill"
        case .featureRequest: return "lightbulb.fill"
        case .general: return "text.bubble.fill"
        }
    }
}
