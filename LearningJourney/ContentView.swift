
import SwiftUI

struct ContentView: View {

    // MARK: - State

    @State private var activeGoal: LearningGoal?
    @State private var showEditGoal = false

    private let goalKey = "activeLearningGoal"

    // MARK: - Body

    var body: some View {

        NavigationStack {

            Group {

                if let goal = activeGoal {

                    ActivityView(
                        goal: goal,

                        onEditGoal: {
                            showEditGoal = true
                        },

                        onSetGoal: {
                            clearGoal()
                        }
                    )
                    .id(goal.id)

                } else {

                    OnboardingView { goal in
                        saveGoal(goal)
                    }
                }
            }
            .navigationDestination(
                isPresented: $showEditGoal
            ) {

                if let goal = activeGoal {

                    EditGoalView(
                        goal: goal,
                        onUpdate: { updatedGoal in
                            showEditGoal = false
                            saveGoal(updatedGoal)
                        }
                    )
                }
            }
        }
        .onAppear {
            loadGoal()
        }
    }

    // MARK: - Save Goal

    private func saveGoal(_ goal: LearningGoal) {

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

    private func loadGoal() {

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

    private func clearGoal() {

        UserDefaults.standard.removeObject(
            forKey: goalKey
        )

        activeGoal = nil
    }
    
    
}

// MARK: - Preview

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
