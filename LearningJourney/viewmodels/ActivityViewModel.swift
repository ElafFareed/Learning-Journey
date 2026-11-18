
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

    // MARK: - Goal State

    var goalIsActive: Bool {

        let currentDay = calendar.startOfDay(for: today)

        let isWithinDuration =
            currentDay >= goalStartDate &&
            currentDay < goalEndDate

        // A broken streak immediately ends the goal.

        return isWithinDuration && !isGoalStreakBroken
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

        goalIsActive &&
        todayStatus == nil
    }

    var canFreezeToday: Bool {

        canLogToday &&
        remainingFreezes > 0
    }

    // MARK: - Goal Records

    private var goalRecords: [LearningDayRecord] {

        records.filter {
            $0.date >= goal.createdAt &&
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

    var coveredDays: Int {
        learnedDays + frozenDays
    }

    // MARK: - Goal Completion

    var totalGoalDays: Int {

        calendar.dateComponents(
            [.day],
            from: goalStartDate,
            to: goalEndDate
        ).day ?? 0
    }

    // Each Freeze replaces one required
    // learning day.

    var requiredLearnedDays: Int {

        max(
            0,
            totalGoalDays - frozenDays
        )
    }

    // A successful goal requires:
    // 1. Every calendar day to be covered.
    // 2. Freeze usage within its limit.
    // 3. No broken 32-hour streak.

    var isGoalCompleted: Bool {

        guard shouldShowGoalResult else {
            return false
        }

        return coveredDays == totalGoalDays &&
               learnedDays >= requiredLearnedDays &&
               frozenDays <= freezeLimit &&
               !isGoalStreakBroken
    }

    // MARK: - Permanent Streak Failure

    var isGoalStreakBroken: Bool {

        // The first countdown starts when
        // the goal is created.

        var previousActivityDate = goal.createdAt

        // Check every saved activity in order.
        // Any past gap over 32 hours permanently
        // fails the current goal.

        for record in sortedGoalRecords {

            let elapsed = record.date.timeIntervalSince(
                previousActivityDate
            )

            if elapsed > streakTimeLimit {
                return true
            }

            previousActivityDate = record.date
        }

        // Do not continue counting inactivity
        // beyond the goal's scheduled end date.

        let evaluationDate = min(
            today,
            goalEndDate
        )

        let inactivity = evaluationDate.timeIntervalSince(
            previousActivityDate
        )

        return inactivity > streakTimeLimit
    }

    // MARK: - Goal Result

    var shouldShowGoalResult: Bool {

        let hasReachedEnd = today >= goalEndDate

        // Show the result at the scheduled end
        // OR immediately when the streak breaks.

        return hasReachedEnd || isGoalStreakBroken
    }

    // MARK: - Current Streak

    var currentStreak: Int {

        // Once a goal has failed, its
        // active streak is finished.

        guard !isGoalStreakBroken else {
            return 0
        }

        let sortedRecords = sortedGoalRecords

        guard let lastRecord = sortedRecords.last else {
            return 0
        }

        let evaluationDate = min(
            today,
            goalEndDate
        )

        if evaluationDate.timeIntervalSince(lastRecord.date)
            > streakTimeLimit {
            return 0
        }

        var streak = 0

        for record in sortedRecords {

            switch record.status {

            case .learned:
                streak += 1

            case .frozen:
                // Freeze protects the streak,
                // but does not increase it.
                break
            }
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

        today = Date()

        switch status {

        case .learned:
            guard canLogToday else { return }

        case .frozen:
            guard canFreezeToday else { return }
        }

        records.append(
            LearningDayRecord(
                date: today,
                status: status
            )
        )

        storage.save(records, for: goal.id)
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

        // Sunday is the first weekday.

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

        // Update the real time.
        // This also lets the UI detect
        // when the 32-hour limit is exceeded.

        today = Date()
    }
}
