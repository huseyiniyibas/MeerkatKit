# API Delivery

Post feedback to your backend with offline retry.

## Bootstrap

```swift
MeerkatFeedback.bootstrap(
    api: URL(string: "https://api.yourapp.com/feedback")!,
    headers: ["Authorization": "Bearer token"],
    offlineRetryEnabled: true,
    apiResultPresentation: .alert
)
```

## Result UI

When `apiResultPresentation` is `.alert` (default for API bootstrap) or `.banner`, MeerkatKit shows a native success, offline-queued, or failure message after submission.

Set `apiResultPresentation: .none` to suppress built-in UI and handle outcomes in ``FeedbackEventHandler`` instead.

## Offline queue

Requests that fail for a transient reason — no network, a timeout, HTTP `408` / `425` / `429`, or any `5xx` — are persisted locally when `offlineRetryEnabled` is `true`. Call ``MeerkatFeedback/flushOfflineQueue()`` to retry manually; MeerkatKit also flushes on bootstrap and after the next successful submission.

Permanent rejections (other `4xx` statuses such as `400`, `401`, `404`) are reported as failures right away and are never queued, because sending the same request again cannot succeed.

The queue is stored as a file in Application Support (Caches on tvOS) and keeps at most 50 submissions; the oldest are dropped first. Request headers are stored with each entry, so prefer short-lived tokens in `headers`.

## Per-screen endpoint

Override the API endpoint on specific screens:

```swift
BillingView()
    .meerkatFeedback(
        screen: "Billing",
        apiEndpoint: URL(string: "https://api.yourapp.com/feedback/billing")!
    )
```

UIKit:

```swift
MeerkatFeedback.setAPIEndpoint(
    URL(string: "https://api.yourapp.com/feedback/billing")!,
    forScreen: "Billing"
)
```

Headers and offline retry settings come from bootstrap; only the endpoint URL is overridden per screen.

## Payload

JSON includes `placement`, `template`, `subject`, `body`, `metadata`, optional `userInput`, `userIdentity`, and base64 `attachments`.

## See also

- <doc:EventHandlers>
- <doc:FormConfiguration>
