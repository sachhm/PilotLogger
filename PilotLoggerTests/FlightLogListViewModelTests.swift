import Testing
import Foundation
@testable import PilotLogger

@Suite("FlightLogListViewModel Tests")
@MainActor
struct FlightLogListViewModelTests {

    private func makeSUT() -> (FlightLogListViewModel, MockFlightLogService) {
        let service = MockFlightLogService()
        let vm = FlightLogListViewModel(service: service)
        return (vm, service)
    }

    private func sampleLogs() -> [FlightLog] {
        [
            FlightLog(
                date: Date(timeIntervalSince1970: 1700000000),
                aircraftType: "C172",
                pilotInCommandName: "Alice",
                flightTime: 2.5,
                departureAirport: "KJFK",
                arrivalAirport: "KLGA",
                nightHours: 0.5,
                instrumentHours: 1.0,
                numberOfLandings: 2
            ),
            FlightLog(
                date: Date(timeIntervalSince1970: 1700100000),
                aircraftType: "PA28",
                pilotInCommandName: "Bob",
                flightTime: 1.5,
                departureAirport: "EGLL",
                arrivalAirport: "LFPG",
                nightHours: 0,
                instrumentHours: 0.5,
                numberOfLandings: 1
            ),
            FlightLog(
                date: Date(timeIntervalSince1970: 1700200000),
                aircraftType: "C172",
                pilotInCommandName: "Alice",
                flightTime: 3.0,
                nightHours: 1.0,
                instrumentHours: 0,
                numberOfLandings: 3
            ),
        ]
    }

    // MARK: - Loading

    @Test("Load logs populates the logs array")
    func loadLogs() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()

        await vm.loadLogs()

        #expect(vm.logs.count == 3)
        #expect(!vm.isLoading)
        #expect(vm.errorMessage == nil)
    }

    @Test("Load logs sets error message on failure")
    func loadLogsError() async {
        let (vm, service) = makeSUT()
        service.shouldThrowOnFetch = true

        await vm.loadLogs()

        #expect(vm.logs.isEmpty)
        #expect(vm.errorMessage != nil)
        #expect(!vm.isLoading)
    }

    // MARK: - Totals

    @Test("Total flight hours sums all logs")
    func totalFlightHours() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()

        #expect(vm.totalFlightHours == 7.0)
    }

    @Test("Total night hours sums correctly")
    func totalNightHours() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()

        #expect(vm.totalNightHours == 1.5)
    }

    @Test("Total instrument hours sums correctly")
    func totalInstrumentHours() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()

        #expect(vm.totalInstrumentHours == 1.5)
    }

    @Test("Total landings sums correctly")
    func totalLandings() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()

        #expect(vm.totalLandings == 6)
    }

    // MARK: - Aircraft Breakdown

    @Test("Hours by aircraft type groups correctly")
    func hoursByAircraftType() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()

        let breakdown = vm.hoursByAircraftType
        #expect(breakdown.count == 2)

        let c172 = breakdown.first { $0.type == "C172" }
        #expect(c172?.hours == 5.5)

        let pa28 = breakdown.first { $0.type == "PA28" }
        #expect(pa28?.hours == 1.5)
    }

    @Test("Aircraft breakdown sorted by hours descending")
    func aircraftBreakdownSorted() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()

        let breakdown = vm.hoursByAircraftType
        #expect(breakdown.first?.type == "C172")
    }

    // MARK: - Filtering

    @Test("Search filters by aircraft type")
    func searchByAircraftType() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()

        vm.searchText = "PA28"
        #expect(vm.filteredLogs.count == 1)
        #expect(vm.filteredLogs.first?.aircraftType == "PA28")
    }

    @Test("Search filters by pilot name")
    func searchByPilotName() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()

        vm.searchText = "alice"
        #expect(vm.filteredLogs.count == 2)
    }

    @Test("Search filters by departure airport")
    func searchByDepartureAirport() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()

        vm.searchText = "EGLL"
        #expect(vm.filteredLogs.count == 1)
    }

    @Test("Empty search returns all logs")
    func emptySearch() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()

        vm.searchText = ""
        #expect(vm.filteredLogs.count == 3)
    }

    @Test("No results for non-matching search")
    func noResults() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()

        vm.searchText = "ZZZZ"
        #expect(vm.filteredLogs.isEmpty)
    }

    // MARK: - Sorting

    @Test("Sort by date descending (default)")
    func sortByDateDescending() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()

        vm.sortOrder = .dateDescending
        let filtered = vm.filteredLogs
        #expect(filtered.first?.date ?? .distantPast > filtered.last?.date ?? .distantFuture)
    }

    @Test("Sort by date ascending")
    func sortByDateAscending() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()

        vm.sortOrder = .dateAscending
        let filtered = vm.filteredLogs
        #expect(filtered.first?.date ?? .distantFuture < filtered.last?.date ?? .distantPast)
    }

    @Test("Sort by flight time descending")
    func sortByFlightTimeDescending() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()

        vm.sortOrder = .flightTimeDescending
        let filtered = vm.filteredLogs
        #expect(filtered.first?.flightTime == 3.0)
        #expect(filtered.last?.flightTime == 1.5)
    }

    @Test("Sort by aircraft type alphabetically")
    func sortByAircraftType() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()

        vm.sortOrder = .aircraftType
        let filtered = vm.filteredLogs
        #expect(filtered.first?.aircraftType == "C172")
    }

    // MARK: - Deletion

    @Test("Delete log removes from list and calls service")
    func deleteLog() async {
        let (vm, service) = makeSUT()
        let logs = sampleLogs()
        service.logs = logs
        await vm.loadLogs()

        await vm.deleteLog(vm.logs[0])

        #expect(vm.logs.count == 2)
        #expect(service.deleteCallCount == 1)
    }

    @Test("Delete log sets error on failure")
    func deleteLogError() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()
        service.shouldThrowOnDelete = true

        await vm.deleteLog(vm.logs[0])

        #expect(vm.errorMessage != nil)
    }

    // MARK: - Logs by Month

    @Test("Logs grouped by month")
    func logsByMonth() async {
        let (vm, service) = makeSUT()
        service.logs = sampleLogs()
        await vm.loadLogs()

        let grouped = vm.logsByMonth
        #expect(!grouped.isEmpty)
        // All sample logs are in November 2023 (epoch ~1700000000)
        #expect(grouped.count == 1)
        #expect(grouped.first?.logs.count == 3)
    }

    // MARK: - Empty State

    @Test("Empty logs returns empty totals")
    func emptyTotals() {
        let (vm, _) = makeSUT()

        #expect(vm.totalFlightHours == 0)
        #expect(vm.totalNightHours == 0)
        #expect(vm.totalInstrumentHours == 0)
        #expect(vm.totalLandings == 0)
        #expect(vm.hoursByAircraftType.isEmpty)
        #expect(vm.logsByMonth.isEmpty)
    }

    // MARK: - Sort Order

    @Test("All sort orders have correct raw values")
    func sortOrderRawValues() {
        #expect(FlightLogListViewModel.SortOrder.dateDescending.rawValue == "Newest First")
        #expect(FlightLogListViewModel.SortOrder.dateAscending.rawValue == "Oldest First")
        #expect(FlightLogListViewModel.SortOrder.flightTimeDescending.rawValue == "Most Hours")
        #expect(FlightLogListViewModel.SortOrder.aircraftType.rawValue == "Aircraft Type")
    }

    @Test("All sort orders are case iterable")
    func sortOrderCaseIterable() {
        #expect(FlightLogListViewModel.SortOrder.allCases.count == 4)
    }
}
