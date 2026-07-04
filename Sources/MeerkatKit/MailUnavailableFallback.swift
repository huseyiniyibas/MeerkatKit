import Foundation

/// Action when Mail is unavailable or mailto cannot be opened.
public enum MailUnavailableFallback: Sendable {
    /// Present a system share sheet with the formatted feedback text.
    case shareSheet
    /// Do nothing after mail / mailto fails.
    case none
}
