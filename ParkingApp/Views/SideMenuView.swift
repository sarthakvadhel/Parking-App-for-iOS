import SwiftUI
import FirebaseAuth

struct SideMenuView: View {
    @Binding var isOpen: Bool
    @StateObject var authManager = AuthManager.shared
    @ObservedObject var firestoreManager = FirestoreManager.shared
    @State private var currentUser: User?
    @State private var showLogoutConfirmation = false
    @State private var showMyVehicles = false
    @State private var showMyBookings = false
    @State private var showSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with user info
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    // Profile image placeholder
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(currentUser?.email.prefix(1).uppercased() ?? "U")
                                .font(.title2)
                                .foregroundColor(.blue)
                        )
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            isOpen = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Close menu")
                }
                
                if let user = currentUser {
                    Text(user.name ?? user.email)
                        .font(.headline)
                        .foregroundColor(Color.theme.textPrimary)
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(Color.theme.textSecondary)
                }
            }
            .padding(.top, 8)

            Divider()

            // Menu items
            ButtonRow(title: "My Profile", systemImage: "person") {
                // Future: Navigate to profile
            }
            .foregroundColor(.white)
            ButtonRow(title: "My Bookings", systemImage: "clock") {
                showMyBookings = true
            }
            ButtonRow(title: "My Vehicles", systemImage: "car.fill") {
                showMyVehicles = true
            }
            ButtonRow(title: "Settings", systemImage: "gearshape") {
                showSettings = true
            }

            Button {
                showLogoutConfirmation = true
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Sign out")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.red)
                .padding(.vertical, 6)
            }
            .padding(.top, 8)
            .alert("Sign Out", isPresented: $showLogoutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .frame(width: 280)
        .background(Color.theme.background)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 6, y: 0)
        .accessibilityIdentifier("SideMenuView")
        .offset(CGSize(width: -10.0, height: 0.0))
        .sheet(isPresented: $showMyBookings) {
            UserBookingsView()
        }
        .sheet(isPresented: $showMyVehicles) {
            MyVehiclesView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            loadUserInfo()
        }
    }
    
    private func loadUserInfo() {
        Task {
            do {
                let user = try await FirestoreManager.shared.fetchUser(userId: authManager.userID)
                await MainActor.run {
                    currentUser = user
                }
            } catch {
                print("Error loading user: \(error)")
            }
        }
    }

    private func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            try authManager.logout()
            
            // Clear analytics and crash logging data
            AnalyticsService.shared.track(.userLoggedOut)
            AnalyticsService.shared.setUserId(nil)
            CrashLogger.shared.clearData()
            
            withAnimation {
                isOpen = false
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

private struct ButtonRow: View {
    let title: String
    let systemImage: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
        }
    }
}
