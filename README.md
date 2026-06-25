# MeerkatKit

Swift package for collecting in-app feedback on iOS.

Drop in a sticky button or use shake-to-trigger. Feedback is sent through Mail with device metadata in the header. Comes with bug report and feature request templates in English and Turkish.

## Requirements

- iOS 15+
- Swift 5.9+
- Xcode 15+

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

### Shake instead of button

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
| `trigger` | `.stickyButton(position:)`, `.shake`, `.manual` |
| `delivery` | `.mailComposer(...)` or `.custom { payload in ... }` |
| `placement` | Label for the screen — shows up in the email subject |
| `templates` | `.bugReport`, `.featureRequest`, `.general` |
| `locale` | `.english`, `.turkish`, `.current` |
| `isEnabled` | Turn the whole thing off without removing code |

## License

MIT
