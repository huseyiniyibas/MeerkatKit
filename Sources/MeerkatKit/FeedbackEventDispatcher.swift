import Foundation

@MainActor
enum FeedbackEventDispatcher {
    static func submitted(
        screen: String,
        template: FeedbackTemplate,
        payload: FeedbackPayload,
        channel: FeedbackDeliveryChannel
    ) {
        let event = FeedbackSubmissionEvent(
            screen: screen,
            template: template,
            payload: payload,
            channel: channel
        )
        MeerkatFeedback.eventHandler?.onSubmitted?(event)
    }

    static func failed(
        screen: String,
        template: FeedbackTemplate,
        error: FeedbackDeliveryError,
        queuedOffline: Bool
    ) {
        let event = FeedbackFailureEvent(
            screen: screen,
            template: template,
            error: error,
            queuedOffline: queuedOffline
        )
        MeerkatFeedback.eventHandler?.onFailed?(event)
    }

    static func cancelled(screen: String, stage: FeedbackCancellationStage) {
        let event = FeedbackCancellationEvent(screen: screen, stage: stage)
        MeerkatFeedback.eventHandler?.onCancelled?(event)
    }

    static func handleAPIOutcome(
        screen: String,
        template: FeedbackTemplate,
        payload: FeedbackPayload,
        outcome: FeedbackAPIOutcome,
        error: FeedbackDeliveryError?
    ) {
        switch outcome {
        case .success:
            if MeerkatFeedback.apiResultPresentation != .none {
                FeedbackResultPresenter.present(
                    outcome: .success,
                    presentation: MeerkatFeedback.apiResultPresentation,
                    locale: MeerkatFeedback.configuredLocale
                )
            }
            submitted(
                screen: screen,
                template: template,
                payload: payload,
                channel: .api
            )
        case .queuedOffline:
            if MeerkatFeedback.apiResultPresentation != .none {
                FeedbackResultPresenter.present(
                    outcome: .queuedOffline,
                    presentation: MeerkatFeedback.apiResultPresentation,
                    locale: MeerkatFeedback.configuredLocale
                )
            }
            failed(
                screen: screen,
                template: template,
                error: error ?? .networkFailure("Queued for retry"),
                queuedOffline: true
            )
        case .failed:
            if MeerkatFeedback.apiResultPresentation != .none {
                FeedbackResultPresenter.present(
                    outcome: .failed,
                    presentation: MeerkatFeedback.apiResultPresentation,
                    locale: MeerkatFeedback.configuredLocale
                )
            }
            failed(
                screen: screen,
                template: template,
                error: error ?? .networkFailure("Delivery failed"),
                queuedOffline: false
            )
        }
    }
}
