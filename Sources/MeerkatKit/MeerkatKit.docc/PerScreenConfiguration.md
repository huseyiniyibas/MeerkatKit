# Per-Screen Configuration

Override mail recipients, API endpoints, timing, shake, and presentation per screen.

## Mail recipients

Default recipients come from bootstrap. Override on billing, support, or results screens:

```swift
MeerkatFeedback.bootstrap(recipients: ["feedback@yourapp.com"])

PaywallView()
    .meerkatFeedback(
        screen: "Paywall",
        mailRecipients: ["billing@yourapp.com", "finance@yourapp.com"]
    )

HomeView()
    .meerkatFeedback(screen: "Home")  // bootstrap default
```

**Mail bootstrap only.** API delivery ignores `mailRecipients`.

UIKit / AppKit:

```swift
MeerkatFeedback.setMailRecipients(["billing@yourapp.com"], forScreen: "Paywall")
MeerkatFeedback.setMailRecipients(nil, forScreen: "Paywall")  // clear
```

## API endpoint

```swift
MeerkatFeedback.bootstrap(api: URL(string: "https://api.yourapp.com/feedback")!)

BillingView()
    .meerkatFeedback(
        screen: "Billing",
        apiEndpoint: URL(string: "https://api.yourapp.com/feedback/billing")!
    )
```

**API bootstrap only.**

```swift
MeerkatFeedback.setAPIEndpoint(
    URL(string: "https://api.yourapp.com/feedback/billing")!,
    forScreen: "Billing"
)
```

## Timing and shake

```swift
HomeView()
    .meerkatFeedback(
        screen: "Home",
        minimumDwell: .seconds(8),
        revealAfter: .seconds(12),
        enableShake: true,
        dismissCooldown: .seconds(604_800)
    )
```

See <doc:TimingAndDismiss> for parameter details.

## Presentation modes

| Mode | Use when |
|---|---|
| `.floating` (default) | Sticky button or custom floating ViewBuilder |
| `.integrated` | Your own button via `@Environment(\.meerkatFeedbackRequest)` |

```swift
@Environment(\.meerkatFeedbackRequest) private var requestFeedback

Button("Feedback") { requestFeedback?() }
    .meerkatFeedback(screen: "Settings", presentation: .integrated)
```

## Custom floating button

```swift
ProfileView()
    .meerkatFeedback(screen: "Profile") { request, dismiss in
        MyChip(onTap: request, onClose: dismiss)
    }
```

## Registry lifecycle

Overrides registered through `.meerkatFeedback(mailRecipients:)` or `.meerkatFeedback(apiEndpoint:)` are cleared when the view disappears. Programmatic overrides via `setMailRecipients` / `setAPIEndpoint` persist until cleared.

## See also

- <doc:MailDelivery>
- <doc:APIDelivery>
- <doc:TimingAndDismiss>
- <doc:PlatformLimits>
