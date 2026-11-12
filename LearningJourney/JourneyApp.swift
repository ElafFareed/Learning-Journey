
import SwiftUI

@main
struct JourneyApp: App {

    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {

        WindowGroup {

            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
        }
    }
}
