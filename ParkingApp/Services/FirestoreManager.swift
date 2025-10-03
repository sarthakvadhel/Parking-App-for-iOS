//
//  FirestoreManager.swift
//  ParkingApp
//
//  Created by Parking App Team
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreManager: ObservableObject {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    @Published var currentUser: User?
    @Published var currentVehicle: Vehicle?
    
    private init() {}
    
    // MARK: - User Operations
    
    func createUser(_ user: User) async throws {
        guard let userId = user.id else {
            throw NSError(domain: "FirestoreManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "User ID is required"])
        }
        try db.collection("users").document(userId).setData(from: user)
    }
    
    func fetchUser(userId: String) async throws -> User {
        let document = try await db.collection("users").document(userId).getDocument()
        guard let user = try? document.data(as: User.self) else {
            throw NSError(domain: "FirestoreManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        await MainActor.run {
            self.currentUser = user
        }
        return user
    }
    
    func updateUser(_ user: User) async throws {
        guard let userId = user.id else {
            throw NSError(domain: "FirestoreManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "User ID is required"])
        }
        try db.collection("users").document(userId).setData(from: user, merge: true)
        await MainActor.run {
            self.currentUser = user
        }
    }
    
    // MARK: - Vehicle Operations
    
    func createVehicle(_ vehicle: Vehicle) async throws -> String {
        let docRef = try db.collection("vehicles").addDocument(from: vehicle)
        return docRef.documentID
    }
    
    func fetchVehicles(userId: String) async throws -> [Vehicle] {
        let snapshot = try await db.collection("vehicles")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Vehicle.self) }
    }
    
    func setActiveVehicle(_ vehicle: Vehicle, userId: String) async throws {
        // Deactivate all vehicles for this user
        let vehicles = try await fetchVehicles(userId: userId)
        for var v in vehicles {
            v.isActive = false
            if let id = v.id {
                try db.collection("vehicles").document(id).setData(from: v)
            }
        }
        
        // Activate selected vehicle
        var activeVehicle = vehicle
        activeVehicle.isActive = true
        if let id = activeVehicle.id {
            try db.collection("vehicles").document(id).setData(from: activeVehicle)
            await MainActor.run {
                self.currentVehicle = activeVehicle
            }
        }
    }
    
    func fetchActiveVehicle(userId: String) async throws -> Vehicle? {
        let snapshot = try await db.collection("vehicles")
            .whereField("userId", isEqualTo: userId)
            .whereField("isActive", isEqualTo: true)
            .limit(to: 1)
            .getDocuments()
        
        return snapshot.documents.first.flatMap { try? $0.data(as: Vehicle.self) }
    }
    
    // MARK: - Parking Lot Operations
    
    func createParkingLot(_ parkingLot: ParkingLot) async throws -> String {
        let docRef = try db.collection("parkingLots").addDocument(from: parkingLot)
        return docRef.documentID
    }
    
    func fetchParkingLots() async throws -> [ParkingLot] {
        let snapshot = try await db.collection("parkingLots")
            .whereField("isActive", isEqualTo: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: ParkingLot.self) }
    }
    
    func fetchVendorParkingLots(vendorId: String) async throws -> [ParkingLot] {
        let snapshot = try await db.collection("parkingLots")
            .whereField("vendorId", isEqualTo: vendorId)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: ParkingLot.self) }
    }
    
    func updateParkingLot(_ parkingLot: ParkingLot) async throws {
        guard let lotId = parkingLot.id else {
            throw NSError(domain: "FirestoreManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "Parking lot ID is required"])
        }
        try db.collection("parkingLots").document(lotId).setData(from: parkingLot, merge: true)
    }
    
    // MARK: - Booking Operations
    
    func createBooking(_ booking: Booking) async throws -> String {
        let docRef = try db.collection("bookings").addDocument(from: booking)
        
        // Update parking lot available spaces
        if let lotId = booking.parkingLotId as String? {
            let lotRef = db.collection("parkingLots").document(lotId)
            try await lotRef.updateData([
                "availableSpaces": FieldValue.increment(Int64(-1))
            ])
        }
        
        return docRef.documentID
    }
    
    func fetchUserBookings(userId: String) async throws -> [Booking] {
        let snapshot = try await db.collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Booking.self) }
    }
    
    func fetchActiveBooking(userId: String) async throws -> Booking? {
        let snapshot = try await db.collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: BookingStatus.active.rawValue)
            .limit(to: 1)
            .getDocuments()
        
        return snapshot.documents.first.flatMap { try? $0.data(as: Booking.self) }
    }
    
    func updateBooking(_ booking: Booking) async throws {
        guard let bookingId = booking.id else {
            throw NSError(domain: "FirestoreManager", code: 5, userInfo: [NSLocalizedDescriptionKey: "Booking ID is required"])
        }
        try db.collection("bookings").document(bookingId).setData(from: booking, merge: true)
        
        // If booking completed, increment available spaces
        if booking.status == .completed || booking.status == .cancelled {
            let lotRef = db.collection("parkingLots").document(booking.parkingLotId)
            try await lotRef.updateData([
                "availableSpaces": FieldValue.increment(Int64(1))
            ])
        }
    }
    
    // MARK: - Payment Operations
    
    func createPayment(_ payment: Payment) async throws -> String {
        let docRef = try db.collection("payments").addDocument(from: payment)
        return docRef.documentID
    }
    
    func fetchPayments(userId: String) async throws -> [Payment] {
        let snapshot = try await db.collection("payments")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Payment.self) }
    }
    
    func updatePayment(_ payment: Payment) async throws {
        guard let paymentId = payment.id else {
            throw NSError(domain: "FirestoreManager", code: 6, userInfo: [NSLocalizedDescriptionKey: "Payment ID is required"])
        }
        try db.collection("payments").document(paymentId).setData(from: payment, merge: true)
    }
}
