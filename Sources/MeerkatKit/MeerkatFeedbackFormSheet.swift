import SwiftUI

struct MeerkatFeedbackFormSheet: View {
    let template: FeedbackTemplate
    let locale: FeedbackLocale
    let formConfiguration: FeedbackFormConfiguration
    let offerScreenshot: Bool
    let onSubmit: (FeedbackUserInput) -> Void
    let onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var message = ""
    @State private var rating: Int?
    @State private var email = ""
    @State private var customFieldValues: [String: String] = [:]
    @State private var includeScreenshot = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    FeedbackFormCategoryRow(template: template, locale: locale)
                    if formConfiguration.collectRating {
                        FeedbackStarRatingRow(
                            label: MeerkatLocalizer.text(.formRatingLabel, locale: locale),
                            rating: $rating
                        )
                    }
                    FeedbackFormMessageField(
                        placeholder: MeerkatLocalizer.text(.formMessagePlaceholder, locale: locale),
                        text: $message
                    )
                    if formConfiguration.collectEmail {
                        FeedbackFormEmailField(
                            label: MeerkatLocalizer.text(.labelEmail, locale: locale),
                            placeholder: MeerkatLocalizer.text(.formEmailPlaceholder, locale: locale),
                            email: $email
                        )
                    }
                    if !formConfiguration.customFields.isEmpty {
                        FeedbackFormCustomFieldsSection(
                            fields: formConfiguration.customFields,
                            values: $customFieldValues
                        )
                    }
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
                        onCancel()
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
        #if os(iOS)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        #endif
    }

    private var canSubmit: Bool {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return false }

        if formConfiguration.collectEmail {
            let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedEmail.isEmpty else { return false }
        }

        for field in formConfiguration.customFields where field.isRequired {
            let value = customFieldValues[field.id, default: ""]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !value.isEmpty else { return false }
        }

        return true
    }

    private func submit() {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedCustomFields = customFieldValues.mapValues {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        onSubmit(
            FeedbackUserInput(
                message: trimmedMessage,
                rating: formConfiguration.collectRating ? rating : nil,
                email: formConfiguration.collectEmail ? trimmedEmail : nil,
                customFields: normalizedCustomFields,
                includeScreenshot: includeScreenshot
            )
        )
        dismiss()
    }
}
