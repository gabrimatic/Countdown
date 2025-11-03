import Foundation

enum SharedCountdownRepository {
    static let suiteName = "group.info.gabrimatic.countdown"
    static let storageKey = "countdowns"

    static func loadCountdowns() -> [CountdownItem] {
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        guard let data = defaults.data(forKey: storageKey) else { return [] }
        do {
            let decoded = try JSONDecoder().decode([CountdownItem].self, from: data)
            return decoded.sorted(by: CountdownItem.displaySort(lhs:rhs:))
        } catch {
            return []
        }
    }
}
