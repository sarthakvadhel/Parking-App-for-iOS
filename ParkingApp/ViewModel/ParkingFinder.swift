//
//  ParkingFinder.swift
//  ParkingApp
//
//  Created by Anik on 2/12/20.
//

import SwiftUI
import MapKit
import CoreLocation
import FirebaseFirestore

class ParkingFinder: NSObject, ObservableObject {
    @Published var spots: [ParkingItem] = []
    @Published var selectedPlace: ParkingItem?
    @Published var showDetail = false
    @Published var isLoading = false
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    private let locationManager = CLLocationManager()
    private var parkingLotsListener: ListenerRegistration?
    
    override init() {
        super.init()
        
        // Initialize with static data immediately to prevent crashes
        self.spots = Data.spots
        self.selectedPlace = Data.spots.first
        
        // Setup location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Load parking lots from Firestore (async)
        loadParkingLots()
        
        // Setup real-time listener
        setupRealtimeListener()
    }
    
    deinit {
        // Clean up listener when object is deallocated
        parkingLotsListener?.remove()
    }
    
    /// Setup real-time Firestore listener for parking lots
    private func setupRealtimeListener() {
        parkingLotsListener = Firestore.firestore()
            .collection("parkingLots")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error listening to parking lots: \(error.localizedDescription)")
                    CrashLogger.shared.logNonFatal("Firestore listener error", metadata: ["error": error.localizedDescription])
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                Task { @MainActor in
                    let parkingLots = documents.compactMap { doc -> ParkingLot? in
                        try? doc.data(as: ParkingLot.self)
                    }
                    
                    self.spots = parkingLots.map { lot in
                        ParkingItem(
                            id: lot.id ?? UUID().uuidString,
                            name: lot.name,
                            address: lot.address,
                            photoName: "1", // Default image
                            place: "A1",
                            carLimit: lot.availableSpaces,
                            location: lot.coordinate,
                            fee: lot.hourlyCharge,
                            hour: "0.0",
                            description: lot.description,
                            lateFee: lot.lateFee,
                            terms: lot.terms,
                            vendorId: lot.vendorId
                        )
                    }
                    
                    // Maintain current selection if it still exists
                    if let currentId = self.selectedPlace?.id,
                       let updatedPlace = self.spots.first(where: { $0.id == currentId }) {
                        self.selectedPlace = updatedPlace
                    } else if self.selectedPlace == nil, let firstSpot = self.spots.first {
                        self.selectedPlace = firstSpot
                    }
                    
                    CrashLogger.shared.log("Real-time update: \(self.spots.count) parking lots")
                }
            }
    }
    
    func loadParkingLots() {
        isLoading = true
        Task {
            do {
                let parkingLots = try await FirestoreManager.shared.fetchParkingLots()
                await MainActor.run {
                    self.spots = parkingLots.map { lot in
                        ParkingItem(
                            id: lot.id ?? UUID().uuidString,
                            name: lot.name,
                            address: lot.address,
                            photoName: "1", // Default image
                            place: "A1", // Can be enhanced
                            carLimit: lot.availableSpaces,
                            location: lot.coordinate,
                            fee: lot.hourlyCharge,
                            hour: "0.0",
                            description: lot.description,
                            lateFee: lot.lateFee,
                            terms: lot.terms,
                            vendorId: lot.vendorId
                        )
                    }
                    
                    // If no parking lots from Firestore, use static data as fallback
                    if self.spots.isEmpty {
                        self.spots = Data.spots
                    }
                    
                    if let firstSpot = self.spots.first {
                        self.selectedPlace = firstSpot
                        self.region = MKCoordinateRegion(
                            center: firstSpot.location,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    }
                    
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    // Fallback to static data on error
                    self.spots = Data.spots
                    if let firstSpot = self.spots.first {
                        self.selectedPlace = firstSpot
                    }
                    self.isLoading = false
                }
            }
        }
    }
    
    func updateRegionToUserLocation(_ location: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    }
}

extension ParkingFinder: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        updateRegionToUserLocation(location.coordinate)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
