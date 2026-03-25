import SwiftUI

struct StatisticsView: View {
    let viewModel: FlightLogListViewModel

    var body: some View {
        List {
            overviewSection
            aircraftBreakdownSection
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var overviewSection: some View {
        Section("Overview") {
            StatCard(
                title: "Total Flight Hours",
                value: String(format: "%.1f", viewModel.totalFlightHours),
                unit: "hours",
                icon: "clock.fill"
            )
            StatCard(
                title: "Night Hours",
                value: String(format: "%.1f", viewModel.totalNightHours),
                unit: "hours",
                icon: "moon.fill"
            )
            StatCard(
                title: "Instrument Hours",
                value: String(format: "%.1f", viewModel.totalInstrumentHours),
                unit: "hours",
                icon: "gauge.with.dots.needle.33percent"
            )
            StatCard(
                title: "Total Landings",
                value: "\(viewModel.totalLandings)",
                unit: "landings",
                icon: "airplane.arrival"
            )
            StatCard(
                title: "Total Flights",
                value: "\(viewModel.logs.count)",
                unit: "entries",
                icon: "list.bullet"
            )
        }
    }

    private var aircraftBreakdownSection: some View {
        Section("Hours by Aircraft") {
            if viewModel.hoursByAircraftType.isEmpty {
                Text("No flights logged yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.hoursByAircraftType, id: \.type) { item in
                    HStack {
                        Text(item.type)
                            .font(.body)
                        Spacer()
                        Text(String(format: "%.1f hrs", item.hours))
                            .font(.body.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(item.type): \(String(format: "%.1f", item.hours)) hours")
                }
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.title2.bold().monospacedDigit())
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value) \(unit)")
    }
}
