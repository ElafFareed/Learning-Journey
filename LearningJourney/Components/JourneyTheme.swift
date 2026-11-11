import SwiftUI

// MARK: - Shared theme

// MARK: - Colors from Sketch

enum JourneyColor {

    // MARK: - General

    static let background = Color.black

    static let text = Color.white

    static let secondaryText = Color(white: 0.60)

    static let toolbarSubtitle = secondaryText

    // Symbol BG Dark
    static let surface = Color(
        red: 0.200,
        green: 0.200,
        blue: 0.200
    )

    // MARK: - Accent Colors

    // 8 Blue
    static let primary = Color(
        red: 0 / 255,
        green: 145 / 255,
        blue: 255 / 255
    )

    // 2 Orange
    static let orange = Color(
        red: 1.000,
        green: 0.573,
        blue: 0.188
    )

    //  7 Cyan
    // Approximate until exact RGB is confirmed
    static let cyan = Color(
        red: 48 / 255,
        green: 200 / 255,
        blue: 235 / 255
    )

    // Buttons

    static let durationBackground = Color(
        red: 38 / 255,
        green: 38 / 255,
        blue: 38 / 255
    )

    static let disabledButton = Color(
        red: 26 / 255,
        green: 26 / 255,
        blue: 26 / 255
    )

    static let borderedButton = Color(
        red: 235 / 255,
        green: 235 / 255,
        blue: 245 / 255
    ).opacity(0.30)

    // MARK: - Toolbars

    static let darkGlass = Color.black.opacity(0.40)

    static let darkCircle = disabledButton

    static let toolbarShadow = Color.black.opacity(0.05)

    static let toolbarSymbolBackground = Color(
        red: 0.210,
        green: 0.405,
        blue: 0.600
    )

    static let toolbarSymbolDim = Color(
        red: 0.749,
        green: 0.749,
        blue: 0.749
    )

    // MARK: - Activity

    // Background for Learned/Frozen statistics cards
    static let statsBackground = Color(
        red: 26 / 255,
        green: 26 / 255,
        blue: 26 / 255
    ).opacity(0.50)

    // Light border around statistics cards
    static let statsBorder = Color.white.opacity(0.20)

    // Background for learned dates
    static let learnedDayBackground = orange.opacity(0.15)

    // Background for frozen dates
    static let frozenDayBackground = cyan.opacity(0.15)

    // MARK: - Alerts

    static let alertBase = Color(
        red: 18 / 255,
        green: 18 / 255,
        blue: 18 / 255
    )

    static let alertPrimaryOverlay = Color.black.opacity(0.67)

    static let alertSecondary = Color(
        red: 0.463,
        green: 0.463,
        blue: 0.502,
        opacity: 0.24
    )

    // MARK: - Text Fields

    static let textFieldPlaceholder = Color(
        red: 0.922,
        green: 0.922,
        blue: 0.961,
        opacity: 0.30
    )

    static let textFieldCursor = Color(
        red: 194 / 255,
        green: 194 / 255,
        blue: 194 / 255
    )

    // MARK: - Date & Time

    // Sketch symbol backing reference.
    // Not displayed behind actual calendar dates.
    static let dateSketchBackground = Color(
        red: 54 / 255,
        green: 103 / 255,
        blue: 153 / 255
    )
}

enum JourneyFont {

    // General Typography

    static let title = Font.system(size: 34, weight: .bold)

    static let subtitle = Font.system(size: 15, weight: .medium)

    static let body = Font.system(size: 17, weight: .regular)

    static let buttonLabel = Font.system(size: 17, weight: .medium)

    static let textField = Font.system(size: 17, weight: .medium)

    static let playButtonLabel = Font.system(size: 17, weight: .regular)

    static let alertLabel = Font.system(size: 17, weight: .semibold)

    static let caption = Font.system(size: 12, weight: .regular)

    static let flame = Font.system(size: 36, weight: .bold)

    // Date Typography

    static let defaultDate = Font.system(size: 20, weight: .regular)

    static let selectedDate = Font.system(size: 24, weight: .medium)

    // Onboarding Typography

    static let onboardingTitleRegular = Font.system(size: 34, weight: .regular)

    static let onboardingTitleBold = Font.system(size: 34, weight: .bold)

    static let onboardingSubtitle = Font.system(size: 17, weight: .regular)

    static let onboardingFieldLabel = Font.system(size: 16, weight: .regular)

    static let onboardingHelper = Font.system(size: 12, weight: .regular)
}

