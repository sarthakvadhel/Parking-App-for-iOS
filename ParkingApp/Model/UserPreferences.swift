//
//  UserPreferences.swift
//  ParkingApp
//
//  Created for managing user settings and preferences
//

import Foundation

struct UserPreferences: Codable {
    var id: String?
    var userId: String
    var notificationsEnabled: Bool
    var bookingUpdatesEnabled: Bool
    var biometricAuthEnabled: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(userId: String,
         notificationsEnabled: Bool = true,
         bookingUpdatesEnabled: Bool = true,
         biometricAuthEnabled: Bool = false) {
        self.userId = userId
        self.notificationsEnabled = notificationsEnabled
        self.bookingUpdatesEnabled = bookingUpdatesEnabled
        self.biometricAuthEnabled = biometricAuthEnabled
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
