import SwiftUI

struct MeerkatFeedbackSheets: ViewModifier {
    let screen: String
    @Binding var showTemplatePicker: Bool

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showTemplatePicker) {
                MeerkatTemplatePickerSheet(
                    screen: screen,
                    templates: MeerkatFeedback.configuredTemplates,
                    locale: MeerkatFeedback.configuredLocale,
                    onSelect: { template in
                        MeerkatFeedback.present(screen: screen, template: template)
                    }
                )
            }
    }
}
