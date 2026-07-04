import Foundation

enum FeedbackMailDelivery {
    @MainActor
    static func present(payload: FeedbackPayload, configuration: MeerkatConfiguration) {
        guard case let .mailComposer(recipients, _, _) = configuration.delivery else { return }

        #if os(iOS)
        MailFeedbackPresenter.present(payload: payload, recipients: recipients)
        #elseif os(macOS)
        deliverViaMailtoOrFallback(payload: payload, recipients: recipients)
        #elseif os(tvOS)
        deliverViaMailtoOrFallback(payload: payload, recipients: recipients)
        #endif
    }

    @MainActor
    private static func deliverViaMailtoOrFallback(
        payload: FeedbackPayload,
        recipients: [String]
    ) {
        let opened = MailtoFeedbackPresenter.presentIfPossible(
            payload: payload,
            recipients: recipients
        )
        if !opened {
            switch MeerkatFeedback.mailUnavailableFallback {
            case .shareSheet:
                ShareFeedbackPresenter.present(payload: payload, recipients: recipients)
            case .none:
                print("MeerkatKit: Mail unavailable and no fallback configured.")
            }
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
