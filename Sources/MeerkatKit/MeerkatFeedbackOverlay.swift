import SwiftUI

public struct MeerkatFeedbackModifier<CustomFloating: View>: ViewModifier {
    let screen: String
    let mailRecipients: [String]?
    let minimumDwell: Duration?
    let revealAfter: Duration?
    let enableShake: Bool
    let dismissCooldown: Duration?
    let presentation: MeerkatFeedbackPresentation
    let customFloatingButton: (
        (@escaping MeerkatFeedbackRequestAction, @escaping MeerkatFeedbackDismissAction) -> CustomFloating
    )?

    @StateObject private var session: MeerkatFeedbackScreenSession
    @StateObject private var visibility = MeerkatFeedbackVisibilityController()
    @State private var isDismissedThisVisit = false

    init(
        screen: String,
        mailRecipients: [String]?,
        minimumDwell: Duration?,
        revealAfter: Duration?,
        enableShake: Bool,
        dismissCooldown: Duration?,
        presentation: MeerkatFeedbackPresentation,
        customFloatingButton: (
            (@escaping MeerkatFeedbackRequestAction, @escaping MeerkatFeedbackDismissAction) -> CustomFloating
        )?
    ) {
        self.screen = screen
        self.mailRecipients = mailRecipients
        self.minimumDwell = minimumDwell
        self.revealAfter = revealAfter
        self.enableShake = enableShake
        self.dismissCooldown = dismissCooldown
        self.presentation = presentation
        self.customFloatingButton = customFloatingButton
        _session = StateObject(wrappedValue: MeerkatFeedbackScreenSession(screen: screen))
    }

    public func body(content: Content) -> some View {
        content
            .environment(
                \.meerkatFeedbackRequest,
                MeerkatFeedbackRequest(action: session.requestFeedback)
            )
            .overlay {
                if presentation == .floating {
                    MeerkatFeedbackFloatingOverlay(
                        isVisible: isFloatingVisible,
                        alignment: MeerkatFeedback.stickyButtonPosition().alignment,
                        customFloatingButton: customFloatingButton,
                        onRequest: session.requestFeedback,
                        onDismiss: dismissFloatingButton
                    )
                }
            }
            .background {
                #if os(iOS)
                if usesShakeTrigger {
                    ShakeResponderBridge(onShake: session.requestFeedback)
                }
                #endif
            }
            .sheet(isPresented: $session.showTemplatePicker) {
                MeerkatTemplatePickerSheet(
                    screen: screen,
                    templates: MeerkatFeedback.configuredTemplates,
                    locale: MeerkatFeedback.configuredLocale,
                    onSelect: { template in
                        session.beginFeedbackForm(template: template)
                    }
                )
            }
            .sheet(isPresented: $session.showFeedbackForm) {
                if let template = session.pendingTemplate {
                    MeerkatFeedbackFormSheet(
                        template: template,
                        locale: MeerkatFeedback.configuredLocale,
                        offerScreenshot: MeerkatFeedback.shouldOfferScreenshotInForm,
                        onSubmit: session.submitForm
                    )
                }
            }
            .onAppear {
                isDismissedThisVisit = false
                MeerkatFeedbackRecipientRegistry.register(screen: screen, recipients: mailRecipients)
                MeerkatFeedbackSessionRegistry.register(session)
                visibility.begin(
                    screen: screen,
                    minimumDwell: minimumDwell,
                    revealAfter: revealAfter
                )
            }
            .onDisappear {
                MeerkatFeedbackSessionRegistry.unregister(screen: screen)
                MeerkatFeedbackRecipientRegistry.unregister(screen: screen)
                visibility.pauseDwell()
            }
    }

    private var resolvedDismissCooldown: Duration {
        MeerkatFeedback.effectiveDismissCooldown(override: dismissCooldown)
    }

    private var usesShakeTrigger: Bool {
        enableShake || MeerkatFeedback.isShakeEnabled
    }

    private var isSuppressedByDismiss: Bool {
        isDismissedThisVisit
            || MeerkatDismissCooldown.isActive(screen: screen, cooldown: resolvedDismissCooldown)
    }

    private var isFloatingVisible: Bool {
        presentation == .floating
            && !usesShakeTrigger
            && MeerkatFeedback.canShowStickyButton
            && visibility.isReady
            && !isSuppressedByDismiss
    }

    private func dismissFloatingButton() {
        isDismissedThisVisit = true
        MeerkatDismissCooldown.recordDismiss(
            screen: screen,
            cooldown: resolvedDismissCooldown
        )
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
