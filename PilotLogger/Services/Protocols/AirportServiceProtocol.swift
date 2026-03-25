import Foundation

protocol AirportServiceProtocol: Sendable {
    func searchAirports(query: String) async throws -> [Airport]
}
