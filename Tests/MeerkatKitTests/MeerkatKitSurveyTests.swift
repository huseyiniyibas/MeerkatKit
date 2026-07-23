import XCTest
@testable import MeerkatKit

final class MeerkatKitSurveyTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        #if DEBUG
        MeerkatSurveyStore.resetAll()
        MeerkatSurveyAnalytics.clearContinuation()
        MeerkatSurveyScreenController.appearDelayOverride = nil
        #endif
    }

    @MainActor
    override func tearDown() async throws {
        #if DEBUG
        MeerkatSurveyStore.resetAll()
        MeerkatSurveyAnalytics.clearContinuation()
        MeerkatSurveyScreenController.appearDelayOverride = nil
        #endif
    }

    // MARK: - Trigger evaluator

    @MainActor
    func testFirstViewPresentsOnceOnly() {
        XCTAssertEqual(
            MeerkatSurveyTriggerEvaluator.decision(
                trigger: .firstView, viewCount: 1, hasPresented: false, hasResponded: false
            ),
            .present
        )
        XCTAssertEqual(
            MeerkatSurveyTriggerEvaluator.decision(
                trigger: .firstView, viewCount: 2, hasPresented: true, hasResponded: false
            ),
            .skip
        )
    }

    @MainActor
    func testEveryViewRepeatsUntilResponse() {
        XCTAssertEqual(
            MeerkatSurveyTriggerEvaluator.decision(
                trigger: .everyView, viewCount: 5, hasPresented: true, hasResponded: false
            ),
            .present
        )
        XCTAssertEqual(
            MeerkatSurveyTriggerEvaluator.decision(
                trigger: .everyView, viewCount: 6, hasPresented: true, hasResponded: true
            ),
            .skip
        )
    }

    @MainActor
    func testAfterViewsThreshold() {
        XCTAssertEqual(
            MeerkatSurveyTriggerEvaluator.decision(
                trigger: .afterViews(3), viewCount: 2, hasPresented: false, hasResponded: false
            ),
            .skip
        )
        XCTAssertEqual(
            MeerkatSurveyTriggerEvaluator.decision(
                trigger: .afterViews(3), viewCount: 3, hasPresented: false, hasResponded: false
            ),
            .present
        )
        XCTAssertEqual(
            MeerkatSurveyTriggerEvaluator.decision(
                trigger: .afterViews(3), viewCount: 4, hasPresented: true, hasResponded: false
            ),
            .skip
        )
    }

    @MainActor
    func testAfterDwellReturnsDwellDecision() {
        XCTAssertEqual(
            MeerkatSurveyTriggerEvaluator.decision(
                trigger: .afterDwell(.seconds(10)), viewCount: 1, hasPresented: false, hasResponded: false
            ),
            .presentAfterDwell(.seconds(10))
        )
        XCTAssertEqual(
            MeerkatSurveyTriggerEvaluator.decision(
                trigger: .afterDwell(.seconds(10)), viewCount: 2, hasPresented: true, hasResponded: false
            ),
            .skip
        )
    }

    @MainActor
    func testRespondedSkipsAllTriggers() {
        let triggers: [SatisfactionSurveyTrigger] = [
            .firstView, .everyView, .afterViews(1), .afterDwell(.seconds(1))
        ]
        for trigger in triggers {
            XCTAssertEqual(
                MeerkatSurveyTriggerEvaluator.decision(
                    trigger: trigger, viewCount: 9, hasPresented: false, hasResponded: true
                ),
                .skip,
                "Expected .skip after response for \(trigger)"
            )
        }
    }

    // MARK: - Store

    @MainActor
    func testStorePersistsViewCountsAndResponse() {
        #if DEBUG
        XCTAssertEqual(MeerkatSurveyStore.registerView(screen: "Chat"), 1)
        XCTAssertEqual(MeerkatSurveyStore.registerView(screen: "Chat"), 2)
        XCTAssertEqual(MeerkatSurveyStore.viewCount(screen: "Chat"), 2)

        XCTAssertFalse(MeerkatSurveyStore.hasPresented(screen: "Chat"))
        MeerkatSurveyStore.markPresented(screen: "Chat")
        XCTAssertTrue(MeerkatSurveyStore.hasPresented(screen: "Chat"))

        XCTAssertNil(MeerkatSurveyStore.response(screen: "Chat"))
        MeerkatSurveyStore.recordResponse(.like, screen: "Chat")
        XCTAssertEqual(MeerkatSurveyStore.response(screen: "Chat"), .like)

        MeerkatSurveyStore.reset(screen: "Chat")
        XCTAssertEqual(MeerkatSurveyStore.viewCount(screen: "Chat"), 0)
        XCTAssertFalse(MeerkatSurveyStore.hasPresented(screen: "Chat"))
        XCTAssertNil(MeerkatSurveyStore.response(screen: "Chat"))
        #endif
    }

    @MainActor
    func testResetSatisfactionSurveyPublicAPI() {
        #if DEBUG
        MeerkatSurveyStore.registerView(screen: "Gallery")
        MeerkatSurveyStore.recordResponse(.dislike, screen: "Gallery")
        MeerkatFeedback.resetSatisfactionSurvey(forScreen: "Gallery")
        XCTAssertEqual(MeerkatSurveyStore.viewCount(screen: "Gallery"), 0)
        XCTAssertNil(MeerkatSurveyStore.response(screen: "Gallery"))
        #endif
    }

    // MARK: - Controller

    @MainActor
    func testControllerPresentsOnFirstViewAndConsumesIt() async {
        #if DEBUG
        MeerkatSurveyScreenController.appearDelayOverride = .zero
        MeerkatFeedback.bootstrap(recipients: ["test@example.com"])

        let controller = MeerkatSurveyScreenController()
        controller.begin(screen: "ControllerFirst", trigger: .firstView)
        try? await Task.sleep(for: .milliseconds(50))
        XCTAssertTrue(controller.isPresentingSurvey)
        XCTAssertTrue(MeerkatSurveyStore.hasPresented(screen: "ControllerFirst"))

        let second = MeerkatSurveyScreenController()
        second.begin(screen: "ControllerFirst", trigger: .firstView)
        try? await Task.sleep(for: .milliseconds(50))
        XCTAssertFalse(second.isPresentingSurvey)
        #endif
    }

    @MainActor
    func testControllerDwellTimerPresentsAfterDuration() async {
        #if DEBUG
        MeerkatFeedback.bootstrap(recipients: ["test@example.com"])

        let controller = MeerkatSurveyScreenController()
        controller.begin(screen: "ControllerDwell", trigger: .afterDwell(.milliseconds(60)))
        XCTAssertFalse(controller.isPresentingSurvey)
        try? await Task.sleep(for: .milliseconds(120))
        XCTAssertTrue(controller.isPresentingSurvey)
        #endif
    }

    @MainActor
    func testControllerDwellCancelledOnDisappear() async {
        #if DEBUG
        MeerkatFeedback.bootstrap(recipients: ["test@example.com"])

        let controller = MeerkatSurveyScreenController()
        controller.begin(screen: "ControllerLeave", trigger: .afterDwell(.milliseconds(60)))
        controller.end()
        try? await Task.sleep(for: .milliseconds(120))
        XCTAssertFalse(controller.isPresentingSurvey)
        XCTAssertFalse(MeerkatSurveyStore.hasPresented(screen: "ControllerLeave"))
        #endif
    }

    @MainActor
    func testControllerRequiresBootstrap() async {
        #if DEBUG
        MeerkatFeedback.bootstrap(recipients: ["test@example.com"])
        MeerkatFeedback.setEnabled(false)
        defer { MeerkatFeedback.setEnabled(true) }

        MeerkatSurveyScreenController.appearDelayOverride = .zero
        let controller = MeerkatSurveyScreenController()
        controller.begin(screen: "ControllerDisabled", trigger: .firstView)
        try? await Task.sleep(for: .milliseconds(50))
        XCTAssertFalse(controller.isPresentingSurvey)
        XCTAssertEqual(MeerkatSurveyStore.viewCount(screen: "ControllerDisabled"), 0)
        #endif
    }

    // MARK: - Analytics

    @MainActor
    func testFirebaseUnavailableIsSafe() {
        XCTAssertFalse(MeerkatAnalytics.isFirebaseConfigured)
        MeerkatAnalytics.logEvent("meerkatkit_like", parameters: ["screen": "Chat"])
        MeerkatSurveyAnalytics.logResponse(.dislike, screen: "Chat")
    }

    @MainActor
    func testTemplateEventNames() {
        XCTAssertEqual(MeerkatSurveyAnalytics.eventName(for: .bugReport), "meerkatkit_bugreport")
        XCTAssertEqual(MeerkatSurveyAnalytics.eventName(for: .featureRequest), "meerkatkit_featurerequest")
        XCTAssertEqual(MeerkatSurveyAnalytics.eventName(for: .general), "meerkatkit_feedback")

        let custom = FeedbackTemplate.custom(
            FeedbackCustomTemplate(
                id: "Billing Issue!",
                title: "Billing",
                subject: "Billing",
                bodyPrefix: "Details:\n\n"
            )
        )
        XCTAssertEqual(MeerkatSurveyAnalytics.eventName(for: custom), "meerkatkit_billing_issue_")
    }

    @MainActor
    func testSanitizedEventComponentCapsLength() {
        let long = String(repeating: "a", count: 60)
        let sanitized = MeerkatSurveyAnalytics.sanitizedEventComponent(long)
        XCTAssertEqual(sanitized.count, 29)
        XCTAssertEqual(MeerkatSurveyAnalytics.sanitizedEventComponent(""), "custom")
        XCTAssertEqual(("meerkatkit_" + sanitized).count, 40)
    }

    @MainActor
    func testContinuationConsumedOnMatchingScreenOnly() {
        #if DEBUG
        MeerkatSurveyAnalytics.noteContinuation(screen: "Chat")
        MeerkatSurveyAnalytics.templateCommitted(screen: "Other", template: .general)
        XCTAssertEqual(MeerkatSurveyAnalytics.pendingContinuationScreen, "Chat")

        MeerkatSurveyAnalytics.templateCommitted(screen: "Chat", template: .bugReport)
        XCTAssertNil(MeerkatSurveyAnalytics.pendingContinuationScreen)
        #endif
    }

    @MainActor
    func testContinuationClearedOnCancellation() {
        #if DEBUG
        MeerkatSurveyAnalytics.noteContinuation(screen: "Chat")
        FeedbackEventDispatcher.cancelled(screen: "Chat", stage: .templatePicker)
        XCTAssertNil(MeerkatSurveyAnalytics.pendingContinuationScreen)
        #endif
    }

    // MARK: - Localization

    @MainActor
    func testSurveyLocalizationCoverage() {
        let languageCodes = [
            "en", "tr", "es", "fr", "de", "ja", "it", "pt", "ru", "ko", "zh-hans", "zh-hant", "nl", "ar"
        ]
        let surveyKeys: [MeerkatLocalizedKey] = [
            .surveyTitle,
            .surveyLike,
            .surveyDislike,
            .surveyThanks,
            .surveySendFeedback,
            .surveyNotNow
        ]

        for languageCode in languageCodes where languageCode != "en" {
            for key in surveyKeys {
                let localized = MeerkatLocalizer.text(key, languageCode: languageCode)
                let english = MeerkatLocalizer.text(key, languageCode: "en")
                XCTAssertNotEqual(
                    localized,
                    english,
                    "Expected \(languageCode) translation for \(key), got English fallback"
                )
            }
        }

        XCTAssertEqual(MeerkatLocalizer.text(.surveyLike, languageCode: "tr"), "Beğendim")
        XCTAssertEqual(MeerkatLocalizer.text(.surveyDislike, languageCode: "tr"), "Beğenmedim")
    }
}
