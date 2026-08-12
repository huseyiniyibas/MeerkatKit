# Changelog

All notable changes to MeerkatKit are documented here.  
Package semver (`0.0.x`) is unrelated to iOS/macOS deployment targets.

## [0.4.9] — 2026-08-12

### Fixed

- **Form → native Mail** — submitting the in-app form presented `MFMailComposeViewController` from the still-visible form sheet, so Mail vanished when the sheet dismissed. Delivery now waits for the form `onDismiss` (and a settled presentation stack), then presents Mail from the underlying screen.

## [0.4.8] — 2026-08-09

### Fixed

- **Survey → Send feedback** — continuation waited on a fixed delay while the survey sheet was still dismissing, so the template picker often failed to present (notably when the screen had no `.meerkatFeedback` session). Feedback now opens from the survey sheet’s `onDismiss`, and UIKit presents wait until mid-dismiss controllers clear.

## [0.4.7] — 2026-08-09

### Added

- **Clean screenshot capture** — when **Include screenshot** is on, MeerkatKit hides its floating chrome (and banners) before capturing, then attaches `screenshot.png` to mail / API.
- **System screenshot → feedback** (iOS / iPadOS / visionOS) — with `offerScreenshotInForm: true`, a system screenshot opens the feedback flow on the active screen with the screenshot toggle pre-checked (chrome is hidden for the capture).

### Changed

- Feedback form `ScrollView` hides scroll indicators.

## [0.4.6] — 2026-08-05

### Added

- **Satisfaction survey** — `SatisfactionSurveyTrigger.everyNthView(n)` presents on every *n*-th screen appearance (10, 20, 30…), including after a previous response — for periodic sampling on result/detail screens.

### Fixed

- **Satisfaction survey sheet** — uses a content-fitted height detent instead of `.medium`, so like/dislike (and follow-up) no longer sit above a large empty region.

## [0.4.5] — 2026-08-02

### Fixed

- **CI flake** — timing-sensitive visibility/survey tests now poll until ready instead of fixed short sleeps (macOS runners).

## [0.4.4] — 2026-08-02

### Fixed

- **tvOS build** — floating button drag uses `DragGesture`, which is unavailable on tvOS; drag is now compiled out on tvOS so CI/platform builds succeed.

## [0.4.3] — 2026-08-02

### Changed

- **Survey like/dislike UI** — compact card-style response buttons instead of oversized circular controls.
- **Template picker** — emoji rows in a height-fitted sheet (no sparse medium-list empty space); optional `emoji` on custom templates.
- **Floating button layout** — respects safe area and reserves bottom chrome so the control stays above tab bars / FABs.
- **Floating button interactions** — suppresses accidental taps while dragging; blocks inherited TabView/navigation animations that previously yanked the button off-screen.

## [0.4.2] — 2026-07-28

### Added

- **Draggable sticky button** — floating feedback control can be dragged freely; on release it snaps to the nearer leading or trailing edge and remembers vertical position across launches.

### Changed

- **Satisfaction survey buttons** — like/dislike controls use circular soft-fill icons with press feedback instead of system bordered buttons; follow-up and close affordances match the same visual language.

## [0.4.1] — 2026-07-28

### Added

- **`FeedbackEventHandler.onAppeared`** — callback when the sticky / custom floating feedback control becomes visible on a screen (after dwell / reveal, when not suppressed by dismiss cooldown or shake).
- **`FeedbackAppearanceEvent`** — carries the `screen` name for the appearance callback.
- **Firebase Analytics** — logs `meerkatkit_shown` with a `screen` parameter when the floating control appears (same crash-safe runtime bridge as survey events).

## [0.4.0] — 2026-07-22

### Added

- **Satisfaction surveys** — `.meerkatSatisfactionSurvey(screen:trigger:offersFeedback:onResponse:)` shows a like/dislike modal per screen with triggers: `.firstView`, `.everyView`, `.afterViews(n)`, `.afterDwell(duration)`.
- **Response callback** — `onResponse` runs developer code when the user taps like or dislike; state persists per screen and never re-asks after a response.
- **Feedback continuation** — after a response the buttons animate out and an optional **Send feedback** button opens the regular flow (template picker → form → delivery); disable with `offersFeedback: false`.
- **`MeerkatFeedback.resetSatisfactionSurvey(forScreen:)`** — clears stored survey state to ask again.
- **Firebase Analytics bridge** — logs `meerkatkit_like` / `meerkatkit_dislike` and `meerkatkit_bugreport` / `meerkatkit_featurerequest` / `meerkatkit_feedback` (survey-originated flows) when Firebase is installed and configured. Resolved at runtime — no dependency added, silent no-op (never a crash) when Firebase or `GoogleService-Info.plist` is missing.
- **i18n** — six survey strings localized in all 14 UI languages.
- **DocC / README / Example** — Satisfaction surveys article, README section, and `ExampleSurveyView` demo.

## [0.3.3] — 2026-07-07

### Added

- **UIKit-only flow** — template picker and API banner overlay work without `.meerkatFeedback` modifier.
- **`FeedbackTrigger.manual`** — assigned for screens using `presentation: .integrated`.
- **`effectiveOfferScreenshotInForm`** — hides screenshot toggle on platforms without capture support (tvOS).
- **Per-screen shake registry** — `enableShake` on modifier updates ``MeerkatConfiguration/trigger`` per screen.
- **Full i18n** — email field and API result strings for all 14 UI languages.
- **DocC / README** — `headerMetadata`, `footerMetadata`, sync script, mail attachment limits, timing OR semantics.
- **CI** — DocC build job; tvOS/visionOS simulators fail loudly instead of silent build-only fallback.

### Fixed

- **Sticky button locale** — uses bootstrap `locale` instead of device locale.
- **macOS standalone windows** — delegate/window retained in registry; close fires `onCancelled`.
- **UIKit presenter missing** — cancels flow instead of silent form skip.
- **API banner overlay** — reinstalls when key window changes.

### Changed

- ``shouldShowStickyButton`` deprecated in favor of ``canShowStickyButton``.

## [0.3.2] — 2026-07-06

### Added

- **DocC — Platform limits** — full capability matrix for iOS, macOS, tvOS, and visionOS (shake, mail, share fallback, form differences).
- **DocC** — mail delivery, attachments & identity, per-screen configuration, tvOS integration, and localization articles.
- **Example app** — timing & dismiss, custom floating button, mail delivery, custom delivery pattern, AppKit toolbar item, and crash log path demo.

### Changed

- DocC catalog and README link to platform limits and tvOS guide.
- Example home screen links to all major integration demos.

## [0.3.1] — 2026-07-06

### Fixed

- **visionOS** — `sheetPresentationController` detents and SwiftUI `presentationDetents` are iOS-only (unavailable on visionOS).
- **CI** — tvOS and visionOS jobs use reliable simulator UUID extraction; concrete UDID targeting (build-only fallback when unavailable).

## [0.3.0] — 2026-07-06

### Added

- **visionOS support** — deployment target 1.5; floating button, form, API delivery, mailto + share fallback, UIKit helpers, and screenshot capture.
- **DocC** — visionOS integration article.
- **CI** — visionOS Simulator build/test job.

### Changed

- Platform policy and sync script now include visionOS alongside iOS, macOS, and tvOS.

## [0.2.1] — 2026-07-06

### Added

- **Per-screen API endpoint** — optional `apiEndpoint` on ``View/meerkatFeedback(screen:apiEndpoint:)`` and ``MeerkatFeedback/setAPIEndpoint(_:forScreen:)``.
- **macOS AppKit helper** — ``MeerkatFeedbackAppKit`` toolbar item + ``NSViewController/meerkatRequestFeedback(screen:)``.
- **DocC** — AppKit integration article.
- **CI** — macOS and tvOS test jobs (previously build-only).

## [0.2.0] — 2026-07-06

### Added

- **API result UI** — `apiResultPresentation` on API bootstrap (`.alert`, `.banner`, or `.none`).
- **Event handlers** — ``FeedbackEventHandler`` with `onSubmitted`, `onFailed`, and `onCancelled` callbacks.
- **Form configuration** — ``FeedbackFormConfiguration`` for optional rating, email collection, and custom fields.
- **Custom templates** — ``FeedbackCustomTemplate`` via ``FeedbackTemplate/custom(_:)``.
- **DocC articles** — API delivery, form configuration, custom templates, and event handlers.
- **Example app** — custom template, form config, event handlers, per-screen mail, and UIKit demo screen.

### Changed

- ``FeedbackTemplate`` is now a sum type (`bugReport`, `featureRequest`, `general`, `custom`) with ``FeedbackTemplate/apiIdentifier`` for API payloads.
- ``FeedbackUserInput`` includes optional `email` and `customFields`.

## [0.1.4] — 2026-07-06

### Fixed

- **Form & picker localization** — completed translations for all 14 supported UI languages (previously only EN/TR had full form and template picker strings).

## [0.1.3] — 2026-07-06

### Added

- **Per-screen mail recipients** — optional `mailRecipients` on ``View/meerkatFeedback(screen:mailRecipients:)`` and ``MeerkatFeedback/setMailRecipients(_:forScreen:)`` for UIKit.

### Changed

- README rewritten with full feature overview and current API reference.

## [0.1.2] — 2026-07-04

### Fixed

- tvOS share fallback no longer uses unavailable `UIPasteboard`.

## [0.1.1] — 2026-07-04

### Fixed

- **tvOS CI build** — `TextEditor` / `presentationDetents` / `pageSheet` guarded per platform; share fallback uses pasteboard on tvOS.
- Extracted ``TopViewControllerFinder`` for shared iOS + tvOS UIKit presentation.

## [0.1.0] — 2026-07-04

### Added

- **REST API delivery** — ``MeerkatFeedback/bootstrap(api:headers:offlineRetryEnabled:)`` posts JSON to your endpoint.
- **Offline queue + retry** — failed API calls are persisted; ``MeerkatFeedback/flushOfflineQueue()`` retries on bootstrap.
- **User identity** — ``FeedbackUserIdentity`` (`userId`, `email`, `isAnonymous`) in metadata and API payloads.
- **Screenshot capture** — optional form toggle via `offerScreenshotInForm`; attached to Mail / API.
- **Log / crash attachments** — ``MeerkatFeedback/setLogProvider(_:)`` and `crashLogPath` bootstrap parameter.
- **UIKit wrapper** — ``MeerkatFeedbackUIKit`` bar button + ``UIViewController/meerkatRequestFeedback(screen:)``.
- **Example app** — `Examples/MeerkatKitExample` (iOS, macOS, tvOS targets).
- DocC article: UIKit integration.

## [0.0.9] — 2026-07-04

### Added

- **In-app feedback form** — message + optional 1–5 star rating before delivery (default `collectUserInput: true` on bootstrap).
- **Mail unavailable fallback** — share sheet when Mail / mailto cannot be used (`mailUnavailableFallback: .shareSheet`, default).

### Changed

- Mail body now includes user message and rating when collected in-app.
- Set `collectUserInput: false` on bootstrap to restore immediate mail delivery (legacy behaviour).

## [0.0.8] — 2026-07-04

### Added

- **Custom floating button** — `meerkatFeedback` ViewBuilder overload (`request` / `dismiss` callbacks).
- **Integrated presentation** — `presentation: .integrated` hides the sticky button; use your own UI.
- ``MeerkatFeedback/requestFeedback(screen:)`` and ``EnvironmentValues/meerkatFeedbackRequest`` for in-screen buttons.

## [0.0.7] — 2026-07-04

### Added

- **Template picker UI** — when `bootstrap` lists multiple ``FeedbackTemplate`` values, users choose bug / feature / general before mail opens.
- **DocC documentation** — `MeerkatKit.docc` catalog with getting-started and configuration articles.
- **CHANGELOG** (this file).

### Changed

- ``FeedbackTemplate/title(for:)`` and ``subject(for:)`` are now public for picker labels and custom UI.
- Removed unused `ShakeDetector` class; shake handling lives in `ShakeResponder` only.

## [0.0.6] — 2026-07-02

### Added

- **Dismiss cooldown** — sticky button stays hidden per screen after ✕ (default 24 hours, configurable at bootstrap or per modifier).
- `dismissCooldown` parameter on ``MeerkatFeedback/bootstrap(recipients:appStoreID:...)`` and `.meerkatFeedback(screen:)`.

## [0.0.5] — 2026-07-02

### Added

- `minimumDwell` — show sticky button after continuous time on screen.
- `revealAfter` — show after elapsed time since screen first opened in session.
- Per-screen `enableShake` on `.meerkatFeedback(screen:enableShake:)`.
- German button label (`Rückmeldung`).
- 14 UI locales, platform policy docs, `sync-platform-targets.mjs`.

### Changed

- Deployment minimums: iOS/tvOS **17.5**, macOS **14.5**.
- API: `bootstrap` + `.meerkatFeedback(screen:)` replaces `configure` / overlay helper.
- Mail body format with metadata block and typing prompt.

## [0.0.4] — 2026-07-02

### Fixed

- CI: generic tvOS simulator destination.
- Swift 6 concurrency in metadata and mail delegate.

## [0.0.3] — 2026-07-02

### Fixed

- tvOS actor isolation and CI destinations.

## [0.0.2] — 2026-07-02

### Fixed

- iOS CI: concrete simulator for tests.
- XCTest `@MainActor` isolation.

## [0.0.1] — 2026-07-02

### Added

- Initial release: floating feedback button, shake (iOS), Mail delivery, metadata, EN/TR templates.
- iOS 17+, macOS 14+, tvOS 17+ (later raised to 17.5 / 14.5).

[0.4.9]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.4.8...v0.4.9
[0.4.8]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.4.7...v0.4.8
[0.4.7]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.4.6...v0.4.7
[0.4.6]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.4.5...v0.4.6
[0.4.5]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.4.4...v0.4.5
[0.4.4]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.4.3...v0.4.4
[0.4.3]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.4.2...v0.4.3
[0.4.2]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.3.3...v0.4.0
[0.3.3]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.1.4...v0.2.0
[0.1.4]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.0.9...v0.1.0
[0.0.9]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.0.8...v0.0.9
[0.0.8]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.0.7...v0.0.8
[0.0.7]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/huseyiniyibas/MeerkatKit/releases/tag/v0.0.1
