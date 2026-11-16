
import SwiftUI

struct ActivitiesCalendarView: View {

    @Environment(\.dismiss) private var dismiss

    let goal: LearningGoal

    @State private var records: [LearningDayRecord] = []

    private let calendar = Calendar.current

    private let weekdays = [
        "SUN", "MON", "TUE", "WED",
        "THU", "FRI", "SAT"
    ]

    // MARK: - Journey Start

    private var journeyStartDate: Date {

        // Use the earliest saved activity, including
        // activities belonging to previous goals.

        guard let earliestRecord = records.min(
            by: { $0.date < $1.date }
        ) else {
            return goal.createdAt
        }

        return min(
            earliestRecord.date,
            goal.createdAt
        )
    }

    // MARK: - Calendar Months

    private var months: [Date] {

        guard let firstMonth = calendar.dateInterval(
            of: .month,
            for: journeyStartDate
        )?.start else {
            return []
        }

        // Continue through December of next year.

        let currentYear = calendar.component(
            .year,
            from: Date()
        )

        let lastYear = currentYear + 1

        guard let lastMonth = calendar.date(
            from: DateComponents(
                year: lastYear,
                month: 12,
                day: 1
            )
        ) else {
            return []
        }

        let monthCount = calendar.dateComponents(
            [.month],
            from: firstMonth,
            to: lastMonth
        ).month ?? 0

        guard monthCount >= 0 else {
            return []
        }

        return (0...monthCount).compactMap { offset in
            calendar.date(
                byAdding: .month,
                value: offset,
                to: firstMonth
            )
        }
    }

    // MARK: - Day Status

    private func style(for date: Date) -> JourneyDayStyle {

        // Check all saved goals, regardless of whether
        // their results were completed or unsuccessful.

        if let record = records.last(where: {
            calendar.isDate(
                $0.date,
                inSameDayAs: date
            )
        }) {

            switch record.status {

            case .learned:
                return .learned

            case .frozen:
                return .frozen
            }
        }

        if calendar.isDateInToday(date) {
            return .today
        }

        return .normal
    }

    // MARK: - Body

    var body: some View {

        VStack(spacing: 0) {

            // MARK: - Header

            HStack {

                Button {
                    dismiss()
                } label: {

                    JourneyCircleIconButton(
                        symbol: "chevron.left"
                    )
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Activities")
                    .font(JourneyFont.buttonLabel)
                    .foregroundStyle(JourneyColor.text)

                Spacer()

                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // MARK: - Calendar

            ScrollView {

                LazyVStack(spacing: 0) {

                    ForEach(months, id: \.self) { month in

                        monthSection(month)

                        Divider()
                            .overlay(
                                JourneyColor.secondaryText
                                    .opacity(0.25)
                            )
                            .padding(.vertical, 16)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .background(JourneyColor.background)
        .navigationBarBackButtonHidden()

        // MARK: - Load History

        .onAppear {
            records = LearningRecordStorage()
                .loadAllRecords()
        }
    }

    // MARK: - Month Section

    private func monthSection(_ month: Date) -> some View {

        VStack(alignment: .leading, spacing: 12) {

            Text(
                month.formatted(
                    .dateTime.month(.wide).year()
                )
            )
            .font(JourneyFont.buttonLabel)
            .foregroundStyle(JourneyColor.text)

            // MARK: - Weekdays

            HStack(spacing: 0) {

                ForEach(
                    weekdays,
                    id: \.self
                ) { weekday in

                    Text(weekday)
                        .font(
                            .system(
                                size: 11,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(
                            JourneyColor.secondaryText
                        )
                        .frame(maxWidth: .infinity)
                }
            }

            monthGrid(month)
        }
    }

    // MARK: - Month Grid

    private func monthGrid(_ month: Date) -> some View {

        let firstWeekday = calendar.component(
            .weekday,
            from: month
        )

        // Sunday is the first weekday.

        let leadingSpaces = firstWeekday - 1

        let numberOfDays = calendar.range(
            of: .day,
            in: .month,
            for: month
        )?.count ?? 0

        let totalCells = leadingSpaces + numberOfDays

        let columns = Array(
            repeating: GridItem(
                .flexible(),
                spacing: 0
            ),
            count: 7
        )

        return LazyVGrid(
            columns: columns,
            spacing: 8
        ) {

            ForEach(
                0..<totalCells,
                id: \.self
            ) { index in

                if index < leadingSpaces {

                    Color.clear
                        .frame(height: 44)

                } else {

                    let day = index - leadingSpaces + 1

                    if let date = calendar.date(
                        byAdding: .day,
                        value: day - 1,
                        to: month
                    ) {

                        if calendar.startOfDay(for: date) <
                            calendar.startOfDay(
                                for: journeyStartDate
                            ) {

                            // Before the first known
                            // learning activity.

                            Color.clear
                                .frame(height: 44)

                        } else {

                            JourneyDayCell(
                                day: day,
                                style: style(for: date)
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }
}

#Preview {

    NavigationStack {

        ActivitiesCalendarView(
            goal: LearningGoal(
                topic: "Swift",
                duration: .week
            )
        )
    }
    .preferredColorScheme(.dark)
}
