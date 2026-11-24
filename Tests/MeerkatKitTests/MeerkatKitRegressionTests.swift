import XCTest
@testable import MeerkatKit

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Regression coverage for bugs found by code review: metadata, attachments, shake, offline queue.
final class MeerkatKitRegressionTests: XCTestCase {
    private let endpoint = URL(string: "https://api.example.com/feedback")!

    @MainActor
    private func resetState() {
        #if DEBUG
        FeedbackOfflineQueue.resetAll()
        MetadataCollector.resetUserIdentity()
        ExtraMetadataStore.resetAll()
        MeerkatFeedbackPendingScreenshot.resetAll()
        MeerkatFeedbackPendingPhotos.resetAll()
        MeerkatFeedbackShakeRegistry.resetAll()
        #endif
        MetadataCollector.setAppStoreID(nil)
        RegressionURLProtocol.reset()
    }

    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [RegressionURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    private func makePayload() -> FeedbackPayload {
        FeedbackPayload(
            placement: "Home",
            template: .general,
            subject: "Feedback",
            body: "body",
            metadata: [:]
        )
    }

    // MARK: - Metadata

    @MainActor
    func testScreenHeaderKeyKeepsPlacementValue() {
        resetState()
        let metadata = MetadataCollector.collect(
            headerKeys: ["appName", "screen", "placement"],
            footerKeys: [],
            placement: "Settings"
        )
        XCTAssertEqual(metadata["screen"], "Settings")
        XCTAssertEqual(metadata["placement"], "Settings")
    }

    @MainActor
    func testMailBodyKeepsScreenLineWhenListedInHeaderMetadata() {
        resetState()
        let configuration = MeerkatConfiguration(
            delivery: .mailComposer(recipients: ["a@b.com"], headerMetadata: ["appName", "screen"]),
            locale: .english
        )
        let payload = FeedbackPayloadBuilder.build(
            configuration: configuration,
            placementOverride: "Settings",
            templateOverride: .general
        )
        XCTAssertTrue(payload.body.contains("Screen: Settings"), payload.body)
    }

    @MainActor
    func testPlacementAliasRendersSingleScreenLine() {
        resetState()
        let configuration = MeerkatConfiguration(
            delivery: .mailComposer(
                recipients: ["a@b.com"],
                headerMetadata: ["appName", "osVersion", "deviceModel", "appversion", "placement"]
            ),
            locale: .english
        )
        let payload = FeedbackPayloadBuilder.build(
            configuration: configuration,
            placementOverride: "Checkout",
            templateOverride: .general
        )
        let lines = payload.body.components(separatedBy: "\n")
        XCTAssertEqual(lines.filter { $0 == "Screen: Checkout" }.count, 1, payload.body)
        XCTAssertEqual(lines.firstIndex(of: "Screen: Checkout"), 4, "Screen stays where it was listed")
        XCTAssertTrue(payload.body.contains("Version: "), "Lower-case appversion key still resolves")
    }

    @MainActor
    func testScreenInFooterMetadataRendersAfterMessage() throws {
        resetState()
        let configuration = MeerkatConfiguration(
            delivery: .mailComposer(
                recipients: ["a@b.com"],
                headerMetadata: ["appName"],
                footerMetadata: ["screen"]
            ),
            locale: .english
        )
        let payload = FeedbackPayloadBuilder.build(
            configuration: configuration,
            placementOverride: "Checkout",
            templateOverride: .general,
            userInput: FeedbackUserInput(message: "Hello")
        )
        let body = payload.body
        let message = try XCTUnwrap(body.range(of: "Hello"))
        let screen = try XCTUnwrap(body.range(of: "Screen: Checkout"))
        XCTAssertTrue(message.lowerBound < screen.lowerBound, body)
        XCTAssertEqual(body.components(separatedBy: "Screen: Checkout").count, 2, body)
    }

    // MARK: - Attachments

    @MainActor
    func testSyncCollectDropsPendingScreenshotWhenNotIncluded() {
        resetState()
        MeerkatFeedbackPendingScreenshot.store(Data([0xAA]))

        let attachments = FeedbackAttachmentCollector.collect(
            userInput: FeedbackUserInput(message: "Hi", includeScreenshot: false),
            offerScreenshot: true,
            logProvider: nil,
            crashLogPath: nil
        )

        XCTAssertTrue(attachments.isEmpty)
        XCTAssertFalse(MeerkatFeedbackPendingScreenshot.shouldPreferInclude)
        XCTAssertNil(MeerkatFeedbackPendingScreenshot.consumePNG())
    }

    func testEmptyLogProviderFallsBackToCrashLog() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("meerkat-regression-\(UUID().uuidString).log")
        try "crash info".write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }

        let attachment = FeedbackLogAttachment.makeAttachment(
            logProvider: { "" },
            crashLogPath: url.path
        )
        XCTAssertEqual(attachment?.data, Data("crash info".utf8))
    }

    // MARK: - Shake

    @MainActor
    func testDefaultScreenRegistrationKeepsBootstrapShake() {
        resetState()
        let session = MeerkatFeedbackScreenSession(screen: "Home")
        MeerkatFeedbackScreenRegistration.register(
            screen: "Home",
            presentation: .floating,
            enableShake: false,
            mailRecipients: nil,
            apiEndpoint: nil,
            session: session
        )
        defer { MeerkatFeedbackScreenRegistration.unregister(screen: "Home") }

        XCTAssertTrue(
            MeerkatFeedbackShakeRegistry.isShakeEnabled(for: "Home", bootstrapDefault: true),
            "A modifier that leaves enableShake at its default must not mask bootstrap(enableShake: true)"
        )
        XCTAssertFalse(
            MeerkatFeedbackShakeRegistry.isShakeEnabled(for: "Home", bootstrapDefault: false)
        )
    }

    @MainActor
    func testExplicitScreenShakeStillOverridesBootstrap() {
        resetState()
        let session = MeerkatFeedbackScreenSession(screen: "Home")
        MeerkatFeedbackScreenRegistration.register(
            screen: "Home",
            presentation: .floating,
            enableShake: true,
            mailRecipients: nil,
            apiEndpoint: nil,
            session: session
        )
        XCTAssertTrue(
            MeerkatFeedbackShakeRegistry.isShakeEnabled(for: "Home", bootstrapDefault: false)
        )

        MeerkatFeedbackScreenRegistration.unregister(screen: "Home")
        XCTAssertFalse(
            MeerkatFeedbackShakeRegistry.isShakeEnabled(for: "Home", bootstrapDefault: false)
        )
    }

    // MARK: - API delivery & offline queue

    func testRetryableStatuses() {
        for status in [408, 425, 429, 500, 502, 503, 599] {
            XCTAssertTrue(APIFeedbackError.unsuccessfulStatus(status).isRetryable, "\(status)")
        }
        for status in [-1, 301, 400, 401, 403, 404, 413, 422] {
            XCTAssertFalse(APIFeedbackError.unsuccessfulStatus(status).isRetryable, "\(status)")
        }
    }

    @MainActor
    func testPermanentRejectionIsNotQueuedOffline() async {
        resetState()
        APIFeedbackDelivery.urlSession = makeSession()
        defer { APIFeedbackDelivery.urlSession = .shared }
        RegressionURLProtocol.statusCode = 401

        let result = await APIFeedbackDelivery.submit(
            payload: makePayload(),
            configuration: FeedbackAPIConfiguration(endpoint: endpoint, offlineRetryEnabled: true),
            identity: .anonymous
        )

        XCTAssertEqual(result.outcome, .failed)
        XCTAssertEqual(result.error, .unsuccessfulStatus(401))
        XCTAssertEqual(FeedbackOfflineQueue.pendingCount(), 0)
    }

    @MainActor
    func testServerErrorIsQueuedOffline() async {
        resetState()
        APIFeedbackDelivery.urlSession = makeSession()
        defer { APIFeedbackDelivery.urlSession = .shared }
        RegressionURLProtocol.statusCode = 503

        let result = await APIFeedbackDelivery.submit(
            payload: makePayload(),
            configuration: FeedbackAPIConfiguration(endpoint: endpoint, offlineRetryEnabled: true),
            identity: .anonymous
        )

        XCTAssertEqual(result.outcome, .queuedOffline)
        XCTAssertEqual(FeedbackOfflineQueue.pendingCount(), 1)
        resetState()
    }

    @MainActor
    func testFlushDropsPermanentlyRejectedItems() async {
        resetState()
        let session = makeSession()
        RegressionURLProtocol.statusCode = 400
        FeedbackOfflineQueue.enqueue(endpoint: endpoint, headers: [:], body: Data("{}".utf8))

        let delivered = await FeedbackOfflineQueue.flush(using: session)

        XCTAssertEqual(delivered, 0)
        XCTAssertEqual(FeedbackOfflineQueue.pendingCount(), 0)
    }

    @MainActor
    func testFlushKeepsItemsEnqueuedWhileInFlight() async {
        resetState()
        let session = makeSession()
        RegressionURLProtocol.responseDelay = 0.3
        FeedbackOfflineQueue.enqueue(endpoint: endpoint, headers: [:], body: Data("first".utf8))

        let flush = Task { @MainActor in
            await FeedbackOfflineQueue.flush(using: session)
        }
        // Let the flush suspend on its network request, then queue another submission.
        try? await Task.sleep(for: .milliseconds(100))
        FeedbackOfflineQueue.enqueue(endpoint: endpoint, headers: [:], body: Data("second".utf8))

        let delivered = await flush.value
        XCTAssertEqual(delivered, 1)
        XCTAssertEqual(
            FeedbackOfflineQueue.pendingCount(),
            1,
            "A submission queued during a flush must not be overwritten when the flush saves"
        )
        resetState()
    }

    @MainActor
    func testOverlappingFlushesDoNotDeliverTwice() async {
        resetState()
        let session = makeSession()
        RegressionURLProtocol.responseDelay = 0.3
        FeedbackOfflineQueue.enqueue(endpoint: endpoint, headers: [:], body: Data("{}".utf8))

        let first = Task { @MainActor in
            await FeedbackOfflineQueue.flush(using: session)
        }
        try? await Task.sleep(for: .milliseconds(100))
        let second = await FeedbackOfflineQueue.flush(using: session)
        let firstDelivered = await first.value

        XCTAssertEqual(firstDelivered, 1)
        XCTAssertEqual(second, 0)
        XCTAssertEqual(RegressionURLProtocol.requestCount, 1)
        XCTAssertEqual(FeedbackOfflineQueue.pendingCount(), 0)
    }

    @MainActor
    func testQueueIsCapped() {
        resetState()
        let limit = FeedbackOfflineQueue.maxPendingSubmissions
        for index in 0 ..< limit + 5 {
            FeedbackOfflineQueue.enqueue(
                endpoint: endpoint,
                headers: [:],
                body: Data("\(index)".utf8)
            )
        }
        XCTAssertEqual(FeedbackOfflineQueue.pendingCount(), limit)
        resetState()
    }

    @MainActor
    func testQueueStoredInUserDefaultsByOlderVersionsIsStillDelivered() async throws {
        resetState()
        struct LegacyItem: Codable {
            let endpoint: URL
            let headers: [String: String]
            let body: Data
            let queuedAt: Date
        }
        let legacy = [
            LegacyItem(endpoint: endpoint, headers: ["X-Key": "1"], body: Data("{}".utf8), queuedAt: Date())
        ]
        UserDefaults.standard.set(try JSONEncoder().encode(legacy), forKey: "meerkatkit.offline_queue")
        XCTAssertEqual(FeedbackOfflineQueue.pendingCount(), 1)

        RegressionURLProtocol.statusCode = 200
        let delivered = await FeedbackOfflineQueue.flush(using: makeSession())

        XCTAssertEqual(delivered, 1)
        XCTAssertEqual(FeedbackOfflineQueue.pendingCount(), 0)
        XCTAssertNil(UserDefaults.standard.data(forKey: "meerkatkit.offline_queue"))
    }

    // MARK: - Surveys, localization, catalog

    func testRecordingResponseWithoutStarsClearsPreviousRating() {
        let screen = "RegressionSurvey"
        MeerkatSurveyStore.reset(screen: screen)
        defer { MeerkatSurveyStore.reset(screen: screen) }

        MeerkatSurveyStore.recordResponse(.like, screen: screen, starRating: 5)
        XCTAssertEqual(MeerkatSurveyStore.starRating(screen: screen), 5)

        MeerkatSurveyStore.recordResponse(.dislike, screen: screen)
        XCTAssertEqual(MeerkatSurveyStore.response(screen: screen), .dislike)
        XCTAssertNil(MeerkatSurveyStore.starRating(screen: screen))
    }

    func testLocalizerFallsBackForEmptyOrUnknownLanguageCode() {
        XCTAssertEqual(MeerkatLocalizer.text(.feedbackButton, languageCode: ""), "Feedback")
        XCTAssertEqual(MeerkatLocalizer.text(.feedbackButton, languageCode: "-"), "Feedback")
        XCTAssertEqual(MeerkatLocalizer.text(.feedbackButton, languageCode: "xx-YY"), "Feedback")
        XCTAssertEqual(MeerkatLocalizer.text(.subjectBugReport, languageCode: "tr-TR"), "Hata Bildirimi")
    }

    func testWriteReviewURLNormalizesAppStoreID() {
        let expected = "https://apps.apple.com/app/id6751549199?action=write-review"
        XCTAssertEqual(
            MeerkatAppStoreReview.writeReviewURL(appStoreID: "id6751549199")?.absoluteString,
            expected
        )
        XCTAssertEqual(
            MeerkatAppStoreReview.writeReviewURL(appStoreID: " 6751549199 ")?.absoluteString,
            expected
        )
        XCTAssertNil(MeerkatAppStoreReview.writeReviewURL(appStoreID: "id"))
        XCTAssertNil(MeerkatAppStoreReview.writeReviewURL(appStoreID: "my-app"))
    }

    func testDeviceCatalogNamesAndFallbacks() {
        XCTAssertEqual(DeviceModelCatalog.marketingName(for: "iPhone18,4"), "iPhone Air")
        XCTAssertEqual(DeviceModelCatalog.fallbackName(for: "iPhone99,1"), "iPhone (iPhone99,1)")
        XCTAssertEqual(DeviceModelCatalog.fallbackName(for: "iPad99,1"), "iPad (iPad99,1)")
        XCTAssertEqual(DeviceModelCatalog.fallbackName(for: "Mac14,2"), "Mac (Mac14,2)")
    }
}

/// Answers every request with ``statusCode`` after ``responseDelay`` seconds.
private final class RegressionURLProtocol: URLProtocol {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var _statusCode = 200
    nonisolated(unsafe) private static var _responseDelay: TimeInterval = 0
    nonisolated(unsafe) private static var _requestCount = 0

    static var statusCode: Int {
        get { lock.withLock { _statusCode } }
        set { lock.withLock { _statusCode = newValue } }
    }

    static var responseDelay: TimeInterval {
        get { lock.withLock { _responseDelay } }
        set { lock.withLock { _responseDelay = newValue } }
    }

    static var requestCount: Int {
        lock.withLock { _requestCount }
    }

    static func reset() {
        lock.withLock {
            _statusCode = 200
            _responseDelay = 0
            _requestCount = 0
        }
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let (status, delay) = Self.lock.withLock { () -> (Int, TimeInterval) in
            Self._requestCount += 1
            return (Self._statusCode, Self._responseDelay)
        }
        if delay > 0 {
            Thread.sleep(forTimeInterval: delay)
        }
        guard let url = request.url,
              let response = HTTPURLResponse(
                  url: url,
                  statusCode: status,
                  httpVersion: nil,
                  headerFields: nil
              ) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data())
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
