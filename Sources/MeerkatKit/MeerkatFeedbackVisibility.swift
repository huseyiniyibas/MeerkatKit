import Foundation

@MainActor
enum MeerkatFeedbackRevealTracker {
    private static var deadlines: [String: ContinuousClock.Instant] = [:]
    private static var revealedScreens: Set<String> = []

    static func hasRevealed(screen: String) -> Bool {
        revealedScreens.contains(screen)
    }

    static func deadline(for screen: String, revealAfter: Duration, now: ContinuousClock.Instant) -> ContinuousClock.Instant {
        if let existing = deadlines[screen] {
            return existing
        }
        let deadline = now.advanced(by: revealAfter)
        deadlines[screen] = deadline
        return deadline
    }

    static func markRevealed(_ screen: String) {
        revealedScreens.insert(screen)
    }

    #if DEBUG
    static func resetAll() {
        deadlines.removeAll()
        revealedScreens.removeAll()
    }
    #endif
}

@MainActor
final class MeerkatFeedbackVisibilityController: ObservableObject {
    @Published private(set) var isReady = false

    private var dwellTask: Task<Void, Never>?
    private var revealTask: Task<Void, Never>?

    func begin(screen: String, minimumDwell: Duration?, revealAfter: Duration?) {
        dwellTask?.cancel()
        dwellTask = nil

        guard minimumDwell != nil || revealAfter != nil else {
            isReady = true
            return
        }

        if MeerkatFeedbackRevealTracker.hasRevealed(screen: screen) {
            isReady = true
            return
        }

        isReady = false
        beginDwell(minimumDwell)
        beginReveal(screen: screen, revealAfter: revealAfter)
    }

    func pauseDwell() {
        dwellTask?.cancel()
        dwellTask = nil
    }

    func stop() {
        pauseDwell()
        revealTask?.cancel()
        revealTask = nil
        isReady = false
    }

    private func beginDwell(_ minimumDwell: Duration?) {
        guard let minimumDwell else { return }
        dwellTask = Task { @MainActor in
            try? await Task.sleep(for: minimumDwell)
            guard !Task.isCancelled else { return }
            isReady = true
        }
    }

    private func beginReveal(screen: String, revealAfter: Duration?) {
        guard let revealAfter else { return }

        let clock = ContinuousClock()
        let now = clock.now
        let deadline = MeerkatFeedbackRevealTracker.deadline(
            for: screen,
            revealAfter: revealAfter,
            now: now
        )

        if now >= deadline {
            MeerkatFeedbackRevealTracker.markRevealed(screen)
            isReady = true
            return
        }

        revealTask?.cancel()
        revealTask = Task { @MainActor in
            try? await clock.sleep(until: deadline, tolerance: .milliseconds(50))
            guard !Task.isCancelled else { return }
            MeerkatFeedbackRevealTracker.markRevealed(screen)
            isReady = true
        }
    }
}
