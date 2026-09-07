import Foundation

@MainActor
enum MeerkatSurveyAvailability {
    private static var isEnabled = true

    static var surveysEnabled: Bool {
        isEnabled
    }

    static func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }

    #if DEBUG
    static func resetAll() {
        isEnabled = true
    }
    #endif
}