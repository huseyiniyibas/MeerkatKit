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
            VStack(spacing: 12) {
                ForEach(templates) { template in
                    Button {
                        onSelect(template)
                        dismiss()
                    } label: {
                        TemplatePickerRow(template: template, locale: locale)
                    }
                    .buttonStyle(TemplatePickerButtonStyle())
                    .accessibilityIdentifier("meerkat_template_\(template.apiIdentifier)")
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle(MeerkatLocalizer.text(.templatePickerTitle, locale: locale))
            #if os(iOS)
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
        #if os(iOS)
        .presentationDetents([.height(sheetHeight)])
        .presentationDragIndicator(.visible)
        #endif
    }

    #if os(iOS)
    private var sheetHeight: CGFloat {
        let navigationChrome: CGFloat = 64
        let verticalPadding: CGFloat = 36
        let rowHeight: CGFloat = 76
        let rowSpacing: CGFloat = 12
        let rows = CGFloat(max(templates.count, 1))
        return navigationChrome + verticalPadding + (rows * rowHeight) + (max(rows - 1, 0) * rowSpacing)
    }
    #endif
}

private struct TemplatePickerRow: View {
    let template: FeedbackTemplate
    let locale: FeedbackLocale

    var body: some View {
        HStack(spacing: 14) {
            Text(template.emoji)
                .font(.system(size: 30))
                .frame(width: 44, height: 44)
                .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(template.rowTitle(for: locale))
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
    }
}

private struct TemplatePickerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.72), value: configuration.isPressed)
    }
}
