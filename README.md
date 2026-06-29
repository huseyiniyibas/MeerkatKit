# MeerkatKit

Swift package for collecting in-app feedback on Apple platforms.

Drop in a sticky button or use shake-to-trigger on iPhone and iPad. Feedback is sent through Mail with device metadata in the header. Comes with bug report and feature request templates in English and Turkish.

## Requirements

| | Minimum | Tested |
|---|---|---|
| **iOS / iPadOS** | 17.0 | 17, 18, 26 |
| **macOS** | 14.0 | 14, 15, 26 |
| **tvOS** | 17.0 | 17, 18, 26 |
| **Swift** | 6.0 | 6.0+ |
| **Xcode** | 16.0 | 16 – 26 |

Supports the three most recent major OS releases on each platform. iPadOS uses the same iOS build — no separate package.

Platform notes:

- **iOS / iPadOS** — sticky button, shake-to-trigger, in-app Mail composer (mailto fallback when Mail is unavailable)
- **macOS** — sticky button, mailto delivery
- **tvOS** — sticky button, mailto delivery (shake is not available)

## Installation

In Xcode: **File → Add Package Dependencies** and paste:

```
https://github.com/huseyiniyibas/MeerkatKit.git
```

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/huseyiniyibas/MeerkatKit.git", from: "0.0.1")
]
```

## Usage

Configure once at launch, then attach the overlay to your root view.

```swift
import SwiftUI
import MeerkatKit

@main
struct MyApp: App {
    init() {
        MeerkatFeedback.configure(
            MeerkatConfiguration(
                trigger: .stickyButton(position: .bottomTrailing),
                delivery: .mailComposer(
                    recipients: ["feedback@yourapp.com"],
                    headerMetadata: ["appVersion", "deviceModel", "osVersion"]
                ),
                placement: "HomeScreen",
                templates: [.bugReport, .featureRequest]
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .meerkatFeedbackOverlay()
        }
    }
}
```

### Shake instead of button (iOS only)

```swift
MeerkatConfiguration(
    trigger: .shake,
    delivery: .mailComposer(recipients: ["feedback@yourapp.com"]),
    placement: "Settings"
)
```

### Your own button

```swift
Button("Feedback") {
    MeerkatFeedback.present(from: "Profile")
}
```

## Options

| | |
|---|---|
| `trigger` | `.stickyButton(position:)`, `.shake` (iOS only), `.manual` |
| `delivery` | `.mailComposer(...)` or `.custom { payload in ... }` |
| `placement` | Label for the screen — shows up in the email subject |
| `templates` | `.bugReport`, `.featureRequest`, `.general` |
| `locale` | `.english`, `.turkish`, `.current` |
| `isEnabled` | Turn the whole thing off without removing code |

## License

MIT
