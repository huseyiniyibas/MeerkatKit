import SwiftUI

public struct MeerkatFeedbackModifier<CustomFloating: View>: ViewModifier {
    private let context: MeerkatFeedbackModifierContext<CustomFloating>

    @StateObject private var session: MeerkatFeedbackScreenSession
    @StateObject private var visibility = MeerkatFeedbackVisibilityController()
    @State private var isDismissedThisVisit = false
    @State private var appearanceTracker = MeerkatFeedbackAppearanceTracker()

    init(
        screen: String,
        mailRecipients: [String]?,
        apiEndpoint: URL?,
        minimumDwell: Duration?,
        revealAfter: Duration?,
        enableShake: Bool,
        dismissCooldown: Duration?,
        presentation: MeerkatFeedbackPresentation,
        customFloatingButton: (
            (@escaping MeerkatFeedbackRequestAction, @escaping MeerkatFeedbackDismissAction) -> CustomFloating
        )?
    ) {
        context = MeerkatFeedbackModifierContext(
            screen: screen,
            mailRecipients: mailRecipients,
            apiEndpoint: apiEndpoint,
            minimumDwell: minimumDwell,
            revealAfter: revealAfter,
            enableShake: enableShake,
            dismissCooldown: dismissCooldown,
            presentation: presentation,
            customFloatingButton: customFloatingButton
        )
        _session = StateObject(wrappedValue: MeerkatFeedbackScreenSession(screen: screen))
    }

    public func body(content: Content) -> some View {
        content
            .environment(
                \.meerkatFeedbackRequest,
                MeerkatFeedbackRequest(action: session.requestFeedback)
            )
            .overlay { floatingOverlay }
            .background { shakeBackground }
            .sheet(isPresented: $session.showTemplatePicker) { templatePickerSheet }
            .sheet(isPresented: $session.showFeedbackForm) { feedbackFormSheet }
            .onAppear(perform: handleAppear)
            .onChange(of: isFloatingVisible) { _, isVisible in
                appearanceTracker.handleVisibilityChange(
                    isVisible: isVisible,
                    screen: context.screen
                )
            }
            .onDisappear(perform: handleDisappear)
    }

    private var isFloatingVisible: Bool {
        context.isFloatingVisible(
            isReady: visibility.isReady,
            isDismissedThisVisit: isDismissedThisVisit
        )
    }

    @ViewBuilder
    private var floatingOverlay: some View {
        if context.presentation == .floating {
            MeerkatFeedbackFloatingOverlay(
                isVisible: isFloatingVisible,
                alignment: MeerkatFeedback.stickyButtonPosition().alignment,
                customFloatingButton: context.customFloatingButton,
                onRequest: session.requestFeedback,
                onDismiss: dismissFloatingButton
            )
        }
        FeedbackResultBannerOverlay()
    }

    @ViewBuilder
    private var shakeBackground: some View {
        #if os(iOS)
        if context.usesShakeTrigger {
            ShakeResponderBridge(onShake: session.requestFeedback)
        }
        #endif
    }

    private var templatePickerSheet: some View {
        MeerkatTemplatePickerSheet(
            screen: context.screen,
            templates: MeerkatFeedback.configuredTemplates,
            locale: MeerkatFeedback.configuredLocale,
            onSelect: { template in
                session.beginFeedbackForm(template: template)
            },
            onCancel: {
                FeedbackEventDispatcher.cancelled(screen: context.screen, stage: .templatePicker)
            }
        )
    }

    @ViewBuilder
    private var feedbackFormSheet: some View {
        if let template = session.pendingTemplate {
            MeerkatFeedbackFormSheet(
                template: template,
                locale: MeerkatFeedback.configuredLocale,
                formConfiguration: MeerkatFeedback.formConfiguration,
                offerScreenshot: MeerkatFeedback.shouldOfferScreenshotInForm,
                onSubmit: session.submitForm,
                onCancel: {
                    FeedbackEventDispatcher.cancelled(screen: context.screen, stage: .form)
                }
            )
        }
    }

    private func handleAppear() {
        isDismissedThisVisit = false
        appearanceTracker.reset()
        MeerkatFeedbackScreenRegistration.register(
            screen: context.screen,
            presentation: context.presentation,
            enableShake: context.enableShake,
            mailRecipients: context.mailRecipients,
            apiEndpoint: context.apiEndpoint,
            session: session
        )
        visibility.begin(
            screen: context.screen,
            minimumDwell: context.minimumDwell,
            revealAfter: context.revealAfter
        )
        appearanceTracker.reportIfNeeded(isVisible: isFloatingVisible, screen: context.screen)
    }

    private func handleDisappear() {
        MeerkatFeedbackScreenRegistration.unregister(screen: context.screen)
        visibility.pauseDwell()
    }

    private func dismissFloatingButton() {
        isDismissedThisVisit = true
        context.recordDismiss()
    }
}
