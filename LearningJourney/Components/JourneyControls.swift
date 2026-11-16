
import SwiftUI

// MARK: - General Button

struct JourneyButton: View {

    let title: String
    var color: Color = JourneyColor.orange

    var body: some View {

        Text(title)
            .font(JourneyFont.buttonLabel)
            .foregroundStyle(JourneyColor.text)
            .padding(.horizontal, 24)
            .frame(height: 48)
            .glassEffect(
                .regular.tint(color).interactive(),
                in: Capsule()
            )
    }
}

// MARK: - Duration Button

struct JourneyDurationButton: View {

    let title: String
    var isSelected = false

    var body: some View {

        Text(title)
            .font(JourneyFont.buttonLabel)
            .foregroundStyle(
                isSelected
                    ? JourneyColor.text
                    : JourneyColor.secondaryText
            )
            .padding(.horizontal, 20)
            .frame(height: 46)
            .glassEffect(
                .regular
                    .tint(
                        isSelected
                            ? JourneyColor.orange
                            : JourneyColor.durationBackground
                    )
                    .interactive(),
                in: Capsule()
            )
    }
}

// MARK: - Learning Button

struct JourneyLearningButton: View {

    var isLogged = false
    var isEnabled = true

    private var isDisabled: Bool {
        isLogged || !isEnabled
    }

    var body: some View {

        Text(
            isLogged
                ? "Logged as Learned"
                : "Log as Learned"
        )
        .font(JourneyFont.buttonLabel)
        .foregroundStyle(
            isDisabled
                ? JourneyColor.secondaryText
                : JourneyColor.text
        )
        .frame(width: 272, height: 272)
        .glassEffect(
            .regular
                .tint(
                    isDisabled
                        ? JourneyColor.disabledButton
                        : JourneyColor.orange
                )
                .interactive(!isDisabled),
            in: Circle()
        )
    }
}

// MARK: - Freeze Button

struct JourneyFreezeButton: View {

    var isFrozen = false
    var isEnabled = true

    private var isDisabled: Bool {
        isFrozen || !isEnabled
    }

    var body: some View {

        Text(
            isFrozen
                ? "Frozen for a day"
                : "Freeze for a day"
        )
        .font(JourneyFont.buttonLabel)
        .foregroundStyle(
            isDisabled
                ? JourneyColor.secondaryText
                : JourneyColor.text
        )
        .frame(width: 272, height: 46)
        .glassEffect(
            .regular
                .tint(
                    isDisabled
                        ? JourneyColor.disabledButton
                        : JourneyColor.cyan
                )
                .interactive(!isDisabled),
            in: Capsule()
        )
    }
}

// MARK: - Play Button

struct JourneyPlayButton: View {

    var body: some View {

        HStack(spacing: 4) {
            Image(systemName: "play.fill")
            Text("Play")
        }
        .font(JourneyFont.playButtonLabel)
        .foregroundStyle(JourneyColor.primary)
        .padding(.horizontal, 12)
        .frame(height: 32)
        .glassEffect(
            .regular.interactive(),
            in: Capsule()
        )
    }
}

// MARK: - Text Field

struct JourneyTextField: View {

    let placeholder: String
    @Binding var text: String

    var body: some View {

        TextField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .foregroundStyle(
                    JourneyColor.textFieldPlaceholder
                )
        )
        .font(JourneyFont.textField)
        .foregroundStyle(JourneyColor.text)
        .tint(JourneyColor.orange)
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(
            JourneyColor.surface,
            in: RoundedRectangle(cornerRadius: 14)
        )
    }
}

// MARK: - Underlined Text Field

struct JourneyUnderlinedTextField: View {

    let placeholder: String
    @Binding var text: String

    var body: some View {

        VStack(spacing: 0) {

            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                    .foregroundStyle(
                        JourneyColor.secondaryText
                    )
            )
            .font(JourneyFont.textField)
            .foregroundStyle(JourneyColor.text)
            .tint(JourneyColor.orange)
            .frame(height: 44)

            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(height: 1)
        }
    }
}

// MARK: - Toolbar Style

enum JourneyToolbarStyle {
    case lightTinted
    case darkTinted
    case dark
}

// MARK: - Toolbar Circle

struct JourneyToolbarCircle: View {

    var style: JourneyToolbarStyle = .darkTinted
    var size: CGFloat = 120

    private var tintColor: Color {

        switch style {
        case .lightTinted, .darkTinted:
            return JourneyColor.primary
        case .dark:
            return JourneyColor.darkCircle
        }
    }

    var body: some View {

        Circle()
            .fill(.clear)
            .frame(width: size, height: size)
            .glassEffect(
                .regular.tint(tintColor),
                in: Circle()
            )
    }
}

// MARK: - Circular Icon Button

struct JourneyCircleIconButton: View {

    let symbol: String

    var color: Color = JourneyColor.darkCircle
    var symbolColor: Color = .white
    var size: CGFloat = 44

    var body: some View {

        Image(systemName: symbol)
            .font(
                .system(size: 20, weight: .medium)
            )
            .foregroundStyle(symbolColor)
            .frame(width: size, height: size)
            .contentShape(Circle())
            .glassEffect(
                .regular
                    .tint(color.opacity(0.35))
                    .interactive(),
                in: Circle()
            )
    }
}

// MARK: - Toolbar Title

struct JourneyToolbarTitle: View {

    let title: String
    let subtitle: String

    var subtitleFont: Font = JourneyFont.subtitle

    var body: some View {

        VStack(alignment: .leading, spacing: 4) {

            Text(title)
                .font(JourneyFont.title)
                .foregroundStyle(JourneyColor.text)

            Text(subtitle)
                .font(subtitleFont)
                .foregroundStyle(
                    JourneyColor.toolbarSubtitle
                )
        }
    }
}

// MARK: - Navigation Bar

struct JourneyNavigationBar: View {

    let title: String

    var onBack: () -> Void
    var onConfirm: (() -> Void)? = nil

    var body: some View {

        HStack {

            Button(action: onBack) {

                JourneyCircleIconButton(
                    symbol: "chevron.left"
                )
            }
            .buttonStyle(.plain)

            Spacer()

            Text(title)
                .font(JourneyFont.buttonLabel)
                .foregroundStyle(JourneyColor.text)

            Spacer()

            if let onConfirm {

                Button(action: onConfirm) {

                    JourneyCircleIconButton(
                        symbol: "checkmark",
                        color: JourneyColor.orange
                    )
                }
                .buttonStyle(.plain)

            } else {

                Color.clear
                    .frame(width: 44, height: 44)
            }
        }
    }
}

// MARK: - Flame

struct JourneyFlame: View {

    var body: some View {

        Image(systemName: "flame.fill")
            .font(JourneyFont.flame)
            .foregroundStyle(JourneyColor.orange)
            .frame(width: 67, height: 43)
    }
}

// MARK: - Alert Button Style

enum JourneyAlertButtonStyle {
    case primary
    case secondary
}

// MARK: - Alert Button

struct JourneyAlertButton: View {

    let title: String

    var style: JourneyAlertButtonStyle = .primary
    var tint: Color = JourneyColor.primary

    var body: some View {

        Text(title)
            .font(JourneyFont.alertLabel)
            .foregroundStyle(JourneyColor.text)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .glassEffect(
                .regular
                    .tint(
                        style == .primary
                            ? tint
                            : JourneyColor.alertSecondary
                    )
                    .interactive(),
                in: Capsule()
            )
    }
}

// MARK: - Alert

struct JourneyAlert: View {

    let title: String
    let message: String

    var primaryTitle = "Primary"
    var secondaryTitle = "Secondary"
    var primaryTint: Color = JourneyColor.primary

    let onPrimary: () -> Void
    let onSecondary: () -> Void

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            VStack(alignment: .leading, spacing: 10) {

                Text(title)
                    .font(JourneyFont.alertLabel)
                    .foregroundStyle(JourneyColor.text)

                Text(message)
                    .font(JourneyFont.body)
                    .foregroundStyle(
                        JourneyColor.secondaryText
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }

            HStack(spacing: 8) {

                Button(action: onSecondary) {

                    JourneyAlertButton(
                        title: secondaryTitle,
                        style: .secondary
                    )
                }

                Button(action: onPrimary) {

                    JourneyAlertButton(
                        title: primaryTitle,
                        style: .primary,
                        tint: primaryTint
                    )
                }
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(width: 300)
        .glassEffect(
            .regular,
            in: RoundedRectangle(cornerRadius: 34)
        )
    }
}
