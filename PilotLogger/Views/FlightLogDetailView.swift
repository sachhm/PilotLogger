import SwiftUI

struct FlightLogDetailView: View {
    let log: FlightLog
    let service: FlightLogServiceProtocol

    @State private var showingEditSheet = false

    var body: some View {
        List {
            flightInfoSection
            airportSection
            hoursSection
            remarksSection
        }
        .navigationTitle("Flight Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEditSheet = true }
                    .accessibilityLabel("Edit this flight log")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            editSheet
        }
    }

    // MARK: - Sections

    private var flightInfoSection: some View {
        Section("Flight Information") {
            DetailRow(label: "Date", value: log.date.formatted(date: .abbreviated, time: .omitted))
            DetailRow(label: "Aircraft", value: log.aircraftType)
            DetailRow(label: "Pilot in Command", value: log.pilotInCommandName)
            DetailRow(label: "Landings", value: "\(log.numberOfLandings)")
        }
    }

    private var airportSection: some View {
        Section("Route") {
            if !log.departureAirport.isEmpty || !log.arrivalAirport.isEmpty {
                HStack {
                    VStack {
                        Text(log.departureAirport.isEmpty ? "—" : log.departureAirport)
                            .font(.title2.bold())
                        Text("Departure")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Departure: \(log.departureAirport.isEmpty ? "not set" : log.departureAirport)")

                    Image(systemName: "airplane")
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)

                    VStack {
                        Text(log.arrivalAirport.isEmpty ? "—" : log.arrivalAirport)
                            .font(.title2.bold())
                        Text("Arrival")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Arrival: \(log.arrivalAirport.isEmpty ? "not set" : log.arrivalAirport)")
                }
                .padding(.vertical, 4)
            } else {
                Text("No airports recorded")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var hoursSection: some View {
        Section("Hours") {
            DetailRow(label: "Total Flight Time", value: String(format: "%.1f hrs", log.flightTime))
            if log.nightHours > 0 {
                DetailRow(label: "Night Hours", value: String(format: "%.1f hrs", log.nightHours))
            }
            if log.instrumentHours > 0 {
                DetailRow(label: "Instrument Hours", value: String(format: "%.1f hrs", log.instrumentHours))
            }
        }
    }

    @ViewBuilder
    private var remarksSection: some View {
        if !log.remarks.isEmpty {
            Section("Remarks") {
                Text(log.remarks)
                    .font(.body)
            }
        }
    }

    private var editSheet: some View {
        let vm = FlightLogFormViewModel(service: service)
        return FlightLogFormView(viewModel: vm)
            .onAppear { vm.configureForEditing(log) }
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}
