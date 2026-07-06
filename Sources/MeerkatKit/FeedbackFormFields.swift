import SwiftUI

struct FeedbackFormMessageField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            #if os(tvOS)
            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(5 ... 10)
                .padding(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.quaternary, lineWidth: 1)
                }
            #else
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
            #endif
        }
    }
}

struct FeedbackFormEmailField: View {
    let label: String
    let placeholder: String
    @Binding var email: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField(placeholder, text: $email)
                #if os(iOS) || os(tvOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                #endif
                .padding(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.quaternary, lineWidth: 1)
                }
        }
    }
}

struct FeedbackFormCustomFieldsSection: View {
    let fields: [FeedbackCustomField]
    @Binding var values: [String: String]

    var body: some View {
        ForEach(fields) { field in
            VStack(alignment: .leading, spacing: 8) {
                Text(field.label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                TextField(field.placeholder ?? field.label, text: binding(for: field.id))
                    .padding(8)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.quaternary, lineWidth: 1)
                    }
            }
        }
    }

    private func binding(for id: String) -> Binding<String> {
        Binding(
            get: { values[id, default: ""] },
            set: { values[id] = $0 }
        )
    }
}

struct FeedbackFormCategoryRow: View {
    let template: FeedbackTemplate
    let locale: FeedbackLocale

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: template.systemImage)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(template.rowTitle(for: locale))
                .font(.headline)
        }
        .accessibilityElement(children: .combine)
    }
}

struct FeedbackScreenshotToggle: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Label(label, systemImage: "camera.viewfinder")
        }
    }
}
