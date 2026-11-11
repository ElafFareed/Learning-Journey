
import SwiftUI

struct OnboardingView: View {

    @StateObject private var viewModel = OnboardingViewModel()

    let onStart: (LearningGoal) -> Void

    var body: some View {

        GeometryReader { geometry in

            ScrollView {

                VStack(alignment: .leading, spacing: 0) {

                    // MARK: - Flame

                    JourneyFlame()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 72)

                    VStack(alignment: .leading, spacing: 4) {

                        Text("Hello \(Text("Learner").bold())")
                            .font(JourneyFont.onboardingTitleRegular)
                            .foregroundStyle(JourneyColor.text)

                        Text("This app will help you learn everyday!")
                            .font(JourneyFont.onboardingSubtitle)
                            .foregroundStyle(JourneyColor.secondaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 76)
                    // MARK: - Shared Goal Form

                    JourneyGoalForm(
                        topic: $viewModel.topic,
                        duration: $viewModel.duration
                    )
                    .padding(.top, 38)

                    Spacer(minLength: 90)

                    // MARK: - Start Learning

                    VStack(spacing: 12) {

                        Button {
                            guard let goal = viewModel.makeGoal() else {
                                return
                            }

                            viewModel.reset()
                            onStart(goal)

                        } label: {
                            JourneyButton(
                                title: "Start Learning",
                                color: JourneyColor.orange
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!viewModel.canStart)
                        .opacity(viewModel.canStart ? 1 : 0.45)

                        Text("You can edit your desire later")
                            .font(JourneyFont.onboardingHelper)
                            .foregroundStyle(JourneyColor.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 16)
                .frame(
                    minHeight: geometry.size.height,
                    alignment: .top
                )
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(JourneyColor.background)
        
    }
}

#Preview {
    OnboardingView { goal in
        print("New goal: \(goal.topic) / \(goal.duration.rawValue)")
    }
}
