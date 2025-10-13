//
//  ProfileSetupView.swift
//  ParkingApp
//
//  Created by Parking App Team
//

import SwiftUI
import PhotosUI

struct ProfileSetupView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var authManager = AuthManager.shared
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var isUploading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSourceSelection = false
    
    let isOptional: Bool
    
    init(isOptional: Bool = false) {
        self.isOptional = isOptional
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        Text(isOptional ? "Complete Your Profile" : "Set Up Your Profile")
                            .font(.title)
                            .bold()
                            .foregroundColor(Color.theme.textPrimary)
                            .padding(.top)
                        
                        Text("Add your details to personalize your experience")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Profile Image Section
                        VStack(spacing: 12) {
                            ZStack {
                                if let image = selectedImage {
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
                                            Image(systemName: "person.fill")
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
                            
                            Text("Add Profile Picture")
                                .font(.caption)
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        .padding(.vertical)
                        
                        // Form Fields
                        VStack(spacing: 16) {
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
                                Text("Phone Number (Optional)")
                                    .font(.subheadline)
                                    .foregroundColor(Color.theme.textSecondary)
                                
                                TextField("Enter your phone number", text: $phoneNumber)
                                    .keyboardType(.phonePad)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .foregroundColor(Color.theme.textPrimary)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Save Button
                        Button {
                            saveProfile()
                        } label: {
                            if isUploading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text(isOptional ? "Update Profile" : "Continue")
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
                        .disabled(name.isEmpty || isUploading)
                        
                        if isOptional {
                            Button {
                                dismiss()
                            } label: {
                                Text("Cancel")
                                    .foregroundColor(Color.theme.textSecondary)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .confirmationDialog("Choose Photo Source", isPresented: $showSourceSelection) {
                Button("Camera") {
                    showCamera = true
                }
                Button("Photo Library") {
                    showImagePicker = true
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isOptional {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .interactiveDismissDisabled(!isOptional)
    }
    
    private func saveProfile() {
        isUploading = true
        
        Task {
            do {
                // Fetch current user
                var user = try await FirestoreManager.shared.fetchUser(userId: authManager.userID)
                
                // Update user details
                user.name = name.isEmpty ? nil : name
                user.phoneNumber = phoneNumber.isEmpty ? nil : phoneNumber
                
                // Upload profile image if selected
                if let image = selectedImage {
                    let imagePath = "profileImages/\(authManager.userID).jpg"
                    let imageURL = try await ImageUploadHelper.shared.uploadImage(image, path: imagePath)
                    user.profileImageURL = imageURL
                }
                
                // Update user in Firestore
                try await FirestoreManager.shared.updateUser(user)
                
                await MainActor.run {
                    isUploading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    errorMessage = "Failed to save profile: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

// Camera Picker for taking photos
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
