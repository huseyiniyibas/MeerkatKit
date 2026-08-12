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
            .labelRecipients,
            .formEmailPlaceholder,
            .labelEmail,
            .apiSuccessTitle,
            .apiSuccessMessage,
            .apiOfflineTitle,
            .apiOfflineMessage,
            .apiFailureTitle,
            .apiFailureMessage,
            .apiResultDismiss
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
    func testSubmitFormDeliversAfterSheetDismiss() async {
        #if DEBUG
        MeerkatFeedbackSessionRegistry.resetAll()
        #endif
        var deliveredMessage: String?
        MeerkatFeedback.bootstrap(
            customDelivery: { payload in
                deliveredMessage = payload.userInput?.message
            }
        )
        let session = MeerkatFeedbackScreenSession(screen: "Settings")
        MeerkatFeedbackSessionRegistry.register(session)
        session.beginFeedbackForm(template: .general)
        session.submitForm(FeedbackUserInput(message: "Native mail please"))
        XCTAssertNil(deliveredMessage)
        XCTAssertFalse(session.showFeedbackForm)

        session.handleFeedbackFormDismissed()
        let delivered = await MeerkatTestAsyncWait.until {
            deliveredMessage == "Native mail please"
        }
        XCTAssertTrue(delivered)
        #if DEBUG
        MeerkatFeedbackSessionRegistry.resetAll()
        #endif
    }

    @MainActor
    func testCancelFormDoesNotDeliver() {
        #if DEBUG
        MeerkatFeedbackSessionRegistry.resetAll()
        #endif
        var delivered = false
        var cancelled = false
        MeerkatFeedback.bootstrap(
            customDelivery: { _ in delivered = true },
            eventHandler: FeedbackEventHandler(
                onCancelled: { _ in cancelled = true }
            )
        )
        let session = MeerkatFeedbackScreenSession(screen: "Settings")
        MeerkatFeedbackSessionRegistry.register(session)
        session.beginFeedbackForm(template: .general)
        session.showFeedbackForm = false
        session.handleFeedbackFormDismissed()
        XCTAssertFalse(delivered)
        XCTAssertTrue(cancelled)
        #if DEBUG
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
                bodyPrefix: "Details:\n\n",
                emoji: "💳"
            )
        )
        XCTAssertEqual(custom.apiIdentifier, "billing")
        XCTAssertEqual(custom.rowTitle(for: .english), "Billing")
        XCTAssertEqual(custom.emoji, "💳")
        XCTAssertEqual(FeedbackTemplate.bugReport.emoji, "🐞")
        XCTAssertEqual(FeedbackTemplate.featureRequest.emoji, "💡")
        XCTAssertEqual(FeedbackTemplate.general.emoji, "💬")
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
    func testFeedbackEventHandlerAppeared() {
        var appearedScreen: String?
        MeerkatFeedback.bootstrap(
            customDelivery: { _ in },
            eventHandler: FeedbackEventHandler(
                onAppeared: { event in
                    appearedScreen = event.screen
                }
            )
        )
        FeedbackEventDispatcher.appeared(screen: "Home")
        XCTAssertEqual(appearedScreen, "Home")
    }

    @MainActor
    func testFeedbackAppearanceEventInit() {
        let event = FeedbackAppearanceEvent(screen: "Profile")
        XCTAssertEqual(event.screen, "Profile")
    }

    @MainActor
    func testAppearanceTrackerReportsOncePerVisibleStretch() {
        var count = 0
        MeerkatFeedback.bootstrap(
            customDelivery: { _ in },
            eventHandler: FeedbackEventHandler(
                onAppeared: { _ in count += 1 }
            )
        )
        var tracker = MeerkatFeedbackAppearanceTracker()
        tracker.reportIfNeeded(isVisible: true, screen: "Home")
        tracker.reportIfNeeded(isVisible: true, screen: "Home")
        XCTAssertEqual(count, 1)

        tracker.handleVisibilityChange(isVisible: false, screen: "Home")
        tracker.handleVisibilityChange(isVisible: true, screen: "Home")
        XCTAssertEqual(count, 2)
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
    func testPerScreenAPIEndpoint() {
        #if DEBUG
        MeerkatFeedbackAPIEndpointRegistry.resetAll()
        #endif
        let defaultEndpoint = URL(string: "https://api.example.com/feedback")!
        let billingEndpoint = URL(string: "https://api.example.com/feedback/billing")!
        let bootstrap = MeerkatBootstrap.api(endpoint: defaultEndpoint)
        MeerkatFeedbackAPIEndpointRegistry.register(screen: "Billing", endpoint: billingEndpoint)

        let billingConfig = bootstrap.configuration(placement: "Billing")
        let homeConfig = bootstrap.configuration(placement: "Home")

        guard case let .api(billingAPI) = billingConfig.delivery else {
            XCTFail("Expected API delivery")
            return
        }
        guard case let .api(homeAPI) = homeConfig.delivery else {
            XCTFail("Expected API delivery")
            return
        }
        XCTAssertEqual(billingAPI.endpoint, billingEndpoint)
        XCTAssertEqual(homeAPI.endpoint, defaultEndpoint)
        #if DEBUG
        MeerkatFeedbackAPIEndpointRegistry.resetAll()
        #endif
    }

    @MainActor
    func testSetAPIEndpointPublicAPI() {
        #if DEBUG
        MeerkatFeedbackAPIEndpointRegistry.resetAll()
        #endif
        let defaultEndpoint = URL(string: "https://api.example.com/feedback")!
        let resultsEndpoint = URL(string: "https://api.example.com/feedback/results")!
        MeerkatFeedback.bootstrap(api: defaultEndpoint, collectUserInput: false)
        MeerkatFeedback.setAPIEndpoint(resultsEndpoint, forScreen: "Result")
        let bootstrap = MeerkatBootstrap.api(endpoint: defaultEndpoint)
        let config = bootstrap.configuration(placement: "Result")
        guard case let .api(apiConfig) = config.delivery else {
            XCTFail("Expected API delivery")
            return
        }
        XCTAssertEqual(apiConfig.endpoint, resultsEndpoint)
        #if DEBUG
        MeerkatFeedbackAPIEndpointRegistry.resetAll()
        #endif
    }

    @MainActor
    func testVisionProDeviceIdentifier() {
        XCTAssertEqual(DeviceModelCatalog.marketingName(for: "RealityDevice14,1"), "Apple Vision Pro")
    }

    @MainActor
    func testZeroDismissCooldownDoesNotPersist() {
        #if DEBUG
        MeerkatDismissCooldown.resetAll()
        MeerkatDismissCooldown.recordDismiss(screen: "Home", cooldown: .zero)
        XCTAssertFalse(MeerkatDismissCooldown.isActive(screen: "Home", cooldown: .zero))
        #endif
    }

    @MainActor
    func testIntegratedPresentationUsesManualTrigger() {
        #if DEBUG
        MeerkatFeedbackPresentationRegistry.resetAll()
        MeerkatFeedbackPresentationRegistry.register(screen: "Settings", presentation: .integrated)
        let bootstrap = MeerkatBootstrap.mail(recipients: ["test@example.com"])
        let configuration = bootstrap.configuration(placement: "Settings")
        XCTAssertEqual(configuration.trigger, .manual)
        MeerkatFeedbackPresentationRegistry.resetAll()
        #endif
    }

    @MainActor
    func testFloatingPresentationUsesStickyButtonTrigger() {
        #if DEBUG
        MeerkatFeedbackPresentationRegistry.resetAll()
        MeerkatFeedbackPresentationRegistry.register(screen: "Home", presentation: .floating)
        let bootstrap = MeerkatBootstrap.mail(
            recipients: ["test@example.com"],
            buttonPosition: .topLeading
        )
        let configuration = bootstrap.configuration(placement: "Home")
        XCTAssertEqual(configuration.trigger, .stickyButton(position: .topLeading))
        MeerkatFeedbackPresentationRegistry.resetAll()
        #endif
    }

    @MainActor
    func testScreenshotSupportAvailability() {
        #if os(tvOS)
        XCTAssertFalse(FeedbackScreenshotCapture.isSupported)
        #else
        XCTAssertTrue(FeedbackScreenshotCapture.isSupported)
        #endif
    }

    @MainActor
    func testEffectiveOfferScreenshotRespectsPlatformSupport() {
        MeerkatFeedback.bootstrap(
            recipients: ["test@example.com"],
            offerScreenshotInForm: true
        )
        #if os(tvOS)
        XCTAssertFalse(MeerkatFeedback.effectiveOfferScreenshotInForm)
        #else
        XCTAssertTrue(MeerkatFeedback.effectiveOfferScreenshotInForm)
        #endif
    }

    @MainActor
    func testCustomHeaderAndFooterMetadata() {
        MeerkatFeedback.bootstrap(
            recipients: ["test@example.com"],
            appStoreID: "1234567890",
            headerMetadata: ["placement"],
            footerMetadata: ["appStoreID"]
        )
        let configuration = MeerkatBootstrap.mail(
            recipients: ["test@example.com"],
            headerMetadata: ["placement"],
            footerMetadata: ["appStoreID"]
        ).configuration(placement: "Checkout")
        let payload = FeedbackPayloadBuilder.build(
            configuration: configuration,
            placementOverride: "Checkout",
            templateOverride: .general,
            userInput: nil
        )

        XCTAssertTrue(payload.body.contains("Screen: Checkout"))
        XCTAssertFalse(payload.body.contains("App Name:"))
        XCTAssertTrue(payload.body.contains("App Store ID:"))
    }

    @MainActor
    func testConfiguredLocaleUsedForStickyButtonLabel() {
        MeerkatFeedback.bootstrap(recipients: ["test@example.com"], locale: .turkish)
        XCTAssertEqual(MeerkatFeedback.configuredLocale, .turkish)
        XCTAssertEqual(MeerkatLocalizer.text(.feedbackButton, locale: MeerkatFeedback.configuredLocale), "Geri Bildirim")
    }

    @MainActor
    func testPerScreenShakeUpdatesConfigurationTrigger() {
        #if DEBUG
        MeerkatFeedbackShakeRegistry.resetAll()
        MeerkatFeedbackShakeRegistry.register(screen: "Home", enableShake: true)
        let bootstrap = MeerkatBootstrap.mail(recipients: ["test@example.com"], enableShake: false)
        let configuration = bootstrap.configuration(placement: "Home")
        XCTAssertEqual(configuration.trigger, .shake)
        MeerkatFeedbackShakeRegistry.resetAll()
        #endif
    }

    @MainActor
    func testMinimumDwellMakesVisibilityReady() async {
        let controller = MeerkatFeedbackVisibilityController()
        controller.begin(screen: "Timed", minimumDwell: .milliseconds(50), revealAfter: nil)
        XCTAssertFalse(controller.isReady)
        let becameReady = await MeerkatTestAsyncWait.until { controller.isReady }
        XCTAssertTrue(becameReady)
    }

    @MainActor
    func testCombinedTimingUsesOrSemantics() async {
        #if DEBUG
        MeerkatFeedbackRevealTracker.resetAll()
        let controller = MeerkatFeedbackVisibilityController()
        controller.begin(
            screen: "Combined",
            minimumDwell: .milliseconds(400),
            revealAfter: .milliseconds(50)
        )
        let becameReady = await MeerkatTestAsyncWait.until { controller.isReady }
        XCTAssertTrue(becameReady)
        MeerkatFeedbackRevealTracker.resetAll()
        #endif
    }

    @MainActor
    func testMailUnavailableFallbackConfiguration() {
        MeerkatFeedback.bootstrap(
            recipients: ["test@example.com"],
            mailUnavailableFallback: .none
        )
        XCTAssertEqual(MeerkatFeedback.mailUnavailableFallback, .none)
    }

    func testFloatingButtonPositionFromFeedbackPosition() {
        XCTAssertEqual(
            MeerkatFloatingButtonPosition.from(.topLeading),
            MeerkatFloatingButtonPosition(edge: .leading, normalizedY: 0)
        )
        XCTAssertEqual(
            MeerkatFloatingButtonPosition.from(.bottomTrailing),
            MeerkatFloatingButtonPosition(edge: .trailing, normalizedY: 1)
        )
    }

    func testFloatingButtonSnapChoosesNearestHorizontalEdge() {
        let container = CGSize(width: 400, height: 800)
        let button = CGSize(width: 120, height: 40)

        let leading = MeerkatFloatingButtonPositionStore.snap(
            freeCenter: CGPoint(x: 80, y: 400),
            containerSize: container,
            buttonSize: button
        )
        XCTAssertEqual(leading.edge, .leading)

        let trailing = MeerkatFloatingButtonPositionStore.snap(
            freeCenter: CGPoint(x: 320, y: 400),
            containerSize: container,
            buttonSize: button
        )
        XCTAssertEqual(trailing.edge, .trailing)
    }

    func testFloatingButtonSnapClampsVerticalRange() {
        let container = CGSize(width: 400, height: 800)
        let button = CGSize(width: 120, height: 40)
        let margin = MeerkatFloatingButtonPositionStore.defaultMargin
        let chrome = MeerkatFloatingButtonPositionStore.defaultBottomChromeInset

        let top = MeerkatFloatingButtonPositionStore.snap(
            freeCenter: CGPoint(x: 50, y: -100),
            containerSize: container,
            buttonSize: button
        )
        XCTAssertEqual(top.normalizedY, 0, accuracy: 0.001)

        let bottom = MeerkatFloatingButtonPositionStore.snap(
            freeCenter: CGPoint(x: 350, y: 9_000),
            containerSize: container,
            buttonSize: button
        )
        XCTAssertEqual(bottom.normalizedY, 1, accuracy: 0.001)

        let midPoint = MeerkatFloatingButtonPositionStore.point(
            for: MeerkatFloatingButtonPosition(edge: .trailing, normalizedY: 0.5),
            containerSize: container,
            buttonSize: button
        )
        let topInset = margin
        let bottomInset = margin + chrome
        let expectedY = topInset + button.height / 2
            + 0.5 * (container.height - topInset - bottomInset - button.height)
        XCTAssertEqual(midPoint.y, expectedY, accuracy: 0.5)
        XCTAssertEqual(midPoint.x, container.width - margin - button.width / 2, accuracy: 0.5)
    }

    func testFloatingButtonRespectsSafeAreaAndBottomChrome() {
        let container = CGSize(width: 390, height: 844)
        let button = CGSize(width: 140, height: 44)
        let safeArea = MeerkatFloatingLayoutInsets(top: 59, leading: 0, bottom: 34, trailing: 0)
        let bottom = MeerkatFloatingButtonPositionStore.point(
            for: MeerkatFloatingButtonPosition(edge: .trailing, normalizedY: 1),
            containerSize: container,
            buttonSize: button,
            safeAreaInsets: safeArea
        )
        let expectedY = container.height
            - MeerkatFloatingButtonPositionStore.defaultMargin
            - safeArea.bottom
            - MeerkatFloatingButtonPositionStore.defaultBottomChromeInset
            - button.height / 2
        XCTAssertEqual(bottom.y, expectedY, accuracy: 0.5)
        XCTAssertGreaterThan(
            container.height - (bottom.y + button.height / 2),
            safeArea.bottom + 48
        )
    }

    func testFloatingButtonPositionPersistence() {
        #if DEBUG
        MeerkatFloatingButtonPositionStore.resetAll()
        let position = MeerkatFloatingButtonPosition(edge: .leading, normalizedY: 0.35)
        MeerkatFloatingButtonPositionStore.save(position)
        let loaded = MeerkatFloatingButtonPositionStore.load(default: .bottomTrailing)
        XCTAssertEqual(loaded, position)
        MeerkatFloatingButtonPositionStore.resetAll()
        #endif
    }

    @MainActor
    func testChromeSuppressorNesting() {
        #if DEBUG
        MeerkatFeedbackChromeSuppressor.shared.resetAll()
        #endif
        let chrome = MeerkatFeedbackChromeSuppressor.shared
        XCTAssertFalse(chrome.isSuppressed)
        chrome.begin()
        XCTAssertTrue(chrome.isSuppressed)
        chrome.begin()
        XCTAssertTrue(chrome.isSuppressed)
        chrome.end()
        XCTAssertTrue(chrome.isSuppressed)
        chrome.end()
        XCTAssertFalse(chrome.isSuppressed)
        #if DEBUG
        MeerkatFeedbackChromeSuppressor.shared.resetAll()
        #endif
    }

    @MainActor
    func testPendingScreenshotPreferAndConsume() {
        #if DEBUG
        MeerkatFeedbackPendingScreenshot.resetAll()
        #endif
        XCTAssertFalse(MeerkatFeedbackPendingScreenshot.shouldPreferInclude)
        let png = Data([0x89, 0x50, 0x4E, 0x47])
        MeerkatFeedbackPendingScreenshot.store(png)
        XCTAssertTrue(MeerkatFeedbackPendingScreenshot.shouldPreferInclude)
        XCTAssertEqual(MeerkatFeedbackPendingScreenshot.consumePNG(), png)
        XCTAssertFalse(MeerkatFeedbackPendingScreenshot.shouldPreferInclude)
        XCTAssertNil(MeerkatFeedbackPendingScreenshot.consumePNG())
    }

    @MainActor
    func testCollectAsyncUsesPendingScreenshotWithoutRecapture() async {
        #if DEBUG
        MeerkatFeedbackPendingScreenshot.resetAll()
        #endif
        let png = Data([0x01, 0x02, 0x03, 0x04])
        MeerkatFeedbackPendingScreenshot.store(png)
        let attachments = await FeedbackAttachmentCollector.collectAsync(
            userInput: FeedbackUserInput(message: "Bug", includeScreenshot: true),
            offerScreenshot: true,
            logProvider: nil,
            crashLogPath: nil,
            sheetDismissDelay: .milliseconds(0)
        )
        XCTAssertEqual(attachments.count, 1)
        XCTAssertEqual(attachments[0].filename, "screenshot.png")
        XCTAssertEqual(attachments[0].data, png)
        XCTAssertFalse(MeerkatFeedbackPendingScreenshot.shouldPreferInclude)
    }

    @MainActor
    func testCollectAsyncClearsPendingWhenScreenshotNotIncluded() async {
        #if DEBUG
        MeerkatFeedbackPendingScreenshot.resetAll()
        #endif
        MeerkatFeedbackPendingScreenshot.store(Data([0xAA]))
        let attachments = await FeedbackAttachmentCollector.collectAsync(
            userInput: FeedbackUserInput(message: "Hi", includeScreenshot: false),
            offerScreenshot: true,
            logProvider: nil,
            crashLogPath: nil,
            sheetDismissDelay: .milliseconds(0)
        )
        XCTAssertTrue(attachments.isEmpty)
        XCTAssertFalse(MeerkatFeedbackPendingScreenshot.shouldPreferInclude)
    }

    @MainActor
    func testSessionRegistryTracksActiveScreen() {
        #if DEBUG
        MeerkatFeedbackSessionRegistry.resetAll()
        #endif
        let home = MeerkatFeedbackScreenSession(screen: "Home")
        let settings = MeerkatFeedbackScreenSession(screen: "Settings")
        MeerkatFeedbackSessionRegistry.register(home)
        MeerkatFeedbackSessionRegistry.register(settings)
        XCTAssertEqual(MeerkatFeedbackSessionRegistry.activeScreen, "Settings")
        MeerkatFeedbackSessionRegistry.markActive("Home")
        XCTAssertEqual(MeerkatFeedbackSessionRegistry.activeScreen, "Home")
        #if DEBUG
        MeerkatFeedbackSessionRegistry.resetAll()
        #endif
    }
}
