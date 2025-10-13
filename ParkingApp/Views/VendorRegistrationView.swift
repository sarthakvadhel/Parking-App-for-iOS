//
//  VendorRegistrationView.swift
//  ParkingApp
//
//  Created by Parking App Team
//

import SwiftUI
import MapKit

struct VendorRegistrationView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("uid") var userID: String = ""
    
    @State private var name = ""
    @State private var description = ""
    @State private var address = ""
    @State private var hourlyCharge = ""
    @State private var lateFee = ""
    @State private var terms = ""
    @State private var totalSpaces = ""
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var showMapPicker = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var shouldDismiss = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Register Parking Lot")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color.theme.textPrimary)
                            .padding(.top)
                        
                        Text("Provide details about your parking space")
                            .foregroundColor(Color.theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom)
                        
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Parking Lot Name")
                                .font(.headline)
                                .foregroundColor(Color.theme.textPrimary)
                            TextField("e.g., City Center Parking", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(Color.theme.textPrimary)
                            TextEditor(text: $description)
                                .frame(height: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                        
                        // Address
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Address")
                                .font(.headline)
                                .foregroundColor(Color.theme.textPrimary)
                            TextField("Full address", text: $address)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                        
                        // Location Picker
                        Button(action: {
                            showMapPicker = true
                        }) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text(selectedLocation == nil ? "Select Location on Map" : "Location Selected ✓")
                            }
                            .foregroundColor(selectedLocation == nil ? .blue : .green)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedLocation == nil ? Color.blue : Color.green, lineWidth: 2)
                            )
                        }
                        .padding(.horizontal)
                        
                        // Hourly Charge
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hourly Charge (₹)")
                                .font(.headline)
                                .foregroundColor(Color.theme.textPrimary)
                            TextField("e.g., 50", text: $hourlyCharge)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal)
                        
                        // Late Fee
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Late Fee per Hour (₹)")
                                .font(.headline)
                                .foregroundColor(Color.theme.textPrimary)
                            TextField("e.g., 20", text: $lateFee)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal)
                        
                        // Total Spaces
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Total Parking Spaces")
                                .font(.headline)
                                .foregroundColor(Color.theme.textPrimary)
                            TextField("e.g., 50", text: $totalSpaces)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        .padding(.horizontal)
                        
                        // Terms
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Terms & Conditions")
                                .font(.headline)
                                .foregroundColor(Color.theme.textPrimary)
                            TextEditor(text: $terms)
                                .frame(height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                        
                        Button(action: saveParkingLot) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Register Parking Lot")
                                    .foregroundColor(.white)
                                    .font(.title3)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black)
                        )
                        .padding(.horizontal)
                        .disabled(isLoading || !isFormValid())
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Skip for Now")
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        .padding(.bottom)
                    }
                }
            }
        }
        .sheet(isPresented: $showMapPicker) {
            MapLocationPickerView(selectedLocation: $selectedLocation)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Success!", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {
                if shouldDismiss {
                    dismiss()
                }
            }
        } message: {
            Text("Parking lot registered successfully!")
        }
    }
    
    private func isFormValid() -> Bool {
        return !name.isEmpty &&
               !description.isEmpty &&
               !address.isEmpty &&
               selectedLocation != nil &&
               !hourlyCharge.isEmpty &&
               !lateFee.isEmpty &&
               !totalSpaces.isEmpty &&
               !terms.isEmpty
    }
    
    private func saveParkingLot() {
        guard let location = selectedLocation,
              let hourlyChargeValue = Double(hourlyCharge),
              let lateFeeValue = Double(lateFee),
              let totalSpacesValue = Int(totalSpaces) else {
            errorMessage = "Please fill in all fields correctly"
            showError = true
            return
        }
        
        isLoading = true
        
        let parkingLot = ParkingLot(
            vendorId: userID,
            name: name,
            description: description,
            address: address,
            latitude: location.latitude,
            longitude: location.longitude,
            hourlyCharge: hourlyChargeValue,
            lateFee: lateFeeValue,
            terms: terms,
            totalSpaces: totalSpacesValue,
            availableSpaces: totalSpacesValue
        )
        
        Task {
            do {
                _ = try await FirestoreManager.shared.createParkingLot(parkingLot)
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                    shouldDismiss = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to register parking lot: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

struct MapLocationPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @StateObject private var locationManager = LocationManagerForVendor()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var pinLocation: CLLocationCoordinate2D?
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: pinLocation.map { [MapPin(coordinate: $0)] } ?? []) { pin in
                    MapAnnotation(coordinate: pin.coordinate) {
                        VStack(spacing: 0) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.red)
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.red)
                                .offset(y: -5)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // Center crosshair when no pin is placed
                if pinLocation == nil {
                    VStack {
                        Spacer()
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .thin))
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                
                VStack {
                    // Instructions at top
                    VStack(spacing: 10) {
                        Text(pinLocation == nil ? "Move map to position" : "Drag pin to adjust position")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.75))
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Action buttons at bottom
                    VStack(spacing: 15) {
                        if let currentLocation = locationManager.currentLocation {
                            Button(action: {
                                region.center = currentLocation
                            }) {
                                HStack {
                                    Image(systemName: "location.fill")
                                    Text("Go to Current Location")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                            }
                        }
                        
                        HStack(spacing: 15) {
                            Button(action: {
                                pinLocation = region.center
                            }) {
                                Text(pinLocation == nil ? "Drop Pin Here" : "Move Pin Here")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .shadow(radius: 3)
                            }
                            
                            if pinLocation != nil {
                                Button(action: {
                                    selectedLocation = pinLocation
                                    dismiss()
                                }) {
                                    Text("Confirm Location")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(10)
                                        .shadow(radius: 3)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding()
                }
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                locationManager.requestLocation()
                // Set initial region to user location if available
                if let userLocation = locationManager.currentLocation {
                    region.center = userLocation
                }
            }
            .onChange(of: locationManager.currentLocation) { newLocation in
                if let location = newLocation, pinLocation == nil {
                    region.center = location
                }
            }
        }
    }
}

struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// Location manager for vendor registration
class LocationManagerForVendor: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.currentLocation = location.coordinate
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
