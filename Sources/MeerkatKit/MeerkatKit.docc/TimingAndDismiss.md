# Timing and dismiss behavior

Control **when** the sticky button appears and **how long** it stays hidden after the user dismisses it.

## Visibility timing

| Modifier parameter | Behavior |
|---|---|
| `minimumDwell` | User must stay on the screen continuously for this duration. Leaving resets the timer. |
| `revealAfter` | Button may appear after this time since the screen was first opened in the app session. |

```swift
HomeView()
    .meerkatFeedback(screen: "Home", minimumDwell: .seconds(8))

ProfileView()
    .meerkatFeedback(screen: "Profile", revealAfter: .seconds(12))
```

## Dismiss cooldown

After the user taps **✕**, the sticky button is hidden for a configurable period (per screen, persisted in `UserDefaults`).

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@example.com"],
    dismissCooldown: .seconds(86_400)  // 24 hours (default)
)

SettingsView()
    .meerkatFeedback(screen: "Settings", dismissCooldown: .zero)  // current visit only
```

Shake-to-feedback is not affected by dismiss cooldown.

## Per-screen shake

```swift
HomeView()
    .meerkatFeedback(screen: "Home", enableShake: true)
```

Hides the sticky button on that screen; shake opens the template picker or feedback flow on iOS.

## See also

- ``MeerkatFeedback``
- <doc:GettingStarted>
