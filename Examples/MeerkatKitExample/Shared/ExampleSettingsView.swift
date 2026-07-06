import MeerkatKit
import SwiftUI

struct ExampleSettingsView: View {
    var body: some View {
        List {
            Button("Send Feedback") {
                MeerkatFeedback.requestFeedback(screen: "Settings")
            }
            Button("Flush offline queue") {
                MeerkatFeedback.flushOfflineQueue()
            }
            LabeledContent("Queued items", value: "\(MeerkatFeedback.offlineQueueCount)")
            LabeledContent("Collect email", value: MeerkatFeedback.formConfiguration.collectEmail ? "Yes" : "No")
            LabeledContent("Custom fields", value: "\(MeerkatFeedback.formConfiguration.customFields.count)")
        }
        .navigationTitle("Settings")
        .meerkatFeedback(
            screen: "Settings",
            mailRecipients: ["settings-feedback@example.com"],
            presentation: .integrated
        )
    }
}
