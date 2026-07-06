# Custom Templates

Use built-in categories or define your own.

## Built-in

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    templates: [.bugReport, .featureRequest, .general]
)
```

## Custom

```swift
let billing = FeedbackCustomTemplate(
    id: "billing",
    title: "Billing issue",
    subject: "Billing issue",
    bodyPrefix: "Describe the billing problem:\n\n",
    systemImage: "creditcard.fill"
)

MeerkatFeedback.bootstrap(
    recipients: ["billing@yourapp.com"],
    templates: [.bugReport, .custom(billing)]
)
```

Custom templates use developer-provided strings (not localized by MeerkatKit). The `id` is sent in API payloads as `template`.

## See also

- <doc:GettingStarted>
- <doc:FormConfiguration>
