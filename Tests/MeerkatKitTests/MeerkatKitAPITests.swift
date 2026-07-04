import XCTest
@testable import MeerkatKit

final class MeerkatKitAPITests: XCTestCase {
    @MainActor
    private func resetState() {
        #if DEBUG
        FeedbackOfflineQueue.resetAll()
        MetadataCollector.resetUserIdentity()
        #endif
        APIFeedbackDelivery.urlSession = .shared
    }

    @MainActor
    func testAPIModelEncoding() throws {
        resetState()
        let payload = FeedbackPayload(
            placement: "Home",
            template: .bugReport,
            subject: "Bug Report",
            body: "details",
            metadata: ["screen": "Home"],
            userInput: FeedbackUserInput(message: "Crash", rating: 1, includeScreenshot: false),
            attachments: [
                FeedbackAttachment(filename: "log.txt", mimeType: "text/plain", data: Data("log".utf8))
            ]
        )
        let identity = FeedbackUserIdentity(userId: "u1", email: "a@b.com")
        let model = FeedbackAPIModel.make(from: payload, identity: identity)
        let data = try model.encoded()
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        XCTAssertEqual(json?["placement"] as? String, "Home")
        XCTAssertEqual(json?["template"] as? String, "bugReport")
        let userIdentity = json?["userIdentity"] as? [String: String]
        XCTAssertEqual(userIdentity?["userId"], "u1")
        let attachments = json?["attachments"] as? [[String: String]]
        XCTAssertEqual(attachments?.count, 1)
    }

    @MainActor
    func testAnonymousIdentityOmittedFromAPIModel() throws {
        resetState()
        let payload = FeedbackPayload(
            placement: "Home",
            template: .general,
            subject: "Feedback",
            body: "body",
            metadata: [:]
        )
        let model = FeedbackAPIModel.make(from: payload, identity: .anonymous)
        let data = try model.encoded()
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertNil(json?["userIdentity"])
    }

    @MainActor
    func testUserIdentityInMetadata() {
        resetState()
        #if DEBUG
        MetadataCollector.resetUserIdentity()
        #endif
        MetadataCollector.setUserIdentity(FeedbackUserIdentity(userId: "42", email: "user@test.com"))
        let metadata = MetadataCollector.collect(headerKeys: ["userId", "email"], footerKeys: [], placement: "Settings")
        XCTAssertEqual(metadata["userId"], "42")
        XCTAssertEqual(metadata["email"], "user@test.com")
    }

    @MainActor
    func testAnonymousIdentityExcludedFromMetadata() {
        resetState()
        MetadataCollector.setUserIdentity(.anonymous)
        let metadata = MetadataCollector.collect(headerKeys: ["userId", "email"], footerKeys: [], placement: "Settings")
        XCTAssertNil(metadata["userId"])
        XCTAssertNil(metadata["email"])
    }

    @MainActor
    func testOfflineQueueEnqueueAndFlush() async throws {
        resetState()
        #if DEBUG
        FeedbackOfflineQueue.resetAll()
        #endif

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        APIFeedbackDelivery.urlSession = session

        MockURLProtocol.handler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let endpoint = URL(string: "https://api.example.com/feedback")!
        FeedbackOfflineQueue.enqueue(endpoint: endpoint, headers: [:], body: Data("{\"ok\":true}".utf8))
        XCTAssertEqual(FeedbackOfflineQueue.pendingCount(), 1)

        let delivered = await FeedbackOfflineQueue.flush(using: session)
        XCTAssertEqual(delivered, 1)
        XCTAssertEqual(FeedbackOfflineQueue.pendingCount(), 0)
    }

    @MainActor
    func testOfflineQueueKeepsFailedItems() async {
        resetState()
        #if DEBUG
        FeedbackOfflineQueue.resetAll()
        #endif

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        APIFeedbackDelivery.urlSession = session

        MockURLProtocol.handler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let endpoint = URL(string: "https://api.example.com/feedback")!
        FeedbackOfflineQueue.enqueue(endpoint: endpoint, headers: [:], body: Data("{}".utf8))

        let delivered = await FeedbackOfflineQueue.flush(using: session)
        XCTAssertEqual(delivered, 0)
        XCTAssertEqual(FeedbackOfflineQueue.pendingCount(), 1)
    }

    @MainActor
    func testLogAttachmentFromProvider() {
        resetState()
        let attachment = FeedbackLogAttachment.makeAttachment(
            logProvider: { "line1\nline2" },
            crashLogPath: nil
        )
        XCTAssertEqual(attachment?.filename, "logs.txt")
        XCTAssertEqual(String(data: attachment?.data ?? Data(), encoding: .utf8), "line1\nline2")
    }

    @MainActor
    func testCrashLogAttachmentFromPath() throws {
        resetState()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("meerkat-crash-test.log")
        try "crash info".write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }

        let attachment = FeedbackLogAttachment.makeAttachment(logProvider: nil, crashLogPath: url.path)
        XCTAssertEqual(String(data: attachment?.data ?? Data(), encoding: .utf8), "crash info")
    }
}

private final class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var handler: ((URLRequest) -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        let (response, data) = handler(request)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
