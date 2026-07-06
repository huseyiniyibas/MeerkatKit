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
    func testTemplatePickerEligibility() {
        MeerkatFeedback.bootstrap(recipients: ["test@example.com"])
        XCTAssertFalse(MeerkatFeedback.shouldShowTemplatePicker)
        XCTAssertEqual(MeerkatFeedback.configuredTemplates, [.general])

        MeerkatFeedback.bootstrap(
            recipients: ["test@example.com"],
            templates: [.bugReport, .featureRequest, .general]
        )
        XCTAssertTrue(MeerkatFeedback.shouldShowTemplatePicker)
        XCTAssertEqual(MeerkatFeedback.configuredTemplates.count, 3)
    }

    @MainActor
    func testTemplateTitlesArePublic() {
        XCTAssertEqual(FeedbackTemplate.bugReport.title(for: .english), "Bug Report")
        XCTAssertEqual(FeedbackTemplate.bugReport.title(for: .turkish), "Hata Bildirimi")
        XCTAssertEqual(FeedbackTemplate.featureRequest.title(for: .english), "Feature Request")
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
        XCTAssertEqual(MeerkatLocalizer.text(.feedbackButton, languageCode: "de"), "Rückmeldung")
        XCTAssertEqual(MeerkatLocalizer.text(.feedbackButton, languageCode: "de-DE"), "Rückmeldung")
        XCTAssertEqual(MeerkatLocalizer.text(.feedbackButton, languageCode: "pt-BR"), "Feedback")
        XCTAssertEqual(MeerkatLocalizer.text(.labelVersion, languageCode: "pt-BR"), "Versão")
        XCTAssertEqual(MeerkatLocalizer.text(.feedbackButton, languageCode: "xx-YY"), "Feedback")
    }

    @MainActor
    func testFormAndPickerLocalizationCoverage() {
        let languageCodes = [
            "en", "tr", "es", "fr", "de", "ja", "it", "pt", "ru", "ko", "zh-hans", "zh-hant", "nl", "ar"
        ]
        let formKeys: [MeerkatLocalizedKey] = [
            .templatePickerTitle,
            .templatePickerCancel,
            .formTitle,
            .formSubmit,
            .formCancel,
            .formRatingLabel,
            .formMessagePlaceholder,
            .formIncludeScreenshot,
            .labelRating,
            .labelRecipients
        ]

        for languageCode in languageCodes where languageCode != "en" {
            for key in formKeys {
                let localized = MeerkatLocalizer.text(key, languageCode: languageCode)
                let english = MeerkatLocalizer.text(key, languageCode: "en")
                XCTAssertNotEqual(
                    localized,
                    english,
                    "Expected \(languageCode) translation for \(key), got English fallback"
                )
            }
        }
    }

    @MainActor
    func testPayloadIncludesScreenName() {
        MeerkatFeedback.bootstrap(
            recipients: ["test@example.com"],
            collectUserInput: false
        )
        MeerkatFeedback.setEnabled(true)
        let expectation = expectation(description: "custom delivery")
        MeerkatFeedback.bootstrap(
            customDelivery: { payload in
                XCTAssertEqual(payload.placement, "Checkout")
                XCTAssertEqual(payload.metadata["placement"], "Checkout")
                expectation.fulfill()
            },
            collectUserInput: false
        )
        MeerkatFeedback.present(screen: "Checkout", template: .bugReport)
        wait(for: [expectation], timeout: 1)
    }

    @MainActor
    func testPayloadIncludesUserInput() {
        MeerkatFeedback.bootstrap(recipients: ["test@example.com"])
        let configuration = MeerkatBootstrap.mail(recipients: ["test@example.com"]).configuration(placement: "Home")
        let userInput = FeedbackUserInput(message: "App crashes on launch", rating: 2)
        let payload = FeedbackPayloadBuilder.build(
            configuration: configuration,
            placementOverride: "Home",
            templateOverride: .bugReport,
            userInput: userInput
        )

        XCTAssertEqual(payload.userInput, userInput)
        XCTAssertTrue(payload.body.contains("App crashes on launch"))
        XCTAssertTrue(payload.body.contains("Rating: 2/5"))
        XCTAssertTrue(payload.body.contains("Describe the bug:"))
    }

    @MainActor
    func testCollectUserInputDefaultsTrue() {
        MeerkatFeedback.bootstrap(recipients: ["test@example.com"])
        XCTAssertTrue(MeerkatFeedback.shouldCollectUserInput)
    }

    @MainActor
    func testBeginFeedbackFormShowsFormSheet() {
        #if DEBUG
        MeerkatFeedbackSessionRegistry.resetAll()
        MeerkatFeedback.bootstrap(recipients: ["test@example.com"], collectUserInput: true)
        let session = MeerkatFeedbackScreenSession(screen: "Settings")
        MeerkatFeedbackSessionRegistry.register(session)
        session.beginFeedbackForm(template: .general)
        XCTAssertTrue(session.showFeedbackForm)
        XCTAssertEqual(session.pendingTemplate, .general)
        MeerkatFeedbackSessionRegistry.resetAll()
        #endif
    }

    @MainActor
    func testPerScreenMailRecipients() {
        #if DEBUG
        MeerkatFeedbackRecipientRegistry.resetAll()
        #endif
        let bootstrap = MeerkatBootstrap.mail(recipients: ["default@example.com"])
        MeerkatFeedbackRecipientRegistry.register(
            screen: "Paywall",
            recipients: ["billing@example.com"]
        )
        let paywallConfig = bootstrap.configuration(placement: "Paywall")
        let homeConfig = bootstrap.configuration(placement: "Home")

        guard case let .mailComposer(paywallRecipients, _, _) = paywallConfig.delivery else {
            XCTFail("Expected mail composer delivery")
            return
        }
        guard case let .mailComposer(homeRecipients, _, _) = homeConfig.delivery else {
            XCTFail("Expected mail composer delivery")
            return
        }
        XCTAssertEqual(paywallRecipients, ["billing@example.com"])
        XCTAssertEqual(homeRecipients, ["default@example.com"])
        #if DEBUG
        MeerkatFeedbackRecipientRegistry.resetAll()
        #endif
    }

    @MainActor
    func testSetMailRecipientsPublicAPI() {
        #if DEBUG
        MeerkatFeedbackRecipientRegistry.resetAll()
        #endif
        MeerkatFeedback.bootstrap(recipients: ["default@example.com"], collectUserInput: false)
        MeerkatFeedback.setMailRecipients(["results@example.com"], forScreen: "Result")
        let bootstrap = MeerkatBootstrap.mail(recipients: ["default@example.com"])
        let config = bootstrap.configuration(placement: "Result")
        guard case let .mailComposer(recipients, _, _) = config.delivery else {
            XCTFail("Expected mail composer")
            return
        }
        XCTAssertEqual(recipients, ["results@example.com"])
        #if DEBUG
        MeerkatFeedbackRecipientRegistry.resetAll()
        #endif
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
            templateOverride: .general,
            userInput: nil
        )

        XCTAssertEqual(payload.subject, "Feedback")
        XCTAssertTrue(payload.body.contains("Please type your feedback below:"))
        XCTAssertTrue(payload.body.contains(String(repeating: "=", count: 40)))
        XCTAssertTrue(payload.body.contains("Screen: Settings"))
        XCTAssertFalse(payload.body.contains("bundleId"))
    }

    @MainActor
    func testRequestFeedbackUsesRegisteredSession() {
        #if DEBUG
        MeerkatFeedbackSessionRegistry.resetAll()
        MeerkatFeedback.bootstrap(
            recipients: ["test@example.com"],
            templates: [.bugReport, .general]
        )
        let session = MeerkatFeedbackScreenSession(screen: "Settings")
        MeerkatFeedbackSessionRegistry.register(session)
        XCTAssertFalse(session.showTemplatePicker)
        MeerkatFeedback.requestFeedback(screen: "Settings")
        XCTAssertTrue(session.showTemplatePicker)
        MeerkatFeedbackSessionRegistry.resetAll()
        #endif
    }

    @MainActor
    func testRevealTrackerSessionDeadline() {
        #if DEBUG
        MeerkatFeedbackRevealTracker.resetAll()
        let clock = ContinuousClock()
        let now = clock.now
        let deadline = MeerkatFeedbackRevealTracker.deadline(
            for: "Home",
            revealAfter: .seconds(8),
            now: now
        )
        XCTAssertGreaterThan(deadline, now)
        XCTAssertFalse(MeerkatFeedbackRevealTracker.hasRevealed(screen: "Home"))
        MeerkatFeedbackRevealTracker.markRevealed("Home")
        XCTAssertTrue(MeerkatFeedbackRevealTracker.hasRevealed(screen: "Home"))
        #endif
    }

    @MainActor
    func testDismissCooldownPersistence() {
        #if DEBUG
        MeerkatDismissCooldown.resetAll()
        XCTAssertFalse(MeerkatDismissCooldown.isActive(screen: "Settings", cooldown: .seconds(60)))
        MeerkatDismissCooldown.recordDismiss(screen: "Settings", cooldown: .seconds(60))
        XCTAssertTrue(MeerkatDismissCooldown.isActive(screen: "Settings", cooldown: .seconds(60)))
        MeerkatDismissCooldown.clear(screen: "Settings")
        XCTAssertFalse(MeerkatDismissCooldown.isActive(screen: "Settings", cooldown: .seconds(60)))
        #endif
    }

    @MainActor
    func testCustomTemplateAPIIdentifier() {
        let custom = FeedbackTemplate.custom(
            FeedbackCustomTemplate(
                id: "billing",
                title: "Billing",
                subject: "Billing issue",
                bodyPrefix: "Details:\n\n"
            )
        )
        XCTAssertEqual(custom.apiIdentifier, "billing")
        XCTAssertEqual(custom.rowTitle(for: .english), "Billing")
    }

    @MainActor
    func testFormConfigurationRatingDisabled() {
        MeerkatFeedback.bootstrap(
            recipients: ["test@example.com"],
            formConfiguration: FeedbackFormConfiguration(collectRating: false)
        )
        XCTAssertFalse(MeerkatFeedback.formConfiguration.collectRating)
    }

    @MainActor
    func testFeedbackEventHandlerSubmitted() {
        MeerkatFeedback.bootstrap(
            customDelivery: { _ in },
            collectUserInput: false,
            eventHandler: FeedbackEventHandler(
                onSubmitted: { event in
                    XCTAssertEqual(event.screen, "Checkout")
                    XCTAssertEqual(event.channel, .custom)
                }
            )
        )
        MeerkatFeedback.present(screen: "Checkout", template: .bugReport)
    }

    @MainActor
    func testPayloadIncludesCustomFieldValues() {
        MeerkatFeedback.bootstrap(recipients: ["test@example.com"])
        let configuration = MeerkatBootstrap.mail(recipients: ["test@example.com"]).configuration(placement: "Home")
        let userInput = FeedbackUserInput(
            message: "Help",
            rating: 4,
            email: "user@test.com",
            customFields: ["orderId": "A-1"]
        )
        let payload = FeedbackPayloadBuilder.build(
            configuration: configuration,
            placementOverride: "Home",
            templateOverride: .general,
            userInput: userInput
        )

        XCTAssertEqual(payload.metadata["email"], "user@test.com")
        XCTAssertEqual(payload.metadata["orderId"], "A-1")
        XCTAssertTrue(payload.body.contains("user@test.com"))
    }

    @MainActor
    func testZeroDismissCooldownDoesNotPersist() {
        #if DEBUG
        MeerkatDismissCooldown.resetAll()
        MeerkatDismissCooldown.recordDismiss(screen: "Home", cooldown: .zero)
        XCTAssertFalse(MeerkatDismissCooldown.isActive(screen: "Home", cooldown: .zero))
        #endif
    }
}
