import SwiftUI
import FirebaseAuth

struct SideMenuView: View {
    @Binding var isOpen: Bool
    @AppStorage("uid") var userID: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with a close control
            HStack {
                Text("Menu")
                    .font(.system(size: 24, weight: .bold))
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
            .padding(.top, 8)

            Divider()

            // Your app menu items
            ButtonRow(title: "My Profile", systemImage: "person")
            ButtonRow(title: "My Bookings", systemImage: "clock")
            ButtonRow(title: "Settings", systemImage: "gearshape")

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
        .padding(.top, 60) // clears status bar/notch
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .frame(width: 280)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 6, y: 0)
        .accessibilityIdentifier("SideMenuView")
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

    var body: some View {
        Button(action: {}) {
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
