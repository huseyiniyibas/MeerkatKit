# Event Handlers

Observe feedback lifecycle events from bootstrap.

```swift
MeerkatFeedback.bootstrap(
    api: endpoint,
    eventHandler: FeedbackEventHandler(
        onAppeared: { event in
            print("Floating feedback appeared on \(event.screen)")
        },
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
| `onAppeared` | Sticky / custom floating control becomes visible (after dwell / reveal, when not suppressed) |
| `onSubmitted` | API success, custom handler invoked, mailto/share opened, or Mail composer sent |
| `onFailed` | API failure (including offline queue when enabled) or mail unavailable |
| `onCancelled` | Template picker or form dismissed without sending |

## Firebase Analytics

When the floating control appears, MeerkatKit also logs `meerkatkit_shown` with a `screen` parameter — if the host app has Firebase Analytics installed and configured. Without Firebase the call is a silent no-op.

## See also

- <doc:APIDelivery>
- <doc:FormConfiguration>
- <doc:TimingAndDismiss>
- <doc:SatisfactionSurveys>
