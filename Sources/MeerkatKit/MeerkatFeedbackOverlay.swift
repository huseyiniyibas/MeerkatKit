import SwiftUI

public struct MeerkatFeedbackModifier: ViewModifier {
    let screen: String
    let minimumDwell: Duration?
    let revealAfter: Duration?
    let enableShake: Bool

    @StateObject private var visibility = MeerkatFeedbackVisibilityController()
    @State private var isDismissedThisVisit = false

    private var usesShakeTrigger: Bool {
        enableShake || MeerkatFeedback.isShakeEnabled
    }

    private var isVisible: Bool {
        !usesShakeTrigger
            && MeerkatFeedback.canShowStickyButton
            && visibility.isReady
            && !isDismissedThisVisit
    }

    private var alignment: Alignment {
        MeerkatFeedback.stickyButtonPosition().alignment
    }

    public func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                if isVisible {
                    StickyFeedbackButton(
                        onTap: { MeerkatFeedback.present(screen: screen) },
                        onDismiss: { isDismissedThisVisit = true }
                    )
                    .padding(16)
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.easeOut(duration: 0.2), value: isVisible)
            .background {
                #if os(iOS)
                if usesShakeTrigger {
                    ShakeResponderBridge {
                        MeerkatFeedback.present(screen: screen)
                    }
                }
                #endif
            }
            .onAppear {
                isDismissedThisVisit = false
                visibility.begin(
                    screen: screen,
                    minimumDwell: minimumDwell,
                    revealAfter: revealAfter
                )
            }
            .onDisappear {
                visibility.pauseDwell()
            }
    }
}

public extension View {
    /// Floating feedback button for this screen. Requires `MeerkatFeedback.bootstrap(...)` once at launch.
    ///
    /// - Parameters:
    ///   - screen: Screen name included in feedback metadata.
    ///   - minimumDwell: Show after the user **stays on this screen** for at least this long.
    ///     Leaving cancels this timer until they return.
    ///   - revealAfter: Show once this much time has passed since the screen was first shown
    ///     in the app session, even if the user navigates away and comes back.
    ///     When both are set, whichever completes first wins.
    ///   - enableShake: On iOS, shake the device to open feedback on this screen (hides the sticky button here).
    func meerkatFeedback(
        screen: String,
        minimumDwell: Duration? = nil,
        revealAfter: Duration? = nil,
        enableShake: Bool = false
    ) -> some View {
        modifier(
            MeerkatFeedbackModifier(
                screen: screen,
                minimumDwell: minimumDwell,
                revealAfter: revealAfter,
                enableShake: enableShake
            )
        )
    }
}

private struct ShakeResponderBridge: View {
    let onShake: () -> Void

    var body: some View {
        #if os(iOS)
        ShakeResponderView(onShake: onShake)
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
        #else
        EmptyView()
        #endif
    }
}

private extension FeedbackPosition {
    var alignment: Alignment {
        switch self {
        case .topLeading: return .topLeading
        case .topTrailing: return .topTrailing
        case .bottomLeading: return .bottomLeading
        case .bottomTrailing: return .bottomTrailing
        }
    }
}

struct StickyFeedbackButton: View {
    let onTap: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onTap) {
                Label(MeerkatLocalizer.text(.feedbackButton, locale: .current), systemImage: "binoculars.fill")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
            }
            .accessibilityIdentifier("meerkat_feedback_button")

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .padding(10)
            }
            .accessibilityIdentifier("meerkat_feedback_dismiss")
        }
        .foregroundStyle(.white)
        .background(.black.opacity(0.82), in: Capsule())
        .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
    }
}
