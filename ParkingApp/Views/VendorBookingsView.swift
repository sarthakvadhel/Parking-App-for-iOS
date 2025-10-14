//
//  VendorBookingsView.swift
//  ParkingApp
//
//  Created for vendor booking management
//

import SwiftUI
import FirebaseFirestore

struct VendorBookingsView: View {
    @StateObject private var viewModel = VendorBookingsViewModel()
    @State private var selectedFilter: BookingStatus = .pending
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter tabs
                filterTabs
                
                // Content
                if viewModel.isLoading {
                    ProgressView("Loading bookings...")
                        .padding()
                } else if filteredBookings.isEmpty {
                    emptyState
                } else {
                    bookingsList
                }
            }
            .navigationTitle("Bookings & Leads")
            .navigationBarTitleDisplayMode(.large)
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .onAppear {
            viewModel.loadBookings()
            AnalyticsService.shared.trackScreen("VendorBookings")
        }
    }
    
    private var filterTabs: some View {
        Picker("Status", selection: $selectedFilter) {
            Text("Pending (\(viewModel.pendingCount))").tag(BookingStatus.pending)
            Text("Active (\(viewModel.activeCount))").tag(BookingStatus.active)
            Text("Completed (\(viewModel.completedCount))").tag(BookingStatus.completed)
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    private var filteredBookings: [Booking] {
        viewModel.bookings.filter { $0.status == selectedFilter }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: iconForStatus(selectedFilter))
                .font(.system(size: 60))
                .foregroundColor(Color.theme.iconSecondary.opacity(0.7))
            
            Text("No \(selectedFilter.rawValue.lowercased()) bookings")
                .font(.headline)
                .foregroundColor(Color.theme.textSecondary)
            
            Text(messageForStatus(selectedFilter))
                .font(.subheadline)
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var bookingsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredBookings) { booking in
                    VendorBookingCard(
                        booking: booking,
                        onAccept: {
                            viewModel.acceptBooking(booking)
                        },
                        onDecline: {
                            viewModel.declineBooking(booking)
                        }
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    private func iconForStatus(_ status: BookingStatus) -> String {
        switch status {
        case .pending: return "clock.badge.questionmark"
        case .active: return "checkmark.circle"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle"
        }
    }
    
    private func messageForStatus(_ status: BookingStatus) -> String {
        switch status {
        case .pending: return "New booking requests will appear here"
        case .active: return "Active bookings will be shown here"
        case .completed: return "Completed bookings will be listed here"
        case .cancelled: return "Cancelled bookings will appear here"
        }
    }
}

// MARK: - Booking Card Component
struct VendorBookingCard: View {
    let booking: Booking
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    @State private var showDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.parkingLotName ?? "Unknown Parking")
                        .font(.headline)
                        .foregroundColor(Color.theme.textPrimary)
                    
                    // Ensure Substring is converted to String for interpolation
                    Text("Booking #\((booking.id.map { String($0.prefix(8)) }) ?? "N/A")")
                        .font(.caption)
                        .foregroundColor(Color.theme.textSecondary)
                }
                
                Spacer()
                
                statusBadge
            }
            
            // Booking details
            VStack(spacing: 8) {
                DetailRow(icon: "calendar", text: formatDate(booking.startTime))
                DetailRow(icon: "clock", text: "\(Int(booking.duration)) hours")
                DetailRow(icon: "indianrupeesign.circle.fill", text: "₹\(Int(booking.totalAmount))")
                
                if let userName = booking.userName {
                    DetailRow(icon: "person.fill", text: userName)
                }
                
                if let vehicleNumber = booking.vehicleNumber {
                    DetailRow(icon: "car.fill", text: vehicleNumber)
                }
            }
            
            // Action buttons for pending bookings
            if booking.status == .pending {
                HStack(spacing: 12) {
                    Button(action: onDecline) {
                        HStack {
                            Image(systemName: "xmark")
                            Text("Decline")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                    }
                    
                    Button(action: onAccept) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Accept")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var statusBadge: some View {
        Text(booking.status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(12)
    }
    
    private var statusColor: Color {
        switch booking.status {
        case .pending: return .orange
        case .active: return .blue
        case .completed: return .green
        case .cancelled: return .red
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Detail Row Component
struct DetailRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Color.theme.iconSecondary)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(Color.theme.textPrimary)
        }
    }
}

// MARK: - View Model
class VendorBookingsViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private var listener: ListenerRegistration?
    
    var pendingCount: Int {
        bookings.filter { $0.status == .pending }.count
    }
    
    var activeCount: Int {
        bookings.filter { $0.status == .active }.count
    }
    
    var completedCount: Int {
        bookings.filter { $0.status == .completed }.count
    }
    
    func loadBookings() {
        let vendorId = AuthManager.shared.userID
        guard !vendorId.isEmpty else {
            return
        }
        
        isLoading = true
        
        // Setup real-time listener for bookings
        listener = Firestore.firestore()
            .collection("bookings")
            .whereField("vendorId", isEqualTo: vendorId)
            .order(by: "startTime", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    CrashLogger.shared.log(error: error, context: ["screen": "VendorBookings"])
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.bookings = documents.compactMap { doc in
                    try? doc.data(as: Booking.self)
                }
                
                CrashLogger.shared.log("Loaded \(self.bookings.count) bookings for vendor")
            }
    }
    
    func acceptBooking(_ booking: Booking) {
        guard let bookingId = booking.id else { return }
        
        Task {
            do {
                try await Firestore.firestore()
                    .collection("bookings")
                    .document(bookingId)
                    .updateData([
                        "status": BookingStatus.active.rawValue,
                        "acceptedAt": Timestamp(date: Date())
                    ])
                
                AnalyticsService.shared.track(.parkingBooked(
                    lotId: booking.parkingLotId,
                    duration: booking.duration,
                    amount: booking.totalAmount
                ))
                
                CrashLogger.shared.log("Booking accepted: \(bookingId)")
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to accept booking: \(error.localizedDescription)"
                    self.showError = true
                }
                error.log(context: ["action": "accept_booking", "bookingId": bookingId])
            }
        }
    }
    
    func declineBooking(_ booking: Booking) {
        guard let bookingId = booking.id else { return }
        
        Task {
            do {
                try await Firestore.firestore()
                    .collection("bookings")
                    .document(bookingId)
                    .updateData([
                        "status": BookingStatus.cancelled.rawValue,
                        "cancelledAt": Timestamp(date: Date()),
                        "cancellationReason": "Declined by vendor"
                    ])
                
                AnalyticsService.shared.track(.bookingCancelled(
                    bookingId: bookingId,
                    reason: "vendor_declined"
                ))
                
                CrashLogger.shared.log("Booking declined: \(bookingId)")
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to decline booking: \(error.localizedDescription)"
                    self.showError = true
                }
                error.log(context: ["action": "decline_booking", "bookingId": bookingId])
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}
