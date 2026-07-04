# UIKit Integration

Use MeerkatKit from UIKit view controllers without SwiftUI modifiers on every screen.

## Bootstrap

Same as SwiftUI — call ``MeerkatFeedback/bootstrap(recipients:appStoreID:)`` once at launch.

## Bar button

```swift
import MeerkatKit

final class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = MeerkatFeedbackUIKit.makeBarButtonItem(screen: "Profile")
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
MeerkatFeedbackUIKit.requestFeedback(screen: "Checkout")
```

## SwiftUI screens in a UIKit app

Attach the modifier on hosting roots:

```swift
let host = UIHostingController(rootView:
    CheckoutView().meerkatFeedback(screen: "Checkout", presentation: .integrated)
)
```

## Attachments and API

UIKit apps can use the same bootstrap options as SwiftUI: ``MeerkatFeedback/bootstrap(api:headers:)``, ``MeerkatFeedback/setUserIdentity(_:)``, ``MeerkatFeedback/setLogProvider(_:)``.
