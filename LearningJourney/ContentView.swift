
import SwiftUI

struct ContentView: View {

    // MARK: - State

    @State private var activeGoal: LearningGoal?
    @State private var showEditGoal = false
    @State private var showCalendar = false

    private let goalKey = "activeLearningGoal"

    // MARK: - Body

    var body: some View {

        NavigationStack {

            Group {

                if let goal = activeGoal {

                    ActivityView(
                        goal: goal,

                        onCalendar: {
                            showCalendar = true
                        },

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

            // MARK: - Edit Goal Navigation

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

            // MARK: - Calendar Navigation

            .navigationDestination(
                isPresented: $showCalendar
            ) {
                if let goal = activeGoal {
                    ActivitiesCalendarView(goal: goal)
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

