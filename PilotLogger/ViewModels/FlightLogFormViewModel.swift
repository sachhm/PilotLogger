import Foundation

@MainActor
@Observable
final class FlightLogFormViewModel {
    private let service: FlightLogServiceProtocol

    var date: Date = .now
    var aircraftType: String = ""
    var pilotInCommandName: String = ""
    var flightTimeText: String = ""
    var departureAirport: String = ""
    var arrivalAirport: String = ""
    var remarks: String = ""
    var nightHoursText: String = ""
    var instrumentHoursText: String = ""
    var numberOfLandingsText: String = "1"

    var isSaving: Bool = false
    var errorMessage: String?
    var didSaveSuccessfully: Bool = false

    // The log being edited (nil = creating new)
    private var editingLog: FlightLog?

    var isEditing: Bool { editingLog != nil }

    var navigationTitle: String {
        isEditing ? "Edit Flight Log" : "New Flight Log"
    }

    // MARK: - Validation

    var flightTime: Double? { Double(flightTimeText) }
    var nightHours: Double? { nightHoursText.isEmpty ? 0 : Double(nightHoursText) }
    var instrumentHours: Double? { instrumentHoursText.isEmpty ? 0 : Double(instrumentHoursText) }
    var numberOfLandings: Int? { Int(numberOfLandingsText) }

    var isValid: Bool {
        guard let ft = flightTime, ft > 0 else { return false }
        guard !aircraftType.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard !pilotInCommandName.trimmingCharacters(in: .whitespaces).isEmpty else { return false }

        if let nh = nightHours, nh < 0 { return false }
        if let ih = instrumentHours, ih < 0 { return false }
        if let nl = numberOfLandings, nl < 0 { return false }

        return true
    }

    var validationErrors: [String] {
        var errors: [String] = []
        if aircraftType.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append("Aircraft type is required")
        }
        if pilotInCommandName.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append("Pilot in command is required")
        }
        if flightTime == nil || (flightTime ?? 0) <= 0 {
            errors.append("Flight time must be a positive number")
        }
        if nightHours == nil && !nightHoursText.isEmpty {
            errors.append("Night hours must be a valid number")
        }
        if instrumentHours == nil && !instrumentHoursText.isEmpty {
            errors.append("Instrument hours must be a valid number")
        }
        if numberOfLandings == nil {
            errors.append("Number of landings must be a valid number")
        }
        return errors
    }

    init(service: FlightLogServiceProtocol) {
        self.service = service
    }

    // MARK: - Actions

    func configureForEditing(_ log: FlightLog) {
        editingLog = log
        date = log.date
        aircraftType = log.aircraftType
        pilotInCommandName = log.pilotInCommandName
        flightTimeText = String(log.flightTime)
        departureAirport = log.departureAirport
        arrivalAirport = log.arrivalAirport
        remarks = log.remarks
        nightHoursText = log.nightHours > 0 ? String(log.nightHours) : ""
        instrumentHoursText = log.instrumentHours > 0 ? String(log.instrumentHours) : ""
        numberOfLandingsText = String(log.numberOfLandings)
    }

    func save() async {
        guard isValid else { return }

        isSaving = true
        errorMessage = nil

        do {
            if let existing = editingLog {
                existing.date = date
                existing.aircraftType = aircraftType.trimmingCharacters(in: .whitespaces)
                existing.pilotInCommandName = pilotInCommandName.trimmingCharacters(in: .whitespaces)
                existing.flightTime = flightTime ?? 0
                existing.departureAirport = departureAirport.trimmingCharacters(in: .whitespaces)
                existing.arrivalAirport = arrivalAirport.trimmingCharacters(in: .whitespaces)
                existing.remarks = remarks.trimmingCharacters(in: .whitespaces)
                existing.nightHours = nightHours ?? 0
                existing.instrumentHours = instrumentHours ?? 0
                existing.numberOfLandings = numberOfLandings ?? 1
                try await service.update(existing)
            } else {
                let newLog = FlightLog(
                    date: date,
                    aircraftType: aircraftType.trimmingCharacters(in: .whitespaces),
                    pilotInCommandName: pilotInCommandName.trimmingCharacters(in: .whitespaces),
                    flightTime: flightTime ?? 0,
                    departureAirport: departureAirport.trimmingCharacters(in: .whitespaces),
                    arrivalAirport: arrivalAirport.trimmingCharacters(in: .whitespaces),
                    remarks: remarks.trimmingCharacters(in: .whitespaces),
                    nightHours: nightHours ?? 0,
                    instrumentHours: instrumentHours ?? 0,
                    numberOfLandings: numberOfLandings ?? 1
                )
                try await service.add(newLog)
            }
            didSaveSuccessfully = true
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }

        isSaving = false
    }

    func resetForm() {
        editingLog = nil
        date = .now
        aircraftType = ""
        pilotInCommandName = ""
        flightTimeText = ""
        departureAirport = ""
        arrivalAirport = ""
        remarks = ""
        nightHoursText = ""
        instrumentHoursText = ""
        numberOfLandingsText = "1"
        errorMessage = nil
        didSaveSuccessfully = false
    }
}
