//
//  FlightLog.swift
//  PilotLogger
//
//  Created by Sachh Moka on 30/7/2024.
//

import Foundation

// Data model
struct FlightLog: Identifiable {
    let id: UUID
    var date: Date
    var aircraftType: String
    var pilotInCommandName: String
    var flightTime: Double
    
    // Custom initializer to create a new FlightLog
    init(date: Date, aircraftType: String, pilotInCommandName: String,flightTime: Double) {
        self.id = UUID()
        self.date = date
        self.aircraftType = aircraftType
        self.pilotInCommandName = pilotInCommandName
        self.flightTime = flightTime
    }

}



