import SwiftUI

@main
struct CountdownApp: App {
    @StateObject private var store = CountdownStore()
    @StateObject private var settingsStore = AppSettingsStore()
    @State private var showLaunchScreen = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                CountdownListView()
                    .environmentObject(store)
                    .environmentObject(settingsStore)

                if showLaunchScreen {
                    LaunchScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .preferredColorScheme(settingsStore.effectiveColorScheme)
            .task {
                // Load data asynchronously to avoid blocking main thread during app launch
                store.load()

                // Keep launch screen visible for at least 0.5 seconds for smooth transition
                try? await Task.sleep(nanoseconds: 500_000_000)

                // Dismiss launch screen after loading completes
                withAnimation(.easeOut(duration: 0.5)) {
                    showLaunchScreen = false
                }
            }
        }
    }
}
