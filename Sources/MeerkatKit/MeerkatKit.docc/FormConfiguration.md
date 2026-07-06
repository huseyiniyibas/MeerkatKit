# Form Configuration

Customize the in-app feedback form.

## Rating

Disable the star rating row:

```swift
MeerkatFeedback.bootstrap(
    api: endpoint,
    formConfiguration: FeedbackFormConfiguration(collectRating: false)
)
```

## Email

Collect the user's email in the form (merged into metadata and API payloads):

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    formConfiguration: FeedbackFormConfiguration(collectEmail: true)
)
```

## Custom fields

Add extra text fields:

```swift
let formConfiguration = FeedbackFormConfiguration(
    customFields: [
        FeedbackCustomField(
            id: "orderId",
            label: "Order ID",
            placeholder: "Optional",
            isRequired: false
        )
    ]
)
```

Values appear in mail bodies, metadata, and API `userInput.customFields`.

## See also

- <doc:CustomTemplates>
- <doc:EventHandlers>
