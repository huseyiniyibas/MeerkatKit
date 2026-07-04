import SwiftUI

struct MeerkatFeedbackFloatingOverlay<CustomFloating: View>: View {
    let isVisible: Bool
    let alignment: Alignment
    let customFloatingButton: ((@escaping MeerkatFeedbackRequestAction, @escaping MeerkatFeedbackDismissAction) -> CustomFloating)?
    let onRequest: MeerkatFeedbackRequestAction
    let onDismiss: MeerkatFeedbackDismissAction

    var body: some View {
        Group {
            if isVisible {
                if let customFloatingButton {
                    customFloatingButton(onRequest, onDismiss)
                        .padding(16)
                } else {
                    StickyFeedbackButton(onTap: onRequest, onDismiss: onDismiss)
                        .padding(16)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        .transition(.opacity.combined(with: .scale))
        .animation(.easeOut(duration: 0.2), value: isVisible)
    }
}
