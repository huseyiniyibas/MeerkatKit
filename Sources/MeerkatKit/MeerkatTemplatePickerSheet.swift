import SwiftUI

struct MeerkatTemplatePickerSheet: View {
    let screen: String
    let templates: [FeedbackTemplate]
    let locale: FeedbackLocale
    let onSelect: (FeedbackTemplate) -> Void
    let onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(templates) { template in
                Button {
                    onSelect(template)
                    dismiss()
                } label: {
                    TemplatePickerRow(template: template, locale: locale)
                }
                .accessibilityIdentifier("meerkat_template_\(template.apiIdentifier)")
            }
            .navigationTitle(MeerkatLocalizer.text(.templatePickerTitle, locale: locale))
            #if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(MeerkatLocalizer.text(.templatePickerCancel, locale: locale)) {
                        onCancel()
                        dismiss()
                    }
                }
            }
        }
        #if os(iOS) || os(visionOS)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        #endif
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
            Text(template.rowTitle(for: locale))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }
}
