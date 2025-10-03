//
//  Vehicle.swift
//  ParkingApp
//
//  Created by Parking App Team
//

import Foundation
import FirebaseFirestore

struct Vehicle: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var vehicleNumber: String
    var model: String
    var manufacturer: String?
    var color: String?
    var imageURLs: [String]?
    var isActive: Bool
    var createdAt: Date
    
    init(id: String? = nil, userId: String, vehicleNumber: String, model: String, manufacturer: String? = nil, color: String? = nil, imageURLs: [String]? = nil, isActive: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.vehicleNumber = vehicleNumber
        self.model = model
        self.manufacturer = manufacturer
        self.color = color
        self.imageURLs = imageURLs
        self.isActive = isActive
        self.createdAt = createdAt
    }
}
