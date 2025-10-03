//
//  VendorDashboardView.swift
//  ParkingApp
//
//  Created by Parking App Team
//

import SwiftUI
import FirebaseAuth

struct VendorDashboardView: View {
    @AppStorage("uid") var userID: String = ""
    @StateObject private var viewModel = VendorDashboardViewModel()
    @State private var showAddParkingLot = false
    @State private var showEditParkingLot: ParkingLot?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Vendor Dashboard")
                                    .font(.largeTitle)
                                    .bold()
                                Text("Manage your parking lots")
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                            Button(action: {
                                logout()
                            }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        
                        // Stats
                        HStack(spacing: 15) {
                            StatCard(
                                title: "Total Lots",
                                value: "\(viewModel.parkingLots.count)",
                                icon: "building.2.fill",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "Total Spaces",
                                value: "\(viewModel.totalSpaces)",
                                icon: "square.grid.3x3.fill",
                                color: .green
                            )
                            
                            StatCard(
                                title: "Available",
                                value: "\(viewModel.availableSpaces)",
                                icon: "checkmark.circle.fill",
                                color: .orange
                            )
                        }
                        .padding(.horizontal)
                        
                        // Parking Lots List
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Your Parking Lots")
                                    .font(.title2)
                                    .bold()
                                Spacer()
                                Button(action: {
                                    showAddParkingLot = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else if viewModel.parkingLots.isEmpty {
                                VStack(spacing: 15) {
                                    Image(systemName: "building.2.slash")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                    Text("No parking lots yet")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                    Button(action: {
                                        showAddParkingLot = true
                                    }) {
                                        Text("Add Your First Parking Lot")
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.blue)
                                            .cornerRadius(10)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                ForEach(viewModel.parkingLots) { lot in
                                    VendorParkingLotCard(
                                        parkingLot: lot,
                                        onEdit: {
                                            showEditParkingLot = lot
                                        }
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .refreshable {
                    await viewModel.loadParkingLots()
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            Task {
                await viewModel.loadParkingLots()
            }
        }
        .sheet(isPresented: $showAddParkingLot) {
            VendorRegistrationView()
                .onDisappear {
                    Task {
                        await viewModel.loadParkingLots()
                    }
                }
        }
        .sheet(item: $showEditParkingLot) { lot in
            VendorEditParkingLotView(parkingLot: lot)
                .onDisappear {
                    Task {
                        await viewModel.loadParkingLots()
                    }
                }
        }
    }
    
    private func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            userID = ""
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            Text(value)
                .font(.title2)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)
    }
}

struct VendorParkingLotCard: View {
    let parkingLot: ParkingLot
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(parkingLot.name)
                        .font(.headline)
                    Text(parkingLot.address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            HStack(spacing: 20) {
                Label("\(parkingLot.availableSpaces)/\(parkingLot.totalSpaces)", systemImage: "car.fill")
                    .foregroundColor(.green)
                Label("₹\(String(format: "%.0f", parkingLot.hourlyCharge))/h", systemImage: "indianrupeesign.circle.fill")
                    .foregroundColor(.orange)
            }
            .font(.subheadline)
            
            HStack {
                Text(parkingLot.isActive ? "Active" : "Inactive")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(parkingLot.isActive ? Color.green : Color.gray)
                    .cornerRadius(5)
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)
    }
}

@MainActor
class VendorDashboardViewModel: ObservableObject {
    @Published var parkingLots: [ParkingLot] = []
    @Published var isLoading = false
    
    var totalSpaces: Int {
        parkingLots.reduce(0) { $0 + $1.totalSpaces }
    }
    
    var availableSpaces: Int {
        parkingLots.reduce(0) { $0 + $1.availableSpaces }
    }
    
    func loadParkingLots() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        do {
            parkingLots = try await FirestoreManager.shared.fetchVendorParkingLots(vendorId: userId)
        } catch {
            print("Error loading parking lots: \(error)")
        }
        isLoading = false
    }
}

struct VendorEditParkingLotView: View {
    @Environment(\.dismiss) var dismiss
    @State var parkingLot: ParkingLot
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $parkingLot.name)
                    TextField("Description", text: $parkingLot.description)
                    TextField("Address", text: $parkingLot.address)
                }
                
                Section(header: Text("Pricing")) {
                    HStack {
                        Text("Hourly Charge (₹)")
                        Spacer()
                        TextField("0", value: $parkingLot.hourlyCharge, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Late Fee (₹)")
                        Spacer()
                        TextField("0", value: $parkingLot.lateFee, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Capacity")) {
                    HStack {
                        Text("Total Spaces")
                        Spacer()
                        TextField("0", value: $parkingLot.totalSpaces, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Available Spaces")
                        Spacer()
                        Text("\(parkingLot.availableSpaces)")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Terms & Conditions")) {
                    TextEditor(text: $parkingLot.terms)
                        .frame(height: 100)
                }
                
                Section {
                    Toggle("Active", isOn: $parkingLot.isActive)
                }
            }
            .navigationTitle("Edit Parking Lot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveParkingLot) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Save")
                                .bold()
                        }
                    }
                    .disabled(isLoading)
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
                dismiss()
            }
        } message: {
            Text("Parking lot updated successfully!")
        }
    }
    
    private func saveParkingLot() {
        isLoading = true
        Task {
            do {
                try await FirestoreManager.shared.updateParkingLot(parkingLot)
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to update: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}
