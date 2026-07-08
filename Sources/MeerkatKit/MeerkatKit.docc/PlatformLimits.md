# Platform Limits

MeerkatKit runs on iOS, iPadOS, macOS, tvOS, and visionOS. Some triggers and delivery paths are platform-specific by design.

## Capability matrix

| Feature | iOS / iPadOS | macOS | tvOS | visionOS |
|---|---|---|---|---|
| Sticky floating button | Yes | Yes | Yes | Yes |
| Shake trigger | Yes | No | No | No |
| In-app form | Yes | Yes | Yes | Yes |
| Template picker | Yes | Yes | Yes | Yes |
| Mail composer (`MFMailComposeViewController`) | Yes | No | No | No |
| `mailto:` fallback | Yes | Yes | Yes | Yes |
| Share fallback | Share sheet | Sharing picker | Console log | Share sheet |
| REST API delivery | Yes | Yes | Yes | Yes |
| Offline queue | Yes | Yes | Yes | Yes |
| Screenshot toggle | Yes | Yes | No | Yes |
| UIKit bar button | Yes | No | Yes | Yes |
| AppKit toolbar item | No | Yes | No | No |

## Shake (iOS only)

Shake-to-feedback is available only on iOS. Enable globally at bootstrap or per screen:

```swift
HomeView()
    .meerkatFeedback(screen: "Home", enableShake: true)
```

When `enableShake` is `true` on a screen, the **sticky button is hidden** on that screen. Shake still opens the template picker or feedback flow.

Dismiss cooldown hides the sticky button only — it does **not** disable shake. See <doc:TimingAndDismiss>.

## Mail delivery

| Platform | Primary path | When Mail is unavailable |
|---|---|---|
| iOS | In-app Mail composer | `mailto:` then share fallback |
| macOS / tvOS / visionOS | `mailto:` | Share fallback (see below) |

Configure fallback at bootstrap:

```swift
MeerkatFeedback.bootstrap(
    recipients: ["feedback@yourapp.com"],
    mailUnavailableFallback: .shareSheet  // default; or .none
)
```

Share fallback behavior:

| Platform | Fallback |
|---|---|
| iOS / visionOS | `UIActivityViewController` share sheet |
| macOS | `NSSharingServicePicker` or compose email service |
| tvOS | Feedback text logged to console |

See <doc:MailDelivery>.

## Form input

On tvOS, the message field uses `TextField` instead of `TextEditor` because `TextEditor` is unavailable on Apple TV.

Screenshot capture is not available on tvOS. When `offerScreenshotInForm` is enabled at bootstrap, the toggle is hidden on tvOS automatically.

Sheet detents (`.medium` / `.large`) and the grabber apply on **iOS only**. visionOS presents the form as a standard sheet without detents.

## Per-screen routing

| Override | Applies to |
|---|---|
| `mailRecipients` | Mail bootstrap only |
| `apiEndpoint` | API bootstrap only |
| Custom delivery handler | Your own routing |

See <doc:PerScreenConfiguration>.

## Platform integration guides

- <doc:UIKitIntegration> — iOS, tvOS, visionOS
- <doc:AppKitIntegration> — macOS
- <doc:VisionOSIntegration> — visionOS specifics
- <doc:TVOSIntegration> — tvOS specifics

## See also

- <doc:GettingStarted>
- <doc:TimingAndDismiss>
- ``MeerkatFeedback``
