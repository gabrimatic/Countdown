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
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showLaunchScreen = false
                    }
                }
            }
        }
    }
}
