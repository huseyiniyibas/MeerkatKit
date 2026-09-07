import Foundation

/// Host-supplied images (for example the last generation result) shown in the form
/// and attached on submit. Limited by ``MeerkatFeedback/maxPhotoAttachments``.
@MainActor
enum MeerkatFeedbackPendingPhotos {
    private static var images: [Data] = []

    static func set(_ images: [Data]) {
        self.images = Array(images.prefix(MeerkatFeedback.maxPhotoAttachments))
    }

    static func peek() -> [Data] {
        images
    }

    static func consume() -> [Data] {
        let current = images
        images = []
        return current
    }

    static func clear() {
        images = []
    }

    #if DEBUG
    static func resetAll() {
        clear()
    }
    #endif
}