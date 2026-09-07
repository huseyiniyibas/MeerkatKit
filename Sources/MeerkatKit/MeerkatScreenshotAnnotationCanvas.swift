import SwiftUI

struct MeerkatScreenshotAnnotationCanvas: View {
    let image: Image
    let marks: [MeerkatAnnotationMark]
    let tool: MeerkatAnnotationTool
    let onAdd: (MeerkatAnnotationMark) -> Void

    @State private var draftStart: CGPoint?
    @State private var draftCurrent: CGPoint?
    @State private var draftStroke: [CGPoint] = []

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: proxy.size.width, height: proxy.size.height)

                Canvas { context, _ in
                    MeerkatScreenshotAnnotationDrawing.draw(
                        marks: visibleMarks,
                        in: &context
                    )
                }
                .allowsHitTesting(false)
            }
            #if !os(tvOS)
            .gesture(dragGesture(in: proxy.size))
            #endif
        }
    }

    private var visibleMarks: [MeerkatAnnotationMark] {
        var result = marks
        if let draft = draftMark {
            result.append(draft)
        }
        return result
    }

    private var draftMark: MeerkatAnnotationMark? {
        switch tool {
        case .pen:
            return draftStroke.count > 1 ? .stroke(draftStroke) : nil
        case .circle:
            guard let start = draftStart, let current = draftCurrent else { return nil }
            return .circle(CGRect(start: start, end: current))
        case .arrow:
            guard let start = draftStart, let current = draftCurrent else { return nil }
            return .arrow(from: start, to: current)
        }
    }

    #if !os(tvOS)
    private func dragGesture(in _: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                switch tool {
                case .pen:
                    draftStroke.append(value.location)
                case .circle, .arrow:
                    if draftStart == nil {
                        draftStart = value.startLocation
                    }
                    draftCurrent = value.location
                }
            }
            .onEnded { _ in
                if let draft = draftMark {
                    onAdd(draft)
                }
                draftStart = nil
                draftCurrent = nil
                draftStroke = []
            }
    }
    #endif
}

enum MeerkatScreenshotAnnotationDrawing {
    static func draw(marks: [MeerkatAnnotationMark], in context: inout GraphicsContext) {
        for mark in marks {
            switch mark {
            case let .stroke(points):
                guard let path = strokePath(points) else { continue }
                context.stroke(path, with: .color(.red), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            case let .circle(rect):
                context.stroke(
                    Path(ellipseIn: rect.standardized),
                    with: .color(.red),
                    lineWidth: 3
                )
            case let .arrow(from, to):
                context.stroke(arrowPath(from: from, to: to), with: .color(.red), lineWidth: 3)
            }
        }
    }

    private static func strokePath(_ points: [CGPoint]) -> Path? {
        guard let first = points.first else { return nil }
        var path = Path()
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }

    private static func arrowPath(from: CGPoint, to: CGPoint) -> Path {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        let angle = atan2(to.y - from.y, to.x - from.x)
        let length: CGFloat = 14
        let left = CGPoint(
            x: to.x - length * cos(angle - .pi / 6),
            y: to.y - length * sin(angle - .pi / 6)
        )
        let right = CGPoint(
            x: to.x - length * cos(angle + .pi / 6),
            y: to.y - length * sin(angle + .pi / 6)
        )
        path.move(to: left)
        path.addLine(to: to)
        path.addLine(to: right)
        return path
    }
}

private extension CGRect {
    init(start: CGPoint, end: CGPoint) {
        self.init(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
    }
}