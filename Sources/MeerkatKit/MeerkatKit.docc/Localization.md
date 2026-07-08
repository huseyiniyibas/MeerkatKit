# Localization

MeerkatKit localizes in-app UI labels (form, picker, alerts) across 14 languages.

## Supported languages

English, Turkish, Spanish, French, German, Japanese, Italian, Portuguese, Russian, Korean, Chinese (Simplified), Chinese (Traditional), Dutch, and Arabic.

Unknown or unsupported locales fall back to English.

## Configure locale

Set at bootstrap:

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    locale: .turkish
)
```

Use `.current` (default) to match the device language when a translation exists.

## What is localized

- Feedback form labels (message, rating, email, submit)
- Template picker title and cancel button
- API result alerts and banners
- Share fallback recipient label

All 14 supported languages include form, picker, email field, and API result strings. Unknown locales fall back to English.

Template titles and email subjects come from your ``FeedbackTemplate`` or ``FeedbackCustomTemplate`` configuration — those are **not** auto-translated.

## Custom templates

Provide localized titles yourself:

```swift
let template = FeedbackCustomTemplate(
    id: "billing",
    title: NSLocalizedString("Billing issue", comment: ""),
    subject: "Billing issue",
    bodyPrefix: "Describe the problem:\n\n"
)
```

## See also

- <doc:CustomTemplates>
- <doc:FormConfiguration>
- ``FeedbackLocale``
