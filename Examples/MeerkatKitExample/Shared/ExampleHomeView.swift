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
            Text("Floating button, shake (iOS), timing, custom UI, mail, and API demos.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            ExampleActionButtons()
        }
        .padding()
        .navigationTitle("Home")
        .meerkatFeedback(
            screen: "Home",
            mailRecipients: ["home-feedback@example.com"],
            enableShake: true
        )
    }
}

private struct ExampleActionButtons: View {
    var body: some View {
        VStack(spacing: 12) {
            NavigationLink("Timing & dismiss") {
                ExampleTimingView()
            }
            .buttonStyle(.bordered)
            NavigationLink("Custom floating button") {
                ExampleCustomButtonView()
            }
            .buttonStyle(.bordered)
            NavigationLink("Mail delivery") {
                ExampleMailDeliveryView()
            }
            .buttonStyle(.bordered)
            NavigationLink("Custom delivery pattern") {
                ExampleCustomDeliveryView()
            }
            .buttonStyle(.bordered)
            NavigationLink("Integrated settings row") {
                ExampleSettingsView()
            }
            .buttonStyle(.bordered)
            NavigationLink("UIKit bar button demo") {
                ExampleUIKitView()
            }
            .buttonStyle(.bordered)
            NavigationLink("AppKit toolbar demo") {
                ExampleAppKitView()
            }
            .buttonStyle(.bordered)
        }
    }
}
