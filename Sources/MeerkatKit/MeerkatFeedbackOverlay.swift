import SwiftUI

public struct MeerkatFeedbackOverlayModifier: ViewModifier {
    @StateObject private var controller = MeerkatOverlayController()

    public func body(content: Content) -> some View {
        content
            .overlay(alignment: controller.alignment) {
                if controller.isVisible {
                    StickyFeedbackButton(
                        onTap: { MeerkatFeedback.present() },
                        onDismiss: { MeerkatFeedback.dismissByUser() }
                    )
                    .padding(16)
                }
            }
            .background {
                #if os(iOS)
                if controller.isShakeEnabled {
                    ShakeResponderBridge {
                        MeerkatFeedback.present()
                    }
                }
                #endif
            }
            .onAppear { controller.refresh() }
    }
}

public extension View {
    func meerkatFeedbackOverlay() -> some View {
        modifier(MeerkatFeedbackOverlayModifier())
    }
}

@MainActor
final class MeerkatOverlayController: ObservableObject {
    @Published private(set) var isVisible = false
    @Published private(set) var alignment: Alignment = .bottomTrailing
    @Published private(set) var isShakeEnabled = false

    func refresh() {
        isVisible = MeerkatFeedback.shouldShowStickyButton
        alignment = MeerkatFeedback.stickyButtonPosition().alignment
        isShakeEnabled = MeerkatFeedback.isShakeEnabled
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
                Label("Feedback", systemImage: "binoculars.fill")
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
