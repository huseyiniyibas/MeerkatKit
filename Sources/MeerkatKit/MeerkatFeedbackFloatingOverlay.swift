import SwiftUI

struct MeerkatFeedbackFloatingOverlay<CustomFloating: View>: View {
    let isVisible: Bool
    let customFloatingButton: ((@escaping MeerkatFeedbackRequestAction, @escaping MeerkatFeedbackDismissAction) -> CustomFloating)?
    let onRequest: MeerkatFeedbackRequestAction
    let onDismiss: MeerkatFeedbackDismissAction

    @State private var storedPosition: MeerkatFloatingButtonPosition
    @State private var dragTranslation: CGSize = .zero
    @State private var buttonSize = CGSize(width: 160, height: 44)
    #if !os(tvOS)
    @State private var suppressTap = false
    @State private var isSnapping = false
    #endif

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
            let insets = layoutInsets(from: geometry)
            ZStack {
                if isVisible {
                    positionedButton(containerSize: geometry.size, insets: insets)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // Tab / navigation transitions inherit animations that yank `.position` off-screen.
        .transaction { transaction in
            #if !os(tvOS)
            if !isSnapping {
                transaction.animation = nil
            }
            #else
            transaction.animation = nil
            #endif
        }
        .animation(.easeOut(duration: 0.18), value: isVisible)
        .onPreferenceChange(FloatingButtonSizeKey.self) { size in
            var transaction = Transaction()
            transaction.animation = nil
            withTransaction(transaction) {
                buttonSize = size
            }
        }
        .allowsHitTesting(isVisible)
        .zIndex(1_000)
    }

    @ViewBuilder
    private func positionedButton(
        containerSize: CGSize,
        insets: MeerkatFloatingLayoutInsets
    ) -> some View {
        let content = floatingContent
            .background(buttonSizeReader)
            .position(center(in: containerSize, insets: insets))
            .transition(.opacity)

        #if os(tvOS)
        content
        #else
        content.simultaneousGesture(dragGesture(containerSize: containerSize, insets: insets))
        #endif
    }

    @ViewBuilder
    private var floatingContent: some View {
        if let customFloatingButton {
            #if os(tvOS)
            customFloatingButton(onRequest, onDismiss)
            #else
            customFloatingButton(requestIfAllowed, dismissIfAllowed)
            #endif
        } else {
            StickyFeedbackButton(
                locale: MeerkatFeedback.configuredLocale,
                onTap: {
                    #if os(tvOS)
                    onRequest()
                    #else
                    requestIfAllowed()
                    #endif
                },
                onDismiss: {
                    #if os(tvOS)
                    onDismiss()
                    #else
                    dismissIfAllowed()
                    #endif
                }
            )
        }
    }

    private var buttonSizeReader: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: FloatingButtonSizeKey.self, value: proxy.size)
        }
    }

    private func layoutInsets(from geometry: GeometryProxy) -> MeerkatFloatingLayoutInsets {
        MeerkatFloatingLayoutInsets(
            top: geometry.safeAreaInsets.top,
            leading: geometry.safeAreaInsets.leading,
            bottom: geometry.safeAreaInsets.bottom,
            trailing: geometry.safeAreaInsets.trailing
        )
    }

    private func center(in containerSize: CGSize, insets: MeerkatFloatingLayoutInsets) -> CGPoint {
        let snapped = MeerkatFloatingButtonPositionStore.point(
            for: storedPosition,
            containerSize: containerSize,
            buttonSize: buttonSize,
            safeAreaInsets: insets
        )
        return CGPoint(
            x: snapped.x + dragTranslation.width,
            y: snapped.y + dragTranslation.height
        )
    }

    #if !os(tvOS)
    private func dragGesture(
        containerSize: CGSize,
        insets: MeerkatFloatingLayoutInsets
    ) -> some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .global)
            .onChanged { value in
                suppressTap = true
                dragTranslation = value.translation
            }
            .onEnded { value in
                let base = MeerkatFloatingButtonPositionStore.point(
                    for: storedPosition,
                    containerSize: containerSize,
                    buttonSize: buttonSize,
                    safeAreaInsets: insets
                )
                let freeCenter = CGPoint(
                    x: base.x + value.translation.width,
                    y: base.y + value.translation.height
                )
                let snapped = MeerkatFloatingButtonPositionStore.snap(
                    freeCenter: freeCenter,
                    containerSize: containerSize,
                    buttonSize: buttonSize,
                    safeAreaInsets: insets
                )
                isSnapping = true
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    storedPosition = snapped
                    dragTranslation = .zero
                }
                MeerkatFloatingButtonPositionStore.save(snapped)
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(320))
                    isSnapping = false
                    suppressTap = false
                }
            }
    }

    private func requestIfAllowed() {
        guard !suppressTap else { return }
        onRequest()
    }

    private func dismissIfAllowed() {
        guard !suppressTap else { return }
        onDismiss()
    }
    #endif
}

private struct FloatingButtonSizeKey: PreferenceKey {
    static let defaultValue = CGSize(width: 160, height: 44)

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
