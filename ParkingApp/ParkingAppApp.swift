//
//  ParkingAppApp.swift
//  ParkingApp
//
//  Created by Anik on 24/10/20.
//

import SwiftUI
import FirebaseCore

@main
struct ParkingAppApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
