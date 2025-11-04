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
            // Do not persist here - only on explicit user actions to avoid redundant operations
        }
    }

    private let storageKey = SharedCountdownRepository.storageKey
    private let userDefaults: UserDefaults
    private let widgetReloader: () -> Void
    private var isRestoring = false

    init(
        userDefaults: UserDefaults = UserDefaults(suiteName: SharedCountdownRepository.suiteName) ?? .standard,
        widgetReloader: (() -> Void)? = nil
    ) {
        self.userDefaults = userDefaults
        self.widgetReloader = widgetReloader ?? CountdownStore.makeWidgetReloader()
        // Do not call load() here - it will be called asynchronously after app launch
    }

    func add(_ item: CountdownItem) {
        countdowns.append(item)
        reorder()
        persist()
    }

    func update(_ item: CountdownItem) {
        guard let index = countdowns.firstIndex(where: { $0.id == item.id }) else { return }
        countdowns[index] = item
        reorder()
        persist()
    }

    func delete(_ indexSet: IndexSet) {
        countdowns.remove(atOffsets: indexSet)
        persist()
    }

    func delete(_ item: CountdownItem) {
        countdowns.removeAll { $0.id == item.id }
        persist()
    }

    func replaceAll(with items: [CountdownItem]) {
        countdowns = items.sorted(by: CountdownItem.displaySort(lhs:rhs:))
        persist()
    }

    /// Load countdowns from UserDefaults
    /// Call this asynchronously after app launch to avoid blocking the main thread
    func load() {
        guard let data = userDefaults.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([CountdownItem].self, from: data)
            isRestoring = true
            countdowns = decoded.sorted(by: CountdownItem.displaySort(lhs:rhs:))
        } catch {
            countdowns = []
        }
    }

    private func persist() {
        do {
            // Array is already sorted by reorder(), no need to sort again
            let data = try JSONEncoder().encode(countdowns)
            userDefaults.set(data, forKey: storageKey)
            widgetReloader()
        } catch {
        }
    }

    private func reorder() {
        countdowns.sort(by: CountdownItem.displaySort(lhs:rhs:))
    }

    private static func makeWidgetReloader() -> () -> Void {
#if canImport(WidgetKit)
        return {
            WidgetCenter.shared.reloadTimelines(ofKind: "CountdownWidget")
        }
#else
        return {}
#endif
    }
}
