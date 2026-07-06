# MeerkatKit

Collect user feedback in SwiftUI apps on iOS, iPadOS, macOS, and tvOS.

## Overview

MeerkatKit adds a floating feedback button (or shake-to-trigger on iOS), delivers feedback through Mail or a custom handler, and attaches app and device metadata automatically.

Typical integration:

1. Call ``MeerkatFeedback/bootstrap(recipients:appStoreID:)`` once at launch.
2. Add ``SwiftUI/View/meerkatFeedback(screen:)`` on each screen.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:TimingAndDismiss>
- <doc:APIDelivery>
- <doc:FormConfiguration>
- <doc:CustomTemplates>
- <doc:EventHandlers>
- <doc:UIKitIntegration>
- <doc:AppKitIntegration>

### Core types

- ``MeerkatFeedback``
- ``FeedbackTemplate``
- ``FeedbackCustomTemplate``
- ``FeedbackFormConfiguration``
- ``FeedbackEventHandler``
- ``FeedbackPayload``
