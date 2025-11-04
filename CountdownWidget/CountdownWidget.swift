import WidgetKit
import SwiftUI
import AppIntents

struct CountdownEntry: TimelineEntry {
    let date: Date
    let countdowns: [CountdownItem]
    let configuration: CountdownSelectionIntent?
}

struct Provider: AppIntentTimelineProvider {
    typealias Entry = CountdownEntry
    typealias Intent = CountdownSelectionIntent

    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(date: Date(), countdowns: sampleCountdowns(), configuration: nil)
    }

    func snapshot(for configuration: CountdownSelectionIntent, in context: Context) async -> CountdownEntry {
        let countdowns = context.isPreview ? sampleCountdowns() : loadCountdowns(for: configuration)
        return CountdownEntry(date: Date(), countdowns: countdowns, configuration: configuration)
    }

    func timeline(for configuration: CountdownSelectionIntent, in context: Context) async -> Timeline<CountdownEntry> {
        let countdowns = loadCountdowns(for: configuration)
        let now = Date()
        let entries = makeEntries(countdowns: countdowns, configuration: configuration, startingAt: now)

        // Refresh at next midnight instead of hourly for efficiency
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
        let refreshDate = entries.last?.date ?? tomorrow

        return Timeline(entries: entries, policy: .after(refreshDate))
    }

    private func loadCountdowns(for configuration: CountdownSelectionIntent) -> [CountdownItem] {
        let allCountdowns = SharedCountdownRepository.loadCountdowns()

        // If user selected specific countdown
        if let selectedID = configuration.countdown?.id {
            // Try to find the selected countdown
            if let selectedCountdown = allCountdowns.first(where: { $0.id == selectedID }) {
                return [selectedCountdown]
            }

            // Auto-switch: If selected countdown was deleted, show next available
            // Return first available countdown if any exist
            if let nextCountdown = allCountdowns.first {
                return [nextCountdown]
            }
        }

        // No countdown selected or no countdowns available
        return []
    }

    private func sampleCountdowns() -> [CountdownItem] {
        [
            CountdownItem(title: "Sample Event", date: Date().addingTimeInterval(86400 * 5)),
            CountdownItem(title: "Design Review", date: Date().addingTimeInterval(86400)),
            CountdownItem(title: "Past Milestone", date: Date().addingTimeInterval(-86400 * 2))
        ]
    }

    private func makeEntries(countdowns: [CountdownItem], configuration: CountdownSelectionIntent?, startingAt now: Date) -> [CountdownEntry] {
        var entries: [CountdownEntry] = []
        entries.append(CountdownEntry(date: now, countdowns: countdowns, configuration: configuration))

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)
        let maxDays = 30  // Extended from 14 to 30 days for better reliability

        // Ensure nextMidnight is in the future
        guard var nextMidnight = calendar.date(byAdding: .day, value: 1, to: startOfToday) else {
            return entries
        }

        // Edge case protection: if nextMidnight is somehow not in the future, advance it
        while nextMidnight <= now {
            guard let following = calendar.date(byAdding: .day, value: 1, to: nextMidnight) else {
                return entries
            }
            nextMidnight = following
        }

        // Generate entries for next 30 midnights
        for _ in 0..<maxDays {
            entries.append(CountdownEntry(date: nextMidnight, countdowns: countdowns, configuration: configuration))

            guard let following = calendar.date(byAdding: .day, value: 1, to: nextMidnight) else {
                break
            }
            nextMidnight = following
        }

        return entries
    }
}

struct CountdownWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode // iOS 26+ Liquid Glass rendering mode support

    var body: some View {
        let referenceDate = entry.date
        let prioritized = Self.prioritizedCountdowns(entry.countdowns, referenceDate: referenceDate)
        return widgetView(for: prioritized, referenceDate: referenceDate)
            // Note: WidgetKit automatically adapts to Clear/Tinted modes using system colors
            // No manual glassEffect needed - follows Liquid Glass best practices
    }

    @ViewBuilder
    private func widgetView(for countdowns: [CountdownItem], referenceDate: Date) -> some View {
        switch family {
        case .systemSmall:
            smallView(countdown: countdowns.first, referenceDate: referenceDate)
        case .systemMedium:
            mediumView(countdowns: countdowns, referenceDate: referenceDate)
        case .systemLarge:
            largeView(countdowns: countdowns, referenceDate: referenceDate)
        default:
            mediumView(countdowns: countdowns, referenceDate: referenceDate)
        }
    }

    private func smallView(countdown: CountdownItem?, referenceDate: Date) -> some View {
        widgetBackground {
            VStack(spacing: 8) {
                if let countdown {
                    Text(countdown.title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                    Text(primaryLabel(for: countdown, referenceDate: referenceDate))
                        .font(countdown.daysRemaining(relativeTo: referenceDate) > 0 ? .system(size: 44, weight: .semibold, design: .rounded) : .title2)
                        .foregroundStyle(.primary)
                    Text(countdown.statusDetail(relativeTo: referenceDate))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                        Text(NSLocalizedString("widget.select.countdown", comment: "Select a countdown"))
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Text(NSLocalizedString("widget.select.hint", comment: "Long press to edit"))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding()
        }
    }

    private func mediumView(countdowns: [CountdownItem], referenceDate: Date) -> some View {
        widgetBackground {
            VStack(alignment: .leading, spacing: 12) {
                if countdowns.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text(NSLocalizedString("widget.select.countdown", comment: "Select a countdown"))
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Text(NSLocalizedString("widget.select.hint", comment: "Long press to edit"))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text(NSLocalizedString("widget.upcoming", comment: "Upcoming"))
                        .font(.headline)
                        .foregroundStyle(.primary)
                    ForEach(Array(countdowns.prefix(2))) { item in
                        HStack(alignment: .center, spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(1)
                                Text(item.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(item.relativeDescription(relativeTo: referenceDate))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(primaryLabel(for: item, referenceDate: referenceDate))
                                    .font(item.daysRemaining(relativeTo: referenceDate) > 0 ? .title2.weight(.semibold) : .headline)
                                Text(item.statusDetail(relativeTo: referenceDate))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    Spacer()
                }
            }
            .padding()
        }
    }

    private func largeView(countdowns: [CountdownItem], referenceDate: Date) -> some View {
        widgetBackground {
            VStack(alignment: .leading, spacing: 12) {
                if countdowns.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text(NSLocalizedString("widget.select.countdown", comment: "Select a countdown"))
                            .font(.title3.weight(.semibold))
                            .multilineTextAlignment(.center)
                        Text(NSLocalizedString("widget.select.hint", comment: "Long press to edit"))
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text(NSLocalizedString("widget.all", comment: "All Countdowns"))
                        .font(.headline)
                    ForEach(Array(countdowns.prefix(4))) { item in
                        HStack(alignment: .center, spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(1)
                                Text(item.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(item.relativeDescription(relativeTo: referenceDate))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(primaryLabel(for: item, referenceDate: referenceDate))
                                    .font(item.daysRemaining(relativeTo: referenceDate) > 0 ? .title2.weight(.semibold) : .headline)
                                Text(item.statusDetail(relativeTo: referenceDate))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    Spacer()
                }
            }
            .padding()
        }
    }

    private func primaryLabel(for item: CountdownItem, referenceDate: Date) -> String {
        let remaining = item.daysRemaining(relativeTo: referenceDate)
        return remaining > 0 ? String(remaining) : item.statusLabel(relativeTo: referenceDate)
    }

    @ViewBuilder
    private func widgetBackground<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        // iOS 17+ API (minimum deployment target is iOS 17)
        content()
            .containerBackground(for: .widget) {
                Color(.systemBackground)
            }
    }

    private static func prioritizedCountdowns(_ countdowns: [CountdownItem], referenceDate: Date) -> [CountdownItem] {
        guard !countdowns.isEmpty else { return [] }
        let sorted = countdowns.sorted(by: CountdownItem.displaySort(lhs:rhs:))
        let upcoming = sorted.filter { !$0.isPast(relativeTo: referenceDate) }
        let past = sorted.filter { $0.isPast(relativeTo: referenceDate) }
            .sorted(by: { $0.date > $1.date })
        if upcoming.isEmpty {
            return past
        }
        return upcoming + past
    }
}

struct CountdownWidget: Widget {
    let kind: String = "CountdownWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: CountdownSelectionIntent.self,
            provider: Provider()
        ) { entry in
            CountdownWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Countdown")
        .description("Track a specific countdown on your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct CountdownWidgetBundle: WidgetBundle {
    var body: some Widget {
        CountdownWidget()
    }
}
