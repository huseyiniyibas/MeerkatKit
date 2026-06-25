import XCTest
@testable import MeerkatKit

@MainActor
final class MeerkatKitTests: XCTestCase {
    func testStickyButtonVisibility() {
        MeerkatFeedback.configure(
            MeerkatConfiguration(
                trigger: .stickyButton(position: .bottomTrailing),
                delivery: .mailComposer(recipients: ["test@example.com"]),
                placement: "TestScreen"
            )
        )
        XCTAssertTrue(MeerkatFeedback.shouldShowStickyButton)
        MeerkatFeedback.dismissByUser()
        XCTAssertFalse(MeerkatFeedback.shouldShowStickyButton)
    }

    func testShakeTriggerEnabled() {
        MeerkatFeedback.configure(
            MeerkatConfiguration(
                trigger: .shake,
                delivery: .mailComposer(recipients: ["test@example.com"])
            )
        )
        XCTAssertTrue(MeerkatFeedback.isShakeEnabled)
        XCTAssertFalse(MeerkatFeedback.shouldShowStickyButton)
    }

    func testDeveloperDisable() {
        MeerkatFeedback.configure(
            MeerkatConfiguration(
                trigger: .stickyButton(position: .bottomLeading),
                delivery: .mailComposer(recipients: ["test@example.com"]),
                isEnabled: true
            )
        )
        MeerkatFeedback.setEnabled(false)
        XCTAssertFalse(MeerkatFeedback.shouldShowStickyButton)
    }

    func testTemplateLocalization() {
        XCTAssertEqual(FeedbackTemplate.bugReport.subject(for: .english), "Bug Report")
        XCTAssertEqual(FeedbackTemplate.bugReport.subject(for: .turkish), "Hata Bildirimi")
        XCTAssertEqual(FeedbackTemplate.featureRequest.subject(for: .english), "Feature Request")
    }

    func testPayloadIncludesPlacement() {
        let expectation = expectation(description: "custom delivery")
        MeerkatFeedback.configure(
            MeerkatConfiguration(
                trigger: .manual,
                delivery: .custom { payload in
                    XCTAssertEqual(payload.placement, "Checkout")
                    XCTAssertEqual(payload.metadata["placement"], "Checkout")
                    expectation.fulfill()
                },
                placement: "Home"
            )
        )
        MeerkatFeedback.present(from: "Checkout", template: .bugReport)
        wait(for: [expectation], timeout: 1)
    }
}
