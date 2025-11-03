import WidgetKit
import SwiftUI

struct CountdownEntry: TimelineEntry {
    let date: Date
    let countdowns: [CountdownItem]
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(date: Date(), countdowns: sampleCountdowns())
    }

    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> Void) {
        let countdowns = context.isPreview ? sampleCountdowns() : loadCountdowns()
        completion(CountdownEntry(date: Date(), countdowns: countdowns))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountdownEntry>) -> Void) {
        let countdowns = loadCountdowns()
        let now = Date()
        let entries = makeEntries(countdowns: countdowns, startingAt: now)
        let refreshDate = entries.last?.date.addingTimeInterval(3600) ?? now.addingTimeInterval(3600)
        completion(Timeline(entries: entries, policy: .after(refreshDate)))
    }

    private func loadCountdowns() -> [CountdownItem] {
        SharedCountdownRepository.loadCountdowns()
    }

    private func sampleCountdowns() -> [CountdownItem] {
        [
            CountdownItem(title: "Sample Event", date: Date().addingTimeInterval(86400 * 5)),
            CountdownItem(title: "Design Review", date: Date().addingTimeInterval(86400)),
            CountdownItem(title: "Past Milestone", date: Date().addingTimeInterval(-86400 * 2))
        ]
    }

    private func makeEntries(countdowns: [CountdownItem], startingAt now: Date) -> [CountdownEntry] {
        var entries: [CountdownEntry] = []
        entries.append(CountdownEntry(date: now, countdowns: countdowns))

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)
        let maxDays = 14
        guard var nextMidnight = calendar.date(byAdding: .day, value: 1, to: startOfToday) else {
            return entries
        }

        for _ in 0..<maxDays {
            if nextMidnight <= now {
                guard let following = calendar.date(byAdding: .day, value: 1, to: nextMidnight) else { break }
                nextMidnight = following
                continue
            }
            entries.append(CountdownEntry(date: nextMidnight, countdowns: countdowns))
            guard let following = calendar.date(byAdding: .day, value: 1, to: nextMidnight) else { break }
            nextMidnight = following
        }

        return entries
    }
}

struct CountdownWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        let referenceDate = entry.date
        let prioritized = Self.prioritizedCountdowns(entry.countdowns, referenceDate: referenceDate)
        return widgetView(for: prioritized, referenceDate: referenceDate)
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
                    Text("No countdowns")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
    }

    private func mediumView(countdowns: [CountdownItem], referenceDate: Date) -> some View {
        widgetBackground {
            VStack(alignment: .leading, spacing: 12) {
                Text("Upcoming")
                    .font(.headline)
                    .foregroundStyle(.primary)
                if countdowns.isEmpty {
                    Text("Add a countdown to see it here.")
                        .foregroundStyle(.secondary)
                } else {
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
                }
                Spacer()
            }
            .padding()
        }
    }

    private func largeView(countdowns: [CountdownItem], referenceDate: Date) -> some View {
        widgetBackground {
            VStack(alignment: .leading, spacing: 12) {
                Text("All Countdowns")
                    .font(.headline)
                if countdowns.isEmpty {
                    Text("Add countdowns in the app to stay on track.")
                        .foregroundStyle(.secondary)
                } else {
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
                }
                Spacer()
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
        if #available(iOSApplicationExtension 17.0, *) {
            content()
                .containerBackground(for: .widget) {
                    Color(.systemBackground)
                }
        } else {
            ZStack {
                Color(.systemBackground)
                content()
            }
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
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CountdownWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Countdown")
        .description("Keep track of your upcoming days with minimalist widgets.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct CountdownWidgetBundle: WidgetBundle {
    var body: some Widget {
        CountdownWidget()
    }
}
