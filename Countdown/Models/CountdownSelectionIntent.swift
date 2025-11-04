//
//  CountdownSelectionIntent.swift
//  Countdown
//
//  Created for per-widget countdown configuration
//

import AppIntents
import WidgetKit
import Foundation

/// Widget configuration intent for selecting which countdown to display
@available(iOS 17.0, *)
struct CountdownSelectionIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Countdown"
    static var description = IntentDescription("Choose which countdown to display in this widget")

    @Parameter(title: "Countdown")
    var countdown: CountdownEntity?
}

/// App entity representing a countdown item for widget configuration
@available(iOS 17.0, *)
struct CountdownEntity: AppEntity, Codable {
    var id: UUID
    var title: String
    var date: Date

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Countdown"

    // Static formatter to avoid creating new instances on every access
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    var displayRepresentation: DisplayRepresentation {
        return DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(Self.dateFormatter.string(from: date))"
        )
    }

    static var defaultQuery = CountdownEntityQuery()
}

/// Query provider for countdown entities in widget configuration UI
@available(iOS 17.0, *)
struct CountdownEntityQuery: EntityQuery {
    /// Load specific countdowns by ID (used when widget needs to resolve saved configuration)
    func entities(for identifiers: [UUID]) async throws -> [CountdownEntity] {
        let countdowns = SharedCountdownRepository.loadCountdowns()
        let result = countdowns
            .filter { identifiers.contains($0.id) }
            .map { CountdownEntity(id: $0.id, title: $0.title, date: $0.date) }
        return result
    }

    /// Provide suggested countdowns for configuration picker (shows all available)
    func suggestedEntities() async throws -> [CountdownEntity] {
        let countdowns = SharedCountdownRepository.loadCountdowns()
        let result = countdowns.map { CountdownEntity(id: $0.id, title: $0.title, date: $0.date) }
        return result
    }

    /// Default result when no specific query provided
    func defaultResult() async -> CountdownEntity? {
        let countdowns = SharedCountdownRepository.loadCountdowns()
        guard let first = countdowns.first else {
            return nil
        }
        return CountdownEntity(id: first.id, title: first.title, date: first.date)
    }
}
