import Foundation
@testable import PilotLogger

final class MockFlightLogService: FlightLogServiceProtocol, @unchecked Sendable {
    var logs: [FlightLog] = []
    var shouldThrowOnFetch = false
    var shouldThrowOnAdd = false
    var shouldThrowOnUpdate = false
    var shouldThrowOnDelete = false
    var addCallCount = 0
    var updateCallCount = 0
    var deleteCallCount = 0

    enum MockError: Error, LocalizedError {
        case simulatedError
        var errorDescription: String? { "Simulated error" }
    }

    func fetchAll() async throws -> [FlightLog] {
        if shouldThrowOnFetch { throw MockError.simulatedError }
        return logs
    }

    func add(_ log: FlightLog) async throws {
        if shouldThrowOnAdd { throw MockError.simulatedError }
        addCallCount += 1
        logs.append(log)
    }

    func update(_ log: FlightLog) async throws {
        if shouldThrowOnUpdate { throw MockError.simulatedError }
        updateCallCount += 1
    }

    func delete(_ log: FlightLog) async throws {
        if shouldThrowOnDelete { throw MockError.simulatedError }
        deleteCallCount += 1
        logs.removeAll { $0.id == log.id }
    }

    func search(query: String) async throws -> [FlightLog] {
        return logs.filter { log in
            log.aircraftType.localizedCaseInsensitiveContains(query) ||
            log.pilotInCommandName.localizedCaseInsensitiveContains(query)
        }
    }
}
