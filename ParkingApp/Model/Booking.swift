//
//  Booking.swift
//  ParkingApp
//
//  Created by Parking App Team
//

import Foundation
import FirebaseFirestore

enum BookingStatus: String, Codable {
    case pending = "pending"
    case active = "active"
    case completed = "completed"
    case cancelled = "cancelled"
}

struct Booking: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var vehicleId: String
    var parkingLotId: String
    var vendorId: String?
    var parkingLotName: String?
    var userName: String?
    var vehicleNumber: String?
    var startTime: Date
    var endTime: Date?
    var duration: Double
    var plannedHours: Double // Deprecated, use duration
    var actualHours: Double?
    var status: BookingStatus
    var totalAmount: Double
    var acceptedAt: Date?
    var cancelledAt: Date?
    var cancellationReason: String?
    var completedAt: Date?
    var lateFeeAmount: Double?
    var paymentConfirmedAt: Date?
    var createdAt: Date
    
    init(
        id: String? = nil,
        userId: String,
        vehicleId: String,
        parkingLotId: String,
        vendorId: String? = nil,
        parkingLotName: String? = nil,
        userName: String? = nil,
        vehicleNumber: String? = nil,
        startTime: Date,
        endTime: Date? = nil,
        duration: Double,
        plannedHours: Double? = nil,
        actualHours: Double? = nil,
        status: BookingStatus = .pending,
        totalAmount: Double,
        acceptedAt: Date? = nil,
        cancelledAt: Date? = nil,
        cancellationReason: String? = nil,
        completedAt: Date? = nil,
        lateFeeAmount: Double? = nil,
        paymentConfirmedAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.vehicleId = vehicleId
        self.parkingLotId = parkingLotId
        self.vendorId = vendorId
        self.parkingLotName = parkingLotName
        self.userName = userName
        self.vehicleNumber = vehicleNumber
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.plannedHours = plannedHours ?? duration
        self.actualHours = actualHours
        self.status = status
        self.totalAmount = totalAmount
        self.acceptedAt = acceptedAt
        self.cancelledAt = cancelledAt
        self.cancellationReason = cancellationReason
        self.completedAt = completedAt
        self.lateFeeAmount = lateFeeAmount
        self.paymentConfirmedAt = paymentConfirmedAt
        self.createdAt = createdAt
    }
}
