# MeerkatKit

Swift package for collecting in-app feedback on iOS, iPadOS, macOS, and tvOS.

Floating button, shake-to-trigger, in-app form, Mail / API / custom delivery — with automatic metadata, optional attachments, and per-screen configuration.

**Links:** [Repository](https://github.com/huseyiniyibas/MeerkatKit) · [Releases](https://github.com/huseyiniyibas/MeerkatKit/releases) · [Changelog](CHANGELOG.md) · [Platform policy](PLATFORM_SUPPORT.md) · [License](LICENSE)

## Features

| Area | What you get |
|------|----------------|
| **Triggers** | Sticky floating button, iOS shake, manual `requestFeedback` / `present` |
| **Presentation** | Built-in button, custom floating ViewBuilder, integrated (your own UI) |
| **Delivery** | Mail composer + mailto + share sheet fallback, REST API + offline queue, custom handler |
| **Form** | In-app message + star rating (default on); skip with `collectUserInput: false` |
| **Templates** | Bug / feature / general picker when multiple templates configured; custom templates via ``FeedbackCustomTemplate`` |
| **Form config** | Optional rating, email field, custom fields via ``FeedbackFormConfiguration`` |
| **Callbacks** | ``FeedbackEventHandler`` — submitted / failed / cancelled |
| **API UX** | Success / offline / failure alert or banner (`apiResultPresentation`) |
| **Timing** | `minimumDwell`, `revealAfter`, dismiss cooldown (per screen) |
| **Recipients** | Default at bootstrap; **per-screen mail override** (optional) |
| **API routing** | Default endpoint at bootstrap; **per-screen API endpoint override** (optional) |
| **Identity** | `userId`, `email`, anonymous mode in metadata & API JSON |
| **Attachments** | Screenshot toggle in form, log provider, crash log path |
| **UIKit** | Bar button item + `meerkatRequestFeedback(screen:)` |
| **i18n** | 14 languages for UI labels |

## Requirements

| | Minimum | Tested majors (stable) |
|---|---|---|
| **iOS / iPadOS** | 17.5 | 17, 18, 26 |
| **macOS** | 14.5 | 14, 15, 26 |
| **tvOS** | 17.5 | 17, 18, 26 |
| **Swift** | 6.0 | 6.0+ |
| **Xcode** | 16.0 | 16 – 26 |

See [PLATFORM_SUPPORT.md](PLATFORM_SUPPORT.md) for deployment target policy.

## Platform notes

| Platform | Sticky button | Shake | Mail | Share fallback |
|---|---|---|---|---|
| iOS / iPadOS | Yes | Yes | Composer + mailto | Share sheet |
| macOS | Yes | No | mailto | Sharing picker |
| tvOS | Yes | No | mailto | Console log |

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/huseyiniyibas/MeerkatKit.git", from: "0.1.3")
]
```

## Quick start

**1. Bootstrap once** (launch):

```swift
import MeerkatKit

MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    appStoreID: "1234567890",
    templates: [.bugReport, .featureRequest, .general]
)
```

**2. Attach per screen:**

```swift
SettingsView()
    .meerkatFeedback(screen: "Settings")
```

## Per-screen mail recipients

Default recipients come from bootstrap. Override on specific screens — e.g. billing on Paywall, support on Results:

```swift
MeerkatFeedback.bootstrap(recipients: ["feedback@yourapp.com"])

PaywallView()
    .meerkatFeedback(
        screen: "Paywall",
        mailRecipients: ["billing@yourapp.com", "finance@yourapp.com"]
    )

ResultView()
    .meerkatFeedback(
        screen: "Result",
        mailRecipients: ["results@yourapp.com"]
    )

HomeView()
    .meerkatFeedback(screen: "Home")  // uses bootstrap default
```

**UIKit** (no SwiftUI modifier on that screen):

```swift
MeerkatFeedback.setMailRecipients(["billing@yourapp.com"], forScreen: "Paywall")
MeerkatFeedback.requestFeedback(screen: "Paywall")
```

Pass `nil` to `setMailRecipients` to clear an override. Overrides registered via `.meerkatFeedback(mailRecipients:)` are cleared when the view disappears.

> Per-screen recipients apply to **mail delivery** only. Per-screen `apiEndpoint` applies to **API delivery** only. Custom handlers use their own routing.

## Per-screen API endpoint

```swift
MeerkatFeedback.bootstrap(api: URL(string: "https://api.yourapp.com/feedback")!)

BillingView()
    .meerkatFeedback(
        screen: "Billing",
        apiEndpoint: URL(string: "https://api.yourapp.com/feedback/billing")!
    )
```

**UIKit / AppKit:**

```swift
MeerkatFeedback.setAPIEndpoint(
    URL(string: "https://api.yourapp.com/feedback/billing")!,
    forScreen: "Billing"
)
```

## Timing & dismiss

```swift
HomeView()
    .meerkatFeedback(screen: "Home", minimumDwell: .seconds(8))

ProfileView()
    .meerkatFeedback(screen: "Profile", revealAfter: .seconds(12))

SettingsView()
    .meerkatFeedback(screen: "Settings", dismissCooldown: .seconds(604_800))  // 7 days after ✕
```

| Parameter | Meaning |
|---|---|
| `minimumDwell` | User must stay on screen continuously |
| `revealAfter` | Button may appear after elapsed time since first visit (session) |
| `dismissCooldown` | Hide sticky button after ✕ (`nil` = bootstrap default 24h) |

Shake (`enableShake: true`) hides the sticky button on that screen; dismiss cooldown does not affect shake.

## Template picker & in-app form

Multiple templates → picker sheet → form (default) → delivery.

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    templates: [.bugReport, .featureRequest, .general],
    collectUserInput: true  // default — message + optional 1–5 stars
)
```

Skip the form (legacy immediate mail):

```swift
collectUserInput: false
```

## Mail unavailable fallback

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    mailUnavailableFallback: .shareSheet  // default; or .none
)
```

## Custom button UI

**Custom floating:**

```swift
.meerkatFeedback(screen: "Settings") { request, dismiss in
    MyChip(onTap: request, onClose: dismiss)
}
```

**Integrated** (your own row / toolbar):

```swift
@Environment(\.meerkatFeedbackRequest) private var requestFeedback

Button("Feedback") { requestFeedback?() }
    .meerkatFeedback(screen: "Settings", presentation: .integrated)
```

## REST API delivery

```swift
MeerkatFeedback.bootstrap(
    api: URL(string: "https://api.yourapp.com/feedback")!,
    headers: ["Authorization": "Bearer token"],
    offlineRetryEnabled: true
)

MeerkatFeedback.flushOfflineQueue()  // also runs on bootstrap
```

## User identity

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    userIdentity: FeedbackUserIdentity(userId: "u_123", email: "user@example.com")
)
MeerkatFeedback.setUserIdentity(.anonymous)
```

## Screenshots & logs

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    offerScreenshotInForm: true,
    crashLogPath: "/path/to/last-crash.log"
)
MeerkatFeedback.setLogProvider { MyLogger.recentLines() }
```

## UIKit

```swift
navigationItem.rightBarButtonItem = MeerkatFeedbackUIKit.makeBarButtonItem(screen: "Profile")
meerkatRequestFeedback(screen: "Checkout")
```

See `Sources/MeerkatKit/MeerkatKit.docc/UIKitIntegration.md`.

## AppKit (macOS)

```swift
let item = MeerkatFeedbackAppKit.makeToolbarItem(screen: "Profile")
meerkatRequestFeedback(screen: "Checkout") // NSViewController extension
```

See `Sources/MeerkatKit/MeerkatKit.docc/AppKitIntegration.md`.

## Custom delivery

```swift
MeerkatFeedback.bootstrap(customDelivery: { payload in
    // POST payload to your backend
})
```

## Manual trigger

```swift
MeerkatFeedback.requestFeedback(screen: "Settings")
MeerkatFeedback.present(screen: "Profile", template: .bugReport)
```

## Example app

`Examples/MeerkatKitExample/MeerkatKitExample.xcodeproj` — floating, shake, integrated mode, API bootstrap (Debug).

## Bootstrap reference

| Parameter | Default |
|---|---|
| `recipients` | required for mail bootstrap |
| `appStoreID` | `nil` |
| `templates` | `[.general]` |
| `locale` | `.current` |
| `buttonPosition` | `.bottomTrailing` |
| `enableShake` | `false` (global; per-screen via modifier) |
| `isEnabled` | `true` |
| `dismissCooldown` | 24 hours |
| `collectUserInput` | `true` |
| `mailUnavailableFallback` | `.shareSheet` |
| `offerScreenshotInForm` | `false` (mail) / `true` (API bootstrap) |
| `userIdentity` | `.anonymous` |

## Modifier reference

| Parameter | Default |
|---|---|
| `mailRecipients` | `nil` (bootstrap default) |
| `apiEndpoint` | `nil` (bootstrap default) |
| `minimumDwell` | `nil` |
| `revealAfter` | `nil` |
| `enableShake` | `false` |
| `dismissCooldown` | `nil` |
| `presentation` | `.floating` |

## Supported UI languages

English, Turkish, Spanish, French, German, Japanese, Italian, Portuguese, Russian, Korean, Chinese (Simplified & Traditional), Dutch, Arabic. Unknown locales fall back to English.

## License

[MIT](LICENSE)
