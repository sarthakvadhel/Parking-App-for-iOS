//
//  ParkingFinder.swift
//  ParkingApp
//
//  Created by Anik on 2/12/20.
//

import SwiftUI
import MapKit
import CoreLocation

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
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Load parking lots from Firestore
        loadParkingLots()
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
                            terms: lot.terms
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
