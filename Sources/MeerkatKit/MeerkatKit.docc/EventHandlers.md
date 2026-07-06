# Event Handlers

Observe feedback lifecycle events from bootstrap.

```swift
MeerkatFeedback.bootstrap(
    api: endpoint,
    eventHandler: FeedbackEventHandler(
        onSubmitted: { event in
            print("Submitted on \(event.screen) via \(event.channel)")
        },
        onFailed: { event in
            print("Failed: \(event.error), queued=\(event.queuedOffline)")
        },
        onCancelled: { event in
            print("Cancelled at \(event.stage)")
        }
    )
)
```

## Events

| Callback | When |
|---|---|
| `onSubmitted` | API success, custom handler invoked, mailto/share opened, or Mail composer sent |
| `onFailed` | API failure (including offline queue when enabled) or mail unavailable |
| `onCancelled` | Template picker or form dismissed without sending |

## See also

- <doc:APIDelivery>
- <doc:FormConfiguration>
