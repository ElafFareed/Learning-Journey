
import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {

        NavigationStack {

            Group {

                if let goal = viewModel.activeGoal {

                    ActivityView(
                        goal: goal,

                        onCalendar: {
                            viewModel.openCalendar()
                        },

                        onEditGoal: {
                            viewModel.openEditGoal()
                        },

                        onSetGoal: {
                            viewModel.clearGoal()
                        }
                    )
                    .id(goal.id)

                } else {

                    OnboardingView { goal in
                        viewModel.saveGoal(goal)
                    }
                }
            }

            // MARK: - Edit Goal

            .sheet(isPresented: $viewModel.showEditGoal) {
                if let goal = viewModel.activeGoal {
                    NavigationStack {
                        EditGoalView(
                            goal: goal,
                            onUpdate: { updatedGoal in
                                viewModel.updateGoal(updatedGoal)
                            }
                        )
                    }
                    .presentationDragIndicator(.hidden)
                }
            }

            // MARK: - Calendar

            .navigationDestination(
                isPresented: $viewModel.showCalendar
            ) {

                if let goal = viewModel.activeGoal {

                    ActivitiesCalendarView(
                        goal: goal
                    )
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
        .preferredColorScheme(.dark)
}
