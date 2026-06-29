import Foundation

enum FeedbackMailDelivery {
    @MainActor
    static func present(payload: FeedbackPayload, configuration: MeerkatConfiguration) {
        guard case let .mailComposer(recipients, _, _) = configuration.delivery else { return }

        #if os(iOS)
        MailFeedbackPresenter.present(payload: payload, recipients: recipients)
        #elseif os(macOS)
        MailtoFeedbackPresenter.present(payload: payload, recipients: recipients)
        #elseif os(tvOS)
        MailtoFeedbackPresenter.present(payload: payload, recipients: recipients)
        #endif
    }
}

#if os(macOS)
import AppKit

enum MailtoFeedbackPresenter {
    @MainActor
    static func present(payload: FeedbackPayload, recipients: [String]) {
        guard let url = MailtoURLBuilder.makeURL(
            recipients: recipients,
            subject: "[\(payload.placement)] \(payload.subject)",
            body: payload.body
        ) else {
            print("MeerkatKit: Could not build mailto URL.")
            return
        }
        NSWorkspace.shared.open(url)
    }
}
#elseif canImport(UIKit)
import UIKit

enum MailtoFeedbackPresenter {
    @MainActor
    static func present(payload: FeedbackPayload, recipients: [String]) {
        guard let url = MailtoURLBuilder.makeURL(
            recipients: recipients,
            subject: "[\(payload.placement)] \(payload.subject)",
            body: payload.body
        ) else {
            print("MeerkatKit: Could not build mailto URL.")
            return
        }
        UIApplication.shared.open(url)
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
