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

A single template opens the in-app feedback form (message + optional rating) before delivery.

Set `collectUserInput: false` at bootstrap to skip the form and open Mail immediately.

When Mail is unavailable, MeerkatKit falls back to a share sheet (`mailUnavailableFallback: .shareSheet`, default).

## Custom UI

### Custom floating button

```swift
ProfileView()
    .meerkatFeedback(screen: "Profile") { request, dismiss in
        MyChip(onTap: request, onClose: dismiss)
    }
```

### Integrated — your own button

```swift
@Environment(\.meerkatFeedbackRequest) private var requestFeedback

Button("Feedback") { requestFeedback?() }
    .meerkatFeedback(screen: "Settings", presentation: .integrated)
```

Or call ``MeerkatFeedback/requestFeedback(screen:)`` from UIKit actions.

## Custom delivery

```swift
MeerkatFeedback.bootstrap(customDelivery: { payload in
    // POST payload to your backend
})
```

## See also

- <doc:TimingAndDismiss>
- ``MeerkatFeedback``
