import MeerkatKit
import SwiftUI

struct ExampleHomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bubble.left.and.text.bubble.right.fill")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("MeerkatKit Example")
                .font(.title2.bold())
            Text("Floating button, shake (iOS), integrated row, and API delivery.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            ExampleActionButtons()
        }
        .padding()
        .navigationTitle("Home")
        .meerkatFeedback(screen: "Home", enableShake: true)
    }
}

private struct ExampleActionButtons: View {
    var body: some View {
        VStack(spacing: 12) {
            NavigationLink("Integrated settings row") {
                ExampleSettingsView()
            }
            .buttonStyle(.bordered)
        }
    }
}
