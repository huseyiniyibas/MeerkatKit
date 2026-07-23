import SwiftUI

public struct MeerkatSatisfactionSurveyModifier: ViewModifier {
    let screen: String
    let trigger: SatisfactionSurveyTrigger
    let offersFeedback: Bool
    let onResponse: SatisfactionSurveyResponseAction?

    @StateObject private var controller = MeerkatSurveyScreenController()

    public func body(content: Content) -> some View {
        content
            .onAppear {
                controller.begin(screen: screen, trigger: trigger)
            }
            .onDisappear {
                controller.end()
            }
            .sheet(isPresented: $controller.isPresentingSurvey) {
                MeerkatSatisfactionSurveySheet(
                    locale: MeerkatFeedback.configuredLocale,
                    offersFeedback: offersFeedback,
                    onRespond: handleResponse,
                    onContinueToFeedback: continueToFeedback
                )
            }
    }

    private func handleResponse(_ response: SatisfactionResponse) {
        MeerkatSurveyStore.recordResponse(response, screen: screen)
        MeerkatSurveyAnalytics.logResponse(response, screen: screen)
        onResponse?(SatisfactionSurveyEvent(screen: screen, response: response))
    }

    private func continueToFeedback() {
        MeerkatSurveyAnalytics.noteContinuation(screen: screen)
        let screen = self.screen
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            MeerkatFeedback.requestFeedback(screen: screen)
        }
    }
}

public extension View {
    /// Collects a like/dislike satisfaction rating for `screen` in a modal.
    ///
    /// The modal appears according to `trigger` — on the first view, on every view,
    /// after a number of views, or after the user stays on the screen for a duration.
    /// Once the user responds, the survey never auto-presents again on that screen;
    /// use ``MeerkatFeedback/resetSatisfactionSurvey(forScreen:)`` to start over.
    ///
    /// After a response the like/dislike buttons animate out and — when
    /// `offersFeedback` is `true` — a feedback button appears that continues into
    /// the regular MeerkatKit feedback flow (template picker → form → delivery).
    ///
    /// When the host app has Firebase Analytics installed and configured,
    /// `meerkatkit_like` / `meerkatkit_dislike` events are logged automatically.
    /// Without Firebase the events are skipped safely — never a crash.
    ///
    /// - Parameter screen: Screen name used for persistence, analytics, and the feedback continuation.
    /// - Parameter trigger: When the modal is shown. Defaults to ``SatisfactionSurveyTrigger/firstView``.
    /// - Parameter offersFeedback: Shows the feedback continuation button after a response. Defaults to `true`.
    /// - Parameter onResponse: Code block executed when the user taps like or dislike.
    func meerkatSatisfactionSurvey(
        screen: String,
        trigger: SatisfactionSurveyTrigger = .firstView,
        offersFeedback: Bool = true,
        onResponse: SatisfactionSurveyResponseAction? = nil
    ) -> some View {
        modifier(
            MeerkatSatisfactionSurveyModifier(
                screen: screen,
                trigger: trigger,
                offersFeedback: offersFeedback,
                onResponse: onResponse
            )
        )
    }
}
