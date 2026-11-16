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
            return JourneyColor.text

        case .selected, .current:
            return JourneyColor.primary

        case .currentSelected, .today:
            return JourneyColor.text

        case .learned:
            return JourneyColor.orange

        case .frozen:
            return JourneyColor.cyan
        }
    }

    private var glassTint: Color {

        switch style {

        case .normal:
            return .clear

        case .selected, .current, .currentSelected:
            return JourneyColor.primary.opacity(0.30)

        case .today:
            return JourneyColor.orange.opacity(0.55)

        case .learned:
            return JourneyColor.orange.opacity(0.20)

        case .frozen:
            return JourneyColor.cyan.opacity(0.20)
        }
    }

    private var dateFont: Font {

        switch style {

        case .selected, .currentSelected, .today:
            return JourneyFont.selectedDate

        default:
            return JourneyFont.defaultDate
        }
    }

    var body: some View {

        Text("\(day)")
            .font(dateFont)
            .foregroundStyle(textColor)
            .frame(width: 44, height: 44)
            .glassEffect(
                .regular.tint(glassTint),
                in: Circle()
            )
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
