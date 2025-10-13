//
//  MyVehiclesView.swift
//  ParkingApp
//
//  Created by Parking App Team
//

import SwiftUI

struct MyVehiclesView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("uid") var userID: String = ""
    @ObservedObject var firestoreManager = FirestoreManager.shared
    
    @State private var vehicles: [Vehicle] = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showAddVehicle = false
    @State private var showEditVehicle = false
    @State private var vehicleToEdit: Vehicle?
    @State private var showDeleteConfirmation = false
    @State private var vehicleToDelete: Vehicle?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                if isLoading && vehicles.isEmpty {
                    VStack {
                        ProgressView("Loading vehicles...")
                            .foregroundColor(Color.theme.textSecondary)
                    }
                } else if vehicles.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color.theme.iconSecondary)
                        
                        Text("No Vehicles")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color.theme.textPrimary)
                        
                        Text("Add your first vehicle to start booking parking")
                            .font(.body)
                            .foregroundColor(Color.theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            showAddVehicle = true
                        }) {
                            Text("Add Vehicle")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: 200)
                                .background(Color.black)
                                .cornerRadius(10)
                        }
                        .padding(.top)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(vehicles) { vehicle in
                                VehicleCard(
                                    vehicle: vehicle,
                                    isActive: vehicle.isActive,
                                    onEdit: {
                                        vehicleToEdit = vehicle
                                        showEditVehicle = true
                                    },
                                    onDelete: {
                                        vehicleToDelete = vehicle
                                        showDeleteConfirmation = true
                                    },
                                    onSetActive: {
                                        setActiveVehicle(vehicle)
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Vehicles")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.theme.textPrimary)
                    }
                }
                
                if !vehicles.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showAddVehicle = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(Color.theme.textPrimary)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddVehicle) {
            VehicleRegistrationView()
                .onDisappear {
                    loadVehicles()
                }
        }
        .sheet(isPresented: $showEditVehicle) {
            if let vehicle = vehicleToEdit {
                EditVehicleView(vehicle: vehicle)
                    .onDisappear {
                        loadVehicles()
                        vehicleToEdit = nil
                    }
            }
        }
        .alert("Delete Vehicle", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                vehicleToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let vehicle = vehicleToDelete {
                    deleteVehicle(vehicle)
                }
            }
        } message: {
            Text("Are you sure you want to delete this vehicle? This action cannot be undone.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadVehicles()
        }
    }
    
    private func loadVehicles() {
        isLoading = true
        Task {
            do {
                let fetchedVehicles = try await FirestoreManager.shared.fetchVehicles(userId: userID)
                await MainActor.run {
                    vehicles = fetchedVehicles.sorted { v1, v2 in
                        // Active vehicles first
                        if v1.isActive != v2.isActive {
                            return v1.isActive
                        }
                        // Then by creation date (newest first)
                        return v1.createdAt > v2.createdAt
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to load vehicles: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func setActiveVehicle(_ vehicle: Vehicle) {
        Task {
            do {
                try await FirestoreManager.shared.setActiveVehicle(vehicle, userId: userID)
                await MainActor.run {
                    loadVehicles()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to set active vehicle: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func deleteVehicle(_ vehicle: Vehicle) {
        guard let vehicleId = vehicle.id else { return }
        
        Task {
            do {
                try await FirestoreManager.shared.deleteVehicle(vehicleId)
                await MainActor.run {
                    vehicleToDelete = nil
                    loadVehicles()
                    
                    // If we deleted the active vehicle, clear it from manager
                    if firestoreManager.currentVehicle?.id == vehicleId {
                        firestoreManager.currentVehicle = nil
                    }
                }
            } catch {
                await MainActor.run {
                    vehicleToDelete = nil
                    errorMessage = "Failed to delete vehicle: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

struct VehicleCard: View {
    let vehicle: Vehicle
    let isActive: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSetActive: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(vehicle.vehicleNumber)
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Text(vehicle.model)
                        .font(.body)
                        .foregroundColor(Color.theme.textSecondary)
                    
                    if let manufacturer = vehicle.manufacturer, !manufacturer.isEmpty {
                        Text(manufacturer)
                            .font(.caption)
                            .foregroundColor(Color.theme.textSecondary)
                    }
                    
                    if let color = vehicle.color, !color.isEmpty {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.theme.textSecondary)
                                .frame(width: 8, height: 8)
                            Text(color)
                                .font(.caption)
                                .foregroundColor(Color.theme.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                if isActive {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("Active")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Divider()
            
            HStack(spacing: 16) {
                if !isActive {
                    Button(action: onSetActive) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("Set Active")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                
                Button(action: onEdit) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .font(.subheadline)
                    .foregroundColor(Color.theme.textPrimary)
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color.theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
