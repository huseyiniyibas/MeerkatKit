import Foundation

struct QueuedFeedbackSubmission: Codable, Equatable {
    let endpoint: URL
    let headers: [String: String]
    let body: Data
    let queuedAt: Date
}

@MainActor
enum FeedbackOfflineQueue {
    private static let storageKey = "meerkatkit.offline_queue"

    static func enqueue(
        endpoint: URL,
        headers: [String: String],
        body: Data
    ) {
        var queue = load()
        queue.append(
            QueuedFeedbackSubmission(
                endpoint: endpoint,
                headers: headers,
                body: body,
                queuedAt: Date()
            )
        )
        save(queue)
    }

    static func flush(using session: URLSession = APIFeedbackDelivery.urlSession) async -> Int {
        let queue = load()
        guard !queue.isEmpty else { return 0 }

        var delivered = 0
        var remaining: [QueuedFeedbackSubmission] = []

        for item in queue {
            do {
                try await APIFeedbackDelivery.post(
                    endpoint: item.endpoint,
                    headers: item.headers,
                    body: item.body,
                    session: session
                )
                delivered += 1
            } catch {
                remaining.append(item)
            }
        }

        save(remaining)
        return delivered
    }

    static func pendingCount() -> Int {
        load().count
    }

    #if DEBUG
    static func resetAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    #endif

    private static func load() -> [QueuedFeedbackSubmission] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return [] }
        return (try? JSONDecoder().decode([QueuedFeedbackSubmission].self, from: data)) ?? []
    }

    private static func save(_ queue: [QueuedFeedbackSubmission]) {
        guard let data = try? JSONEncoder().encode(queue) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
