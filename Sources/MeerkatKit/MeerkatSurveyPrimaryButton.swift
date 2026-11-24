import SwiftUI

#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

enum MeerkatSurveyPrimaryButton {
    static var background: Color { Color.primary }

    /// Inverse of ``background``: light on a dark button, dark on a light one.
    static var foreground: Color {
        #if os(tvOS)
        // `UIColor.systemBackground` is unavailable on tvOS.
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? .black : .white
        })
        #elseif canImport(UIKit) && !os(watchOS)
        Color(uiColor: .systemBackground)
        #elseif os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color.white
        #endif
    }
}
