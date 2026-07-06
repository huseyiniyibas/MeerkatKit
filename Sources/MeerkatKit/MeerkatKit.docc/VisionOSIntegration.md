# visionOS Integration

MeerkatKit supports visionOS with the same SwiftUI-first integration as iOS.

## Bootstrap & modifier

```swift
MeerkatFeedback.bootstrap(
    api: URL(string: "https://api.yourapp.com/feedback")!,
    apiResultPresentation: .banner
)

ContentView()
    .meerkatFeedback(screen: "Home")
```

## Platform behavior

| Feature | visionOS |
|---------|----------|
| Floating button | Yes |
| Shake | No |
| In-app form | Yes (sheet) |
| Mail composer | No — uses mailto |
| Share fallback | Yes (share sheet) |
| API delivery | Yes |
| Screenshot toggle | Yes (window capture when available) |
| UIKit bar button | Yes |

## Delivery

Mail bootstrap opens the default mail app via `mailto:` when available, then falls back to the share sheet — same pattern as macOS/tvOS.

API bootstrap is the recommended path on visionOS when you control a backend.

## UIKit

```swift
navigationItem.rightBarButtonItem = MeerkatFeedbackUIKit.makeBarButtonItem(screen: "Profile")
```

## See also

- <doc:PlatformLimits>
- <doc:APIDelivery>
- <doc:UIKitIntegration>
- <doc:FormConfiguration>
