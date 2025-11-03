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

    /// The number of whole days between now and the countdown date.
    /// Positive values indicate future dates, negative values indicate past dates.
    var daysRemaining: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: start, to: end)
        return components.day ?? 0
    }

    var isPast: Bool {
        daysRemaining < 0
    }

    /// Clamps negative values to zero for display in countdown badges.
    var clampedDaysRemaining: Int {
        max(daysRemaining, 0)
    }

    /// A concise label communicating the countdown status.
    var statusLabel: String {
        switch daysRemaining {
        case ..<0:
            return "Done"
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        default:
            return "\(daysRemaining) days"
        }
    }

    /// A detailed description for accessibility and secondary labels.
    var statusDetail: String {
        switch daysRemaining {
        case ..<0:
            let overdue = abs(daysRemaining)
            return overdue == 1 ? "Completed 1 day ago" : "Completed \(overdue) days ago"
        case 0:
            return "Due today"
        case 1:
            return "1 day left"
        default:
            return "\(daysRemaining) days left"
        }
    }

    /// Relative description used by widgets and accessibility.
    var relativeDescription: String {
        CountdownItem.relativeFormatter.localizedString(for: date, relativeTo: Date())
    }

    func updated(date: Date) -> CountdownItem {
        CountdownItem(id: id, title: title, date: date, notes: notes)
    }

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
}
