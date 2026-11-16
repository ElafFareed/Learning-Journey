
import SwiftUI

#if DEBUG

struct JourneyTesting: View {

    // MARK: - Test State

    @State private var duration: LearningDuration = .week
    @State private var simulatedNow: Date
    @State private var activities: [LearningDayRecord] = []

    // MARK: - Test Configuration

    private let goalStart: Date
    private let calendar = Calendar.current

    private let streakTimeLimit: TimeInterval = 32 * 60 * 60

    init() {
        let start = Date()

        self.goalStart = start
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

        return min(max(elapsedDays + 1, 1), totalDays)
    }

    private var isExpired: Bool {
        simulatedNow >= goalEnd
    }

    // MARK: - Freeze Limits

    private var freezeLimit: Int {

        switch duration {
        case .week: return 2
        case .month: return 8
        case .year: return 96
        }
    }

    // MARK: - Counters

    private var learnedDays: Int {
        activities.filter { $0.status == .learned }.count
    }

    private var frozenDays: Int {
        activities.filter { $0.status == .frozen }.count
    }

    private var remainingFreezes: Int {
        max(0, freezeLimit - frozenDays)
    }

    private var coveredDays: Int {
        learnedDays + frozenDays
    }

    private var hasActivityToday: Bool {

        activities.contains {
            calendar.isDate(
                $0.date,
                inSameDayAs: simulatedNow
            )
        }
    }

    // MARK: - 32-Hour Streak

    private var sortedActivities: [LearningDayRecord] {
        activities.sorted { $0.date < $1.date }
    }

    private var lastActivityDate: Date {
        sortedActivities.last?.date ?? goalStart
    }

    private var hoursSinceActivity: Double {

        max(
            0,
            simulatedNow.timeIntervalSince(lastActivityDate) / 3600
        )
    }

    private var isGoalStreakBroken: Bool {

        var previousDate = goalStart

        for activity in sortedActivities {

            if activity.date.timeIntervalSince(previousDate)
                > streakTimeLimit {
                return true
            }

            previousDate = activity.date
        }

        let evaluationDate = min(simulatedNow, goalEnd)

        return evaluationDate.timeIntervalSince(previousDate)
            > streakTimeLimit
    }

    private var currentStreak: Int {

        guard let lastActivity = sortedActivities.last else {
            return 0
        }

        if simulatedNow.timeIntervalSince(lastActivity.date)
            > streakTimeLimit {
            return 0
        }

        var streak = 0
        var previousDate = goalStart

        for activity in sortedActivities {

            if activity.date.timeIntervalSince(previousDate)
                > streakTimeLimit {
                streak = 0
            }

            if activity.status == .learned {
                streak += 1
            }

            previousDate = activity.date
        }

        return streak
    }

    // MARK: - Goal Completion

    private var isCompleted: Bool {

        coveredDays == totalDays &&
        frozenDays <= freezeLimit &&
        !isGoalStreakBroken
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 24) {

                    Text("Journey Test Mode")
                        .font(.title2.bold())

                    Text("DEBUG ONLY — SIMULATED TIME")
                        .font(.caption)
                        .foregroundStyle(.cyan)

                    // MARK: - Duration

                    Picker("Duration", selection: $duration) {

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

                        Text("\(currentDay) / \(totalDays)")
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

                        Text(
                            isExpired
                            ? "Goal Ended"
                            : "Goal Active"
                        )
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
                        in: RoundedRectangle(cornerRadius: 16)
                    )

                    // MARK: - Daily Actions

                    if !isExpired {

                        Button {
                            record(.learned)
                        } label: {

                            JourneyLearningButton(
                                isLogged: todayStatus == .learned,
                                isEnabled: !hasActivityToday
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(hasActivityToday)

                        Button {
                            record(.frozen)
                        } label: {

                            JourneyFreezeButton(
                                isFrozen: todayStatus == .frozen,
                                isEnabled: !hasActivityToday
                                    && remainingFreezes > 0
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(
                            hasActivityToday ||
                            remainingFreezes == 0
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
                            "Missed days cannot be filled retroactively."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    }

                    // MARK: - Saved Test Actions

                    VStack(alignment: .leading, spacing: 10) {

                        Text("Simulated Activity History")
                            .font(.headline)

                        if sortedActivities.isEmpty {

                            Text("No activities recorded yet.")
                                .foregroundStyle(.secondary)

                        } else {

                            ForEach(
                                Array(sortedActivities.enumerated()),
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
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // MARK: - Reset

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

    // MARK: - Today's Status

    private var todayStatus: LearningDayStatus? {

        activities.first {
            calendar.isDate(
                $0.date,
                inSameDayAs: simulatedNow
            )
        }?.status
    }

    // MARK: - Record Activity

    private func record(_ status: LearningDayStatus) {

        guard !isExpired else { return }
        guard !hasActivityToday else { return }

        if status == .frozen {
            guard remainingFreezes > 0 else { return }
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
            TimeInterval(hours * 60 * 60)
        )
    }

    // MARK: - Reset

    private func reset() {

        simulatedNow = goalStart
        activities = []
    }
}

#Preview {
    JourneyTesting()
}

#endif

