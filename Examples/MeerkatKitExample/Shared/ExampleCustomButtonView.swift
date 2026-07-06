import MeerkatKit
import SwiftUI

struct ExampleCustomButtonView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 40))
                .foregroundStyle(.tint)
            Text("Custom floating chip")
                .font(.headline)
            Text("The feedback chip below replaces the default sticky button.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("Custom Button")
        .meerkatFeedback(screen: "CustomButton") { request, dismiss in
            ExampleFeedbackChip(onRequest: request, onDismiss: dismiss)
        }
    }
}

private struct ExampleFeedbackChip: View {
    let onRequest: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onRequest) {
                Label("Feedback", systemImage: "bubble.left.and.text.bubble.right")
            }
            .buttonStyle(.borderedProminent)
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(.borderless)
        }
        .padding(10)
        .background(.ultraThinMaterial, in: Capsule())
    }
}
