import SwiftUI

/// Design tokens measured from the Doji reference screens.
enum Doji {
    static let ink = Color(red: 0.04, green: 0.03, blue: 0.04)
    static let secondary = Color(red: 0.47, green: 0.46, blue: 0.48)
    static let tertiary = Color(red: 0.70, green: 0.69, blue: 0.71)
    static let faint = Color(red: 0.89, green: 0.88, blue: 0.90)
    static let fill = Color(red: 0.95, green: 0.94, blue: 0.95)
    static let hairline = Color(red: 0.91, green: 0.90, blue: 0.92)
    static let placeholder = Color(red: 0.96, green: 0.96, blue: 0.96)
    static let red = Color(red: 0.86, green: 0.07, blue: 0.09)
    static let goodLight = Color(red: 0.42, green: 0.55, blue: 0.20)
    static let checkGreen = Color(red: 0.25, green: 0.60, blue: 0.31)
    static let rejectRed = Color(red: 0.82, green: 0.13, blue: 0.13)
    static let link = Color(red: 0.16, green: 0.35, blue: 0.85)

    /// Standard horizontal page margin.
    static let gutter: CGFloat = 20
}

extension Font {
    /// Doji sets everything in a transitional serif. The original typeface was not provided,
    /// so Apple's built-in "New York" serif (`.serif` design) stands in for it.
    static func doji(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    static let dojiLargeTitle = Font.doji(28)
    static let dojiTitle = Font.doji(24)
    static let dojiBody = Font.doji(17)
    static let dojiCallout = Font.doji(15)
    static let dojiCaption = Font.doji(13)
}
