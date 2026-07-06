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

Failed requests are persisted locally when `offlineRetryEnabled` is `true`. Call ``MeerkatFeedback/flushOfflineQueue()`` to retry manually; bootstrap also flushes automatically.

## Payload

JSON includes `placement`, `template`, `subject`, `body`, `metadata`, optional `userInput`, `userIdentity`, and base64 `attachments`.

## See also

- <doc:EventHandlers>
- <doc:FormConfiguration>
