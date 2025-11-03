import Foundation
import Combine
#if canImport(WidgetKit)
import WidgetKit
#endif

@MainActor
final class CountdownStore: ObservableObject {
    @Published var countdowns: [CountdownItem] = [] {
        didSet {
            guard !isRestoring else {
                isRestoring = false
                return
            }
            persist()
        }
    }

    private let storageKey = SharedCountdownRepository.storageKey
    private let userDefaults: UserDefaults
    private let widgetReloader: () -> Void
    private var isRestoring = false

    init(
        userDefaults: UserDefaults = UserDefaults(suiteName: SharedCountdownRepository.suiteName) ?? .standard,
        widgetReloader: @escaping () -> Void = CountdownStore.makeWidgetReloader()
    ) {
        self.userDefaults = userDefaults
        self.widgetReloader = widgetReloader
        load()
    }

    func add(_ item: CountdownItem) {
        countdowns.append(item)
        reorder()
    }

    func update(_ item: CountdownItem) {
        guard let index = countdowns.firstIndex(where: { $0.id == item.id }) else { return }
        countdowns[index] = item
        reorder()
    }

    func delete(_ indexSet: IndexSet) {
        countdowns.remove(atOffsets: indexSet)
    }

    func delete(_ item: CountdownItem) {
        countdowns.removeAll { $0.id == item.id }
    }

    func replaceAll(with items: [CountdownItem]) {
        countdowns = items.sorted(by: { $0.date < $1.date })
    }

    private func load() {
        guard let data = userDefaults.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([CountdownItem].self, from: data)
            isRestoring = true
            countdowns = decoded.sorted(by: { $0.date < $1.date })
        } catch {
            print("Failed to load countdowns: \(error)")
            countdowns = []
        }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(countdowns.sorted(by: { $0.date < $1.date }))
            userDefaults.set(data, forKey: storageKey)
            widgetReloader()
        } catch {
            print("Failed to save countdowns: \(error)")
        }
    }

    private func reorder() {
        countdowns.sort(by: { $0.date < $1.date })
    }

    private static func makeWidgetReloader() -> () -> Void {
#if canImport(WidgetKit)
        return {
            WidgetCenter.shared.reloadAllTimelines()
        }
#else
        return {}
#endif
    }
}
