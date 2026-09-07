import SwiftUI

struct MeerkatScreenshotAnnotationToolbar: View {
    let locale: FeedbackLocale
    @Binding var tool: MeerkatAnnotationTool
    let onClear: () -> Void
    let onCancel: () -> Void
    let onDone: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(MeerkatLocalizer.text(.formCancel, locale: locale), action: onCancel)
            Spacer()
            toolButton(.pen, systemImage: "pencil", titleKey: .annotationPen)
            toolButton(.circle, systemImage: "circle", titleKey: .annotationCircle)
            toolButton(.arrow, systemImage: "arrow.up.right", titleKey: .annotationArrow)
            Button(MeerkatLocalizer.text(.annotationClear, locale: locale), action: onClear)
            Button(MeerkatLocalizer.text(.annotationDone, locale: locale), action: onDone)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func toolButton(
        _ candidate: MeerkatAnnotationTool,
        systemImage: String,
        titleKey: MeerkatLocalizedKey
    ) -> some View {
        Button {
            tool = candidate
        } label: {
            Label(MeerkatLocalizer.text(titleKey, locale: locale), systemImage: systemImage)
                .labelStyle(.iconOnly)
                .foregroundStyle(tool == candidate ? Color.accentColor : Color.primary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(MeerkatLocalizer.text(titleKey, locale: locale))
    }
}