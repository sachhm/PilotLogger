import Foundation
import SwiftData

@MainActor
@Observable
final class FlightLogListViewModel {
    private let service: FlightLogServiceProtocol

    var logs: [FlightLog] = []
    var searchText: String = ""
    var sortOrder: SortOrder = .dateDescending
    var isLoading: Bool = false
    var errorMessage: String?

    enum SortOrder: String, CaseIterable, Identifiable {
        case dateDescending = "Newest First"
        case dateAscending = "Oldest First"
        case flightTimeDescending = "Most Hours"
        case aircraftType = "Aircraft Type"

        var id: String { rawValue }
    }

    var filteredLogs: [FlightLog] {
        let filtered = searchText.isEmpty
            ? logs
            : logs.filter { log in
                log.aircraftType.localizedCaseInsensitiveContains(searchText) ||
                log.pilotInCommandName.localizedCaseInsensitiveContains(searchText) ||
                log.departureAirport.localizedCaseInsensitiveContains(searchText) ||
                log.arrivalAirport.localizedCaseInsensitiveContains(searchText) ||
                log.remarks.localizedCaseInsensitiveContains(searchText)
            }

        return sorted(filtered)
    }

    var totalFlightHours: Double {
        logs.reduce(0) { $0 + $1.flightTime }
    }

    var totalNightHours: Double {
        logs.reduce(0) { $0 + $1.nightHours }
    }

    var totalInstrumentHours: Double {
        logs.reduce(0) { $0 + $1.instrumentHours }
    }

    var totalLandings: Int {
        logs.reduce(0) { $0 + $1.numberOfLandings }
    }

    var hoursByAircraftType: [(type: String, hours: Double)] {
        Dictionary(grouping: logs, by: \.aircraftType)
            .map { (type: $0.key, hours: $0.value.reduce(0) { $0 + $1.flightTime }) }
            .sorted { $0.hours > $1.hours }
    }

    var logsByMonth: [(month: String, logs: [FlightLog])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let grouped = Dictionary(grouping: filteredLogs) { log in
            formatter.string(from: log.date)
        }

        return grouped
            .map { (month: $0.key, logs: $0.value) }
            .sorted { ($0.logs.first?.date ?? .distantPast) > ($1.logs.first?.date ?? .distantPast) }
    }

    init(service: FlightLogServiceProtocol) {
        self.service = service
    }

    func loadLogs() async {
        isLoading = true
        errorMessage = nil
        do {
            logs = try await service.fetchAll()
        } catch {
            errorMessage = "Failed to load flight logs: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func deleteLog(_ log: FlightLog) async {
        do {
            try await service.delete(log)
            logs.removeAll { $0.id == log.id }
        } catch {
            errorMessage = "Failed to delete log: \(error.localizedDescription)"
        }
    }

    func deleteLog(at offsets: IndexSet) async {
        for index in offsets {
            let log = filteredLogs[index]
            await deleteLog(log)
        }
    }

    private func sorted(_ logs: [FlightLog]) -> [FlightLog] {
        switch sortOrder {
        case .dateDescending:
            return logs.sorted { $0.date > $1.date }
        case .dateAscending:
            return logs.sorted { $0.date < $1.date }
        case .flightTimeDescending:
            return logs.sorted { $0.flightTime > $1.flightTime }
        case .aircraftType:
            return logs.sorted { $0.aircraftType < $1.aircraftType }
        }
    }
}
