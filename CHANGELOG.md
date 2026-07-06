# Changelog

All notable changes to MeerkatKit are documented here.  
Package semver (`0.0.x`) is unrelated to iOS/macOS deployment targets.

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
