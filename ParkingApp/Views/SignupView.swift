//
//  SignupView.swift
//  SwiftUI-Auth
//
//  Created by Derek Hsieh on 1/7/23.
//

import SwiftUI
import FirebaseAuth

struct SignupView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var selectedRole: UserRole = .user
    @State private var showRoleSelection = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var isLoading = false
    
    @AppStorage("uid") var userID: String = ""
    @AppStorage("userRole") var userRole: String = ""
    @Binding var currentShowingView: String
    
    private func isValidPassword(_ password: String) -> Bool {
        // minimum 6 characters long
        // 1 uppercase character
        // 1 special char
        
        let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")
        
        return passwordRegex.evaluate(with: password)
    }
    
    private func signUp() {
        guard email.isValidEmail() else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        guard isValidPassword(password) else {
            errorMessage = "Password must be at least 6 characters with 1 uppercase and 1 special character"
            showError = true
            return
        }
        
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            if let authResult = authResult {
                let newUser = User(
                    id: authResult.user.uid,
                    email: email,
                    role: selectedRole
                )
                
                Task {
                    do {
                        try await FirestoreManager.shared.createUser(newUser)
                        await MainActor.run {
                            userID = authResult.user.uid
                            userRole = selectedRole.rawValue
                            showSuccess = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                showSuccess = false
                            }
                        }
                    } catch {
                        await MainActor.run {
                            errorMessage = "Failed to create user profile: \(error.localizedDescription)"
                            showError = true
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Parking with Sarthak")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                }
                .padding()
                .padding(.top)
                
                Spacer()
                
                HStack {
                    Image(systemName: "mail")
                    TextField("Email", text: $email)
                    
                    Spacer()
                    
                    
                    if(email.count != 0) {
                        
                        Image(systemName: email.isValidEmail() ? "checkmark" : "xmark")

                            .foregroundColor(email.isValidEmail() ? .green : .red)
                    }
                    
                }
                .foregroundColor(.white)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white)
                    
                )
                
                .padding()
                
                
                HStack {
                    Image(systemName: "lock")
                    SecureField("Password", text: $password)
                    
                    Spacer()
                    
                    if(password.count != 0) {
                        
                        Image(systemName: isValidPassword(password) ? "checkmark" : "xmark")
                            .foregroundColor(isValidPassword(password) ? .green : .red)
                    }
                    
                }
                .foregroundColor(.white)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white)
                    
                )
                .padding()
                
                // Role Selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("I am a:")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.leading)
                    
                    HStack(spacing: 15) {
                        RoleButton(
                            title: "User (Finding Parking)",
                            icon: "car.fill",
                            isSelected: selectedRole == .user
                        ) {
                            selectedRole = .user
                        }
                        
                        RoleButton(
                            title: "Vendor (Providing Space)",
                            icon: "building.2.fill",
                            isSelected: selectedRole == .vendor
                        ) {
                            selectedRole = .vendor
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                Button(action: {
                    withAnimation {
                        self.currentShowingView = "login"
                    }
                }) {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                Spacer()
                
                
                Button {
                    signUp()
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Create New Account")
                            .foregroundColor(.black)
                            .font(.title3)
                            .bold()
                        
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                )
                .padding(.horizontal)
                .disabled(isLoading)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Success!", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Account created successfully!")
        }
    }
}

struct RoleButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                Text(title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(isSelected ? .black : .white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.white : Color.white.opacity(0.2))
            )
        }
    }
}


