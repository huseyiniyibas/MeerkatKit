import MeerkatKit
import SwiftUI

struct ExampleTimingView: View {
    var body: some View {
        List {
            Section("This screen") {
                LabeledContent("minimumDwell", value: "5 seconds")
                LabeledContent("revealAfter", value: "3 seconds")
                LabeledContent("dismissCooldown", value: "Current visit only")
            }
            Section("Behavior") {
                Text("Stay on this screen for 5 seconds to reveal the sticky button.")
                Text("Or wait 3 seconds from first visit (revealAfter).")
                Text("Tap ✕ to hide the button until you leave this screen.")
            }
        }
        .navigationTitle("Timing")
        .meerkatFeedback(
            screen: "Timing",
            minimumDwell: .seconds(5),
            revealAfter: .seconds(3),
            dismissCooldown: .zero
        )
    }
}
