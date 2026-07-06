# Attachments and Identity

Attach screenshots, logs, and crash reports. Include user identity in metadata and API payloads.

## Screenshots

Enable the screenshot toggle in the feedback form:

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    offerScreenshotInForm: true
)
```

When the user opts in, MeerkatKit captures the current window or screen where supported. Screenshot availability varies by platform — see <doc:PlatformLimits>.

## Log provider

Attach recent log lines from your logging system:

```swift
MeerkatFeedback.setLogProvider {
    MyLogger.recentLines().joined(separator: "\n")
}
```

The provider is called at submission time. Return `nil` or an empty string to omit the attachment.

## Crash log path

Attach a crash log file from a known path:

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    crashLogPath: "/path/to/last-crash.log"
)
```

The file is read at submission time. Missing or unreadable files are skipped silently.

## User identity

Include user context in metadata and API JSON:

```swift
MeerkatFeedback.bootstrap(
    api: URL(string: "https://api.yourapp.com/feedback")!,
    userIdentity: FeedbackUserIdentity(
        userId: "u_123",
        email: "user@example.com"
    )
)
```

Update at runtime:

```swift
MeerkatFeedback.setUserIdentity(.anonymous)
MeerkatFeedback.setUserIdentity(FeedbackUserIdentity(userId: "u_456"))
```

Anonymous mode omits identity fields from the API payload. Non-anonymous identity is included in email body metadata.

## API vs mail

| Field | Mail body | API JSON |
|---|---|---|
| `userId` | Metadata section | `userId` field |
| `email` | Metadata section | `email` field |
| Screenshot | Attachment | Base64 in JSON |
| Log provider output | Attachment | Base64 in JSON |
| Crash log | Attachment | Base64 in JSON |

## See also

- <doc:APIDelivery>
- <doc:MailDelivery>
- ``FeedbackUserIdentity``
- ``MeerkatFeedback``
