import SwiftUI
import Combine

/// Manages app-wide settings with UserDefaults persistence
@MainActor
final class AppSettingsStore: ObservableObject {
    @Published private(set) var settings: AppSettings {
        didSet {
            saveSettings()
        }
    }

    private let settingsKey = "app_settings"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.settings = Self.loadSettings(from: userDefaults)
    }

    // MARK: - Public Methods

    /// Updates the theme preference
    func updateTheme(_ theme: ThemePreference) {
        settings.themePreference = theme
    }

    /// Returns the effective color scheme based on user preference
    var effectiveColorScheme: ColorScheme? {
        switch settings.themePreference {
        case .system:
            return nil // Let system decide
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    // MARK: - Private Methods

    private static func loadSettings(from userDefaults: UserDefaults) -> AppSettings {
        guard let data = userDefaults.data(forKey: "app_settings"),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return .default
        }
        return settings
    }

    private func saveSettings() {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        userDefaults.set(data, forKey: settingsKey)
    }
}

// MARK: - Preview Support

extension AppSettingsStore {
    static let preview: AppSettingsStore = {
        let store = AppSettingsStore()
        return store
    }()
}
