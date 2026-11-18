
import SwiftUI
import UIKit

@main
struct JourneyApp: App {

    @StateObject private var viewModel = AppViewModel()

    // MARK: - App Appearance

    init() {
        UIView.appearance(
            whenContainedInInstancesOf: [UIAlertController.self]
        ).tintColor = UIColor(named: "AccentColor") ?? .systemOrange
    }

    // MARK: - App Launch

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
        }
    }
}
