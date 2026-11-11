import SwiftUI

// MARK: - Statistics Card

struct JourneyStatsCard: View {

    let title: String
    let count: Int
    let symbol: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: symbol)
                .font(.system(size: 22))
                .foregroundStyle(color)

            Text("\(count) \(count == 1 ? "day" : "days")")
                .font(JourneyFont.buttonLabel)
                .foregroundStyle(JourneyColor.text)

            Text(title)
                .font(JourneyFont.caption)
                .foregroundStyle(JourneyColor.text)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 102)
        .background(
            JourneyColor.statsBackground,
            in: RoundedRectangle(cornerRadius: 34)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 34)
                .strokeBorder(JourneyColor.statsBorder, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.45), radius: 24, x: 0, y: 18)
    }
}

// MARK: - Goal Result

struct JourneyGoalResult: View {

    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: isCompleted ? "hands.clap.fill" : "xmark.seal")
                .font(.system(size: 40))
                .foregroundStyle(JourneyColor.orange)
                .frame(width: 50, height: 51)

            VStack(spacing: 4) {
                Text(
                    isCompleted
                        ? "Well done!"
                        : "You didn't reach your goal this time."
                )
                .font(JourneyFont.alertLabel)
                .foregroundStyle(JourneyColor.text)
                .multilineTextAlignment(.center)

                Text(
                    isCompleted
                        ? "Ready for your next goal?"
                        : "Want to set another goal?"
                )
                .font(JourneyFont.body)
                .foregroundStyle(JourneyColor.secondaryText)
                .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

