import MeerkatKit
import SwiftUI

@main
struct MeerkatKitExampleApp: App {
    init() {
        ExampleBootstrap.configure()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ExampleHomeView()
            }
        }
    }
}
