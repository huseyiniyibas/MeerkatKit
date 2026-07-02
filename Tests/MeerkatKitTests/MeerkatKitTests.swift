import XCTest
@testable import MeerkatKit

final class MeerkatKitTests: XCTestCase {
    @MainActor
    func testStickyButtonAvailability() {
        MeerkatFeedback.bootstrap(recipients: ["test@example.com"])
        MeerkatFeedback.setEnabled(true)
        XCTAssertTrue(MeerkatFeedback.canShowStickyButton)
    }

    @MainActor
    func testShakeTriggerEnabled() {
        MeerkatFeedback.bootstrap(
            recipients: ["test@example.com"],
            enableShake: true
        )
        XCTAssertTrue(MeerkatFeedback.isShakeEnabled)
        XCTAssertFalse(MeerkatFeedback.canShowStickyButton)
    }

    @MainActor
    func testDeveloperDisable() {
        MeerkatFeedback.bootstrap(
            recipients: ["test@example.com"],
            buttonPosition: .bottomLeading
        )
        MeerkatFeedback.setEnabled(false)
        XCTAssertFalse(MeerkatFeedback.canShowStickyButton)
    }

    @MainActor
    func testTemplateLocalization() {
        XCTAssertEqual(FeedbackTemplate.bugReport.subject(for: .english), "Bug Report")
        XCTAssertEqual(FeedbackTemplate.bugReport.subject(for: .turkish), "Hata Bildirimi")
        XCTAssertEqual(FeedbackTemplate.featureRequest.subject(for: .english), "Feature Request")
    }


    @MainActor
    func testLocalizationFallbackAndTurkish() {
        XCTAssertEqual(MeerkatLocalizer.text(.feedbackButton, locale: .turkish), "Geri Bildirim")
        XCTAssertEqual(MeerkatLocalizer.text(.feedbackButton, locale: .english), "Feedback")
    }

    @MainActor
    func testLocalizationLanguageCoverageAndFallbacks() {
        XCTAssertEqual(MeerkatLocalizer.text(.feedbackButton, languageCode: "zh-Hans"), "反馈")
        XCTAssertEqual(MeerkatLocalizer.text(.feedbackButton, languageCode: "zh-Hant"), "回饋")
        XCTAssertEqual(MeerkatLocalizer.text(.feedbackButton, languageCode: "ar"), "ملاحظات")
        XCTAssertEqual(MeerkatLocalizer.text(.feedbackButton, languageCode: "pt-BR"), "Feedback")
        XCTAssertEqual(MeerkatLocalizer.text(.labelVersion, languageCode: "pt-BR"), "Versão")
        XCTAssertEqual(MeerkatLocalizer.text(.feedbackButton, languageCode: "xx-YY"), "Feedback")
    }

    @MainActor
    func testPayloadIncludesScreenName() {
        MeerkatFeedback.bootstrap(recipients: ["test@example.com"])
        MeerkatFeedback.setEnabled(true)
        let expectation = expectation(description: "custom delivery")
        MeerkatFeedback.bootstrap(customDelivery: { payload in
            XCTAssertEqual(payload.placement, "Checkout")
            XCTAssertEqual(payload.metadata["placement"], "Checkout")
            expectation.fulfill()
        })
        MeerkatFeedback.present(screen: "Checkout", template: .bugReport)
        wait(for: [expectation], timeout: 1)
    }

    @MainActor
    func testEmailBodyFormat() {
        MetadataCollector.setAppStoreID("1234567890")
        MeerkatFeedback.bootstrap(
            recipients: ["test@example.com"],
            appStoreID: "1234567890"
        )
        let configuration = MeerkatBootstrap.mail(recipients: ["test@example.com"]).configuration(placement: "Settings")
        let payload = FeedbackPayloadBuilder.build(
            configuration: configuration,
            placementOverride: "Settings",
            templateOverride: .general
        )

        XCTAssertEqual(payload.subject, "Feedback")
        XCTAssertTrue(payload.body.contains("Please type your feedback below:"))
        XCTAssertTrue(payload.body.contains(String(repeating: "=", count: 40)))
        XCTAssertTrue(payload.body.contains("Screen: Settings"))
        XCTAssertFalse(payload.body.contains("bundleId"))
    }
}
