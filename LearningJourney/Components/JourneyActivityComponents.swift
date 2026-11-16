
import SwiftUI

// MARK: - Statistics Card




struct JourneyStatsCard: View {

    let title: String
    let count: Int
    let symbol: String
    let color: Color

    private let cardShape = RoundedRectangle(
        cornerRadius: 34,
        style: .continuous
    )

    var body: some View {

        VStack(spacing: 5) {

            Image(systemName: symbol)
                .font(.system(size: 22))
                .foregroundStyle(color)

            Text("\(count) \(count == 1 ? "day" : "days")")
                .font(JourneyFont.buttonLabel)
                .foregroundStyle(.white)

            Text(title)
                .font(JourneyFont.caption)
                .foregroundStyle(.white)

        }
        .frame(maxWidth: .infinity)
        .frame(height: 102)

        // Dark interior from the Sketch reference.
        .background {
            cardShape.fill(Color.black.opacity(0.75))
        }

        // Apple's native Liquid Glass.
        .glassEffect(
            .clear,
            in: cardShape
        )

        // Subtle illuminated edge.
        .overlay {
            cardShape
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.30),
                            .white.opacity(0.08),
                            .white.opacity(0.03),
                            .white.opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
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

