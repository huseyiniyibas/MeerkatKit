# Satisfaction surveys

Collect a 1–5 star rating per screen with a configurable trigger. High ratings go to the public App Store review; low ratings stay private as in-app feedback.

## Overview

Attach `meerkatSatisfactionSurvey(screen:trigger:offersFeedback:onResponse:)` to any screen — an image generation result, a chat conversation, a paywall. MeerkatKit presents a compact star-rating modal according to the trigger you pick:

```swift
ChatView()
    .meerkatFeedback(screen: "Chat")
    .meerkatSatisfactionSurvey(
        screen: "Chat",
        trigger: .afterDwell(.seconds(30)),
        onResponse: { event in
            print("\(event.starRating) stars on \(event.screen)")
        }
    )
```

Requires `MeerkatFeedback.bootstrap` (mail, API, or custom variant) once at launch, like the rest of MeerkatKit. Pass `appStoreID` at bootstrap so 4–5 star ratings open the App Store write-review page.

## Triggers

| Trigger | Behavior |
|---|---|
| ``SatisfactionSurveyTrigger/firstView`` | First appearance after the survey is configured (default) |
| ``SatisfactionSurveyTrigger/everyView`` | Every appearance until the user responds |
| ``SatisfactionSurveyTrigger/afterViews(_:)`` | Once the screen has appeared at least *n* times |
| ``SatisfactionSurveyTrigger/everyNthView(_:)`` | Every *n*-th appearance (10, 20, 30…), including after a previous response |
| ``SatisfactionSurveyTrigger/afterDwell(_:)`` | After staying on the screen for a duration in one visit |

Most triggers stop firing once the user answers. `everyNthView` keeps sampling on each *n*-th visit. Except for `everyView` and `everyNthView`, a one-shot trigger is also consumed the first time the modal is shown — dismissing without answering does not re-arm it. State is persisted in `UserDefaults` per screen; clear it with:

```swift
MeerkatFeedback.resetSatisfactionSurvey(forScreen: "Chat")
```

## Response flow

1. The modal asks **How would you rate [App Name]?** with five tappable stars and **Not now**.
2. **4–5 stars** → “Awesome, thank you!” and a **Rate on the App Store** button. That CTA opens `https://apps.apple.com/app/id{id}?action=write-review` when `appStoreID` was set at bootstrap; otherwise it falls back to `SKStoreReviewController`. **Maybe later** dismisses without leaving the app.
3. **1–3 stars** → “Sorry to hear that” with a private text field. **Send feedback** submits through the regular MeerkatKit delivery path (mail / API / custom) — not the App Store. **Skip** dismisses.
4. `onResponse` runs as soon as a star is tapped. ``SatisfactionSurveyEvent/starRating`` is 1…5; ``SatisfactionSurveyEvent/response`` is ``SatisfactionResponse/like`` for 4–5 and ``dislike`` for 1–3.

With `offersFeedback: false`, the 1–3 star path skips the text field and auto-dismisses after a short thank-you.

Disable every survey without removing modifiers (Remote Config):

```swift
MeerkatFeedback.setSatisfactionSurveysEnabled(remoteConfig.bool(forKey: "meerkat_surveys"))
```

You do **not** need `.meerkatFeedback` on the same screen for the low-star submission to work.

## Firebase Analytics events

When the host app links Firebase **and** has called `FirebaseApp.configure()`, MeerkatKit logs these events with a `screen` parameter:

| Event | When |
|---|---|
| `meerkatkit_shown` | Sticky / custom floating feedback control becomes visible |
| `meerkatkit_like` | 4–5 stars tapped (`star_rating` is 4 or 5) |
| `meerkatkit_dislike` | 1–3 stars tapped (`star_rating` is 1, 2, or 3) |
| `meerkatkit_bugreport` / `meerkatkit_featurerequest` / `meerkatkit_feedback` | Template chosen in a feedback flow started from the survey modal (custom templates log `meerkatkit_<id>`) |

MeerkatKit has **no Firebase dependency**. Firebase is looked up at runtime through the Objective-C runtime; when Firebase is missing or unconfigured (for example, no `GoogleService-Info.plist`), events are skipped silently and nothing crashes.

## See also

- ``SatisfactionSurveyTrigger``
- ``SatisfactionResponse``
- ``SatisfactionSurveyEvent``
- <doc:TimingAndDismiss>
- <doc:EventHandlers>
