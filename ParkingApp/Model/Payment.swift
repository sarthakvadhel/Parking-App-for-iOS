//
//  Payment.swift
//  ParkingApp
//
//  Created by Parking App Team
//

import Foundation
import FirebaseFirestore

enum PaymentMethod: String, Codable {
    case cash = "cash"
    case card = "card"
    case upi = "upi"
    case wallet = "wallet"
}

enum PaymentStatus: String, Codable {
    case pending = "pending"
    case completed = "completed"
    case failed = "failed"
}

struct Payment: Codable, Identifiable {
    @DocumentID var id: String?
    var bookingId: String
    var userId: String
    var amount: Double
    var method: PaymentMethod
    var status: PaymentStatus
    var transactionId: String?
    var createdAt: Date
    
    init(id: String? = nil, bookingId: String, userId: String, amount: Double, method: PaymentMethod, status: PaymentStatus = .pending, transactionId: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.bookingId = bookingId
        self.userId = userId
        self.amount = amount
        self.method = method
        self.status = status
        self.transactionId = transactionId
        self.createdAt = createdAt
    }
}
