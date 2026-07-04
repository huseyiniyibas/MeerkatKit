import Foundation

/// Binary attachment (screenshot, log file, etc.) sent with feedback.
public struct FeedbackAttachment: Sendable, Equatable {
    public let filename: String
    public let mimeType: String
    public let data: Data

    public init(filename: String, mimeType: String, data: Data) {
        self.filename = filename
        self.mimeType = mimeType
        self.data = data
    }
}
