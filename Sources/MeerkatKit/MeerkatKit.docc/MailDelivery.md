# Mail Delivery

Send feedback through the system Mail composer on iOS, or via `mailto:` and share fallback on other platforms.

## Bootstrap

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    appStoreID: "1234567890",
    templates: [.bugReport, .featureRequest, .general],
    mailUnavailableFallback: .shareSheet  // default
)
```

## Delivery flow

1. User completes the in-app form (unless `collectUserInput: false`).
2. MeerkatKit builds a ``FeedbackPayload`` with metadata and attachments.
3. **iOS** — presents `MFMailComposeViewController` when Mail is configured.
4. **Other platforms** — opens a `mailto:` URL, then falls back if needed.

## Mail unavailable fallback

When the Mail composer is unavailable (iOS) or `mailto:` cannot open (macOS / tvOS / visionOS):

| `mailUnavailableFallback` | Behavior |
|---|---|
| `.shareSheet` (default) | Platform share fallback — see <doc:PlatformLimits> |
| `.none` | Logs a message and reports failure via ``FeedbackEventHandler`` |

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    mailUnavailableFallback: .none
)
```

## Per-screen recipients

Override recipients on specific screens. Mail bootstrap only — API endpoints use `apiEndpoint` instead.

```swift
PaywallView()
    .meerkatFeedback(
        screen: "Paywall",
        mailRecipients: ["billing@yourapp.com"]
    )
```

UIKit:

```swift
MeerkatFeedback.setMailRecipients(["billing@yourapp.com"], forScreen: "Paywall")
MeerkatFeedback.requestFeedback(screen: "Paywall")
```

Pass `nil` to clear an override. Overrides from `.meerkatFeedback(mailRecipients:)` are cleared when the view disappears.

## Skip the form

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    collectUserInput: false
)
```

Opens Mail (or fallback) immediately after template selection.

## See also

- <doc:PlatformLimits>
- <doc:PerScreenConfiguration>
- <doc:AttachmentsAndIdentity>
- ``MeerkatFeedback``
