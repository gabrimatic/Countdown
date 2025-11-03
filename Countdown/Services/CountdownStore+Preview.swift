#if DEBUG
import Foundation

extension CountdownStore {
    @MainActor static var preview: CountdownStore {
        let defaults = UserDefaults(suiteName: "preview.countdown.store") ?? .standard
        defaults.removeObject(forKey: SharedCountdownRepository.storageKey)
        let items = [
            CountdownItem(title: "Product Launch", date: Date().addingTimeInterval(86400 * 5), notes: "Finalize press kit"),
            CountdownItem(title: "Team Offsite", date: Date().addingTimeInterval(86400 * 12)),
            CountdownItem(title: "Conference Talk", date: Date().addingTimeInterval(-86400 * 2), notes: "Slides archived")
        ]
        let store = CountdownStore(userDefaults: defaults, widgetReloader: {})
        store.replaceAll(with: items)
        return store
    }
}
#endif
