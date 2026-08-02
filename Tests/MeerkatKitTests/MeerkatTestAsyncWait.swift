import XCTest

@MainActor
enum MeerkatTestAsyncWait {
    /// Polls until `condition` is true or `timeout` elapses. Avoids fixed sleeps that flake on busy CI runners.
    static func until(
        timeout: Duration = .seconds(2),
        poll: Duration = .milliseconds(20),
        _ condition: @MainActor () -> Bool
    ) async -> Bool {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: timeout)
        while clock.now < deadline {
            if condition() {
                return true
            }
            try? await Task.sleep(for: poll)
        }
        return condition()
    }
}
