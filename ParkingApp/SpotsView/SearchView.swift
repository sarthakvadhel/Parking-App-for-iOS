//
//  SearchView.swift
//  ParkingApp
//
//  Created by Anik on 2/12/20.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @State private var showSearch = false
    @EnvironmentObject var parkingFinder: ParkingFinder
    
    var body: some View {
        Button(action: {
            showSearch = true
        }) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 22))
                    .padding()
                    .foregroundColor(.blue)
                Text("Search For Parking")
                    .foregroundColor(Color.theme.textSecondary)
                Spacer()
                Image(systemName: "chevron.right")
                    .padding()
                    .foregroundColor(Color.theme.iconSecondary)
            }
            .background(Color.theme.cardBackground)
            .cornerRadius(25)
        }
        .sheet(isPresented: $showSearch) {
            ParkingSearchView()
                .environmentObject(parkingFinder)
        }
    }
}

struct ParkingSearchView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var parkingFinder: ParkingFinder
    @State private var searchText = ""
    @State private var parkingLots: [ParkingItem] = []
    @State private var isLoading = false
    
    var filteredLots: [ParkingItem] {
        let filtered = searchText.isEmpty ? parkingLots : parkingLots.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText)
        }
        
        // Sort by distance from user location
        guard parkingFinder.userLocation != nil else { return filtered }
        return filtered.sorted { spot1, spot2 in
            let dist1 = parkingFinder.distanceToSpot(spot1) ?? Double.infinity
            let dist2 = parkingFinder.distanceToSpot(spot2) ?? Double.infinity
            return dist1 < dist2
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.theme.iconSecondary)
                    TextField("Search by name or address", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(Color.theme.textPrimary)
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color.theme.iconSecondary)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
                
                // Results
                if isLoading {
                    ProgressView()
                        .padding()
                } else if filteredLots.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(Color.theme.iconSecondary)
                        Text(searchText.isEmpty ? "Start searching for parking" : "No results found")
                            .foregroundColor(Color.theme.textSecondary)
                    }
                    .padding()
                    Spacer()
                } else {
                    List(filteredLots) { lot in
                        SearchResultRow(parkingItem: lot, parkingFinder: parkingFinder)
                            .onTapGesture {
                                // Select the parking spot and navigate back
                                parkingFinder.selectedPlace = lot
                                // Center map on selected spot
                                parkingFinder.region = MKCoordinateRegion(
                                    center: lot.location,
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                )
                                dismiss()
                            }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Search Parking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadParkingLots()
        }
    }
    
    private func loadParkingLots() {
        isLoading = true
        Task {
            do {
                let lots = try await FirestoreManager.shared.fetchParkingLots()
                await MainActor.run {
                    parkingLots = lots.map { lot in
                        ParkingItem(
                            id: lot.id ?? UUID().uuidString,
                            name: lot.name,
                            address: lot.address,
                            photoName: "1",
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
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    parkingLots = Data.spots
                    isLoading = false
                }
            }
        }
    }
}

struct SearchResultRow: View {
    let parkingItem: ParkingItem
    let parkingFinder: ParkingFinder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(parkingItem.name)
                .font(.headline)
                .foregroundColor(Color.theme.textPrimary)
            Text(parkingItem.address)
                .font(.subheadline)
                .foregroundColor(Color.theme.textSecondary)
            HStack {
                Label("\(parkingItem.carLimit) spaces", systemImage: "car.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                Spacer()
                Text("₹\(String(format: "%.0f", parkingItem.fee))/h")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                // Show distance if user location is available
                if parkingFinder.userLocation != nil {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text(parkingFinder.formattedDistance(to: parkingItem))
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
