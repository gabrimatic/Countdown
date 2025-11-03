import SwiftUI

@main
struct CountdownApp: App {
    @StateObject private var store = CountdownStore()

    var body: some Scene {
        WindowGroup {
            CountdownListView()
                .environmentObject(store)
        }
    }
}
