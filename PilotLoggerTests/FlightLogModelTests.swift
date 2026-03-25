import Testing
import Foundation
@testable import PilotLogger

@Suite("FlightLog Model Tests")
struct FlightLogModelTests {

    @Test("Default initializer sets correct values")
    func defaultInit() {
        let log = FlightLog()

        #expect(log.aircraftType == "")
        #expect(log.pilotInCommandName == "")
        #expect(log.flightTime == 0)
        #expect(log.departureAirport == "")
        #expect(log.arrivalAirport == "")
        #expect(log.remarks == "")
        #expect(log.nightHours == 0)
        #expect(log.instrumentHours == 0)
        #expect(log.numberOfLandings == 1)
        #expect(log.id != UUID())
    }

    @Test("Custom initializer sets all fields")
    func customInit() {
        let date = Date(timeIntervalSince1970: 1000000)
        let log = FlightLog(
            date: date,
            aircraftType: "C172",
            pilotInCommandName: "John Doe",
            flightTime: 2.5,
            departureAirport: "KJFK",
            arrivalAirport: "KLGA",
            remarks: "Smooth flight",
            nightHours: 0.5,
            instrumentHours: 1.0,
            numberOfLandings: 2
        )

        #expect(log.date == date)
        #expect(log.aircraftType == "C172")
        #expect(log.pilotInCommandName == "John Doe")
        #expect(log.flightTime == 2.5)
        #expect(log.departureAirport == "KJFK")
        #expect(log.arrivalAirport == "KLGA")
        #expect(log.remarks == "Smooth flight")
        #expect(log.nightHours == 0.5)
        #expect(log.instrumentHours == 1.0)
        #expect(log.numberOfLandings == 2)
    }

    @Test("Each FlightLog gets a unique ID")
    func uniqueIDs() {
        let log1 = FlightLog()
        let log2 = FlightLog()

        #expect(log1.id != log2.id)
    }
}
