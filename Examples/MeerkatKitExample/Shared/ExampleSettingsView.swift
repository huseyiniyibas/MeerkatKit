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
        }
        .navigationTitle("Settings")
        .meerkatFeedback(screen: "Settings", presentation: .integrated)
    }
}
