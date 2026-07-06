# AppKit Integration

Use MeerkatKit from AppKit view controllers on macOS.

## Bootstrap

Same as SwiftUI — call ``MeerkatFeedback/bootstrap(recipients:appStoreID:)`` or ``MeerkatFeedback/bootstrap(api:headers:)`` once at launch.

## Toolbar item

```swift
import MeerkatKit

final class ProfileViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let item = MeerkatFeedbackAppKit.makeToolbarItem(screen: "Profile")
        // Add item to your NSToolbar in the window controller or toolbar delegate.
    }
}
```

## Any control

```swift
@objc private func feedbackTapped() {
    meerkatRequestFeedback(screen: "Checkout")
}
```

Or without a view controller extension:

```swift
MeerkatFeedbackAppKit.requestFeedback(screen: "Checkout")
```

## Per-screen API endpoint

```swift
MeerkatFeedback.setAPIEndpoint(
    URL(string: "https://api.yourapp.com/feedback/billing")!,
    forScreen: "Billing"
)
```

## See also

- <doc:UIKitIntegration>
- <doc:APIDelivery>
