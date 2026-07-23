# Satisfaction surveys

Collect like/dislike ratings per screen with a configurable trigger, response callbacks, an optional continuation into the feedback flow, and crash-safe Firebase Analytics events.

## Overview

Attach `meerkatSatisfactionSurvey(screen:trigger:offersFeedback:onResponse:)` to any screen — an image generation result, a chat conversation, a paywall. MeerkatKit presents a compact like/dislike modal according to the trigger you pick:

```swift
ChatView()
    .meerkatFeedback(screen: "Chat")
    .meerkatSatisfactionSurvey(
        screen: "Chat",
        trigger: .afterDwell(.seconds(30)),
        onResponse: { event in
            print("\(event.response) on \(event.screen)")
        }
    )
```

Requires `MeerkatFeedback.bootstrap` (mail, API, or custom variant) once at launch, like the rest of MeerkatKit.

## Triggers

| Trigger | Behavior |
|---|---|
| ``SatisfactionSurveyTrigger/firstView`` | First appearance after the survey is configured (default) |
| ``SatisfactionSurveyTrigger/everyView`` | Every appearance until the user responds |
| ``SatisfactionSurveyTrigger/afterViews(_:)`` | Once the screen has appeared at least *n* times |
| ``SatisfactionSurveyTrigger/afterDwell(_:)`` | After staying on the screen for a duration in one visit |

All triggers stop firing once the user answers. Except for `everyView`, a trigger is also consumed the first time the modal is shown — dismissing without answering does not re-arm it. State is persisted in `UserDefaults` per screen; clear it with:

```swift
MeerkatFeedback.resetSatisfactionSurvey(forScreen: "Chat")
```

## Response flow

1. The modal shows localized **Like** / **Dislike** buttons.
2. On tap, your `onResponse` callback runs and the buttons animate out.
3. With `offersFeedback: true` (default) a **Send feedback** button animates in. Tapping it opens the regular feedback flow — template picker (bug report / feature request / …) and then the form or mail composer, exactly like `MeerkatFeedback.requestFeedback(screen:)`.
4. With `offersFeedback: false` the modal thanks the user and dismisses itself.

## Firebase Analytics events

When the host app links Firebase **and** has called `FirebaseApp.configure()`, MeerkatKit logs these events with a `screen` parameter:

| Event | When |
|---|---|
| `meerkatkit_like` | Like tapped |
| `meerkatkit_dislike` | Dislike tapped |
| `meerkatkit_bugreport` / `meerkatkit_featurerequest` / `meerkatkit_feedback` | Template chosen in a feedback flow started from the survey modal (custom templates log `meerkatkit_<id>`) |

MeerkatKit has **no Firebase dependency**. Firebase is looked up at runtime through the Objective-C runtime; when Firebase is missing or unconfigured (for example, no `GoogleService-Info.plist`), events are skipped silently and nothing crashes.

## See also

- ``SatisfactionSurveyTrigger``
- ``SatisfactionResponse``
- ``SatisfactionSurveyEvent``
- <doc:TimingAndDismiss>
- <doc:EventHandlers>
