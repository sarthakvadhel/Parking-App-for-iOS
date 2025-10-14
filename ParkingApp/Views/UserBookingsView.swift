//
//  UserBookingsView.swift
//  ParkingApp
//
//  Created for user booking management
//

import SwiftUI
import FirebaseFirestore

struct UserBookingsView: View {
    @StateObject private var viewModel = UserBookingsViewModel()
    @State private var selectedTab: BookingTab = .active
    
    enum BookingTab {
        case pending, active, previous
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                tabSelector
                
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
            .navigationTitle("My Bookings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .onAppear {
            viewModel.loadBookings()
            AnalyticsService.shared.trackScreen("UserBookings")
        }
    }
    
    private var tabSelector: some View {
        Picker("Booking Type", selection: $selectedTab) {
            Text("Pending (\(viewModel.pendingCount))").tag(BookingTab.pending)
            Text("Active (\(viewModel.activeCount))").tag(BookingTab.active)
            Text("Previous (\(viewModel.previousCount))").tag(BookingTab.previous)
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    private var filteredBookings: [Booking] {
        switch selectedTab {
        case .pending:
            return viewModel.bookings.filter { $0.status == .pending }
        case .active:
            return viewModel.bookings.filter { $0.status == .active }
        case .previous:
            return viewModel.bookings.filter { $0.status == .completed || $0.status == .cancelled }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: iconForTab(selectedTab))
                .font(.system(size: 60))
                .foregroundColor(Color.theme.iconSecondary.opacity(0.7))
            
            Text(titleForTab(selectedTab))
                .font(.headline)
                .foregroundColor(Color.theme.textSecondary)
            
            Text(messageForTab(selectedTab))
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
                    UserBookingCard(
                        booking: booking,
                        isActive: booking.status == .active
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    private func iconForTab(_ tab: BookingTab) -> String {
        switch tab {
        case .pending: return "clock.badge.questionmark"
        case .active: return "timer"
        case .previous: return "checkmark.circle.fill"
        }
    }
    
    private func titleForTab(_ tab: BookingTab) -> String {
        switch tab {
        case .pending: return "No Pending Bookings"
        case .active: return "No Active Bookings"
        case .previous: return "No Previous Bookings"
        }
    }
    
    private func messageForTab(_ tab: BookingTab) -> String {
        switch tab {
        case .pending: return "Bookings awaiting vendor confirmation will appear here"
        case .active: return "Your active parking sessions will be shown here"
        case .previous: return "Completed and cancelled bookings will be listed here"
        }
    }
}

// MARK: - User Booking Card Component
struct UserBookingCard: View {
    let booking: Booking
    let isActive: Bool
    @State private var currentTime = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.parkingLotName ?? "Unknown Parking")
                        .font(.headline)
                        .foregroundColor(Color.theme.textPrimary)
                    
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
                DetailRow(icon: "clock", text: "\(Int(booking.duration)) hours planned")
                DetailRow(icon: "indianrupeesign.circle.fill", text: "₹\(Int(booking.totalAmount))")
                
                if let vehicleNumber = booking.vehicleNumber {
                    DetailRow(icon: "car.fill", text: vehicleNumber)
                }
            }
            
            // Active booking timer
            if isActive, let acceptedAt = booking.acceptedAt {
                Divider()
                    .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Parking Session")
                        .font(.caption)
                        .foregroundColor(Color.theme.textSecondary)
                    
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.blue)
                        
                        Text(timeElapsed(since: acceptedAt))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .onReceive(timer) { _ in
                                currentTime = Date()
                            }
                        
                        Spacer()
                        
                        if let plannedEndTime = Calendar.current.date(
                            byAdding: .hour,
                            value: Int(booking.duration),
                            to: acceptedAt
                        ) {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Ends at")
                                    .font(.caption2)
                                    .foregroundColor(Color.theme.textSecondary)
                                Text(formatTime(plannedEndTime))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.theme.textPrimary)
                            }
                        }
                    }
                    
                    // Overtime warning
                    if isOvertime(acceptedAt: acceptedAt, duration: booking.duration) {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Overtime - Late fees apply")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
            }
            
            // Completed booking details
            if booking.status == .completed {
                Divider()
                    .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 6) {
                    if let actualHours = booking.actualHours {
                        HStack {
                            Text("Actual Duration:")
                                .font(.caption)
                                .foregroundColor(Color.theme.textSecondary)
                            Spacer()
                            Text(String(format: "%.1f hours", actualHours))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Color.theme.textPrimary)
                        }
                    }
                    
                    if let lateFee = booking.lateFeeAmount, lateFee > 0 {
                        HStack {
                            Text("Late Fee:")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Spacer()
                            Text("₹\(Int(lateFee))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    if let completedAt = booking.completedAt {
                        HStack {
                            Text("Completed:")
                                .font(.caption)
                                .foregroundColor(Color.theme.textSecondary)
                            Spacer()
                            Text(formatDate(completedAt))
                                .font(.caption)
                                .foregroundColor(Color.theme.textSecondary)
                        }
                    }
                }
                .padding(.top, 4)
            }
            
            // Cancelled booking reason
            if booking.status == .cancelled, let reason = booking.cancellationReason {
                Divider()
                    .padding(.vertical, 4)
                
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.red)
                    Text(reason)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var statusBadge: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(12)
    }
    
    private var statusText: String {
        switch booking.status {
        case .pending: return "Pending"
        case .active: return "Active"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
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
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func timeElapsed(since startDate: Date) -> String {
        let elapsed = Date().timeIntervalSince(startDate)
        let hours = Int(elapsed) / 3600
        let minutes = (Int(elapsed) % 3600) / 60
        let seconds = Int(elapsed) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func isOvertime(acceptedAt: Date, duration: Double) -> Bool {
        let elapsed = Date().timeIntervalSince(acceptedAt)
        let plannedDuration = duration * 3600 // Convert hours to seconds
        return elapsed > plannedDuration
    }
}

// MARK: - View Model
class UserBookingsViewModel: ObservableObject {
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
    
    var previousCount: Int {
        bookings.filter { $0.status == .completed || $0.status == .cancelled }.count
    }
    
    func loadBookings() {
        let userId = AuthManager.shared.userID
        guard !userId.isEmpty else {
            return
        }
        
        isLoading = true
        
        // Setup real-time listener for user bookings
        listener = Firestore.firestore()
            .collection("bookings")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    CrashLogger.shared.log(error: error, context: ["screen": "UserBookings"])
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.bookings = documents.compactMap { doc in
                    try? doc.data(as: Booking.self)
                }
                
                CrashLogger.shared.log("Loaded \(self.bookings.count) bookings for user")
            }
    }
    
    deinit {
        listener?.remove()
    }
}
