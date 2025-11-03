import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @EnvironmentObject private var settingsStore: AppSettingsStore

    var body: some View {
        NavigationStack {
            Form {
                // Theme Section
                Section {
                    ForEach(ThemePreference.allCases) { theme in
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                settingsStore.updateTheme(theme)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: theme.icon)
                                    .font(.system(size: 20))
                                    .foregroundStyle(settingsStore.settings.themePreference == theme ? Color.accentColor : Color.secondary)
                                    .frame(width: 28)

                                Text(theme.displayName)
                                    .foregroundStyle(.primary)

                                Spacer()

                                if settingsStore.settings.themePreference == theme {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.tint)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text(NSLocalizedString("settings.appearance.header", comment: "Appearance section header"))
                } footer: {
                    Text(NSLocalizedString("settings.appearance.footer", comment: "Appearance section footer"))
                }

                // Language Section
                Section {
                    HStack {
                        Image(systemName: "globe")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                            .frame(width: 28)

                        Text(NSLocalizedString("settings.language.title", comment: "Language"))

                        Spacer()

                        Text(currentLanguageDisplayName)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(NSLocalizedString("settings.language.header", comment: "Language section header"))
                } footer: {
                    Text(NSLocalizedString("settings.language.footer", comment: "Language section footer"))
                }
            }
            .navigationTitle(NSLocalizedString("settings.title", comment: "Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(NSLocalizedString("common.done", comment: "Done"))
                            .fontWeight(.semibold)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                appInfoFooter
            }
        }
    }

    // MARK: - Footer View

    @ViewBuilder
    private var appInfoFooter: some View {
        VStack(spacing: 4) {
            // Developer Link
            Link(destination: URL(string: "https://gabrimatic.info")!) {
                Text("gabrimatic.info")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            // Version
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
               let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                Text("Version \(version) (\(build))")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(
                    GlassSettings.chromeMaterial(
                        reduceTransparency: reduceTransparency,
                        contrast: contrast
                    )
                )
                .ignoresSafeArea()
        }
    }

    // MARK: - Helpers

    private var currentLanguageDisplayName: String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        let displayLanguage = Locale.current.localizedString(forLanguageCode: languageCode) ?? "English"
        return displayLanguage.capitalized
    }
}

struct SettingsView_Previews: PreviewProvider {
    @MainActor static var previews: some View {
        SettingsView()
            .environmentObject(AppSettingsStore.preview)
    }
}
