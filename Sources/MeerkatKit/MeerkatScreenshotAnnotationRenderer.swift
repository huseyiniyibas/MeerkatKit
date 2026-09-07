import Foundation
import CoreGraphics

#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

enum MeerkatScreenshotAnnotationRenderer {
    static func render(png: Data, marks: [MeerkatAnnotationMark], canvasSize: CGSize) -> Data {
        guard !marks.isEmpty, canvasSize.width > 1, canvasSize.height > 1 else {
            return png
        }
        #if canImport(UIKit) && !os(watchOS)
        return renderUIKit(png: png, marks: marks, canvasSize: canvasSize) ?? png
        #elseif os(macOS)
        return renderAppKit(png: png, marks: marks, canvasSize: canvasSize) ?? png
        #else
        return png
        #endif
    }

    #if canImport(UIKit) && !os(watchOS)
    private static func renderUIKit(
        png: Data,
        marks: [MeerkatAnnotationMark],
        canvasSize: CGSize
    ) -> Data? {
        guard let image = UIImage(data: png) else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.pngData { context in
            image.draw(in: CGRect(origin: .zero, size: image.size))
            let scaleX = image.size.width / canvasSize.width
            let scaleY = image.size.height / canvasSize.height
            stroke(marks, in: context.cgContext, scaleX: scaleX, scaleY: scaleY)
        }
    }
    #endif

    #if os(macOS)
    private static func renderAppKit(
        png: Data,
        marks: [MeerkatAnnotationMark],
        canvasSize: CGSize
    ) -> Data? {
        guard let image = NSImage(data: png) else { return nil }
        let size = image.size
        let output = NSImage(size: size)
        output.lockFocus()
        image.draw(in: CGRect(origin: .zero, size: size))
        if let context = NSGraphicsContext.current?.cgContext {
            let scaleX = size.width / canvasSize.width
            let scaleY = size.height / canvasSize.height
            stroke(marks, in: context, scaleX: scaleX, scaleY: scaleY)
        }
        output.unlockFocus()
        guard let tiff = output.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff) else {
            return nil
        }
        return rep.representation(using: .png, properties: [:])
    }
    #endif

    private static func stroke(
        _ marks: [MeerkatAnnotationMark],
        in context: CGContext,
        scaleX: CGFloat,
        scaleY: CGFloat
    ) {
        context.setStrokeColor(red: 0.95, green: 0.2, blue: 0.2, alpha: 1)
        context.setLineWidth(3 * max(scaleX, scaleY))
        context.setLineCap(.round)
        context.setLineJoin(.round)
        for mark in marks {
            switch mark {
            case let .stroke(points):
                guard let first = points.first else { continue }
                context.beginPath()
                context.move(to: CGPoint(x: first.x * scaleX, y: first.y * scaleY))
                for point in points.dropFirst() {
                    context.addLine(to: CGPoint(x: point.x * scaleX, y: point.y * scaleY))
                }
                context.strokePath()
            case let .circle(rect):
                let scaled = CGRect(
                    x: rect.minX * scaleX,
                    y: rect.minY * scaleY,
                    width: rect.width * scaleX,
                    height: rect.height * scaleY
                )
                context.strokeEllipse(in: scaled.standardized)
            case let .arrow(from, to):
                let start = CGPoint(x: from.x * scaleX, y: from.y * scaleY)
                let end = CGPoint(x: to.x * scaleX, y: to.y * scaleY)
                context.beginPath()
                context.move(to: start)
                context.addLine(to: end)
                let angle = atan2(end.y - start.y, end.x - start.x)
                let length: CGFloat = 14 * max(scaleX, scaleY)
                context.addLine(to: CGPoint(
                    x: end.x - length * cos(angle - .pi / 6),
                    y: end.y - length * sin(angle - .pi / 6)
                ))
                context.move(to: end)
                context.addLine(to: CGPoint(
                    x: end.x - length * cos(angle + .pi / 6),
                    y: end.y - length * sin(angle + .pi / 6)
                ))
                context.strokePath()
            }
        }
    }
}