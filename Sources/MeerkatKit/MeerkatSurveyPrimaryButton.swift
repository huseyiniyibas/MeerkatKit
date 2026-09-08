import SwiftUI

enum MeerkatSurveyPrimaryButton {
    static var background: Color { Color.primary }

    static var foreground: Color {
        #if canImport(UIKit) && !os(watchOS)
        Color(uiColor: .systemBackground)
        #elseif os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color.white
        #endif
    }
}
