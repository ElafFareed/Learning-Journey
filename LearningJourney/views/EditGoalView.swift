
import SwiftUI

struct EditGoalView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var topic: String
    @State private var duration: LearningDuration
    @State private var showUpdateAlert = false

    let onUpdate: (LearningGoal) -> Void

    init(
        goal: LearningGoal,
        onUpdate: @escaping (LearningGoal) -> Void
    ) {
        _topic = State(initialValue: goal.topic)
        _duration = State(initialValue: goal.duration)
        self.onUpdate = onUpdate
    }

    private var canUpdate: Bool {
        !topic.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
    }

    var body: some View {

        VStack(spacing: 0) {

            // MARK: - Navigation

            HStack {

                Button {
                    dismiss()
                } label: {
                    JourneyCircleIconButton(
                        symbol: "chevron.left"
                    )
                }

                Spacer()

                Text("Learning Goal")
                    .font(JourneyFont.buttonLabel)
                    .foregroundStyle(JourneyColor.text)

                Spacer()

                Button {
                    showUpdateAlert = true
                } label: {
                    JourneyCircleIconButton(
                        symbol: "checkmark",
                        color: JourneyColor.orange
                    )
                }
                .disabled(!canUpdate)
            }
            .buttonStyle(.plain)

            // MARK: - Goal Form

            JourneyGoalForm(
                topic: $topic,
                duration: $duration
            )
            .padding(.top, 48)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .background(JourneyColor.background)
        .navigationBarBackButtonHidden()

        // MARK: - Update Confirmation

        
        .overlay {
            if showUpdateAlert {

                ZStack {

                    Color.black.opacity(0.60)
                        .ignoresSafeArea()

                    JourneyAlert(
                        title: "Update goal",
                        message: "If you update now, your streak will start over.",
                        primaryTitle: "Update",
                        secondaryTitle: "Dismiss",
                        primaryTint: JourneyColor.orange,
                        onPrimary: {
                            showUpdateAlert = false
                            updateGoal()
                        },
                        onSecondary: {
                            showUpdateAlert = false
                        }
                    )
                }
            }
        }

    }

    // MARK: - Save Updated Goal

    private func updateGoal() {
        guard canUpdate else { return }

        let updatedGoal = LearningGoal(
            topic: topic.trimmingCharacters(in: .whitespacesAndNewlines),
            duration: duration
        )

        onUpdate(updatedGoal)
    }
}
