import Foundation

/// Represents the user's preferred color scheme
enum ThemePreference: String, Codable, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    /// Localized display name for the theme preference
    var displayName: String {
        switch self {
        case .system:
            return NSLocalizedString("settings.theme.system", comment: "System theme option")
        case .light:
            return NSLocalizedString("settings.theme.light", comment: "Light theme option")
        case .dark:
            return NSLocalizedString("settings.theme.dark", comment: "Dark theme option")
        }
    }

    /// Icon representing the theme
    var icon: String {
        switch self {
        case .system:
            return "circle.lefthalf.filled"
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
}

/// App-wide settings model
struct AppSettings: Codable {
    var themePreference: ThemePreference

    static let `default` = AppSettings(themePreference: .system)
}
