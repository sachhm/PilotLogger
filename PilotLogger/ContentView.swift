import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        let service = FlightLogService(modelContainer: modelContext.container)
        let airportService = AirportService()
        let listViewModel = FlightLogListViewModel(service: service)

        FlightLogListView(
            viewModel: listViewModel,
            service: service,
            airportService: airportService
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: FlightLog.self, inMemory: true)
}
