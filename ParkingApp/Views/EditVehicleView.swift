//
//  EditVehicleView.swift
//  ParkingApp
//
//  Created by Parking App Team
//

import SwiftUI

struct EditVehicleView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("uid") var userID: String = ""
    
    let vehicle: Vehicle
    
    @State private var vehicleNumber = ""
    @State private var model = ""
    @State private var manufacturer = ""
    @State private var color = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Edit Vehicle")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color.theme.textPrimary)
                            .padding(.top)
                        
                        Text("Update your vehicle details")
                            .foregroundColor(Color.theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom)
                        
                        // Vehicle Number
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Vehicle Number")
                                .font(.headline)
                                .foregroundColor(Color.theme.textPrimary)
                            TextField("e.g., GJ01AE7828", text: $vehicleNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.allCharacters)
                        }
                        .padding(.horizontal)
                        
                        // Model
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Model")
                                .font(.headline)
                                .foregroundColor(Color.theme.textPrimary)
                            TextField("e.g., Swift, City, i20", text: $model)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                        
                        // Manufacturer
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Manufacturer (Optional)")
                                .font(.headline)
                                .foregroundColor(Color.theme.textPrimary)
                            TextField("e.g., Maruti, Honda, Hyundai", text: $manufacturer)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                        
                        // Color
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Color (Optional)")
                                .font(.headline)
                                .foregroundColor(Color.theme.textPrimary)
                            TextField("e.g., White, Black, Red", text: $color)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        Button(action: updateVehicle) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Update Vehicle")
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
                        .disabled(isLoading || vehicleNumber.isEmpty || model.isEmpty)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        .padding(.bottom)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Success!", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Vehicle updated successfully!")
        }
        .onAppear {
            // Pre-populate fields with existing vehicle data
            vehicleNumber = vehicle.vehicleNumber
            model = vehicle.model
            manufacturer = vehicle.manufacturer ?? ""
            color = vehicle.color ?? ""
        }
    }
    
    private func updateVehicle() {
        guard !vehicleNumber.isEmpty, !model.isEmpty else {
            errorMessage = "Please fill in required fields"
            showError = true
            return
        }
        
        isLoading = true
        
        var updatedVehicle = vehicle
        updatedVehicle.vehicleNumber = vehicleNumber.uppercased()
        updatedVehicle.model = model
        updatedVehicle.manufacturer = manufacturer.isEmpty ? nil : manufacturer
        updatedVehicle.color = color.isEmpty ? nil : color
        
        Task {
            do {
                try await FirestoreManager.shared.updateVehicle(updatedVehicle)
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to update vehicle: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}
