import SwiftUI

struct FlightLogListView: View {
    @Bindable var viewModel: FlightLogListViewModel
    let service: FlightLogServiceProtocol
    var airportService: AirportServiceProtocol?

    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.logs.isEmpty {
                    ProgressView("Loading flights...")
                        .accessibilityLabel("Loading flight logs")
                } else if viewModel.filteredLogs.isEmpty {
                    emptyState
                } else {
                    logList
                }
            }
            .navigationTitle("Pilot Logger")
            .searchable(text: $viewModel.searchText, prompt: "Search flights")
            .toolbar { toolbarContent }
            .sheet(isPresented: $showingAddSheet) {
                addSheet
            }
            .task { await viewModel.loadLogs() }
            .refreshable { await viewModel.loadLogs() }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    // MARK: - List

    private var logList: some View {
        List {
            ForEach(viewModel.logsByMonth, id: \.month) { section in
                Section(section.month) {
                    ForEach(section.logs) { log in
                        NavigationLink(destination: FlightLogDetailView(log: log, service: service)) {
                            FlightLogRow(log: log)
                        }
                        .accessibilityLabel(rowAccessibilityLabel(for: log))
                    }
                    .onDelete { offsets in
                        let logsInSection = section.logs
                        Task {
                            for index in offsets {
                                await viewModel.deleteLog(logsInSection[index])
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .animation(.easeInOut(duration: 0.3), value: viewModel.filteredLogs.count)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            viewModel.searchText.isEmpty ? "No Flights Logged" : "No Results",
            systemImage: viewModel.searchText.isEmpty ? "airplane" : "magnifyingglass",
            description: Text(
                viewModel.searchText.isEmpty
                    ? "Tap + to log your first flight."
                    : "No flights match \"\(viewModel.searchText)\"."
            )
        )
        .accessibilityLabel(viewModel.searchText.isEmpty ? "No flights logged yet" : "No results for \(viewModel.searchText)")
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showingAddSheet = true
                }
            } label: {
                Image(systemName: "plus")
            }
            .accessibilityLabel("Add new flight log")
            .accessibilityHint("Opens a form to log a new flight")
        }
        ToolbarItem(placement: .secondaryAction) {
            NavigationLink(destination: StatisticsView(viewModel: viewModel)) {
                Label("Statistics", systemImage: "chart.bar")
            }
            .accessibilityLabel("View flight statistics")
        }
        ToolbarItem(placement: .secondaryAction) {
            Menu("Sort", systemImage: "arrow.up.arrow.down") {
                Picker("Sort Order", selection: $viewModel.sortOrder) {
                    ForEach(FlightLogListViewModel.SortOrder.allCases) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
            }
            .accessibilityLabel("Sort flight logs")
        }
    }

    // MARK: - Sheets

    private var addSheet: some View {
        let vm = FlightLogFormViewModel(service: service)
        return FlightLogFormView(viewModel: vm, airportService: airportService)
            .onDisappear { Task { await viewModel.loadLogs() } }
    }

    // MARK: - Accessibility

    private func rowAccessibilityLabel(for log: FlightLog) -> String {
        let date = log.date.formatted(date: .abbreviated, time: .omitted)
        var label = "\(log.aircraftType), \(String(format: "%.1f", log.flightTime)) hours, \(date)"
        if !log.departureAirport.isEmpty && !log.arrivalAirport.isEmpty {
            label += ", from \(log.departureAirport) to \(log.arrivalAirport)"
        }
        return label
    }
}

// MARK: - Flight Log Row

struct FlightLogRow: View {
    let log: FlightLog

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(log.aircraftType)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1f hrs", log.flightTime))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text(log.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !log.departureAirport.isEmpty || !log.arrivalAirport.isEmpty {
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text(routeText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(log.pilotInCommandName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private var routeText: String {
        let dep = log.departureAirport.isEmpty ? "?" : log.departureAirport
        let arr = log.arrivalAirport.isEmpty ? "?" : log.arrivalAirport
        return "\(dep) → \(arr)"
    }
}
