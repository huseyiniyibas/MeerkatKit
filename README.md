# MeerkatKit

Swift package for collecting in-app feedback on Apple platforms.

Drop in a floating feedback button per screen, or use shake-to-trigger on iOS. Feedback is delivered through Mail (with mailto fallback) or a custom handler. Device and app metadata are included automatically.

**Links:** [Repository](https://github.com/huseyiniyibas/MeerkatKit) · [Releases](https://github.com/huseyiniyibas/MeerkatKit/releases) · [Changelog](CHANGELOG.md) · [Platform policy](PLATFORM_SUPPORT.md) · [License](LICENSE)

## Requirements

| | Minimum | Tested majors (stable) |
|---|---|---|
| **iOS / iPadOS** | 17.5 | 17, 18, 26 |
| **macOS** | 14.5 | 14, 15, 26 |
| **tvOS** | 17.5 | 17, 18, 26 |
| **Swift** | 6.0 | 6.0+ |
| **Xcode** | 16.0 | 16 – 26 |

See [PLATFORM_SUPPORT.md](PLATFORM_SUPPORT.md) for the full deployment target policy.

## Deployment policy

- We support the latest **3 stable major** OS versions (betas excluded).
- Minimum deployment follows: `oldestSupportedMajor.latestStableMinor`
- Example: latest stable iOS `26.5.x` → minimum iOS `17.5`
- When Apple ships `26.6` stable → minimum iOS becomes `17.6`
- Package semver (`0.0.x`) is unrelated to deployment targets

### Updating minimum OS versions (the sync script)

When Apple releases a new **stable** iOS/macOS/tvOS version, you only update one file:
[`scripts/platform-targets.json`](scripts/platform-targets.json) (set `latestStable` and adjust `supportedMajors` if a major is dropped).

Then run:

```bash
node scripts/sync-platform-targets.mjs
```

**What it does in plain terms:** reads that JSON and rewrites the `platforms:` block in `Package.swift` automatically — so you don't hand-edit three version strings. It applies the rule *“oldest supported major + latest stable minor”* (e.g. iOS 26.5 stable → min iOS **17.5**).

You still commit the changed `Package.swift` + JSON yourself; the script does not tag releases or touch the README table.

## Platform notes

| Platform | Sticky button | Shake | Delivery |
|---|---|---|---|
| iOS / iPadOS | Yes | Yes | Mail composer + mailto fallback |
| macOS | Yes | No | mailto |
| tvOS | Yes | No | mailto |

iPadOS uses the same iOS build — no separate package.

## Installation

In Xcode: **File → Add Package Dependencies**, then paste:

**[https://github.com/huseyiniyibas/MeerkatKit.git](https://github.com/huseyiniyibas/MeerkatKit.git)**

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/huseyiniyibas/MeerkatKit.git", from: "0.1.0")
]
```

## Usage

**1. Once at app launch** — recipients and metadata (`AppDelegate` or `App` init):

```swift
import MeerkatKit

MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    appStoreID: "1234567890"
)
```

**2. Per screen** — add the modifier with a screen name:

```swift
SettingsView()
    .meerkatFeedback(screen: "Settings")
```

Show the button only after the user stays on the screen for a while (optional):

```swift
HomeView()
    .meerkatFeedback(screen: "Home", minimumDwell: .seconds(8))
```

Or reveal on a fixed schedule after the screen appears:

```swift
ProfileView()
    .meerkatFeedback(screen: "Profile", revealAfter: .seconds(12))
```

Both can be combined — whichever completes first shows the button:

```swift
CheckoutView()
    .meerkatFeedback(screen: "Checkout", minimumDwell: .seconds(20), revealAfter: .seconds(8))
```

| Parameter | Meaning |
|---|---|
| `minimumDwell` | User must **stay on this screen continuously** for this long. Leave → timer resets. |
| `revealAfter` | Button may appear after this much time since the screen was **first opened in the session**, even if the user navigates away in between. |
| `dismissCooldown` | After the user taps **✕**, the sticky button stays hidden on that screen for this long. `nil` = bootstrap default (24h). `.zero` = current visit only. |

Hide the sticky button for 24 hours after dismiss (default):

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    dismissCooldown: .seconds(86_400)  // 24 hours — this is the default
)

SettingsView()
    .meerkatFeedback(screen: "Settings")
```

Per-screen override, or hide only until the user leaves:

```swift
SettingsView()
    .meerkatFeedback(screen: "Settings", dismissCooldown: .seconds(604_800))  // 7 days

DebugView()
    .meerkatFeedback(screen: "Debug", dismissCooldown: .zero)  // ✕ hides until next appear only
```

Dismiss cooldown applies to the **sticky button only** — shake-to-feedback is unaffected.

### Template picker

Pass multiple templates at bootstrap — users pick before Mail opens:

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    templates: [.bugReport, .featureRequest, .general]
)
```

With a single template, feedback opens the in-app form (or Mail directly when `collectUserInput: false`).

### In-app feedback form

By default users fill a short form (message + optional star rating) before Mail or custom delivery:

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    collectUserInput: true  // default
)
```

Disable for legacy immediate-mail behaviour:

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    collectUserInput: false
)
```

### Mail unavailable fallback

When Mail is not configured or mailto cannot open, MeerkatKit shows a **share sheet** with the formatted feedback text (default). Override at bootstrap:

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    mailUnavailableFallback: .shareSheet  // or .none
)
```

### Custom button UI

**Your own floating control** — replace the built-in sticky button:

```swift
SettingsView()
    .meerkatFeedback(screen: "Settings") { request, dismiss in
        MyFeedbackChip(onTap: request, onClose: dismiss)
    }
```

**Your own in-screen button** — no floating UI; wire an existing row or toolbar item:

```swift
struct SettingsView: View {
    @Environment(\.meerkatFeedbackRequest) private var requestFeedback

    var body: some View {
        List {
            Button("Send Feedback") { requestFeedback?() }
        }
        .meerkatFeedback(screen: "Settings", presentation: .integrated)
    }
}
```

From UIKit or anywhere else on the same screen:

```swift
MeerkatFeedback.requestFeedback(screen: "Settings")
```

`requestFeedback` runs the template picker (if configured), in-app form, then delivery.

### REST API delivery

Post JSON to your backend instead of Mail:

```swift
MeerkatFeedback.bootstrap(
    api: URL(string: "https://api.yourapp.com/feedback")!,
    headers: ["Authorization": "Bearer token"],
    offlineRetryEnabled: true
)
```

Failed submissions are queued locally and retried via ``MeerkatFeedback/flushOfflineQueue()``.

### User identity

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    userIdentity: FeedbackUserIdentity(userId: "u_123", email: "user@example.com")
)

// or anonymous
MeerkatFeedback.setUserIdentity(.anonymous)
```

### Screenshots & logs

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    offerScreenshotInForm: true,
    crashLogPath: "/path/to/last-crash.log"
)
MeerkatFeedback.setLogProvider { MyLogger.recentLines() }
```

Attachments are included in Mail, share sheet text context, and API JSON (`attachments[].dataBase64`).

### UIKit integration

```swift
navigationItem.rightBarButtonItem = MeerkatFeedbackUIKit.makeBarButtonItem(screen: "Profile")
// or
meerkatRequestFeedback(screen: "Checkout")
```

See `MeerkatKit.docc/UIKitIntegration.md`.

### Example app

Open `Examples/MeerkatKitExample/MeerkatKitExample.xcodeproj` — demonstrates floating, shake, integrated mode, and API bootstrap (Debug).

### API documentation (DocC)

Open the package in Xcode → **Product → Build Documentation**, or browse `Sources/MeerkatKit/MeerkatKit.docc/` (Getting Started, timing & dismiss).

### AppDelegate example

```swift
import MeerkatKit

func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    MeerkatFeedback.bootstrap(
        recipients: ["feedback@yourapp.com"],
        appStoreID: "1234567890"
    )
    return true
}
```

### Mail body format

The default mail body includes localized labels and a typing area:

```
App: YourApp
Version: 1.2.0 (42)
Screen: Settings
Device: iPhone 17 Pro
OS: iOS 26.5.2
App Store ID: 1234567890

Please type your feedback below:
========================================



```

### Supported UI languages

- English (`en`)
- Turkish (`tr`)
- Spanish (`es`)
- French (`fr`)
- German (`de`)
- Japanese (`ja`)
- Italian (`it`)
- Portuguese (`pt`) — covers `pt-BR`
- Russian (`ru`)
- Korean (`ko`)
- Chinese Simplified (`zh-Hans`)
- Chinese Traditional (`zh-Hant`)
- Dutch (`nl`)
- Arabic (`ar`)

Fallback: region-specific locales map to base language (e.g. `pt-BR` → `pt`); unknown locales fall back to English.

| Parameter | Default |
|---|---|
| `minimumDwell` | `nil` (show immediately) |
| `revealAfter` | `nil` (show immediately) |
| `enableShake` | `false` (iOS shake on this screen; hides sticky button here) |
| `dismissCooldown` | `nil` (uses bootstrap default) |

See the table under **Usage** for what each timing parameter means.

### Optional bootstrap settings

| Parameter | Default |
|---|---|
| `appStoreID` | `nil` |
| `headerMetadata` | app name, version, device, OS |
| `footerMetadata` | `[]` |
| `templates` | `.general` |
| `locale` | `.current` (follows device language) |
| `buttonPosition` | `.bottomTrailing` |
| `enableShake` | `false` |
| `isEnabled` | `true` |
| `dismissCooldown` | 24 hours (`.seconds(86_400)`) — sticky button hidden after ✕ until this elapses (per screen). Pass `.zero` to hide for the current visit only. |

### Custom delivery

```swift
MeerkatFeedback.bootstrap(customDelivery: { payload in
    // send payload to your backend
})
```

### Manual trigger

```swift
MeerkatFeedback.present(screen: "Profile", template: .bugReport)
```

## License

[MIT](LICENSE)
