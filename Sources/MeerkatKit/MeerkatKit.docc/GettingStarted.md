# Getting Started

Bootstrap once, then attach the modifier per screen.

## Bootstrap

```swift
import MeerkatKit

MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    appStoreID: "1234567890",
    templates: [.bugReport, .featureRequest, .general]
)
```

## Per screen

```swift
SettingsView()
    .meerkatFeedback(screen: "Settings")
```

## Template picker

When you pass **more than one** ``FeedbackTemplate`` at bootstrap, tapping the feedback button (or shaking on iOS) opens a picker sheet before Mail or your custom handler runs.

A single template skips the picker and opens feedback immediately.

## Custom delivery

```swift
MeerkatFeedback.bootstrap(customDelivery: { payload in
    // POST payload to your backend
})
```

## See also

- <doc:TimingAndDismiss>
- ``MeerkatFeedback``
