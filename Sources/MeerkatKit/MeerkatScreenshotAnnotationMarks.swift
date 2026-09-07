import Foundation
import CoreGraphics

enum MeerkatAnnotationTool: String, Sendable, Equatable, CaseIterable {
    case pen
    case circle
    case arrow
}

enum MeerkatAnnotationMark: Sendable, Equatable {
    case stroke([CGPoint])
    case circle(CGRect)
    case arrow(from: CGPoint, to: CGPoint)
}