import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case dark, dusk, warm, cold, green, blue
    var id: String { rawValue }
    var title: String { self == .cold ? "Cool" : rawValue.capitalized }
    var subtitle: String {
        switch self {
        case .dark: "Black, crimson & gold"
        case .dusk: "Slate & soft mint"
        case .warm: "Paper, clay & forest"
        case .cold: "Stone, slate & teal"
        case .green: "Deep forest & soft sage"
        case .blue: "Midnight blue & pale sky"
        }
    }
    var scheme: ColorScheme { self == .warm || self == .cold ? .light : .dark }
    var paperHex: String {
        switch self { case .dark: "101010"; case .dusk: "3A404A"; case .warm: "F4EEE3"; case .cold: "EBF0F0"; case .green: "10271E"; case .blue: "101F36" }
    }
    var surfaceHex: String {
        switch self { case .dark: "1C1A19"; case .dusk: "474E5A"; case .warm: "FBF8F2"; case .cold: "FAFCFC"; case .green: "1B372A"; case .blue: "1B314F" }
    }
    var accentHex: String {
        switch self { case .dark: "F2C94C"; case .dusk: "9ACDB0"; case .warm: "A9552F"; case .cold: "2F6F73"; case .green: "9BCFA8"; case .blue: "A2C9F5" }
    }
    var actionHex: String {
        switch self { case .dark: "A92D38"; case .dusk: "9ACDB0"; case .warm: "A9552F"; case .cold: "2F6F73"; case .green: "9BCFA8"; case .blue: "A2C9F5" }
    }
    var inkHex: String {
        switch self { case .dark: "FFF5DA"; case .dusk: "F4F5F7"; case .warm: "2A2620"; case .cold: "1B2730"; case .green: "E7F2EA"; case .blue: "E8F0FC" }
    }
    var mutedHex: String {
        switch self { case .dark: "BEB3A0"; case .dusk: "BCC3CC"; case .warm: "6F675B"; case .cold: "56656E"; case .green: "A7C1AF"; case .blue: "ABBDD7" }
    }
    var tintHex: String {
        switch self { case .dark: "30271A"; case .dusk: "545E5A"; case .warm: "EAD9CA"; case .cold: "D1DEDE"; case .green: "264B37"; case .blue: "284460" }
    }
    var lineHex: String {
        switch self { case .dark: "4B4032"; case .dusk: "68717F"; case .warm: "D9CDBB"; case .cold: "CCD6D7"; case .green: "3D5C48"; case .blue: "3D5778" }
    }
    var correctionHex: String { self == .dark ? "FF7770" : scheme == .dark ? "FFAAA1" : "C42B2B" }
    var correction: Color { Color(hex: correctionHex) }
    var onAction: Color { Color(hex: self == .dark ? "FFF5DA" : self == .dusk ? "1F2429" : self == .green ? "10271E" : self == .blue ? "101F36" : "FFFFFF") }
    var secondaryAccent: Color {
        Color(hex: self == .dark ? "FF7770" : self == .dusk ? "D9B97A" : self == .warm ? "8A6B3F" : self == .green ? "B9CB8B" : self == .blue ? "9FC9E8" : "4C6A8A")
    }
    func nounColorHex(_ gender: NounGender) -> String {
        switch (gender, scheme == .dark) {
        case (.masculine, false): "2457A7"
        case (.feminine, false): "AF234C"
        case (.neuter, false): "246C3B"
        case (.masculine, true): "BBDFFF"
        case (.feminine, true): "FFC8D2"
        case (.neuter, true): "B1EABD"
        }
    }
    func nounColor(_ gender: NounGender) -> Color { Color(hex: nounColorHex(gender)) }
    func wordColor(_ entry: WordEntry) -> Color { entry.nounGender.map(nounColor) ?? ink }
    var paper: Color { Color(hex: paperHex) }
    var surface: Color { Color(hex: surfaceHex) }
    var accent: Color { Color(hex: accentHex) }
    var action: Color { Color(hex: actionHex) }
    var ink: Color { Color(hex: inkHex) }
    var muted: Color { Color(hex: mutedHex) }
    var line: Color { Color(hex: lineHex) }
    var css: String {
        "--paper:#\(paperHex);--ink:#\(inkHex);--muted:#\(mutedHex);--blue:#\(accentHex);--rule:#\(lineHex);--tint:#\(tintHex);--red:#\(correctionHex);--noun-masculine:#\(nounColorHex(.masculine));--noun-feminine:#\(nounColorHex(.feminine));--noun-neuter:#\(nounColorHex(.neuter));color-scheme:\(scheme == .dark ? "dark" : "light");"
    }
}
private struct AppThemeKey: EnvironmentKey { static let defaultValue = AppTheme.dark }
extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}
private extension Color {
    init(hex: String) {
        let value = UInt32(hex, radix: 16) ?? 0
        self.init(.sRGB, red: Double((value >> 16) & 255) / 255, green: Double((value >> 8) & 255) / 255, blue: Double(value & 255) / 255, opacity: 1)
    }
}
