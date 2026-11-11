import SwiftUI



struct JourneyGoalForm: View {
    @Binding var topic: String
    @Binding var duration: LearningDuration

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("I want to learn")
                    .font(JourneyFont.body)
                    .foregroundStyle(.white)
                JourneyUnderlinedTextField(placeholder: "Swift", text: $topic)
            }
            VStack(alignment: .leading, spacing: 12) {
                Text("I want to learn it in a")
                    .font(JourneyFont.body)
                    .foregroundStyle(.white)
                HStack(spacing: 12) {
                    ForEach(LearningDuration.allCases, id: \.self) { option in
                        Button {
                            duration = option
                        } label: {
                            JourneyDurationButton(
                                title: option.rawValue,
                                isSelected: duration == option
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
