//
//  SearchView.swift
//  ParkingApp
//
//  Created by Anik on 2/12/20.
//

import SwiftUI

struct SearchView: View {
    @State private var showSearch = false
    
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
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "chevron.right")
                    .padding()
                    .foregroundColor(.gray)
            }
            .background(Color.white)
            .cornerRadius(25)
        }
        .sheet(isPresented: $showSearch) {
            ParkingSearchView()
        }
    }
}

struct ParkingSearchView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var parkingLots: [ParkingItem] = []
    @State private var isLoading = false
    
    var filteredLots: [ParkingItem] {
        if searchText.isEmpty {
            return parkingLots
        }
        return parkingLots.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by name or address", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
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
                            .foregroundColor(.gray)
                        Text(searchText.isEmpty ? "Start searching for parking" : "No results found")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    Spacer()
                } else {
                    List(filteredLots) { lot in
                        SearchResultRow(parkingItem: lot)
                            .onTapGesture {
                                // Future: Navigate to detail
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
                            terms: lot.terms
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(parkingItem.name)
                .font(.headline)
            Text(parkingItem.address)
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack {
                Label("\(parkingItem.carLimit) spaces", systemImage: "car.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                Spacer()
                Text("₹\(String(format: "%.0f", parkingItem.fee))/h")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 8)
    }
}
