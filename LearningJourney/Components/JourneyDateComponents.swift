import SwiftUI

// MARK: - Date Visual States

enum JourneyDayStyle {
    case normal
    case selected
    case current
    case currentSelected
    case today
    case learned
    case frozen
}

// MARK: - Day Cell

struct JourneyDayCell: View {

    let day: Int
    var style: JourneyDayStyle = .normal

    private var textColor: Color {
        switch style {
        case .normal:
            JourneyColor.text
        case .selected, .current:
            JourneyColor.primary
        case .currentSelected, .today:
            JourneyColor.text
        case .learned:
            JourneyColor.orange
        case .frozen:
            JourneyColor.cyan
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .normal:
            .clear
        case .selected, .current:
            JourneyColor.primary.opacity(0.12)
        case .currentSelected:
            JourneyColor.primary
        case .today:
            JourneyColor.orange
        case .learned:
            JourneyColor.learnedDayBackground
        case .frozen:
            JourneyColor.frozenDayBackground
        }
    }

    private var dateFont: Font {
        switch style {
        case .selected, .currentSelected, .today:
            JourneyFont.selectedDate
        default:
            JourneyFont.defaultDate
        }
    }

    var body: some View {
        Text("\(day)")
            .font(dateFont)
            .foregroundStyle(textColor)
            .frame(width: 44, height: 44)
            .background(backgroundColor, in: Circle())
    }
}

// MARK: - Week Row

struct JourneyWeekRow: View {

    let days: [Int]
    let styles: [JourneyDayStyle]

    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days.indices, id: \.self) { index in
                VStack(spacing: 4) {
                    Text(weekdays[index % 7])
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(JourneyColor.text)

                    JourneyDayCell(
                        day: days[index],
                        style: index < styles.count ? styles[index] : .normal
                    )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Date Picker Week

struct JourneyDatePickerWeek: View {

    let days: [Int]
    let styles: [JourneyDayStyle]

    var body: some View {
        JourneyWeekRow(days: days, styles: styles)
            .frame(height: 66)
    }
}
