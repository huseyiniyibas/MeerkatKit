import MeerkatKit
import SwiftUI

struct ExampleSurveyView: View {
    @State private var lastResponse = "—"

    var body: some View {
        List {
            Section("This screen") {
                LabeledContent("trigger", value: ".everyView")
                LabeledContent("offersFeedback", value: "true")
                LabeledContent("Last response", value: lastResponse)
            }
            Section("Behavior") {
                Text("The like/dislike modal appears on every visit until you respond.")
                Text("After responding, the buttons animate out and a feedback button appears.")
                Text("With Firebase configured, meerkatkit_like / meerkatkit_dislike events are logged.")
            }
            Section {
                Button("Reset survey state") {
                    MeerkatFeedback.resetSatisfactionSurvey(forScreen: "Survey")
                    lastResponse = "—"
                }
            }
        }
        .navigationTitle("Survey")
        .meerkatFeedback(screen: "Survey")
        .meerkatSatisfactionSurvey(
            screen: "Survey",
            trigger: .everyView,
            onResponse: { event in
                lastResponse = event.response.rawValue
                print("Example: survey \(event.response.rawValue) on \(event.screen)")
            }
        )
    }
}
