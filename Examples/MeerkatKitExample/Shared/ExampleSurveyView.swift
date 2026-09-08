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
                Text("The 1–5 star modal appears on every visit until you respond.")
                Text("4–5 stars continue to the App Store. 1–3 stars collect private feedback.")
                Text("With Firebase configured, meerkatkit_like / meerkatkit_dislike events include star_rating.")
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
                lastResponse = "\(event.starRating) (\(event.response.rawValue))"
                print("Example: survey \(event.response.rawValue) on \(event.screen)")
            }
        )
    }
}
