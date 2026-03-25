import SwiftUI

struct FlightLogFormView: View {
    @Bindable var viewModel: FlightLogFormViewModel
    var airportService: AirportServiceProtocol?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                flightInfoSection
                airportSection
                hoursBreakdownSection
                remarksSection

                if !viewModel.validationErrors.isEmpty && !viewModel.aircraftType.isEmpty {
                    validationSection
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityLabel("Cancel and discard changes")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.isEditing ? "Save" : "Add") {
                        Task { await saveAndDismiss() }
                    }
                    .disabled(!viewModel.isValid || viewModel.isSaving)
                    .accessibilityLabel(viewModel.isEditing ? "Save flight log" : "Add flight log")
                    .accessibilityHint(viewModel.isValid ? "Saves the flight log" : "Fill in all required fields first")
                }
            }
            .disabled(viewModel.isSaving)
            .overlay {
                if viewModel.isSaving {
                    ProgressView("Saving...")
                        .accessibilityLabel("Saving flight log")
                }
            }
        }
    }

    // MARK: - Sections

    private var flightInfoSection: some View {
        Section("Flight Information") {
            DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                .accessibilityLabel("Flight date")
            TextField("Aircraft Type", text: $viewModel.aircraftType)
                .textContentType(.none)
                .autocorrectionDisabled()
                .accessibilityLabel("Aircraft type")
                .accessibilityHint("Enter the aircraft model, such as C172 or PA28")
            TextField("Pilot in Command", text: $viewModel.pilotInCommandName)
                .textContentType(.name)
                .accessibilityLabel("Pilot in command name")
            TextField("Flight Time (hours)", text: $viewModel.flightTimeText)
            #if os(iOS)
                .keyboardType(.decimalPad)
            #endif
                .accessibilityLabel("Flight time in hours")
                .accessibilityValue(viewModel.flightTimeText.isEmpty ? "empty" : "\(viewModel.flightTimeText) hours")
            HStack {
                Text("Landings")
                Spacer()
                TextField("1", text: $viewModel.numberOfLandingsText)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                #if os(iOS)
                    .keyboardType(.numberPad)
                #endif
                    .accessibilityLabel("Number of landings")
            }
        }
    }

    private var airportSection: some View {
        Section("Airports") {
            if let service = airportService {
                AirportSearchField(label: "Departure (ICAO/IATA)", code: $viewModel.departureAirport, service: service)
                AirportSearchField(label: "Arrival (ICAO/IATA)", code: $viewModel.arrivalAirport, service: service)
            } else {
                TextField("Departure (ICAO/IATA)", text: $viewModel.departureAirport)
                    .textContentType(.none)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.characters)
                    .accessibilityLabel("Departure airport code")
                TextField("Arrival (ICAO/IATA)", text: $viewModel.arrivalAirport)
                    .textContentType(.none)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.characters)
                    .accessibilityLabel("Arrival airport code")
            }
        }
    }

    private var hoursBreakdownSection: some View {
        Section("Hours Breakdown") {
            TextField("Night Hours", text: $viewModel.nightHoursText)
            #if os(iOS)
                .keyboardType(.decimalPad)
            #endif
                .accessibilityLabel("Night flying hours")
            TextField("Instrument Hours", text: $viewModel.instrumentHoursText)
            #if os(iOS)
                .keyboardType(.decimalPad)
            #endif
                .accessibilityLabel("Instrument flying hours")
        }
    }

    private var remarksSection: some View {
        Section("Remarks") {
            TextField("Notes or remarks", text: $viewModel.remarks, axis: .vertical)
                .lineLimit(3...6)
                .accessibilityLabel("Flight remarks and notes")
        }
    }

    private var validationSection: some View {
        Section {
            ForEach(viewModel.validationErrors, id: \.self) { error in
                Label(error, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
                    .font(.caption)
                    .accessibilityLabel("Validation error: \(error)")
            }
        }
    }

    // MARK: - Actions

    private func saveAndDismiss() async {
        await viewModel.save()
        if viewModel.didSaveSuccessfully {
            dismiss()
        }
    }
}
