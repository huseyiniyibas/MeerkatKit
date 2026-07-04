import Foundation

enum APIFeedbackDelivery {
    nonisolated(unsafe) static var urlSession: URLSession = .shared

    @MainActor
    static func deliver(
        payload: FeedbackPayload,
        configuration: FeedbackAPIConfiguration,
        identity: FeedbackUserIdentity?
    ) {
        Task {
            await submit(payload: payload, configuration: configuration, identity: identity)
        }
    }

    @MainActor
    static func submit(
        payload: FeedbackPayload,
        configuration: FeedbackAPIConfiguration,
        identity: FeedbackUserIdentity?
    ) async {
        let model = FeedbackAPIModel.make(from: payload, identity: identity)
        guard let body = try? model.encoded() else {
            print("MeerkatKit: Failed to encode API payload.")
            return
        }

        do {
            try await post(
                endpoint: configuration.endpoint,
                headers: configuration.headers,
                body: body,
                session: urlSession
            )
        } catch {
            print("MeerkatKit: API delivery failed — \(error.localizedDescription)")
            if configuration.offlineRetryEnabled {
                FeedbackOfflineQueue.enqueue(
                    endpoint: configuration.endpoint,
                    headers: configuration.headers,
                    body: body
                )
            }
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

enum APIFeedbackError: Error, Equatable {
    case unsuccessfulStatus(Int)
}
