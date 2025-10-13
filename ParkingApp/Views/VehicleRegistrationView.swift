//
//  VehicleRegistrationView.swift
//  ParkingApp
//
//  Created by Parking App Team
//

import SwiftUI
import FirebaseAuth

struct VehicleRegistrationView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("uid") var userID: String = ""
    
    var isOptional: Bool = true  // Can be skipped by default
    
    @State private var vehicleNumber = ""
    @State private var model = ""
    @State private var manufacturer = ""
    @State private var color = ""
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
                        Text("Add Your Vehicle")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color.theme.textPrimary)
                            .padding(.top)
                        
                        Text("Register your vehicle details to book parking")
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
                        
                        Button(action: saveVehicle) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Save Vehicle")
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
                        
                        if isOptional {
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
            Text("Vehicle registered successfully!")
        }
    }
    
    private func saveVehicle() {
        guard !vehicleNumber.isEmpty, !model.isEmpty else {
            errorMessage = "Please fill in required fields"
            showError = true
            return
        }
        
        isLoading = true
        
        let vehicle = Vehicle(
            userId: userID,
            vehicleNumber: vehicleNumber.uppercased(),
            model: model,
            manufacturer: manufacturer.isEmpty ? nil : manufacturer,
            color: color.isEmpty ? nil : color,
            isActive: true
        )
        
        Task {
            do {
                _ = try await FirestoreManager.shared.createVehicle(vehicle)
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                    shouldDismiss = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to save vehicle: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}
