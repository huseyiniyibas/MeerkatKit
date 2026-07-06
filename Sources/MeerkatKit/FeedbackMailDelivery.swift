import Foundation

enum MailPresentationResult: Equatable {
    case composerPresented
    case deliveredImmediately
    case failed
}

enum FeedbackMailDelivery {
    @MainActor
    static func present(
        payload: FeedbackPayload,
        configuration: MeerkatConfiguration,
        screen: String,
        template: FeedbackTemplate
    ) -> MailPresentationResult {
        guard case let .mailComposer(recipients, _, _) = configuration.delivery else { return .failed }

        #if os(iOS)
        return MailFeedbackPresenter.present(
            payload: payload,
            recipients: recipients,
            screen: screen,
            template: template
        )
        #else
        return deliverViaMailtoOrFallback(payload: payload, recipients: recipients)
        #endif
    }

    @MainActor
    private static func deliverViaMailtoOrFallback(
        payload: FeedbackPayload,
        recipients: [String]
    ) -> MailPresentationResult {
        let opened = MailtoFeedbackPresenter.presentIfPossible(
            payload: payload,
            recipients: recipients
        )
        if opened {
            return .deliveredImmediately
        }

        switch MeerkatFeedback.mailUnavailableFallback {
        case .shareSheet:
            ShareFeedbackPresenter.present(payload: payload, recipients: recipients)
            return .deliveredImmediately
        case .none:
            print("MeerkatKit: Mail unavailable and no fallback configured.")
            return .failed
        }
    }
}

#if os(macOS)
import AppKit

enum MailtoFeedbackPresenter {
    @MainActor
    @discardableResult
    static func presentIfPossible(payload: FeedbackPayload, recipients: [String]) -> Bool {
        guard let url = MailtoURLBuilder.makeURL(
            recipients: recipients,
            subject: "[\(payload.placement)] \(payload.subject)",
            body: payload.body
        ) else {
            print("MeerkatKit: Could not build mailto URL.")
            return false
        }
        return NSWorkspace.shared.open(url)
    }
}
#elseif canImport(UIKit)
import UIKit

enum MailtoFeedbackPresenter {
    @MainActor
    @discardableResult
    static func presentIfPossible(payload: FeedbackPayload, recipients: [String]) -> Bool {
        guard let url = MailtoURLBuilder.makeURL(
            recipients: recipients,
            subject: "[\(payload.placement)] \(payload.subject)",
            body: payload.body
        ) else {
            print("MeerkatKit: Could not build mailto URL.")
            return false
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return true
    }
}
#endif

enum MailtoURLBuilder {
    static func makeURL(recipients: [String], subject: String, body: String) -> URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = recipients.joined(separator: ",")
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        return components.url
    }
}
