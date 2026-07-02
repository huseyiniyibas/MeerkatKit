# MeerkatKit

Swift package for collecting in-app feedback on Apple platforms.

Drop in a floating feedback button per screen, or use shake-to-trigger on iOS. Feedback is delivered through Mail (with mailto fallback) or a custom handler. Device and app metadata are included automatically.

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

To sync targets after a new stable OS release:

```bash
node scripts/sync-platform-targets.mjs
```

## Platform notes

| Platform | Sticky button | Shake | Delivery |
|---|---|---|---|
| iOS / iPadOS | Yes | Yes | Mail composer + mailto fallback |
| macOS | Yes | No | mailto |
| tvOS | Yes | No | mailto |

iPadOS uses the same iOS build — no separate package.

## Installation

In Xcode: **File → Add Package Dependencies**

```
https://github.com/huseyiniyibas/MeerkatKit.git
```

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/huseyiniyibas/MeerkatKit.git", from: "0.0.4")
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

That is the full integration for the default floating button.

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

MIT
