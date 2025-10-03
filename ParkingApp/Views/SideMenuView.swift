import SwiftUI
import FirebaseAuth

struct SideMenuView: View {
    @Binding var isOpen: Bool
    @AppStorage("uid") var userID: String = ""
    @ObservedObject var firestoreManager = FirestoreManager.shared
    @State private var currentUser: User?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with user info
            VStack(alignment: .leading, spacing: 12) {
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
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Close menu")
                }
                
                if let user = currentUser {
                    Text(user.name ?? user.email)
                        .font(.headline)
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 8)

            Divider()

            // Menu items
            ButtonRow(title: "My Profile", systemImage: "person") {
                // Future: Navigate to profile
            }
            ButtonRow(title: "My Bookings", systemImage: "clock") {
                // Future: Navigate to bookings
            }
            ButtonRow(title: "My Vehicles", systemImage: "car.fill") {
                // Future: Navigate to vehicles
            }
            ButtonRow(title: "Settings", systemImage: "gearshape") {
                // Future: Navigate to settings
            }

            Button {
                signOut()
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

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 60)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .frame(width: 280)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 6, y: 0)
        .accessibilityIdentifier("SideMenuView")
        .onAppear {
            loadUserInfo()
        }
    }
    
    private func loadUserInfo() {
        Task {
            do {
                let user = try await FirestoreManager.shared.fetchUser(userId: userID)
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
            withAnimation {
                userID = ""
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
            .foregroundColor(.black)
            .padding(.vertical, 6)
        }
    }
}
