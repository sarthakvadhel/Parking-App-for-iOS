//
//  MyProfileView.swift
//  ParkingApp
//
//  Created by Parking App Team
//

import SwiftUI

struct MyProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var authManager = AuthManager.shared
    @State private var user: User?
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var selectedImage: UIImage?
    @State private var profileImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSourceSelection = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    ProgressView("Loading profile...")
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Profile Image Section
                            VStack(spacing: 12) {
                                ZStack {
                                    if let image = selectedImage ?? profileImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.theme.textPrimary, lineWidth: 3))
                                    } else {
                                        Circle()
                                            .fill(Color.blue.opacity(0.2))
                                            .frame(width: 120, height: 120)
                                            .overlay(
                                                Text(user?.name?.prefix(1).uppercased() ?? user?.email.prefix(1).uppercased() ?? "U")
                                                    .font(.system(size: 50))
                                                    .foregroundColor(.blue)
                                            )
                                            .overlay(Circle().stroke(Color.theme.textPrimary, lineWidth: 3))
                                    }
                                    
                                    // Camera icon button overlay
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Button {
                                                showSourceSelection = true
                                            } label: {
                                                Image(systemName: "camera.fill")
                                                    .foregroundColor(.white)
                                                    .padding(8)
                                                    .background(Color.blue)
                                                    .clipShape(Circle())
                                            }
                                        }
                                    }
                                    .frame(width: 120, height: 120)
                                }
                                
                                Text("Tap to change photo")
                                    .font(.caption)
                                    .foregroundColor(Color.theme.textSecondary)
                            }
                            .padding(.top)
                            
                            // Form Fields
                            VStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Email")
                                        .font(.subheadline)
                                        .foregroundColor(Color.theme.textSecondary)
                                    
                                    Text(user?.email ?? "")
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(10)
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Full Name")
                                        .font(.subheadline)
                                        .foregroundColor(Color.theme.textSecondary)
                                    
                                    TextField("Enter your name", text: $name)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                        .foregroundColor(Color.theme.textPrimary)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Phone Number")
                                        .font(.subheadline)
                                        .foregroundColor(Color.theme.textSecondary)
                                    
                                    TextField("Enter your phone number", text: $phoneNumber)
                                        .keyboardType(.phonePad)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                        .foregroundColor(Color.theme.textPrimary)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("User Role")
                                        .font(.subheadline)
                                        .foregroundColor(Color.theme.textSecondary)
                                    
                                    Text(user?.role.rawValue.capitalized ?? "")
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(10)
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Save Button
                            Button {
                                saveProfile()
                            } label: {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                } else {
                                    Text("Save Changes")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(name.isEmpty ? Color.gray : Color.black)
                            )
                            .padding(.horizontal)
                            .disabled(name.isEmpty || isSaving)
                            .padding(.top)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog("Choose Photo Source", isPresented: $showSourceSelection) {
                Button("Camera") {
                    showCamera = true
                }
                Button("Photo Library") {
                    showImagePicker = true
                }
                if selectedImage != nil || profileImage != nil {
                    Button("Remove Photo", role: .destructive) {
                        selectedImage = nil
                        profileImage = nil
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showCamera) {
                CameraPicker(selectedImage: $selectedImage)
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Profile updated successfully!")
            }
            .onAppear {
                loadProfile()
            }
        }
    }
    
    private func loadProfile() {
        isLoading = true
        Task {
            do {
                let fetchedUser = try await FirestoreManager.shared.fetchUser(userId: authManager.userID)
                
                // Load profile image if URL exists
                if let imageURL = fetchedUser.profileImageURL, let url = URL(string: imageURL) {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        await MainActor.run {
                            profileImage = image
                        }
                    }
                }
                
                await MainActor.run {
                    user = fetchedUser
                    name = fetchedUser.name ?? ""
                    phoneNumber = fetchedUser.phoneNumber ?? ""
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to load profile: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func saveProfile() {
        isSaving = true
        
        Task {
            do {
                guard var currentUser = user else { return }
                
                // Update user details
                currentUser.name = name.isEmpty ? nil : name
                currentUser.phoneNumber = phoneNumber.isEmpty ? nil : phoneNumber
                
                // Upload new profile image if selected
                if let image = selectedImage {
                    let imagePath = "profileImages/\(authManager.userID).jpg"
                    let imageURL = try await ImageUploadHelper.shared.uploadImage(image, path: imagePath)
                    currentUser.profileImageURL = imageURL
                } else if selectedImage == nil && profileImage == nil && currentUser.profileImageURL != nil {
                    // User removed the photo
                    currentUser.profileImageURL = nil
                }
                
                // Update user in Firestore
                try await FirestoreManager.shared.updateUser(currentUser)
                
                await MainActor.run {
                    isSaving = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = "Failed to save profile: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}
