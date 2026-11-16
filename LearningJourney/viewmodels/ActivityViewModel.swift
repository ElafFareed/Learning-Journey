
import Foundation
import Combine

@MainActor
final class ActivityViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var records: [LearningDayRecord] = []
    @Published private(set) var today = Date()

    // MARK: - Properties

    let goal: LearningGoal

    private let storage = LearningRecordStorage()
    private let calendar = Calendar.current

    private let streakTimeLimit: TimeInterval = 32 * 60 * 60

    // MARK: - Initialization

    init(goal: LearningGoal) {
        self.goal = goal
        self.records = storage.load(for: goal.id)
    }

    // MARK: - Goal Duration

    private var goalStartDate: Date {
        calendar.startOfDay(for: goal.createdAt)
    }

    var goalEndDate: Date {

        switch goal.duration {

        case .week:
            return calendar.date(
                byAdding: .day,
                value: 7,
                to: goalStartDate
            ) ?? goalStartDate

        case .month:
            return calendar.date(
                byAdding: .month,
                value: 1,
                to: goalStartDate
            ) ?? goalStartDate

        case .year:
            return calendar.date(
                byAdding: .year,
                value: 1,
                to: goalStartDate
            ) ?? goalStartDate
        }
    }

    var goalIsActive: Bool {

        let currentDay = calendar.startOfDay(for: today)

        return currentDay >= goalStartDate &&
               currentDay < goalEndDate
    }

    // MARK: - Freeze Limits

    var freezeLimit: Int {

        switch goal.duration {

        case .week:
            return 2

        case .month:
            return 8

        case .year:
            return 96
        }
    }

    var remainingFreezes: Int {
        max(0, freezeLimit - frozenDays)
    }

    // MARK: - Today's Status

    var todayStatus: LearningDayStatus? {
        status(for: today)
    }

    var canLogToday: Bool {
        goalIsActive && todayStatus == nil
    }

    var canFreezeToday: Bool {
        canLogToday && remainingFreezes > 0
    }

    // MARK: - Goal Records

    private var goalRecords: [LearningDayRecord] {

        records.filter {
            $0.date >= goalStartDate &&
            $0.date < goalEndDate
        }
    }

    private var sortedGoalRecords: [LearningDayRecord] {

        goalRecords.sorted {
            $0.date < $1.date
        }
    }

    // MARK: - Counters

    var learnedDays: Int {

        goalRecords.filter {
            $0.status == .learned
        }.count
    }

    var frozenDays: Int {

        goalRecords.filter {
            $0.status == .frozen
        }.count
    }

    // MARK: - Goal Completion

    var totalGoalDays: Int {

        calendar.dateComponents(
            [.day],
            from: goalStartDate,
            to: goalEndDate
        ).day ?? 0
    }

    // Freeze substitutes for a required learning day.

    var requiredLearnedDays: Int {
        max(0, totalGoalDays - frozenDays)
    }

    // Each day must be covered by Learned or Freeze.

    var coveredDays: Int {
        learnedDays + frozenDays
    }

    // MARK: - Permanent Goal Streak Failure

    var isGoalStreakBroken: Bool {

        // The first deadline begins when the goal
        // is created, not at midnight.

        var previousActivityDate = goal.createdAt

        // Check every recorded action in chronological order.
        // A past gap cannot be repaired by later activity.

        for record in sortedGoalRecords {

            let elapsed = record.date.timeIntervalSince(
                previousActivityDate
            )

            if elapsed > streakTimeLimit {
                return true
            }

            previousActivityDate = record.date
        }

        // Once the goal ends, stop measuring inactivity
        // for this goal. Otherwise, an old completed goal
        // could incorrectly fail days later.

        let evaluationDate = min(
            today,
            goalEndDate
        )

        let inactivity = evaluationDate.timeIntervalSince(
            previousActivityDate
        )

        return inactivity > streakTimeLimit
    }

    // Goal success requires both:
    // 1. Every calendar day covered.
    // 2. No 32-hour streak break during the goal.

    var isGoalCompleted: Bool {

        coveredDays == totalGoalDays &&
        frozenDays <= freezeLimit &&
        !isGoalStreakBroken
    }

    // MARK: - Goal Result

    var shouldShowGoalResult: Bool {

        let currentDay = calendar.startOfDay(for: today)

        return currentDay >= goalEndDate
    }

    // MARK: - Current Streak

    var currentStreak: Int {

        let sortedRecords = sortedGoalRecords

        guard let lastRecord = sortedRecords.last else {
            return 0
        }

        // The current streak also expires after
        // more than 32 hours of inactivity.

        if today.timeIntervalSince(lastRecord.date) >
            streakTimeLimit {
            return 0
        }

        var streak = 0

        // First activity is measured from goal creation.

        var previousActivityDate = goal.createdAt

        for record in sortedRecords {

            let elapsed = record.date.timeIntervalSince(
                previousActivityDate
            )

            if elapsed > streakTimeLimit {

                // A new streak can start, but the goal
                // remains permanently failed.

                streak = 0
            }

            switch record.status {

            case .learned:
                // Learning increases the current streak.
                streak += 1

            case .frozen:
                // Freeze protects the streak without
                // increasing the number of Learned days.
                break
            }

            previousActivityDate = record.date
        }

        return streak
    }

    // MARK: - Daily Actions

    func logLearningToday() {
        record(.learned)
    }

    func freezeToday() {
        record(.frozen)
    }

    private func record(_ status: LearningDayStatus) {

        // Use the current real date and time.

        today = Date()

        // One action per calendar day.

        guard canLogToday else {
            return
        }

        // Freezes cannot exceed the allowance.

        if status == .frozen {
            guard canFreezeToday else {
                return
            }
        }

        let newRecord = LearningDayRecord(
            date: today,
            status: status
        )

        records.append(newRecord)

        storage.save(
            records,
            for: goal.id
        )
    }

    // MARK: - Calendar Status

    func status(for date: Date) -> LearningDayStatus? {

        goalRecords.first {
            calendar.isDate(
                $0.date,
                inSameDayAs: date
            )
        }?.status
    }

    // MARK: - Weekly Calendar

    var weekDays: [Date] {

        let weekday = calendar.component(
            .weekday,
            from: today
        )

        let start = calendar.startOfDay(for: today)

        // Sunday is the first day of the week.

        guard let firstDay = calendar.date(
            byAdding: .day,
            value: -(weekday - 1),
            to: start
        ) else {
            return []
        }

        return (0..<7).compactMap { offset in
            calendar.date(
                byAdding: .day,
                value: offset,
                to: firstDay
            )
        }
    }

    var weekDayNumbers: [Int] {

        weekDays.map {
            calendar.component(.day, from: $0)
        }
    }

    var weekDayStyles: [JourneyDayStyle] {

        weekDays.map { date in

            switch status(for: date) {

            case .learned:
                return .learned

            case .frozen:
                return .frozen

            case nil:
                return calendar.isDate(
                    date,
                    inSameDayAs: today
                ) ? .today : .normal
            }
        }
    }

    // MARK: - Refresh

    func refreshDay() {

        // Refresh midnight availability
        // and the 32-hour streak deadline.

        today = Date()
    }
}
