import Foundation

enum APIFeedbackDelivery {
    nonisolated(unsafe) static var urlSession: URLSession = .shared

    @MainActor
    static func deliver(
        payload: FeedbackPayload,
        configuration: FeedbackAPIConfiguration,
        identity: FeedbackUserIdentity?,
        screen: String,
        template: FeedbackTemplate
    ) {
        Task {
            let result = await submit(
                payload: payload,
                configuration: configuration,
                identity: identity
            )
            FeedbackEventDispatcher.handleAPIOutcome(
                screen: screen,
                template: template,
                payload: payload,
                outcome: result.outcome,
                error: result.error
            )
            // The server is reachable again, so retry anything queued earlier.
            if result.outcome == .success, configuration.offlineRetryEnabled {
                _ = await FeedbackOfflineQueue.flush()
            }
        }
    }

    @MainActor
    static func submit(
        payload: FeedbackPayload,
        configuration: FeedbackAPIConfiguration,
        identity: FeedbackUserIdentity?
    ) async -> APIFeedbackSubmitResult {
        let model = FeedbackAPIModel.make(
            from: payload,
            identity: identity,
            extraFields: ExtraMetadataStore.resolved()
        )
        guard let body = try? model.encoded() else {
            print("MeerkatKit: Failed to encode API payload.")
            return APIFeedbackSubmitResult(outcome: .failed, error: .encodingFailed)
        }

        do {
            try await post(
                endpoint: configuration.endpoint,
                headers: configuration.headers,
                body: body,
                session: urlSession
            )
            return APIFeedbackSubmitResult(outcome: .success, error: nil)
        } catch let error as APIFeedbackError {
            print("MeerkatKit: API delivery failed — HTTP status \(error.statusCode)")
            let deliveryError = FeedbackDeliveryError.unsuccessfulStatus(error.statusCode)
            // Retrying a request the server rejected for good (bad payload, auth, wrong URL)
            // can never succeed; report it as failed instead of promising a retry.
            if configuration.offlineRetryEnabled, error.isRetryable {
                FeedbackOfflineQueue.enqueue(
                    endpoint: configuration.endpoint,
                    headers: configuration.headers,
                    body: body
                )
                return APIFeedbackSubmitResult(outcome: .queuedOffline, error: deliveryError)
            }
            return APIFeedbackSubmitResult(outcome: .failed, error: deliveryError)
        } catch {
            print("MeerkatKit: API delivery failed — \(error.localizedDescription)")
            let deliveryError = FeedbackDeliveryError.networkFailure(error.localizedDescription)
            if configuration.offlineRetryEnabled {
                FeedbackOfflineQueue.enqueue(
                    endpoint: configuration.endpoint,
                    headers: configuration.headers,
                    body: body
                )
                return APIFeedbackSubmitResult(outcome: .queuedOffline, error: deliveryError)
            }
            return APIFeedbackSubmitResult(outcome: .failed, error: deliveryError)
        }
    }

    static func post(
        endpoint: URL,
        headers: [String: String],
        body: Data,
        session: URLSession
    ) async throws {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw APIFeedbackError.unsuccessfulStatus(code)
        }
    }
}

struct APIFeedbackSubmitResult {
    let outcome: FeedbackAPIOutcome
    let error: FeedbackDeliveryError?
}

enum APIFeedbackError: Error, Equatable {
    case unsuccessfulStatus(Int)

    var statusCode: Int {
        switch self {
        case let .unsuccessfulStatus(code):
            return code
        }
    }

    /// `true` when sending the same request again later may succeed: server errors,
    /// timeouts, and rate limiting. Other statuses are permanent rejections.
    var isRetryable: Bool {
        switch statusCode {
        case 408, 425, 429:
            return true
        case 500 ... 599:
            return true
        default:
            return false
        }
    }
}
