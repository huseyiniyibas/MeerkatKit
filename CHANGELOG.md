# Changelog

All notable changes to MeerkatKit are documented here.  
Package semver (`0.0.x`) is unrelated to iOS/macOS deployment targets.

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

[0.0.8]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.0.7...v0.0.8
[0.0.7]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/huseyiniyibas/MeerkatKit/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/huseyiniyibas/MeerkatKit/releases/tag/v0.0.1
