
import Foundation
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {

    @Published var topic = ""
    @Published var duration: LearningDuration = .week

    var canStart: Bool {
        !topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func makeGoal() -> LearningGoal? {
        guard canStart else { return nil }

        return LearningGoal(
            topic: topic.trimmingCharacters(in: .whitespacesAndNewlines),
            duration: duration
        )
    }

    // MARK: - Reset Form

    func reset() {
        topic = ""
        duration = .week
    }
}
