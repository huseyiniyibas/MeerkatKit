import MeerkatKit
import SwiftUI

struct ExampleMailDeliveryView: View {
    var body: some View {
        List {
            Section("Release build") {
                Text("Release uses mail bootstrap with share fallback.")
                LabeledContent("Recipients", value: "feedback@example.com")
                LabeledContent("Fallback", value: "Share sheet / picker")
            }
            Section("Per-screen override") {
                Text("This screen routes to support@example.com instead of the bootstrap default.")
                LabeledContent("Override", value: "support@example.com")
            }
            Section("Actions") {
                Button("Send feedback now") {
                    MeerkatFeedback.requestFeedback(screen: "MailDemo")
                }
            }
        }
        .navigationTitle("Mail Delivery")
        .meerkatFeedback(
            screen: "MailDemo",
            mailRecipients: ["support@example.com"]
        )
    }
}
