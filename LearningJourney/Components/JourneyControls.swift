
import SwiftUI

// MARK: - General Button

struct JourneyButton: View {

    let title: String
    var color: Color = JourneyColor.orange

    var body: some View {
        Text(title)
            .font(JourneyFont.buttonLabel)
            .foregroundStyle(JourneyColor.text)
            .padding(.horizontal, 20)
            .frame(height: 48)
            .background(color, in: Capsule())
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
            .background(
                isSelected
                    ? JourneyColor.orange
                    : JourneyColor.durationBackground,
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .strokeBorder(
                        Color.white.opacity(isSelected ? 0.40 : 0.12),
                        lineWidth: 1
                    )
            }
    }
}

// MARK: - Learning Button

struct JourneyLearningButton: View {

    var isLogged = false
    var isEnabled = true

    var body: some View {
        Text(
            isLogged
                ? "Logged as Learned"
                : "Log as Learned"
        )
        .font(JourneyFont.buttonLabel)
        .foregroundStyle(
            isLogged || !isEnabled
                ? JourneyColor.secondaryText
                : JourneyColor.text
        )
        .frame(width: 272, height: 272)
        .background(
            isLogged || !isEnabled
                ? JourneyColor.disabledButton
                : JourneyColor.orange,
            in: Circle()
        )
        .overlay {
            Circle()
                .strokeBorder(
                    Color.white.opacity(0.12),
                    lineWidth: 1
                )
        }
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
        .background(
            isDisabled
                ? JourneyColor.disabledButton
                : JourneyColor.cyan,
            in: Capsule()
        )
        .overlay {
            Capsule()
                .strokeBorder(
                    Color.white.opacity(0.12),
                    lineWidth: 1
                )
        }
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
        .background(.white, in: Capsule())
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
                .foregroundStyle(JourneyColor.textFieldPlaceholder)
        )
        .font(JourneyFont.textField)
        .foregroundStyle(JourneyColor.text)
        .tint(JourneyColor.textFieldCursor)
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(JourneyColor.surface)
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
                    .foregroundStyle(JourneyColor.secondaryText)
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

    private var borderOpacity: Double {
        switch style {
        case .lightTinted:
            0.40
        case .darkTinted:
            0.70
        case .dark:
            0.10
        }
    }

    var body: some View {
        Circle()
            .fill(
                style == .dark
                    ? JourneyColor.darkCircle
                    : JourneyColor.primary
            )
            .frame(width: size, height: size)
            .overlay {
                Circle()
                    .strokeBorder(
                        Color.white.opacity(borderOpacity),
                        lineWidth: 1
                    )
            }
            .shadow(
                color: JourneyColor.toolbarShadow,
                radius: 5
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
        if #available(iOS 26.0, *) {
            iconLabel
                .glassEffect(
                    .regular.tint(color.opacity(0.35)),
                    in: .circle
                )
        } else {
            iconLabel
                .background(color, in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(
                            Color.white.opacity(0.15),
                            lineWidth: 1
                        )
                }
        }
    }

    private var iconLabel: some View {
        Image(systemName: symbol)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(symbolColor)
            .frame(width: size, height: size)
            .contentShape(Circle())
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
                .foregroundStyle(JourneyColor.toolbarSubtitle)
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

    private var backgroundColor: Color {
        switch style {
        case .primary:
            tint
        case .secondary:
            JourneyColor.alertSecondary
        }
    }

    var body: some View {
        Text(title)
            .font(JourneyFont.alertLabel)
            .foregroundStyle(JourneyColor.text)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(backgroundColor, in: Capsule())
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
        VStack(alignment: .leading, spacing: 0) {

            VStack(alignment: .leading, spacing: 10) {

                Text(title)
                    .font(JourneyFont.alertLabel)
                    .foregroundStyle(JourneyColor.text)
                    .frame(height: 22, alignment: .leading)

                Text(message)
                    .font(JourneyFont.body)
                    .foregroundStyle(JourneyColor.secondaryText)
                    .frame(height: 44, alignment: .topLeading)
            }
            .frame(width: 256, alignment: .leading)
            .padding(.leading, 8)
            .padding(.top, 8)

            Spacer(minLength: 16)

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
        .padding(14)
        .frame(width: 300, height: 184)
        .background {
            RoundedRectangle(cornerRadius: 34)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 34)
                        .fill(
                            JourneyColor.alertBase.opacity(0.40)
                        )
                }
        }
        .shadow(
            color: .black.opacity(0.16),
            radius: 25,
            x: 0,
            y: 2
        )
    }
}
