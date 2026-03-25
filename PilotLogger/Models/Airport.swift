import Foundation

struct Airport: Codable, Identifiable, Sendable, Hashable {
    var id: String { icao }
    let icao: String
    let iata: String
    let name: String
    let city: String
    let country: String
    let latitude: Double
    let longitude: Double

    enum CodingKeys: String, CodingKey {
        case icao
        case iata
        case name
        case city
        case country
        case latitude = "lat"
        case longitude = "lon"
    }
}

struct AirportSearchResult: Codable, Sendable {
    let airports: [Airport]
}
