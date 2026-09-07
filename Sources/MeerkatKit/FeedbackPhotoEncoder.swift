import Foundation

#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

enum FeedbackPhotoEncoder {
    static func jpegData(from data: Data, quality: CGFloat = 0.82) -> Data {
        #if canImport(UIKit) && !os(watchOS)
        if let image = UIImage(data: data), let jpeg = image.jpegData(compressionQuality: quality) {
            return jpeg
        }
        #elseif os(macOS)
        if let image = NSImage(data: data),
           let tiff = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiff),
           let jpeg = bitmap.representation(using: .jpeg, properties: [.compressionFactor: quality]) {
            return jpeg
        }
        #endif
        return data
    }
}