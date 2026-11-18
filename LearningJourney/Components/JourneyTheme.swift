
import SwiftUI

// MARK: - Shared Theme

// MARK: - Colors from Assets.xcassets

enum JourneyColor {

    // MARK: - General

    static let background = Color("JourneyBackground")

    static let text = Color("JourneyText")

    static let secondaryText = Color("JourneySecondaryText")

    static let toolbarSubtitle = secondaryText

    // Symbol BG Dark
    static let surface = Color("JourneySurface")


    // MARK: - Accent Colors

    // Blue
    static let primary = Color("JourneyPrimary")

    // Orange
    static let orange = Color("JourneyOrange")

    // Cyan
    static let cyan = Color("JourneyCyan")


    // MARK: - Buttons

    static let durationBackground =
        Color("JourneyDurationBackground")

    static let disabledButton =
        Color("JourneyDisabledButton")

    static let borderedButton =
        Color("JourneyBorderedButton").opacity(0.30)


    // MARK: - Toolbars

    static let darkGlass =
        background.opacity(0.40)

    static let darkCircle = disabledButton

    static let toolbarShadow =
        background.opacity(0.05)

    static let toolbarSymbolBackground =
        Color("JourneyToolbarSymbolBackground")

    static let toolbarSymbolDim =
        Color("JourneyToolbarSymbolDim")


    // MARK: - Activity

    // Background for Learned/Frozen statistics cards
    static let statsBackground =
        disabledButton.opacity(0.50)

    // Light border around statistics cards
    static let statsBorder =
        text.opacity(0.20)

    // Background for learned dates
    static let learnedDayBackground =
        orange.opacity(0.15)

    // Background for frozen dates
    static let frozenDayBackground =
        cyan.opacity(0.15)


    // MARK: - Alerts

    static let alertBase =
        Color("JourneyAlertBase")

    static let alertPrimaryOverlay =
        background.opacity(0.67)

    static let alertSecondary =
        Color("JourneyAlertSecondary").opacity(0.24)


    // MARK: - Text Fields

    static let textFieldPlaceholder =
        Color("JourneyTextFieldPlaceholder").opacity(0.30)

    static let textFieldCursor =
        Color("JourneyTextFieldCursor")


    // MARK: - Date & Time

    // Sketch symbol backing reference.
    // Not displayed behind actual calendar dates.
    static let dateSketchBackground =
        Color("JourneyDateSketchBackground")
}


// MARK: - Typography

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


    // MARK: - Date Typography

    static let defaultDate = Font.system(size: 20, weight: .regular)

    static let selectedDate = Font.system(size: 24, weight: .medium)


    // MARK: - Onboarding Typography

    static let onboardingTitleRegular =
        Font.system(size: 34, weight: .regular)

    static let onboardingTitleBold =
        Font.system(size: 34, weight: .bold)

    static let onboardingSubtitle =
        Font.system(size: 17, weight: .regular)

    static let onboardingFieldLabel =
        Font.system(size: 16, weight: .regular)

    static let onboardingHelper =
        Font.system(size: 12, weight: .regular)
}
