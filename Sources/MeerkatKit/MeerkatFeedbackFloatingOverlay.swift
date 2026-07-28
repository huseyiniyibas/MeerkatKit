import SwiftUI

struct MeerkatFeedbackFloatingOverlay<CustomFloating: View>: View {
    let isVisible: Bool
    let customFloatingButton: ((@escaping MeerkatFeedbackRequestAction, @escaping MeerkatFeedbackDismissAction) -> CustomFloating)?
    let onRequest: MeerkatFeedbackRequestAction
    let onDismiss: MeerkatFeedbackDismissAction

    @State private var storedPosition: MeerkatFloatingButtonPosition
    @State private var dragTranslation: CGSize = .zero
    @State private var buttonSize = CGSize(width: 160, height: 44)

    init(
        isVisible: Bool,
        customFloatingButton: ((@escaping MeerkatFeedbackRequestAction, @escaping MeerkatFeedbackDismissAction) -> CustomFloating)?,
        onRequest: @escaping MeerkatFeedbackRequestAction,
        onDismiss: @escaping MeerkatFeedbackDismissAction
    ) {
        self.isVisible = isVisible
        self.customFloatingButton = customFloatingButton
        self.onRequest = onRequest
        self.onDismiss = onDismiss
        _storedPosition = State(
            initialValue: MeerkatFloatingButtonPositionStore.load(
                default: MeerkatFeedback.stickyButtonPosition()
            )
        )
    }

    var body: some View {
        GeometryReader { geometry in
            if isVisible {
                floatingContent
                    .background(buttonSizeReader)
                    .position(center(in: geometry.size))
                    .simultaneousGesture(dragGesture(containerSize: geometry.size))
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeOut(duration: 0.2), value: isVisible)
        .onPreferenceChange(FloatingButtonSizeKey.self) { buttonSize = $0 }
    }

    @ViewBuilder
    private var floatingContent: some View {
        if let customFloatingButton {
            customFloatingButton(onRequest, onDismiss)
        } else {
            StickyFeedbackButton(
                locale: MeerkatFeedback.configuredLocale,
                onTap: onRequest,
                onDismiss: onDismiss
            )
        }
    }

    private var buttonSizeReader: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: FloatingButtonSizeKey.self, value: proxy.size)
        }
    }

    private func center(in containerSize: CGSize) -> CGPoint {
        let snapped = MeerkatFloatingButtonPositionStore.point(
            for: storedPosition,
            containerSize: containerSize,
            buttonSize: buttonSize
        )
        return CGPoint(
            x: snapped.x + dragTranslation.width,
            y: snapped.y + dragTranslation.height
        )
    }

    private func dragGesture(containerSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .local)
            .onChanged { value in
                dragTranslation = value.translation
            }
            .onEnded { value in
                let base = MeerkatFloatingButtonPositionStore.point(
                    for: storedPosition,
                    containerSize: containerSize,
                    buttonSize: buttonSize
                )
                let freeCenter = CGPoint(
                    x: base.x + value.translation.width,
                    y: base.y + value.translation.height
                )
                let snapped = MeerkatFloatingButtonPositionStore.snap(
                    freeCenter: freeCenter,
                    containerSize: containerSize,
                    buttonSize: buttonSize
                )
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    storedPosition = snapped
                    dragTranslation = .zero
                }
                MeerkatFloatingButtonPositionStore.save(snapped)
            }
    }
}

private struct FloatingButtonSizeKey: PreferenceKey {
    static let defaultValue = CGSize(width: 160, height: 44)

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
