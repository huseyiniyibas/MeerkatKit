# MeerkatKit Example

Multi-platform demo for MeerkatKit (iOS, macOS, tvOS, visionOS).

## Open in Xcode

1. Open `Examples/MeerkatKitExample/MeerkatKitExample.xcodeproj`
2. Select the **MeerkatKitExample** scheme and an iOS Simulator (or My Mac / Apple TV)
3. Run

The project links the local MeerkatKit package at the repo root (`../..`).

## What it demonstrates

- API bootstrap (Debug) with offline queue flush and banner result UI
- Mail bootstrap (Release)
- Floating button + shake on Home with per-screen mail override
- Timing: `minimumDwell`, `revealAfter`, `dismissCooldown`
- Custom floating button chip
- Mail delivery screen with per-screen recipients
- Custom delivery integration pattern
- Integrated presentation on Settings
- Custom template (`billing`) in template picker
- Form config: email field + custom field
- Event handlers (`onSubmitted` / `onFailed` / `onCancelled`)
- Screenshot toggle, log provider, crash log path, user identity
- UIKit bar button screen
- AppKit toolbar item (`MeerkatFeedbackAppKit.makeToolbarItem`)

## UIKit

See `Shared/ExampleUIKitView.swift` and README **UIKit integration** section.

```swift
navigationItem.rightBarButtonItem = MeerkatFeedbackUIKit.makeBarButtonItem(screen: "Profile")
```

## AppKit

See `Shared/ExampleAppKitView.swift` for toolbar item integration.

```swift
let item = MeerkatFeedbackAppKit.makeToolbarItem(screen: "Profile")
```
