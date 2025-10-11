//
//  LoginView.swift
//  SwiftUI-Auth
//
//  Created by Derek Hsieh on 1/7/23.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var currentShowingView: String
    @AppStorage("uid") var userID: String = ""
    @AppStorage("userRole") var userRole: String = ""
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    private func isValidPassword(_ password: String) -> Bool {
        // minimum 6 characters long
        // 1 uppercase character
        // 1 special char
        
        let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")
        
        return passwordRegex.evaluate(with: password)
    }
    
    private func login() {
        guard email.isValidEmail() else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Please enter your password"
            showError = true
            return
        }
        
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            if let authResult = authResult {
                Task {
                    do {
                        let user = try await FirestoreManager.shared.fetchUser(userId: authResult.user.uid)
                        await MainActor.run {
                            userID = authResult.user.uid
                            userRole = user.role.rawValue
                        }
                    } catch {
                        await MainActor.run {
                            errorMessage = "Failed to load user profile"
                            showError = true
                            try? Auth.auth().signOut()
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Parking with Sarthak")
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
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.black)
                    
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
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.black)
                    
                )
                .padding()
                
                
                Button(action: {
                    withAnimation {
                        self.currentShowingView = "signup"
                    }
                    
                    
                }) {
                    Text("Don't have an account?")
                        .foregroundColor(.black.opacity(0.7))
                }
                
                Spacer()
                Spacer()
                
                
                Button {
                    login()
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .font(.title3)
                            .bold()
                        
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black)
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
    }
}


