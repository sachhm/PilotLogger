//
//  ContentView.swift
//  PilotLogger
//
//  Created by Sachh Moka on 22/7/2024.
//

import SwiftUI


// Data model
struct FlightLog: Identifiable {
    let id = UUID()
    var date: Date
    var aircraftType: String
    var pilotInCommandName: String
    var flightTime: Double
}

// Main Content View
struct ContentView: View {
    @State private var logs: [FlightLog] = []
    @State private var date = Date()
    @State private var aircraftType = ""
    @State private var pilotInCommandName: String = ""
    @State private var flightTime = ""
    
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Aircraft Type", text: $aircraftType)
                    TextField("Pilot in Command", text: $pilotInCommandName)
                    TextField("Flight Time (hours)", text: $flightTime)
                        .keyboardType(.decimalPad)
                    Button(action: addLog) {
                        Text("Add Flight Log")
                    }
                }.padding()
                
                List(logs) { log in
                    VStack(alignment: .leading) {
                        Text("Date: \(log.date, formatter: dateFormatter)")
                        Text("Aircraft Type: \(log.aircraftType)")
                        Text("Flight Time: \(log.flightTime) hours")
                    }
                }
            }
            .navigationTitle("Zenith Log")
        }
    }
    
    // Function to add a new log entry
    func addLog() {
        guard let time = Double(flightTime) else { return }
        let newLog = FlightLog(date: date, aircraftType: aircraftType, pilotInCommandName: pilotInCommandName, flightTime: time)
        logs.append(newLog)
        // Clear input fields
        date = Date()
        aircraftType = ""
        flightTime = ""
    }
    
    // Date formatter for displaying date
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}


// Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
