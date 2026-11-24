import Foundation

struct QueuedFeedbackSubmission: Codable, Equatable {
    let id: UUID
    let endpoint: URL
    let headers: [String: String]
    let body: Data
    let queuedAt: Date

    init(
        id: UUID = UUID(),
        endpoint: URL,
        headers: [String: String],
        body: Data,
        queuedAt: Date = Date()
    ) {
        self.id = id
        self.endpoint = endpoint
        self.headers = headers
        self.body = body
        self.queuedAt = queuedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case endpoint
        case headers
        case body
        case queuedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Entries queued by 0.4.13 and earlier have no identifier.
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        endpoint = try container.decode(URL.self, forKey: .endpoint)
        headers = try container.decode([String: String].self, forKey: .headers)
        body = try container.decode(Data.self, forKey: .body)
        queuedAt = try container.decode(Date.self, forKey: .queuedAt)
    }
}

/// Persists API submissions that failed for a transient reason and retries them later.
///
/// The queue lives in a file rather than `UserDefaults`: bodies carry base64 screenshots
/// and photos, which are far too large for the defaults database (tvOS terminates apps
/// that store more than 1 MB there).
@MainActor
enum FeedbackOfflineQueue {
    /// Oldest entries are dropped once the queue grows past this size.
    static let maxPendingSubmissions = 50

    private static let legacyDefaultsKey = "meerkatkit.offline_queue"
    private static var isFlushing = false

    static func enqueue(
        endpoint: URL,
        headers: [String: String],
        body: Data
    ) {
        var queue = load()
        queue.append(
            QueuedFeedbackSubmission(endpoint: endpoint, headers: headers, body: body)
        )
        if queue.count > maxPendingSubmissions {
            queue.removeFirst(queue.count - maxPendingSubmissions)
        }
        save(queue)
    }

    /// Retries every queued submission and returns how many were delivered.
    ///
    /// Submissions the server rejects for good (see ``APIFeedbackError/isRetryable``) are
    /// dropped; everything else stays queued for the next flush.
    static func flush(using session: URLSession = APIFeedbackDelivery.urlSession) async -> Int {
        // A second flush while requests are in flight would post the same entries twice.
        guard !isFlushing else { return 0 }
        isFlushing = true
        defer { isFlushing = false }

        let snapshot = load()
        guard !snapshot.isEmpty else { return 0 }

        var delivered = 0
        var remaining: [QueuedFeedbackSubmission] = []

        for item in snapshot {
            do {
                try await APIFeedbackDelivery.post(
                    endpoint: item.endpoint,
                    headers: item.headers,
                    body: item.body,
                    session: session
                )
                delivered += 1
            } catch let error as APIFeedbackError where !error.isRetryable {
                print("MeerkatKit: Dropping queued feedback — server answered \(error.statusCode).")
            } catch {
                remaining.append(item)
            }
        }

        // Keep whatever was enqueued while the requests above were in flight.
        let snapshotIDs = Set(snapshot.map(\.id))
        let enqueuedMeanwhile = load().filter { !snapshotIDs.contains($0.id) }
        save(remaining + enqueuedMeanwhile)
        return delivered
    }

    static func pendingCount() -> Int {
        load().count
    }

    #if DEBUG
    static func resetAll() {
        UserDefaults.standard.removeObject(forKey: legacyDefaultsKey)
        if let storageURL {
            try? FileManager.default.removeItem(at: storageURL)
        }
    }
    #endif

    private static var storageURL: URL? {
        #if os(tvOS)
        // tvOS offers no persistent Application Support storage.
        let directory = FileManager.SearchPathDirectory.cachesDirectory
        #else
        let directory = FileManager.SearchPathDirectory.applicationSupportDirectory
        #endif
        guard let base = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return nil
        }
        // Unsandboxed macOS apps share Application Support, so namespace by bundle.
        let namespace = Bundle.main.bundleIdentifier ?? ProcessInfo.processInfo.processName
        return base
            .appendingPathComponent("MeerkatKit", isDirectory: true)
            .appendingPathComponent(namespace, isDirectory: true)
            .appendingPathComponent("offline_queue.json", isDirectory: false)
    }

    private static func load() -> [QueuedFeedbackSubmission] {
        if let storageURL, let data = try? Data(contentsOf: storageURL) {
            return decode(data)
        }
        // Queue written by 0.4.13 and earlier, or kept there because the file was unwritable.
        guard let data = UserDefaults.standard.data(forKey: legacyDefaultsKey) else { return [] }
        let queue = decode(data)
        // Legacy entries get their identifier while decoding. Persist them right away so the
        // identifiers stay stable; `flush` relies on them to tell old entries from new ones.
        save(queue)
        return queue
    }

    private static func decode(_ data: Data) -> [QueuedFeedbackSubmission] {
        (try? JSONDecoder().decode([QueuedFeedbackSubmission].self, from: data)) ?? []
    }

    private static func save(_ queue: [QueuedFeedbackSubmission]) {
        guard !queue.isEmpty else {
            if let storageURL {
                try? FileManager.default.removeItem(at: storageURL)
            }
            UserDefaults.standard.removeObject(forKey: legacyDefaultsKey)
            return
        }
        guard let data = try? JSONEncoder().encode(queue) else { return }

        if let storageURL, write(data, to: storageURL) {
            UserDefaults.standard.removeObject(forKey: legacyDefaultsKey)
        } else {
            // Never lose a submission because the file could not be written. Remove any
            // older file so `load()` does not prefer its outdated contents.
            if let storageURL {
                try? FileManager.default.removeItem(at: storageURL)
            }
            UserDefaults.standard.set(data, forKey: legacyDefaultsKey)
        }
    }

    private static func write(_ data: Data, to url: URL) -> Bool {
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: url, options: .atomic)
            return true
        } catch {
            print("MeerkatKit: Could not persist offline queue — \(error.localizedDescription)")
            return false
        }
    }
}
