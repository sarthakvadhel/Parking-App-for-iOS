//
//  Booking.swift
//  ParkingApp
//
//  Created by Parking App Team
//

import Foundation
import FirebaseFirestore

enum BookingStatus: String, Codable {
    case active = "active"
    case completed = "completed"
    case cancelled = "cancelled"
}

struct Booking: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var vehicleId: String
    var parkingLotId: String
    var startTime: Date
    var endTime: Date?
    var plannedHours: Double
    var actualHours: Double?
    var status: BookingStatus
    var totalAmount: Double?
    var createdAt: Date
    
    init(id: String? = nil, userId: String, vehicleId: String, parkingLotId: String, startTime: Date, endTime: Date? = nil, plannedHours: Double, actualHours: Double? = nil, status: BookingStatus = .active, totalAmount: Double? = nil, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.vehicleId = vehicleId
        self.parkingLotId = parkingLotId
        self.startTime = startTime
        self.endTime = endTime
        self.plannedHours = plannedHours
        self.actualHours = actualHours
        self.status = status
        self.totalAmount = totalAmount
        self.createdAt = createdAt
    }
}
