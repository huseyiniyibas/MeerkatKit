# MeerkatKit Example

Multi-platform demo for MeerkatKit (iOS, macOS, tvOS).

## Open in Xcode

1. Open `Examples/MeerkatKitExample/MeerkatKitExample.xcodeproj`
2. Select the **MeerkatKitExample** scheme and an iOS Simulator (or My Mac / Apple TV)
3. Run

The project links the local MeerkatKit package at the repo root (`../..`).

## What it demonstrates

- API bootstrap (Debug) with offline queue flush
- Mail bootstrap (Release)
- Floating button + shake on Home
- Integrated presentation on Settings
- Screenshot toggle, log provider, user identity

## UIKit

See `Sources/MeerkatKit/MeerkatFeedbackUIKit.swift` and README **UIKit integration** section.

```swift
navigationItem.rightBarButtonItem = MeerkatFeedbackUIKit.makeBarButtonItem(screen: "Profile")
```
