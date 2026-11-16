
import SwiftUI

#if DEBUG

struct JourneyTesting: View {

    // MARK: - Test State

    @State private var duration: LearningDuration = .week
    @State private var goalStart: Date
    @State private var simulatedNow: Date
    @State private var activities: [LearningDayRecord] = []

    // MARK: - Test Configuration

    private let calendar = Calendar.current
    private let streakTimeLimit: TimeInterval = 32 * 60 * 60

    init() {

        let start = Date()

        _goalStart = State(initialValue: start)
        _simulatedNow = State(initialValue: start)
    }

    // MARK: - Goal Duration

    private var goalEnd: Date {

        let startDay = calendar.startOfDay(for: goalStart)

        switch duration {

        case .week:
            return calendar.date(
                byAdding: .day,
                value: 7,
                to: startDay
            ) ?? startDay

        case .month:
            return calendar.date(
                byAdding: .month,
                value: 1,
                to: startDay
            ) ?? startDay

        case .year:
            return calendar.date(
                byAdding: .year,
                value: 1,
                to: startDay
            ) ?? startDay
        }
    }

    private var totalDays: Int {

        calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: goalStart),
            to: goalEnd
        ).day ?? 0
    }

    private var currentDay: Int {

        let elapsedDays = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: goalStart),
            to: calendar.startOfDay(for: simulatedNow)
        ).day ?? 0

        return min(
            max(elapsedDays + 1, 1),
            totalDays
        )
    }

    // MARK: - Goal State

    private var isExpired: Bool {
        simulatedNow >= goalEnd
    }

    private var isGoalActive: Bool {

        !isExpired &&
        !isGoalStreakBroken
    }

    private var shouldShowGoalResult: Bool {

        isExpired ||
        isGoalStreakBroken
    }

    // MARK: - Freeze Limits

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

    private var remainingFreezes: Int {

        max(0, freezeLimit - frozenDays)
    }

    // MARK: - Counters

    private var learnedDays: Int {

        activities.filter {
            $0.status == .learned
        }.count
    }

    private var frozenDays: Int {

        activities.filter {
            $0.status == .frozen
        }.count
    }

    private var coveredDays: Int {

        learnedDays + frozenDays
    }

    // MARK: - Today's Status

    private var todayStatus: LearningDayStatus? {

        activities.first {
            calendar.isDate(
                $0.date,
                inSameDayAs: simulatedNow
            )
        }?.status
    }

    private var hasActivityToday: Bool {

        todayStatus != nil
    }

    private var canLogToday: Bool {

        isGoalActive &&
        !hasActivityToday
    }

    private var canFreezeToday: Bool {

        canLogToday &&
        remainingFreezes > 0
    }

    // MARK: - Activity Records

    private var sortedActivities: [LearningDayRecord] {

        activities.sorted {
            $0.date < $1.date
        }
    }

    private var lastActivityDate: Date {

        sortedActivities.last?.date ?? goalStart
    }

    // MARK: - 32-Hour Streak

    private var hoursSinceActivity: Double {

        let evaluationDate = min(
            simulatedNow,
            goalEnd
        )

        return max(
            0,
            evaluationDate.timeIntervalSince(
                lastActivityDate
            ) / 3600
        )
    }

    // MARK: - Permanent Goal Failure

    private var isGoalStreakBroken: Bool {

        // Countdown begins when the goal starts.

        var previousDate = goalStart

        // A historical gap greater than 32 hours
        // permanently breaks the goal.

        for activity in sortedActivities {

            let elapsed = activity.date.timeIntervalSince(
                previousDate
            )

            if elapsed > streakTimeLimit {
                return true
            }

            previousDate = activity.date
        }

        // Stop measuring when the goal expires.

        let evaluationDate = min(
            simulatedNow,
            goalEnd
        )

        let inactivity = evaluationDate.timeIntervalSince(
            previousDate
        )

        return inactivity > streakTimeLimit
    }

    // MARK: - Current Streak

    private var currentStreak: Int {

        // A failed goal no longer has
        // an active streak.

        guard !isGoalStreakBroken else {
            return 0
        }

        guard !sortedActivities.isEmpty else {
            return 0
        }

        // Learned increases the streak.
        // Freeze maintains it.

        return sortedActivities.filter {
            $0.status == .learned
        }.count
    }

    // MARK: - Goal Completion

    private var isCompleted: Bool {

        guard shouldShowGoalResult else {
            return false
        }

        return coveredDays == totalDays &&
               frozenDays <= freezeLimit &&
               !isGoalStreakBroken
    }

    // MARK: - Goal Status Text

    private var goalStatusText: String {

        if isGoalStreakBroken {
            return "Goal Failed — Streak Broken"
        }

        if isExpired {
            return isCompleted
                ? "Goal Completed"
                : "Goal Ended — Not Completed"
        }

        return "Goal Active"
    }

    private var goalStatusColor: Color {

        if isGoalStreakBroken {
            return .red
        }

        if isExpired {
            return isCompleted ? .green : .orange
        }

        return .cyan
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 24) {

                    // MARK: - Header

                    Text("Journey Test Mode")
                        .font(.title2.bold())

                    Text("DEBUG ONLY — SIMULATED TIME")
                        .font(.caption)
                        .foregroundStyle(.cyan)

                    // MARK: - Duration Picker

                    Picker(
                        "Duration",
                        selection: $duration
                    ) {

                        ForEach(
                            LearningDuration.allCases,
                            id: \.self
                        ) { item in

                            Text(item.rawValue)
                                .tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: duration) { _, _ in
                        reset()
                    }

                    // MARK: - Simulated Time

                    VStack(spacing: 12) {

                        Text("Simulated Day")
                            .foregroundStyle(.secondary)

                        Text(
                            "\(currentDay) / \(totalDays)"
                        )
                        .font(.title.bold())

                        Text(
                            simulatedNow.formatted(
                                .dateTime
                                    .weekday(.wide)
                                    .day()
                                    .month(.wide)
                                    .hour()
                                    .minute()
                            )
                        )
                        .font(.subheadline)

                        Text(goalStatusText)
                            .font(.subheadline.bold())
                            .foregroundStyle(
                                goalStatusColor
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(
                        Color.white.opacity(0.08),
                        in: RoundedRectangle(
                            cornerRadius: 20
                        )
                    )

                    // MARK: - Statistics

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

                    // MARK: - Streak Diagnostics

                    VStack(spacing: 12) {

                        HStack {

                            Text("Current streak")

                            Spacer()

                            Text("\(currentStreak)")
                        }

                        HStack {

                            Text("Hours since action")

                            Spacer()

                            Text(
                                hoursSinceActivity.formatted(
                                    .number.precision(
                                        .fractionLength(1)
                                    )
                                )
                            )
                        }

                        HStack {

                            Text("32-hour goal streak")

                            Spacer()

                            Text(
                                isGoalStreakBroken
                                ? "BROKEN"
                                : "VALID"
                            )
                            .foregroundStyle(
                                isGoalStreakBroken
                                ? .red
                                : .green
                            )
                        }

                        HStack {

                            Text("Freezes remaining")

                            Spacer()

                            Text("\(remainingFreezes)")
                        }
                    }
                    .font(.subheadline)
                    .padding(16)
                    .background(
                        Color.white.opacity(0.08),
                        in: RoundedRectangle(
                            cornerRadius: 16
                        )
                    )

                    // MARK: - Daily Actions

                    if isGoalActive {

                        // Only show Learned when
                        // the goal is still active.

                        Button {

                            record(.learned)

                        } label: {

                            JourneyLearningButton(
                                isLogged: todayStatus == .learned,
                                isEnabled: canLogToday
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!canLogToday)

                        // Only show Freeze while
                        // the goal is active.

                        Button {

                            record(.frozen)

                        } label: {

                            JourneyFreezeButton(
                                isFrozen: todayStatus == .frozen,
                                isEnabled: canFreezeToday
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!canFreezeToday)

                    } else if shouldShowGoalResult {

                        // Display immediately after
                        // the 32-hour streak breaks.

                        JourneyGoalResult(
                            isCompleted: isCompleted
                        )

                        Button("Set a new goal") {

                            reset()

                        }
                        .buttonStyle(.borderedProminent)
                        .tint(JourneyColor.orange)
                    }

                    // MARK: - Time Controls

                    VStack(spacing: 12) {

                        Text("Advance Simulated Time")
                            .font(.headline)

                        HStack(spacing: 10) {

                            Button("+1 Hour") {
                                advance(hours: 1)
                            }

                            Button("+8 Hours") {
                                advance(hours: 8)
                            }

                            Button("+24 Hours") {
                                advance(hours: 24)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(JourneyColor.orange)

                        Text(
                            "Time only moves forward. " +
                            "Once the streak breaks, " +
                            "the goal ends immediately."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    }

                    // MARK: - Activity History

                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {

                        Text("Simulated Activity History")
                            .font(.headline)

                        if sortedActivities.isEmpty {

                            Text(
                                "No activities recorded yet."
                            )
                            .foregroundStyle(.secondary)

                        } else {

                            ForEach(
                                Array(
                                    sortedActivities.enumerated()
                                ),
                                id: \.offset
                            ) { _, activity in

                                HStack {

                                    Image(
                                        systemName:
                                            activity.status == .learned
                                            ? "flame.fill"
                                            : "snowflake"
                                    )
                                    .foregroundStyle(
                                        activity.status == .learned
                                        ? JourneyColor.orange
                                        : JourneyColor.cyan
                                    )

                                    Text(
                                        activity.date.formatted(
                                            .dateTime
                                                .month(.abbreviated)
                                                .day()
                                                .hour()
                                                .minute()
                                        )
                                    )

                                    Spacer()

                                    Text(
                                        activity.status == .learned
                                        ? "Learned"
                                        : "Frozen"
                                    )
                                }
                                .font(.subheadline)
                            }
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                    // MARK: - Reset Simulation

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

    // MARK: - Record Activity

    private func record(
        _ status: LearningDayStatus
    ) {

        // No actions are allowed when
        // the goal fails or expires.

        guard canLogToday else {
            return
        }

        if status == .frozen {

            guard canFreezeToday else {
                return
            }
        }

        let activity = LearningDayRecord(
            date: simulatedNow,
            status: status
        )

        activities.append(activity)
    }

    // MARK: - Advance Clock

    private func advance(hours: Int) {

        simulatedNow = simulatedNow.addingTimeInterval(
            TimeInterval(hours) * 60 * 60
        )
    }

    // MARK: - Reset Simulation

    private func reset() {

        // Create a fresh simulated goal.

        let newStart = Date()

        goalStart = newStart
        simulatedNow = newStart

        // Clear only the DEBUG simulation records.
        // This does not touch UserDefaults or
        // the real Activities Calendar history.

        activities = []
    }
}

#Preview {

    JourneyTesting()
}

#endif
