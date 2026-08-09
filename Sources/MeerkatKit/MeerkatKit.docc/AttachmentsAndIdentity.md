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

When the user opts in, MeerkatKit:

1. Dismisses the feedback form
2. Temporarily hides MeerkatKit chrome (floating button / banners)
3. Captures the host app window
4. Attaches `screenshot.png` to mail or API delivery

On **iOS / iPadOS / visionOS**, taking a **system screenshot** while MeerkatKit is enabled with screenshot offering also opens the feedback flow for the active screen. MeerkatKit hides itself first, captures a clean screenshot, and pre-checks **Include screenshot** in the form.

Screenshot availability varies by platform — see <doc:PlatformLimits>.

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
