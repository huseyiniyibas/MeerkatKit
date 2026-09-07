import SwiftUI

#if canImport(PhotosUI) && !os(tvOS)
import PhotosUI
#endif

#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

struct FeedbackPhotoAttachmentsSection: View {
    let locale: FeedbackLocale
    let maxCount: Int
    @Binding var images: [Data]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(
                    MeerkatLocalizer.text(.formAddPhotos, locale: locale),
                    systemImage: "photo.on.rectangle"
                )
                Spacer()
                Text(countLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !images.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(Array(images.enumerated()), id: \.offset) { index, data in
                            photoThumbnail(data: data, index: index)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }

            #if canImport(PhotosUI) && !os(tvOS)
            if images.count < maxCount {
                PhotosPicker(
                    selection: Binding(
                        get: { [] },
                        set: { loadPhotos($0) }
                    ),
                    maxSelectionCount: maxCount - images.count,
                    matching: .images
                ) {
                    Text(MeerkatLocalizer.text(.formAddPhotos, locale: locale))
                        .font(.subheadline.weight(.medium))
                }
            }
            #endif
        }
    }

    private var countLabel: String {
        let format = MeerkatLocalizer.text(.formPhotosCount, locale: locale)
        return String(format: format, images.count, maxCount)
    }

    private func photoThumbnail(data: Data, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            FeedbackPhotoThumbnail(data: data)
            Button {
                images.remove(at: index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .black.opacity(0.55))
            }
            .buttonStyle(.plain)
            .offset(x: 4, y: -4)
        }
    }

    #if canImport(PhotosUI) && !os(tvOS)
    private func loadPhotos(_ items: [PhotosPickerItem]) {
        Task { @MainActor in
            var next = images
            for item in items {
                guard next.count < maxCount else { break }
                guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
                next.append(FeedbackPhotoEncoder.jpegData(from: data))
            }
            images = next
        }
    }
    #endif
}

struct FeedbackPhotoThumbnail: View {
    let data: Data

    var body: some View {
        thumbnailImage
            .resizable()
            .scaledToFill()
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var thumbnailImage: Image {
        #if canImport(UIKit) && !os(watchOS)
        if let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        #elseif os(macOS)
        if let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
        #endif
        return Image(systemName: "photo")
    }
}