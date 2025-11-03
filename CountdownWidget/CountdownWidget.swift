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
        let entryDate = Date()
        let nextUpdate = Calendar.current.nextDate(after: entryDate, matching: DateComponents(hour: 0, minute: 1), matchingPolicy: .nextTimePreservingSmallerComponents) ?? entryDate.addingTimeInterval(3600)
        let entry = CountdownEntry(date: entryDate, countdowns: countdowns)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
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
}

struct CountdownWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView(countdown: entry.countdowns.first)
        case .systemMedium:
            mediumView(countdowns: entry.countdowns)
        case .systemLarge:
            largeView(countdowns: entry.countdowns)
        default:
            mediumView(countdowns: entry.countdowns)
        }
    }

    private func smallView(countdown: CountdownItem?) -> some View {
        widgetBackground {
            VStack(spacing: 8) {
                if let countdown {
                    Text(countdown.title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                    Text(primaryLabel(for: countdown))
                        .font(countdown.daysRemaining > 0 ? .system(size: 44, weight: .semibold, design: .rounded) : .title2)
                        .foregroundStyle(.primary)
                    Text(countdown.statusDetail)
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

    private func mediumView(countdowns: [CountdownItem]) -> some View {
        widgetBackground {
            VStack(alignment: .leading, spacing: 12) {
                Text("Upcoming")
                    .font(.headline)
                    .foregroundStyle(.primary)
                if countdowns.isEmpty {
                    Text("Add a countdown to see it here.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(countdowns.prefix(2).enumerated()), id: \.offset) { _, item in
                        HStack(alignment: .center, spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(1)
                                Text(item.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(item.relativeDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(primaryLabel(for: item))
                                    .font(item.daysRemaining > 0 ? .title2.weight(.semibold) : .headline)
                                Text(item.statusDetail)
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

    private func largeView(countdowns: [CountdownItem]) -> some View {
        widgetBackground {
            VStack(alignment: .leading, spacing: 12) {
                Text("All Countdowns")
                    .font(.headline)
                if countdowns.isEmpty {
                    Text("Add countdowns in the app to stay on track.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(countdowns.prefix(4).enumerated()), id: \.offset) { _, item in
                        HStack(alignment: .center, spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(1)
                                Text(item.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(item.relativeDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(primaryLabel(for: item))
                                    .font(item.daysRemaining > 0 ? .title2.weight(.semibold) : .headline)
                                Text(item.statusDetail)
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

    private func primaryLabel(for item: CountdownItem) -> String {
        item.daysRemaining > 0 ? item.clampedDaysRemaining.description : item.statusLabel
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
