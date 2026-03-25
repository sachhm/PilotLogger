import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Timeline Entry

struct FlightLogEntry: TimelineEntry {
    let date: Date
    let totalHours: Double
    let totalFlights: Int
    let lastFlightDate: Date?
    let lastAircraftType: String?
    let recentFlights: [RecentFlight]

    struct RecentFlight: Identifiable {
        let id: UUID
        let aircraftType: String
        let flightTime: Double
        let date: Date
        let route: String
    }

    static var placeholder: FlightLogEntry {
        FlightLogEntry(
            date: .now,
            totalHours: 127.5,
            totalFlights: 42,
            lastFlightDate: .now.addingTimeInterval(-86400),
            lastAircraftType: "C172",
            recentFlights: [
                RecentFlight(id: UUID(), aircraftType: "C172", flightTime: 2.5, date: .now, route: "KJFK → KLGA"),
                RecentFlight(id: UUID(), aircraftType: "PA28", flightTime: 1.5, date: .now, route: "EGLL → LFPG"),
                RecentFlight(id: UUID(), aircraftType: "C172", flightTime: 3.0, date: .now, route: "KDEN → KSFO"),
            ]
        )
    }

    static var empty: FlightLogEntry {
        FlightLogEntry(
            date: .now,
            totalHours: 0,
            totalFlights: 0,
            lastFlightDate: nil,
            lastAircraftType: nil,
            recentFlights: []
        )
    }
}

// MARK: - Timeline Provider

struct FlightLogTimelineProvider: TimelineProvider {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: FlightLog.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    func placeholder(in context: Context) -> FlightLogEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (FlightLogEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
            return
        }
        Task { @MainActor in
            let entry = fetchEntry()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FlightLogEntry>) -> Void) {
        Task { @MainActor in
            let entry = fetchEntry()
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    @MainActor
    private func fetchEntry() -> FlightLogEntry {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<FlightLog>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        guard let logs = try? context.fetch(descriptor) else {
            return .empty
        }

        let totalHours = logs.reduce(0) { $0 + $1.flightTime }
        let recentFlights = logs.prefix(3).map { log in
            let route: String
            if !log.departureAirport.isEmpty && !log.arrivalAirport.isEmpty {
                route = "\(log.departureAirport) → \(log.arrivalAirport)"
            } else {
                route = ""
            }
            return FlightLogEntry.RecentFlight(
                id: log.id,
                aircraftType: log.aircraftType,
                flightTime: log.flightTime,
                date: log.date,
                route: route
            )
        }

        return FlightLogEntry(
            date: .now,
            totalHours: totalHours,
            totalFlights: logs.count,
            lastFlightDate: logs.first?.date,
            lastAircraftType: logs.first?.aircraftType,
            recentFlights: recentFlights
        )
    }
}

// MARK: - Widget Definition

struct PilotLoggerWidget: Widget {
    let kind = "PilotLoggerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FlightLogTimelineProvider()) { entry in
            PilotLoggerWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Pilot Logger")
        .description("View your flight hours and recent flights.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget Views

struct PilotLoggerWidgetView: View {
    let entry: FlightLogEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        default:
            smallWidget
        }
    }

    // MARK: - Small Widget

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "airplane")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Pilot Logger")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "%.1f", entry.totalHours))
                    .font(.system(.title, design: .rounded).bold().monospacedDigit())
                Text("total hours")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let lastDate = entry.lastFlightDate, let aircraft = entry.lastAircraftType {
                VStack(alignment: .leading, spacing: 1) {
                    Text("Last flight")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(aircraft) · \(lastDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2)
                        .lineLimit(1)
                }
            } else {
                Text("No flights yet")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Medium Widget

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            // Left: stats
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "airplane")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Pilot Logger")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: "%.1f", entry.totalHours))
                        .font(.system(.title, design: .rounded).bold().monospacedDigit())
                    Text("total hours")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("\(entry.totalFlights)")
                            .font(.subheadline.bold().monospacedDigit())
                        Text("flights")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }

            Divider()

            // Right: recent flights
            VStack(alignment: .leading, spacing: 6) {
                Text("Recent")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)

                if entry.recentFlights.isEmpty {
                    Text("No flights yet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(entry.recentFlights) { flight in
                        HStack {
                            VStack(alignment: .leading, spacing: 1) {
                                Text(flight.aircraftType)
                                    .font(.caption.bold())
                                if !flight.route.isEmpty {
                                    Text(flight.route)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            Text(String(format: "%.1fh", flight.flightTime))
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()
            }
        }
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    PilotLoggerWidget()
} timeline: {
    FlightLogEntry.placeholder
    FlightLogEntry.empty
}

#Preview("Medium", as: .systemMedium) {
    PilotLoggerWidget()
} timeline: {
    FlightLogEntry.placeholder
    FlightLogEntry.empty
}
