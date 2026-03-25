import Foundation

@MainActor
@Observable
final class AirportSearchViewModel {
    private let service: AirportServiceProtocol

    var query: String = "" {
        didSet { searchTask?.cancel(); scheduleSearch() }
    }
    var results: [Airport] = []
    var isSearching: Bool = false

    private var searchTask: Task<Void, Never>?

    init(service: AirportServiceProtocol) {
        self.service = service
    }

    private func scheduleSearch() {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }

        searchTask = Task {
            // Debounce: wait 300ms before searching
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            isSearching = true
            do {
                results = try await service.searchAirports(query: query)
            } catch {
                if !Task.isCancelled {
                    results = []
                }
            }
            isSearching = false
        }
    }
}
