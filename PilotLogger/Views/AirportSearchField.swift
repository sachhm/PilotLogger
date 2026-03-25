import SwiftUI

struct AirportSearchField: View {
    let label: String
    @Binding var code: String
    let service: AirportServiceProtocol

    @State private var viewModel: AirportSearchViewModel
    @State private var showSuggestions = false
    @FocusState private var isFocused: Bool

    init(label: String, code: Binding<String>, service: AirportServiceProtocol) {
        self.label = label
        self._code = code
        self.service = service
        self._viewModel = State(initialValue: AirportSearchViewModel(service: service))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField(label, text: $code)
                .textContentType(.none)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
                .focused($isFocused)
                .onChange(of: code) { _, newValue in
                    viewModel.query = newValue
                    showSuggestions = !newValue.isEmpty && isFocused
                }
                .onChange(of: isFocused) { _, focused in
                    showSuggestions = focused && !code.isEmpty
                }
                .accessibilityLabel(label)
                .accessibilityHint("Enter an ICAO or IATA airport code")

            if showSuggestions && !viewModel.results.isEmpty {
                suggestionsView
            }
        }
    }

    private var suggestionsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(viewModel.results.prefix(5)) { airport in
                Button {
                    code = airport.icao
                    showSuggestions = false
                    isFocused = false
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(airport.icao)
                                .font(.caption.bold())
                            Text(airport.name)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Text(airport.city)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(airport.icao), \(airport.name), \(airport.city)")
            }
        }
        .padding(.horizontal, 4)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}
