import Foundation
import SwiftUI

/// Temporarily hides MeerkatKit chrome (floating button, banners) so screenshots
/// capture the host app UI without feedback controls.
@MainActor
final class MeerkatFeedbackChromeSuppressor: ObservableObject {
    static let shared = MeerkatFeedbackChromeSuppressor()

    @Published private(set) var isSuppressed = false

    private var depth = 0

    func begin() {
        depth += 1
        if !isSuppressed {
            isSuppressed = true
        }
    }

    func end() {
        depth = max(0, depth - 1)
        if depth == 0, isSuppressed {
            isSuppressed = false
        }
    }

    func withSuppressed<T: Sendable>(
        settleDelay: Duration = .milliseconds(50),
        _ body: () async -> T
    ) async -> T {
        begin()
        defer { end() }
        try? await Task.sleep(for: settleDelay)
        return await body()
    }

    #if DEBUG
    func resetAll() {
        depth = 0
        isSuppressed = false
    }
    #endif
}
