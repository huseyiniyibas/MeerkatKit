import MeerkatKit
import SwiftUI

struct ExampleCustomDeliveryView: View {
    @State private var lastDeliveryNote = "No delivery yet."

    var body: some View {
        List {
            Section("Pattern") {
                Text("Replace mail or API bootstrap with a custom handler:")
                    .font(.subheadline)
                Text(customDeliverySnippet)
                    .font(.system(.caption, design: .monospaced))
            }
            Section("Try it") {
                Text(lastDeliveryNote)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button("Request feedback (uses current bootstrap)") {
                    MeerkatFeedback.requestFeedback(screen: "CustomDelivery")
                }
            }
        }
        .navigationTitle("Custom Delivery")
        .onAppear {
            lastDeliveryNote = ExampleCustomDeliveryStore.note
        }
    }

    private var customDeliverySnippet: String {
        """
        MeerkatFeedback.bootstrap(
            customDelivery: { payload in
                // POST payload to your backend
            }
        )
        """
    }
}

enum ExampleCustomDeliveryStore {
    static var note = "Custom delivery runs at bootstrap — see ExampleBootstrap for the active mode."
}
