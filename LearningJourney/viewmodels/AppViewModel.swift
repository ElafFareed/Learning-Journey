
import Foundation
import Combine

@MainActor
final class AppViewModel: ObservableObject {

    // MARK: - App State

    @Published private(set) var activeGoal: LearningGoal?

    @Published var showEditGoal = false
    @Published var showCalendar = false

    // MARK: - Storage

    private let goalKey = "activeLearningGoal"

    // MARK: - Initialization

    init() {
        loadGoal()
    }

    // MARK: - Save Goal

    func saveGoal(_ goal: LearningGoal) {

        guard let data = try? JSONEncoder().encode(goal) else {
            return
        }

        UserDefaults.standard.set(
            data,
            forKey: goalKey
        )

        activeGoal = goal
    }

    // MARK: - Load Goal

    func loadGoal() {

        guard let data = UserDefaults.standard.data(
            forKey: goalKey
        ),
        let goal = try? JSONDecoder().decode(
            LearningGoal.self,
            from: data
        ) else {
            return
        }

        activeGoal = goal
    }

    // MARK: - Clear Goal

    func clearGoal() {

        UserDefaults.standard.removeObject(
            forKey: goalKey
        )

        activeGoal = nil
    }

    // MARK: - Navigation

    func openEditGoal() {
        showEditGoal = true
    }

    func openCalendar() {
        showCalendar = true
    }

    // MARK: - Update Goal

    func updateGoal(_ goal: LearningGoal) {
        showEditGoal = false
        saveGoal(goal)
    }
}
