import Foundation

actor AirportService: AirportServiceProtocol {
    private let networkService: NetworkServiceProtocol

    // Bundled airport data for offline-first experience
    private var cachedAirports: [Airport]?

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func searchAirports(query: String) async throws -> [Airport] {
        let airports = try await loadAirports()
        let trimmed = query.trimmingCharacters(in: .whitespaces).uppercased()

        guard !trimmed.isEmpty else { return [] }

        return airports.filter { airport in
            airport.icao.uppercased().contains(trimmed) ||
            airport.iata.uppercased().contains(trimmed) ||
            airport.name.uppercased().contains(trimmed) ||
            airport.city.uppercased().contains(trimmed)
        }
        .prefix(20)
        .map { $0 }
    }

    private func loadAirports() async throws -> [Airport] {
        if let cached = cachedAirports {
            return cached
        }

        guard let url = Bundle.main.url(forResource: "airports", withExtension: "json") else {
            return []
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let airports = try decoder.decode([Airport].self, from: data)
        cachedAirports = airports
        return airports
    }
}
