//
//  SettingsView.swift
//  ParkingApp
//
//  Created for user settings and preferences
//

import SwiftUI
import FirebaseAuth
import LocalAuthentication

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject var authManager = AuthManager.shared
    
    var body: some View {
        NavigationView {
            List {
                // Account Section
                Section(header: Text("Account")) {
                    NavigationLink(destination: ChangePasswordView()) {
                        SettingsRow(icon: "key.fill", title: "Change Password", iconColor: .blue)
                    }
                    
                    Button(action: {
                        viewModel.showDeleteAccountAlert = true
                    }) {
                        SettingsRow(icon: "trash.fill", title: "Delete Account", iconColor: .red)
                    }
                }
                
                // Notifications Section
                Section(header: Text("Notifications")) {
                    Toggle(isOn: $viewModel.notificationsEnabled) {
                        SettingsRow(icon: "bell.fill", title: "All Notifications", iconColor: .orange)
                    }
                    .onChange(of: viewModel.notificationsEnabled) { newValue in
                        viewModel.updateNotificationSettings()
                    }
                    
                    Toggle(isOn: $viewModel.bookingUpdatesEnabled) {
                        SettingsRow(icon: "calendar.badge.clock", title: "Booking Updates", iconColor: .green)
                    }
                    .disabled(!viewModel.notificationsEnabled)
                    .onChange(of: viewModel.bookingUpdatesEnabled) { newValue in
                        viewModel.updateNotificationSettings()
                    }
                }
                
                // Payment Methods Section
                Section(header: Text("Payment Methods")) {
                    NavigationLink(destination: PaymentMethodsView()) {
                        SettingsRow(icon: "creditcard.fill", title: "Payment Methods", iconColor: .purple)
                    }
                }
                
                // Receipts/History Section
                Section(header: Text("Receipts & History")) {
                    NavigationLink(destination: ReceiptsHistoryView()) {
                        SettingsRow(icon: "doc.text.fill", title: "View Receipts", iconColor: .indigo)
                    }
                }
                
                // Privacy & Security Section
                Section(header: Text("Privacy & Security")) {
                    if viewModel.biometricType != .none {
                        Toggle(isOn: $viewModel.biometricAuthEnabled) {
                            SettingsRow(
                                icon: viewModel.biometricType == .faceID ? "faceid" : "touchid",
                                title: viewModel.biometricType == .faceID ? "Face ID" : "Touch ID",
                                iconColor: .teal
                            )
                        }
                        .onChange(of: viewModel.biometricAuthEnabled) { newValue in
                            viewModel.updateBiometricSettings()
                        }
                    }
                }
                
                // App Info Section
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                            .foregroundColor(Color.theme.textPrimary)
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundColor(Color.theme.textSecondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Account", isPresented: $viewModel.showDeleteAccountAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.showDeleteConfirmation = true
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
            .alert("Final Confirmation", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete Forever", role: .destructive) {
                    Task {
                        await viewModel.deleteAccount()
                    }
                }
            } message: {
                Text("All your data including bookings, vehicles, and payment history will be permanently deleted. Type your password to confirm.")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .onAppear {
            viewModel.loadPreferences()
        }
    }
}

// MARK: - Settings Row Component
struct SettingsRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Color.theme.textPrimary)
        }
    }
}

// MARK: - Settings ViewModel
@MainActor
class SettingsViewModel: ObservableObject {
    @Published var notificationsEnabled = true
    @Published var bookingUpdatesEnabled = true
    @Published var biometricAuthEnabled = false
    @Published var showDeleteAccountAlert = false
    @Published var showDeleteConfirmation = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var biometricType: LABiometryType = .none
    
    private let authManager = AuthManager.shared
    private let firestoreManager = FirestoreManager.shared
    private let context = LAContext()
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    init() {
        checkBiometricAvailability()
    }
    
    func loadPreferences() {
        Task {
            do {
                let preferences = try await firestoreManager.fetchUserPreferences(userId: authManager.userID)
                notificationsEnabled = preferences.notificationsEnabled
                bookingUpdatesEnabled = preferences.bookingUpdatesEnabled
                biometricAuthEnabled = preferences.biometricAuthEnabled
            } catch {
                print("Error loading preferences: \(error.localizedDescription)")
                // Use default values if preferences don't exist
            }
        }
    }
    
    func updateNotificationSettings() {
        Task {
            do {
                var preferences = try await firestoreManager.fetchUserPreferences(userId: authManager.userID)
                preferences.notificationsEnabled = notificationsEnabled
                preferences.bookingUpdatesEnabled = notificationsEnabled && bookingUpdatesEnabled
                try await firestoreManager.updateUserPreferences(preferences)
            } catch {
                errorMessage = "Failed to update notification settings: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    func updateBiometricSettings() {
        Task {
            do {
                var preferences = try await firestoreManager.fetchUserPreferences(userId: authManager.userID)
                preferences.biometricAuthEnabled = biometricAuthEnabled
                try await firestoreManager.updateUserPreferences(preferences)
            } catch {
                errorMessage = "Failed to update biometric settings: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    private func checkBiometricAvailability() {
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        }
    }
    
    func deleteAccount() async {
        do {
            let userId = authManager.userID
            
            // 1. Delete user document
            try await firestoreManager.deleteUser(userId: userId)
            
            // 2. Delete vehicles
            let vehicles = try await firestoreManager.fetchVehicles(userId: userId)
            for vehicle in vehicles {
                if let id = vehicle.id {
                    try await firestoreManager.deleteVehicle(id)
                }
            }
            
            // 3. Anonymize bookings (keep for analytics, remove PII)
            let bookings = try await firestoreManager.fetchUserBookings(userId: userId)
            for var booking in bookings {
                booking.userId = "DELETED_USER"
                booking.userName = "DELETED_USER"
                booking.vehicleNumber = "XXXXX"
                try await firestoreManager.updateBooking(booking)
            }
            
            // 4. Delete from Firebase Auth
            try await Auth.auth().currentUser?.delete()
            
            // 5. Clear local data
            try authManager.logout()
            
            // Analytics
            AnalyticsService.shared.track(.userDeleted)
            AnalyticsService.shared.setUserId(nil)
            CrashLogger.shared.clearData()
            
        } catch {
            errorMessage = "Failed to delete account: \(error.localizedDescription)"
            showError = true
        }
    }
}

// MARK: - Change Password View
struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        Form {
            Section(header: Text("Current Password")) {
                SecureField("Current Password", text: $currentPassword)
                    .textContentType(.password)
                    .autocapitalization(.none)
            }
            
            Section(header: Text("New Password")) {
                SecureField("New Password", text: $newPassword)
                    .textContentType(.newPassword)
                    .autocapitalization(.none)
                
                SecureField("Confirm New Password", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .autocapitalization(.none)
            }
            
            Section(footer: Text("Password must be at least 6 characters long")) {
                Button(action: changePassword) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Change Password")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                }
                .disabled(isLoading || !isValidInput)
                .listRowBackground(isValidInput ? Color.blue : Color.gray)
            }
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your password has been changed successfully")
        }
    }
    
    private var isValidInput: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        newPassword.count >= 6 &&
        newPassword == confirmPassword
    }
    
    private func changePassword() {
        isLoading = true
        
        Task {
            do {
                guard let user = Auth.auth().currentUser,
                      let email = user.email else {
                    throw NSError(domain: "ChangePassword", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                }
                
                // Re-authenticate user
                let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
                try await user.reauthenticate(with: credential)
                
                // Update password
                try await user.updatePassword(to: newPassword)
                
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                    
                    // Track analytics
                    AnalyticsService.shared.track(.passwordChanged)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Payment Methods View
struct PaymentMethodsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue.opacity(0.5))
            
            Text("Payment Methods")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.textPrimary)
            
            Text("Additional payment methods like UPI and Cards will be available soon.")
                .font(.body)
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 12) {
                PaymentMethodRow(icon: "indianrupeesign.circle.fill", title: "Cash Payment", status: "Available")
                PaymentMethodRow(icon: "app.badge", title: "UPI Payment", status: "Coming Soon")
                PaymentMethodRow(icon: "creditcard.fill", title: "Card Payment", status: "Coming Soon")
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .padding(.top, 60)
        .navigationTitle("Payment Methods")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PaymentMethodRow: View {
    let icon: String
    let title: String
    let status: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.theme.textPrimary)
            
            Spacer()
            
            Text(status)
                .font(.system(size: 14))
                .foregroundColor(status == "Available" ? .green : Color.theme.textSecondary)
        }
        .padding()
        .background(Color.theme.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Receipts History View
struct ReceiptsHistoryView: View {
    @StateObject private var viewModel = ReceiptsViewModel()
    @StateObject var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading receipts...")
            } else if viewModel.bookings.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 80))
                        .foregroundColor(.blue.opacity(0.5))
                    
                    Text("No Receipts")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Text("Your booking receipts will appear here")
                        .font(.body)
                        .foregroundColor(Color.theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                List(viewModel.bookings) { booking in
                    ReceiptRow(booking: booking)
                }
            }
        }
        .navigationTitle("Receipts & History")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadBookings(userId: authManager.userID)
        }
    }
}

struct ReceiptRow: View {
    let booking: Booking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(booking.parkingLotName ?? "Unknown Location")
                    .font(.headline)
                    .foregroundColor(Color.theme.textPrimary)
                
                Spacer()
                
                Text("₹\(Int(booking.totalAmount))")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            HStack {
                Text(formatDate(booking.startTime))
                    .font(.caption)
                    .foregroundColor(Color.theme.textSecondary)
                
                Spacer()
                
                StatusBadge(status: booking.status)
            }
            
            if let vehicleNumber = booking.vehicleNumber {
                Text("Vehicle: \(vehicleNumber)")
                    .font(.caption)
                    .foregroundColor(Color.theme.textSecondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct StatusBadge: View {
    let status: BookingStatus
    
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .cornerRadius(6)
    }
    
    private var statusColor: Color {
        switch status {
        case .active: return .blue
        case .completed: return .green
        case .cancelled: return .red
        case .pending: return .orange
        }
    }
}

@MainActor
class ReceiptsViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    
    private let firestoreManager = FirestoreManager.shared
    
    func loadBookings(userId: String) {
        isLoading = true
        Task {
            do {
                let fetchedBookings = try await firestoreManager.fetchUserBookings(userId: userId)
                bookings = fetchedBookings
                isLoading = false
            } catch {
                print("Error loading bookings: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }
}
