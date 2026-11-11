
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

    var goalEndDate: Date {

        let start = calendar.startOfDay(for: goal.createdAt)

        switch goal.duration {

        case .week:
            return calendar.date(
                byAdding: .day,
                value: 7,
                to: start
            ) ?? start

        case .month:
            return calendar.date(
                byAdding: .month,
                value: 1,
                to: start
            ) ?? start

        case .year:
            return calendar.date(
                byAdding: .year,
                value: 1,
                to: start
            ) ?? start
        }
    }

    var goalIsActive: Bool {

        let currentDay = calendar.startOfDay(for: today)
        let start = calendar.startOfDay(for: goal.createdAt)

        return currentDay >= start
            && currentDay < goalEndDate
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

    // MARK: - Today's Status

    var todayStatus: LearningDayStatus? {
        status(for: today)
    }

    var canLogToday: Bool {
        goalIsActive && todayStatus == nil
    }

    var canFreezeToday: Bool {
        canLogToday && frozenDays < freezeLimit
    }

    // MARK: - Goal Records

    private var goalRecords: [LearningDayRecord] {

        let start = calendar.startOfDay(for: goal.createdAt)

        return records.filter {
            $0.date >= start && $0.date < goalEndDate
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

    // MARK: - Streak

    var currentStreak: Int {

        let sortedRecords = goalRecords.sorted {
            $0.date < $1.date
        }

        guard let lastRecord = sortedRecords.last else {
            return 0
        }

        // A streak expires after 32 hours of inactivity.
        if today.timeIntervalSince(lastRecord.date) > streakTimeLimit {
            return 0
        }

        var streak = 0
        var previousDate: Date?

        for record in sortedRecords {

            if let previousDate {

                let elapsed = record.date.timeIntervalSince(
                    previousDate
                )

                // A gap longer than 32 hours breaks the streak.
                if elapsed > streakTimeLimit {
                    streak = 0
                }
            }

            switch record.status {

            case .learned:
                // Learning increases the streak.
                streak += 1

            case .frozen:
                // Freezing preserves the existing streak.
                break
            }

            previousDate = record.date
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

        // Refresh the current date and time.
        today = Date()

        // Allow only one action per calendar day.
        guard canLogToday else {
            return
        }

        // Check the remaining Freeze allowance.
        if status == .frozen {
            guard canFreezeToday else {
                return
            }
        }

        // Save the actual timestamp, not midnight.
        let newRecord = LearningDayRecord(
            date: today,
            status: status
        )

        records.append(newRecord)

        storage.save(records, for: goal.id)
    }

    // MARK: - Calendar Status

    func status(for date: Date) -> LearningDayStatus? {

        records.first {
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

        // Display Sunday as the first weekday.
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
        // Refresh the time for both the midnight reset
        // and the 32-hour streak deadline.
        today = Date()
    }
}
