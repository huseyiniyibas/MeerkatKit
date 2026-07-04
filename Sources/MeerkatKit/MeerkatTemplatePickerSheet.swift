import SwiftUI

struct MeerkatTemplatePickerSheet: View {
    let screen: String
    let templates: [FeedbackTemplate]
    let locale: FeedbackLocale
    let onSelect: (FeedbackTemplate) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(templates, id: \.self) { template in
                Button {
                    onSelect(template)
                    dismiss()
                } label: {
                    TemplatePickerRow(template: template, locale: locale)
                }
                .accessibilityIdentifier("meerkat_template_\(template.rawValue)")
            }
            .navigationTitle(MeerkatLocalizer.text(.templatePickerTitle, locale: locale))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(MeerkatLocalizer.text(.templatePickerCancel, locale: locale)) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

private struct TemplatePickerRow: View {
    let template: FeedbackTemplate
    let locale: FeedbackLocale

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: template.systemImage)
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 28)
            Text(template.title(for: locale))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
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
