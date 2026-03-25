import Testing
import Foundation
@testable import PilotLogger

@Suite("FlightLogFormViewModel Tests")
@MainActor
struct FlightLogFormViewModelTests {

    private func makeSUT() -> (FlightLogFormViewModel, MockFlightLogService) {
        let service = MockFlightLogService()
        let vm = FlightLogFormViewModel(service: service)
        return (vm, service)
    }

    // MARK: - Validation

    @Test("Empty form is invalid")
    func emptyFormInvalid() {
        let (vm, _) = makeSUT()
        #expect(!vm.isValid)
    }

    @Test("Valid form with required fields")
    func validForm() {
        let (vm, _) = makeSUT()
        vm.aircraftType = "C172"
        vm.pilotInCommandName = "Jane Doe"
        vm.flightTimeText = "1.5"

        #expect(vm.isValid)
    }

    @Test("Invalid flight time text")
    func invalidFlightTime() {
        let (vm, _) = makeSUT()
        vm.aircraftType = "C172"
        vm.pilotInCommandName = "Jane Doe"
        vm.flightTimeText = "abc"

        #expect(!vm.isValid)
    }

    @Test("Zero flight time is invalid")
    func zeroFlightTime() {
        let (vm, _) = makeSUT()
        vm.aircraftType = "C172"
        vm.pilotInCommandName = "Jane Doe"
        vm.flightTimeText = "0"

        #expect(!vm.isValid)
    }

    @Test("Negative flight time is invalid")
    func negativeFlightTime() {
        let (vm, _) = makeSUT()
        vm.aircraftType = "C172"
        vm.pilotInCommandName = "Jane Doe"
        vm.flightTimeText = "-1"

        #expect(!vm.isValid)
    }

    @Test("Whitespace-only aircraft type is invalid")
    func whitespaceAircraftType() {
        let (vm, _) = makeSUT()
        vm.aircraftType = "   "
        vm.pilotInCommandName = "Jane Doe"
        vm.flightTimeText = "1.5"

        #expect(!vm.isValid)
    }

    @Test("Whitespace-only pilot name is invalid")
    func whitespacePilotName() {
        let (vm, _) = makeSUT()
        vm.aircraftType = "C172"
        vm.pilotInCommandName = "   "
        vm.flightTimeText = "1.5"

        #expect(!vm.isValid)
    }

    @Test("Validation errors are correct for empty form")
    func validationErrors() {
        let (vm, _) = makeSUT()
        vm.flightTimeText = "abc"

        let errors = vm.validationErrors
        #expect(errors.contains("Aircraft type is required"))
        #expect(errors.contains("Pilot in command is required"))
        #expect(errors.contains("Flight time must be a positive number"))
    }

    @Test("Invalid night hours text produces validation error")
    func invalidNightHours() {
        let (vm, _) = makeSUT()
        vm.aircraftType = "C172"
        vm.pilotInCommandName = "Jane Doe"
        vm.flightTimeText = "1.5"
        vm.nightHoursText = "abc"

        let errors = vm.validationErrors
        #expect(errors.contains("Night hours must be a valid number"))
    }

    // MARK: - Saving

    @Test("Save creates new log via service")
    func saveNewLog() async {
        let (vm, service) = makeSUT()
        vm.aircraftType = "C172"
        vm.pilotInCommandName = "Jane Doe"
        vm.flightTimeText = "1.5"
        vm.departureAirport = "KJFK"
        vm.arrivalAirport = "KLGA"

        await vm.save()

        #expect(vm.didSaveSuccessfully)
        #expect(service.addCallCount == 1)
        #expect(service.logs.count == 1)
        #expect(service.logs.first?.aircraftType == "C172")
        #expect(service.logs.first?.departureAirport == "KJFK")
    }

    @Test("Save trims whitespace from fields")
    func saveTrimming() async {
        let (vm, service) = makeSUT()
        vm.aircraftType = "  C172  "
        vm.pilotInCommandName = "  Jane Doe  "
        vm.flightTimeText = "1.5"

        await vm.save()

        #expect(service.logs.first?.aircraftType == "C172")
        #expect(service.logs.first?.pilotInCommandName == "Jane Doe")
    }

    @Test("Save sets error message on failure")
    func saveError() async {
        let (vm, service) = makeSUT()
        service.shouldThrowOnAdd = true
        vm.aircraftType = "C172"
        vm.pilotInCommandName = "Jane Doe"
        vm.flightTimeText = "1.5"

        await vm.save()

        #expect(!vm.didSaveSuccessfully)
        #expect(vm.errorMessage != nil)
    }

    @Test("Save does nothing when form is invalid")
    func saveInvalidForm() async {
        let (vm, service) = makeSUT()
        await vm.save()

        #expect(!vm.didSaveSuccessfully)
        #expect(service.addCallCount == 0)
    }

    // MARK: - Editing

    @Test("Configure for editing populates fields")
    func configureForEditing() {
        let (vm, _) = makeSUT()
        let log = FlightLog(
            date: Date(timeIntervalSince1970: 1000000),
            aircraftType: "PA28",
            pilotInCommandName: "Bob Smith",
            flightTime: 3.0,
            departureAirport: "EGLL",
            arrivalAirport: "LFPG",
            remarks: "Turbulence",
            nightHours: 1.0,
            instrumentHours: 0.5,
            numberOfLandings: 2
        )

        vm.configureForEditing(log)

        #expect(vm.isEditing)
        #expect(vm.aircraftType == "PA28")
        #expect(vm.pilotInCommandName == "Bob Smith")
        #expect(vm.flightTimeText == "3.0")
        #expect(vm.departureAirport == "EGLL")
        #expect(vm.arrivalAirport == "LFPG")
        #expect(vm.remarks == "Turbulence")
        #expect(vm.nightHoursText == "1.0")
        #expect(vm.instrumentHoursText == "0.5")
        #expect(vm.numberOfLandingsText == "2")
        #expect(vm.navigationTitle == "Edit Flight Log")
    }

    @Test("Save updates existing log when editing")
    func saveEdit() async {
        let (vm, service) = makeSUT()
        let log = FlightLog(
            aircraftType: "PA28",
            pilotInCommandName: "Bob",
            flightTime: 3.0
        )
        service.logs = [log]

        vm.configureForEditing(log)
        vm.aircraftType = "C172"
        await vm.save()

        #expect(vm.didSaveSuccessfully)
        #expect(service.updateCallCount == 1)
        #expect(log.aircraftType == "C172")
    }

    // MARK: - Reset

    @Test("Reset clears all form fields")
    func resetForm() {
        let (vm, _) = makeSUT()
        vm.aircraftType = "C172"
        vm.pilotInCommandName = "Jane"
        vm.flightTimeText = "1.5"
        vm.errorMessage = "Some error"

        vm.resetForm()

        #expect(vm.aircraftType == "")
        #expect(vm.pilotInCommandName == "")
        #expect(vm.flightTimeText == "")
        #expect(vm.errorMessage == nil)
        #expect(!vm.isEditing)
        #expect(!vm.didSaveSuccessfully)
    }

    @Test("New form has correct navigation title")
    func newFormTitle() {
        let (vm, _) = makeSUT()
        #expect(vm.navigationTitle == "New Flight Log")
    }
}
