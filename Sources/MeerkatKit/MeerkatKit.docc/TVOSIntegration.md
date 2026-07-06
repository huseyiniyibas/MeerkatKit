# tvOS Integration

MeerkatKit supports tvOS with the same SwiftUI modifier and API delivery as other platforms.

## Bootstrap & modifier

```swift
MeerkatFeedback.bootstrap(
    api: URL(string: "https://api.yourapp.com/feedback")!,
    apiResultPresentation: .banner
)

ContentView()
    .meerkatFeedback(screen: "Home")
```

API bootstrap is recommended on tvOS — there is no Mail composer and `mailto:` may not be available on all devices.

## Platform behavior

| Feature | tvOS |
|---|---|
| Floating button | Yes |
| Shake | No |
| In-app form | Yes (`TextField` for message) |
| Mail composer | No — uses `mailto:` |
| Share fallback | Console log |
| API delivery | Yes |
| UIKit bar button | Yes |

See the full matrix in <doc:PlatformLimits>.

## Mail bootstrap on tvOS

When using mail bootstrap:

1. MeerkatKit attempts `mailto:`.
2. If that fails, the share fallback logs feedback text to the console (`mailUnavailableFallback: .shareSheet`, default).
3. Set `mailUnavailableFallback: .none` to suppress the console fallback.

## Focus and remote

The sticky button and in-app form work with Siri Remote focus. Use `.integrated` presentation when you provide your own focusable feedback control:

```swift
Button("Send Feedback") {
    MeerkatFeedback.requestFeedback(screen: "Settings")
}
.meerkatFeedback(screen: "Settings", presentation: .integrated)
```

## UIKit

```swift
navigationItem.rightBarButtonItem = MeerkatFeedbackUIKit.makeBarButtonItem(screen: "Profile")
```

## See also

- <doc:PlatformLimits>
- <doc:APIDelivery>
- <doc:UIKitIntegration>
