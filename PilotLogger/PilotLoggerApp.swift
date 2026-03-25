import SwiftUI
import SwiftData

@main
struct PilotLoggerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: FlightLog.self)
    }
}
