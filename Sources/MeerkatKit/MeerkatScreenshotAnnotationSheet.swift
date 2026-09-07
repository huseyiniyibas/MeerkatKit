import SwiftUI

#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

struct MeerkatScreenshotAnnotationSheet: View {
    let png: Data
    let locale: FeedbackLocale
    let onFinish: (Data) -> Void

    @State private var tool: MeerkatAnnotationTool = .pen
    @State private var marks: [MeerkatAnnotationMark] = []
    @State private var canvasSize: CGSize = .zero

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    canvas(in: proxy.size)
                        .onAppear { canvasSize = proxy.size }
                        .onChange(of: proxy.size) { _, size in
                            canvasSize = size
                        }
                }
                MeerkatScreenshotAnnotationToolbar(
                    locale: locale,
                    tool: $tool,
                    onClear: { marks = [] },
                    onCancel: { onFinish(png) },
                    onDone: { onFinish(renderedPNG()) }
                )
            }
            .navigationTitle(MeerkatLocalizer.text(.annotationTitle, locale: locale))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    private func canvas(in size: CGSize) -> some View {
        MeerkatScreenshotAnnotationCanvas(
            image: previewImage,
            marks: marks,
            tool: tool,
            onAdd: { marks.append($0) }
        )
        .frame(width: size.width, height: size.height)
    }

    private var previewImage: Image {
        #if canImport(UIKit) && !os(watchOS)
        if let uiImage = UIImage(data: png) {
            return Image(uiImage: uiImage)
        }
        #elseif os(macOS)
        if let nsImage = NSImage(data: png) {
            return Image(nsImage: nsImage)
        }
        #endif
        return Image(systemName: "photo")
    }

    private func renderedPNG() -> Data {
        MeerkatScreenshotAnnotationRenderer.render(
            png: png,
            marks: marks,
            canvasSize: canvasSize
        )
    }
}