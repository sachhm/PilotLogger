import Foundation

protocol FlightLogServiceProtocol: Sendable {
    func fetchAll() async throws -> [FlightLog]
    func add(_ log: FlightLog) async throws
    func update(_ log: FlightLog) async throws
    func delete(_ log: FlightLog) async throws
    func search(query: String) async throws -> [FlightLog]
}
