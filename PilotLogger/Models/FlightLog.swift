import Foundation
import SwiftData

@Model
final class FlightLog: @unchecked Sendable {
    var id: UUID
    var date: Date
    var aircraftType: String
    var pilotInCommandName: String
    var flightTime: Double
    var departureAirport: String
    var arrivalAirport: String
    var remarks: String
    var nightHours: Double
    var instrumentHours: Double
    var numberOfLandings: Int
    var createdAt: Date

    init(
        date: Date = .now,
        aircraftType: String = "",
        pilotInCommandName: String = "",
        flightTime: Double = 0,
        departureAirport: String = "",
        arrivalAirport: String = "",
        remarks: String = "",
        nightHours: Double = 0,
        instrumentHours: Double = 0,
        numberOfLandings: Int = 1,
        createdAt: Date = .now
    ) {
        self.id = UUID()
        self.date = date
        self.aircraftType = aircraftType
        self.pilotInCommandName = pilotInCommandName
        self.flightTime = flightTime
        self.departureAirport = departureAirport
        self.arrivalAirport = arrivalAirport
        self.remarks = remarks
        self.nightHours = nightHours
        self.instrumentHours = instrumentHours
        self.numberOfLandings = numberOfLandings
        self.createdAt = createdAt
    }
}
