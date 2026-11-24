import SwiftUI

public struct MeerkatSatisfactionSurveyModifier: ViewModifier {
    let screen: String
    let trigger: SatisfactionSurveyTrigger
    let offersFeedback: Bool
    let onResponse: SatisfactionSurveyResponseAction?

    @StateObject private var controller = MeerkatSurveyScreenController()
    @State private var pendingAction: MeerkatSurveyDismissAction = .none

    public func body(content: Content) -> some View {
        content
            .onAppear {
                controller.begin(screen: screen, trigger: trigger)
            }
            .onDisappear {
                controller.end()
            }
            .sheet(
                isPresented: $controller.isPresentingSurvey,
                onDismiss: handleSurveyDismissed
            ) {
                MeerkatSatisfactionSurveySheet(
                    locale: MeerkatFeedback.configuredLocale,
                    offersFeedback: offersFeedback,
                    onRespond: handleResponse,
                    onContinueToAppStore: { pendingAction = .appStore },
                    onContinueToFeedback: { stars, message in
                        pendingAction = .feedback(stars: stars, message: message)
                    }
                )
            }
    }

    private func handleResponse(_ response: SatisfactionResponse, _ starRating: Int) {
        MeerkatSurveyStore.recordResponse(response, screen: screen, starRating: starRating)
        MeerkatSurveyAnalytics.logResponse(
            response,
            screen: screen,
            starRating: starRating
        )
        onResponse?(
            SatisfactionSurveyEvent(
                screen: screen,
                response: response,
                starRating: starRating
            )
        )
    }

    private func handleSurveyDismissed() {
        let action = pendingAction
        pendingAction = .none
        let screen = self.screen
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(100))
            switch action {
            case .none:
                break
            case .appStore:
                MeerkatAppStoreReview.request()
            case let .feedback(stars, message):
                // The survey submits straight to delivery (no template picker), so commit the
                // continuation here. Leaving it pending would attribute the next unrelated
                // feedback flow on this screen to the survey.
                MeerkatSurveyAnalytics.noteContinuation(screen: screen)
                MeerkatSurveyAnalytics.templateCommitted(screen: screen, template: .general)
                MeerkatFeedback.submitFeedback(
                    screen: screen,
                    template: .general,
                    userInput: FeedbackUserInput(
                        message: message.trimmingCharacters(in: .whitespacesAndNewlines),
                        rating: stars
                    )
                )
            }
        }
    }
}

private enum MeerkatSurveyDismissAction {
    case none
    case appStore
    case feedback(stars: Int, message: String)
}

public extension View {
    /// Collects a 1–5 star satisfaction rating for `screen` in a modal.
    ///
    /// The modal appears according to `trigger` — on the first view, on every view,
    /// after a number of views, every *n*-th view, or after the user stays on the
    /// screen for a duration.
    ///
    /// 4–5 stars continue to the App Store write-review page (or the native review
    /// prompt when no App Store ID is configured). 1–3 stars collect private
    /// feedback and submit it through the regular MeerkatKit delivery path.
    ///
    /// For most triggers, once the user responds the survey never auto-presents
    /// again on that screen; use ``MeerkatFeedback/resetSatisfactionSurvey(forScreen:)``
    /// to start over. ``SatisfactionSurveyTrigger/everyNthView(_:)`` keeps sampling
    /// on each *n*-th visit even after a previous response.
    ///
    /// When the host app has Firebase Analytics installed and configured,
    /// `meerkatkit_like` / `meerkatkit_dislike` events are logged automatically
    /// with a `star_rating` parameter. Without Firebase the events are skipped
    /// safely — never a crash.
    ///
    /// - Parameter screen: Screen name used for persistence, analytics, and the feedback continuation.
    /// - Parameter trigger: When the modal is shown. Defaults to ``SatisfactionSurveyTrigger/firstView``.
    /// - Parameter offersFeedback: Shows the private-feedback field after a 1–3 star rating. Defaults to `true`.
    /// - Parameter onResponse: Code block executed when the user taps a star.
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
