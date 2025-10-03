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
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Register Parking Lot")
                            .font(.largeTitle)
                            .bold()
                            .padding(.top)
                        
                        Text("Provide details about your parking space")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.bottom)
                        
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Parking Lot Name")
                                .font(.headline)
                            TextField("e.g., City Center Parking", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
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
                            TextField("e.g., 50", text: $hourlyCharge)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal)
                        
                        // Late Fee
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Late Fee per Hour (₹)")
                                .font(.headline)
                            TextField("e.g., 20", text: $lateFee)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal)
                        
                        // Total Spaces
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Total Parking Spaces")
                                .font(.headline)
                            TextField("e.g., 50", text: $totalSpaces)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        .padding(.horizontal)
                        
                        // Terms
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Terms & Conditions")
                                .font(.headline)
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
                                .foregroundColor(.gray)
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
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var pinLocation: CLLocationCoordinate2D?
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: pinLocation.map { [MapPin(coordinate: $0)] } ?? []) { pin in
                    MapMarker(coordinate: pin.coordinate, tint: .red)
                }
                .onTapGesture {
                    // This doesn't work well with Map in SwiftUI, but we'll use a button to set location
                }
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 15) {
                        Text("Tap 'Drop Pin' to mark your parking location")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                        
                        HStack(spacing: 15) {
                            Button(action: {
                                pinLocation = region.center
                            }) {
                                Text("Drop Pin Here")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
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
                                }
                            }
                        }
                    }
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
        }
    }
}

struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
