import CoreGraphics
import Foundation

enum MeerkatFloatingButtonEdge: String, Codable, Sendable, Equatable {
    case leading
    case trailing
}

struct MeerkatFloatingButtonPosition: Codable, Equatable, Sendable {
    var edge: MeerkatFloatingButtonEdge
    /// Vertical center as a fraction of the movable range (`0` = top, `1` = bottom).
    var normalizedY: CGFloat

    static func from(_ position: FeedbackPosition) -> MeerkatFloatingButtonPosition {
        switch position {
        case .topLeading:
            return MeerkatFloatingButtonPosition(edge: .leading, normalizedY: 0)
        case .topTrailing:
            return MeerkatFloatingButtonPosition(edge: .trailing, normalizedY: 0)
        case .bottomLeading:
            return MeerkatFloatingButtonPosition(edge: .leading, normalizedY: 1)
        case .bottomTrailing:
            return MeerkatFloatingButtonPosition(edge: .trailing, normalizedY: 1)
        }
    }
}

enum MeerkatFloatingButtonPositionStore {
    private static let defaultsKey = "MeerkatKit.floatingButton.position"
    static let defaultMargin: CGFloat = 16

    static func load(default defaultPosition: FeedbackPosition) -> MeerkatFloatingButtonPosition {
        guard
            let data = UserDefaults.standard.data(forKey: defaultsKey),
            let stored = try? JSONDecoder().decode(MeerkatFloatingButtonPosition.self, from: data)
        else {
            return MeerkatFloatingButtonPosition.from(defaultPosition)
        }
        return stored
    }

    static func save(_ position: MeerkatFloatingButtonPosition) {
        guard let data = try? JSONEncoder().encode(position) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    static func point(
        for position: MeerkatFloatingButtonPosition,
        containerSize: CGSize,
        buttonSize: CGSize,
        margin: CGFloat = defaultMargin
    ) -> CGPoint {
        let range = verticalRange(
            containerHeight: containerSize.height,
            buttonHeight: buttonSize.height,
            margin: margin
        )
        let y = range.lowerBound + position.normalizedY * (range.upperBound - range.lowerBound)
        let x: CGFloat
        switch position.edge {
        case .leading:
            x = margin + buttonSize.width / 2
        case .trailing:
            x = containerSize.width - margin - buttonSize.width / 2
        }
        return CGPoint(x: x, y: y)
    }

    static func snap(
        freeCenter: CGPoint,
        containerSize: CGSize,
        buttonSize: CGSize,
        margin: CGFloat = defaultMargin
    ) -> MeerkatFloatingButtonPosition {
        let edge: MeerkatFloatingButtonEdge = freeCenter.x >= containerSize.width / 2
            ? .trailing
            : .leading
        let range = verticalRange(
            containerHeight: containerSize.height,
            buttonHeight: buttonSize.height,
            margin: margin
        )
        let clampedY = min(max(freeCenter.y, range.lowerBound), range.upperBound)
        let span = max(range.upperBound - range.lowerBound, 1)
        let normalizedY = (clampedY - range.lowerBound) / span
        return MeerkatFloatingButtonPosition(edge: edge, normalizedY: normalizedY)
    }

    #if DEBUG
    static func resetAll() {
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }
    #endif

    private static func verticalRange(
        containerHeight: CGFloat,
        buttonHeight: CGFloat,
        margin: CGFloat
    ) -> ClosedRange<CGFloat> {
        let minY = margin + buttonHeight / 2
        let maxY = max(minY, containerHeight - margin - buttonHeight / 2)
        return minY ... maxY
    }
}
