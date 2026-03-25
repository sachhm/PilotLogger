import Foundation
import SwiftData

@ModelActor
actor FlightLogService: FlightLogServiceProtocol {

    func fetchAll() async throws -> [FlightLog] {
        let descriptor = FetchDescriptor<FlightLog>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func add(_ log: FlightLog) async throws {
        modelContext.insert(log)
        try modelContext.save()
    }

    func update(_ log: FlightLog) async throws {
        try modelContext.save()
    }

    func delete(_ log: FlightLog) async throws {
        modelContext.delete(log)
        try modelContext.save()
    }

    func search(query: String) async throws -> [FlightLog] {
        let descriptor = FetchDescriptor<FlightLog>(
            predicate: #Predicate<FlightLog> { log in
                log.aircraftType.localizedStandardContains(query) ||
                log.pilotInCommandName.localizedStandardContains(query) ||
                log.departureAirport.localizedStandardContains(query) ||
                log.arrivalAirport.localizedStandardContains(query) ||
                log.remarks.localizedStandardContains(query)
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
}
