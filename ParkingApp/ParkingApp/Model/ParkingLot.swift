//
//  ParkingLot.swift
//  ParkingApp
//
//  Created by Parking App Team
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct ParkingLot: Codable, Identifiable {
    @DocumentID var id: String?
    var vendorId: String
    var name: String
    var description: String
    var address: String
    var latitude: Double
    var longitude: Double
    var hourlyCharge: Double
    var lateFee: Double
    var terms: String
    var totalSpaces: Int
    var availableSpaces: Int
    var imageURLs: [String]?
    var isActive: Bool
    var createdAt: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(id: String? = nil, vendorId: String, name: String, description: String, address: String, latitude: Double, longitude: Double, hourlyCharge: Double, lateFee: Double, terms: String, totalSpaces: Int, availableSpaces: Int, imageURLs: [String]? = nil, isActive: Bool = true, createdAt: Date = Date()) {
        self.id = id
        self.vendorId = vendorId
        self.name = name
        self.description = description
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.hourlyCharge = hourlyCharge
        self.lateFee = lateFee
        self.terms = terms
        self.totalSpaces = totalSpaces
        self.availableSpaces = availableSpaces
        self.imageURLs = imageURLs
        self.isActive = isActive
        self.createdAt = createdAt
    }
}
