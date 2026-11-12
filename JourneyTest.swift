
import SwiftUI

#if DEBUG

struct JourneyTest: View {

    // MARK: - Test State

    @State private var duration: LearningDuration = .week
    @State private var day = 1
    @State private var activities: [Int: LearningDayStatus] = [:]

    // MARK: - Test Rules

    private var totalDays: Int {
        switch duration {
        case .week:
            return 7
        case .month:
            return 30
        case .year:
            return 365
        }
    }

    private var freezeLimit: Int {
        switch duration {
        case .week:
            return 2
        case .month:
            return 8
        case .year:
            return 96
        }
    }

    private var learnedDays: Int {
        activities.values.filter {
            $0 == .learned
        }.count
    }

    private var frozenDays: Int {
        activities.values.filter {
            $0 == .frozen
        }.count
    }

    private var requiredLearnedDays: Int {
        totalDays - frozenDays
    }

    private var isCompleted: Bool {
        learnedDays >= requiredLearnedDays
    }

    private var hasActivityToday: Bool {
        activities[day] != nil
    }

    private var isExpired: Bool {
        day > totalDays
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 24) {

                    Text("Journey Test Mode")
                        .font(.title2.bold())

                    Text("DEBUG ONLY")
                        .font(.caption)
                        .foregroundStyle(.cyan)

                    // MARK: - Duration Picker

                    Picker("Duration", selection: $duration) {

                        ForEach(LearningDuration.allCases, id: \.self) { item in
                            Text(item.rawValue)
                                .tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: duration) { _, _ in
                        reset()
                    }

                    // MARK: - Day Display

                    VStack(spacing: 10) {

                        Text("Simulated Day")
                            .foregroundStyle(.secondary)

                        Text("\(min(day, totalDays)) / \(totalDays)")

                        Text(isExpired ? "Goal Ended" : "Goal Active")
                            .foregroundStyle(
                                isExpired ? .orange : .cyan
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(
                        Color.white.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: 20)
                    )

                    // MARK: - Stats

                    HStack(spacing: 12) {

                        JourneyStatsCard(
                            title: "Learned",
                            count: learnedDays,
                            symbol: "flame.fill",
                            color: JourneyColor.orange
                        )

                        JourneyStatsCard(
                            title: "Frozen",
                            count: frozenDays,
                            symbol: "snowflake",
                            color: JourneyColor.cyan
                        )
                    }

                    // MARK: - Actions

                    if !isExpired {

                        Button {
                            activities[day] = .learned
                        } label: {
                            JourneyLearningButton(
                                isLogged: activities[day] == .learned,
                                isEnabled: !hasActivityToday
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(hasActivityToday)

                        Button {
                            activities[day] = .frozen
                        } label: {
                            JourneyFreezeButton(
                                isFrozen: activities[day] == .frozen,
                                isEnabled: !hasActivityToday
                                    && frozenDays < freezeLimit
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(
                            hasActivityToday || frozenDays >= freezeLimit
                        )

                    } else {

                        JourneyGoalResult(
                            isCompleted: isCompleted
                        )

                        Button("Set a goal") {
                            reset()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(JourneyColor.orange)
                    }

                    // MARK: - Navigation

                    HStack(spacing: 12) {

                        Button("Previous Day") {
                            day = max(1, day - 1)
                        }
                        .buttonStyle(.bordered)
                        .disabled(day <= 1)

                        Button("Next Day") {
                            day = min(totalDays + 1, day + 1)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isExpired)
                    }

                    Button("Reset Simulation") {
                        reset()
                    }
                    .foregroundStyle(.red)
                }
                .padding(20)
            }
            .background(JourneyColor.background)
            .preferredColorScheme(.dark)
            .navigationTitle("Testing")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Reset

    private func reset() {
        day = 1
        activities = [:]
    }
}

#Preview {
    JourneyTest()
}

#endif

