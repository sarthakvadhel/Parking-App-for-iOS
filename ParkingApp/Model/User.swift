//
//  User.swift
//  ParkingApp
//
//  Created by Parking App Team
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var email: String
    var role: UserRole
    var name: String?
    var phoneNumber: String?
    var profileImageURL: String?
    var createdAt: Date
    var vehicles: [String]? // Array of vehicle IDs
    
    init(id: String? = nil, email: String, role: UserRole, name: String? = nil, phoneNumber: String? = nil, profileImageURL: String? = nil, createdAt: Date = Date(), vehicles: [String]? = nil) {
        self.id = id
        self.email = email
        self.role = role
        self.name = name
        self.phoneNumber = phoneNumber
        self.profileImageURL = profileImageURL
        self.createdAt = createdAt
        self.vehicles = vehicles
    }
}
