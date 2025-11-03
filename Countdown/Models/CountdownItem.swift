import Foundation

struct CountdownItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var date: Date
    var notes: String

    init(id: UUID = UUID(), title: String, date: Date, notes: String = "") {
        self.id = id
        self.title = title
        self.date = Calendar.current.startOfDay(for: date)
        self.notes = notes
    }

    /// The number of whole days between the supplied reference date and the countdown date.
    /// Positive values indicate future dates, negative values indicate past dates.
    func daysRemaining(relativeTo referenceDate: Date) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: referenceDate)
        let end = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: start, to: end)
        return components.day ?? 0
    }

    /// The number of whole days between now and the countdown date.
    /// Positive values indicate future dates, negative values indicate past dates.
    var daysRemaining: Int {
        daysRemaining(relativeTo: Date())
    }

    func isPast(relativeTo referenceDate: Date) -> Bool {
        daysRemaining(relativeTo: referenceDate) < 0
    }

    var isPast: Bool {
        daysRemaining < 0
    }

    /// Clamps negative values to zero for display in countdown badges.
    var clampedDaysRemaining: Int {
        max(daysRemaining, 0)
    }

    func statusLabel(relativeTo referenceDate: Date) -> String {
        let remaining = daysRemaining(relativeTo: referenceDate)
        switch remaining {
        case ..<0:
            return "Done"
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        default:
            return "\(remaining) days"
        }
    }

    /// A concise label communicating the countdown status.
    var statusLabel: String {
        statusLabel(relativeTo: Date())
    }

    func statusDetail(relativeTo referenceDate: Date) -> String {
        let remaining = daysRemaining(relativeTo: referenceDate)
        switch remaining {
        case ..<0:
            let overdue = abs(remaining)
            return overdue == 1 ? "Completed 1 day ago" : "Completed \(overdue) days ago"
        case 0:
            return "Due today"
        case 1:
            return "1 day left"
        default:
            return "\(remaining) days left"
        }
    }

    /// A detailed description for accessibility and secondary labels.
    var statusDetail: String {
        statusDetail(relativeTo: Date())
    }

    func relativeDescription(relativeTo referenceDate: Date) -> String {
        CountdownItem.relativeFormatter.localizedString(for: date, relativeTo: referenceDate)
    }

    /// Relative description used by widgets and accessibility.
    var relativeDescription: String {
        relativeDescription(relativeTo: Date())
    }

    func updated(date: Date) -> CountdownItem {
        CountdownItem(id: id, title: title, date: date, notes: notes)
    }

    static func displaySort(lhs: CountdownItem, rhs: CountdownItem) -> Bool {
        if lhs.date != rhs.date {
            return lhs.date < rhs.date
        }
        let comparison = lhs.title.localizedCaseInsensitiveCompare(rhs.title)
        if comparison != .orderedSame {
            return comparison == .orderedAscending
        }
        return lhs.id.uuidString < rhs.id.uuidString
    }

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
}
