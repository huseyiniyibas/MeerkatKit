import Foundation

/// Holds a screenshot taken after hiding MeerkatKit chrome (e.g. right after a
/// system screenshot) until the user submits or cancels the feedback form.
@MainActor
enum MeerkatFeedbackPendingScreenshot {
    private static var pngData: Data?
    private static var preferInclude = false

    static var shouldPreferInclude: Bool {
        preferInclude || pngData != nil
    }

    static func store(_ data: Data) {
        pngData = data
        preferInclude = true
    }

    static func markPreferInclude() {
        preferInclude = true
    }

    static func consumePNG() -> Data? {
        let data = pngData
        clear()
        return data
    }

    static func clear() {
        pngData = nil
        preferInclude = false
    }

    #if DEBUG
    static func resetAll() {
        clear()
    }
    #endif
}

extension Notification.Name {
    /// Posted when a system screenshot should turn on the form's include-screenshot toggle.
    static let meerkatPreferIncludeScreenshot = Notification.Name(
        "MeerkatKit.preferIncludeScreenshot"
    )
}
