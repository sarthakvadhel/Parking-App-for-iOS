# User Profile Feature - Developer Quick Reference

## Quick Links
- 📖 **Full Documentation**: [USER_PROFILE_FEATURE.md](USER_PROFILE_FEATURE.md)
- 🎨 **Visual Flows**: [USER_PROFILE_VISUAL_FLOW.md](USER_PROFILE_VISUAL_FLOW.md)
- 📋 **Implementation Summary**: [USER_PROFILE_IMPLEMENTATION_SUMMARY.md](USER_PROFILE_IMPLEMENTATION_SUMMARY.md)
- 🚀 **Quick Start Guide**: [USER_PROFILE_QUICK_START.md](USER_PROFILE_QUICK_START.md)

## Key Files

### New Views
```
ParkingApp/Views/
├── ProfileSetupView.swift    (271 lines) - Profile setup after registration
└── MyProfileView.swift        (285 lines) - Profile editing interface
```

### Modified Files
```
ParkingApp/Views/
├── SignupView.swift           - Triggers ProfileSetupView
└── SideMenuView.swift         - Enhanced profile display

ParkingApp/
└── Info.plist                 - Camera/photo permissions
```

## Code Snippets

### Show Profile Setup After Signup
```swift
// In SignupView
@State private var showProfileSetup = false

// After successful signup
DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    showSuccess = false
    showProfileSetup = true
}

// Present as sheet
.sheet(isPresented: $showProfileSetup) {
    ProfileSetupView(isOptional: false)
}
```

### Display Profile Picture in UI
```swift
// Load profile image
if let imageURL = user.profileImageURL, let url = URL(string: imageURL) {
    let (data, _) = try await URLSession.shared.data(from: url)
    if let image = UIImage(data: data) {
        await MainActor.run {
            profileImage = image
        }
    }
}

// Display in UI
if let image = profileImage {
    Image(uiImage: image)
        .resizable()
        .scaledToFill()
        .frame(width: 60, height: 60)
        .clipShape(Circle())
}
```

### Upload Profile Picture
```swift
// Upload image to Firebase Storage
let imagePath = "profileImages/\(authManager.userID).jpg"
let imageURL = try await ImageUploadHelper.shared.uploadImage(image, path: imagePath)

// Save URL to Firestore
user.profileImageURL = imageURL
try await FirestoreManager.shared.updateUser(user)
```

### Update User Profile
```swift
// Update profile
var user = try await FirestoreManager.shared.fetchUser(userId: authManager.userID)
user.name = name
user.phoneNumber = phoneNumber
try await FirestoreManager.shared.updateUser(user)
```

## Data Model

```swift
struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var email: String
    var role: UserRole
    var name: String?              // ← Profile name
    var phoneNumber: String?        // ← Profile phone
    var profileImageURL: String?    // ← Profile picture URL
    var createdAt: Date
    var vehicles: [String]?
}
```

## Firebase Structure

### Storage
```
profileImages/
└── {userId}.jpg  (JPEG, 70% quality)
```

### Firestore
```json
users/{userId}
{
  "name": "John Doe",
  "phoneNumber": "+1234567890",
  "profileImageURL": "https://firebasestorage.googleapis.com/...",
  "email": "john@example.com",
  "role": "user"
}
```

## Common Tasks

### Add New Profile Field
1. Update `User` model in `ParkingApp/Model/User.swift`
2. Add UI field in `ProfileSetupView.swift`
3. Add UI field in `MyProfileView.swift`
4. Update save logic in both views

### Change Profile Picture Size
```swift
// In SideMenuView.swift
.frame(width: 60, height: 60)  // Change these values
```

### Add Profile Validation
```swift
// In ProfileSetupView or MyProfileView
guard !name.isEmpty else {
    errorMessage = "Name is required"
    showError = true
    return
}
```

### Modify Image Compression
```swift
// In ImageUploadHelper.swift
guard let imageData = image.jpegData(compressionQuality: 0.7) else {
    // Change 0.7 to desired quality (0.0 to 1.0)
}
```

## API Reference

### ProfileSetupView
```swift
ProfileSetupView(isOptional: Bool)
// isOptional: false = mandatory (after signup)
// isOptional: true = can be dismissed
```

### MyProfileView
```swift
MyProfileView()
// No parameters
// Opens with current user data
// Automatically saves on "Save Changes"
```

### ImageUploadHelper
```swift
ImageUploadHelper.shared.uploadImage(
    _ image: UIImage,
    path: String
) async throws -> String
// Returns: Download URL string
```

## Testing Commands

### Check User Data
```swift
let user = try await FirestoreManager.shared.fetchUser(userId: userId)
print("Name: \(user.name ?? "Not set")")
print("Phone: \(user.phoneNumber ?? "Not set")")
print("Picture: \(user.profileImageURL ?? "Not set")")
```

### Test Image Upload
```swift
let imagePath = "profileImages/testUser.jpg"
let imageURL = try await ImageUploadHelper.shared.uploadImage(testImage, path: imagePath)
print("Uploaded to: \(imageURL)")
```

## Debugging Tips

### Profile Picture Not Showing
1. Check Firebase Storage console
2. Verify `profileImageURL` in Firestore
3. Check internet connection
4. Look for URLSession errors in console

### Profile Not Saving
1. Verify user is authenticated
2. Check Firestore rules
3. Ensure required fields are filled
4. Look for error messages in console

### Camera Not Working
1. Check Info.plist has `NSCameraUsageDescription`
2. Verify camera permissions granted
3. Test on real device (simulator may not have camera)

## Performance Considerations

### Image Loading
- Images cached in memory during session
- No persistent cache (future enhancement)
- Loaded on-demand from Firebase Storage

### Network Calls
```
Side Menu Open:
├── 1x Firestore read (user data)
└── 1x Storage download (if profile picture exists)

Profile Edit Save:
├── 1x Storage upload (if image changed)
└── 1x Firestore write (user data)
```

## Security Notes

### Permissions Required
```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take profile pictures.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select profile pictures.</string>
```

### Firebase Storage Rules
```javascript
match /profileImages/{userId} {
  allow read, write: if request.auth != null 
                     && request.auth.uid == userId;
}
```

## Error Handling

### Common Errors
```swift
// Network error
"Failed to save profile: The Internet connection appears to be offline."

// Authentication error
"User ID is required"

// Image error
"Failed to convert image to data"

// Firestore error
"User not found"
```

### Handle Errors Gracefully
```swift
do {
    try await saveProfile()
} catch {
    await MainActor.run {
        errorMessage = "Failed to save profile: \(error.localizedDescription)"
        showError = true
    }
}
```

## Best Practices

### ✅ Do
- Always update UI on MainActor
- Use async/await for Firebase calls
- Show loading indicators during operations
- Provide user feedback (success/error)
- Validate input before saving
- Handle optional values safely

### ❌ Don't
- Don't block UI thread
- Don't ignore errors
- Don't save without validation
- Don't store sensitive data in profile picture
- Don't allow empty required fields

## Migration Guide

### For Existing Users
```swift
// Existing users will see ProfileSetupView next time they log in
// if they haven't set up their profile yet.
// The view is optional for them (can be dismissed).
```

### For New Users
```swift
// New users MUST complete ProfileSetupView after signup
// (can't be dismissed, name is required)
```

## Troubleshooting

### Issue: Build Errors
**Solution**: Clean build folder (Cmd+Shift+K) and rebuild

### Issue: Firebase Permission Denied
**Solution**: Check Firestore and Storage security rules

### Issue: Image Upload Fails
**Solution**: Verify Firebase Storage is enabled and configured

### Issue: Profile Changes Not Persisting
**Solution**: Check Firestore write succeeded, verify data in console

## Version Compatibility

- **iOS**: 15.0+
- **SwiftUI**: 3.0+
- **Firebase**: Latest SDK
- **Xcode**: 13.0+

## Resources

### Documentation
- [USER_PROFILE_FEATURE.md](USER_PROFILE_FEATURE.md) - Complete feature docs
- [USER_PROFILE_VISUAL_FLOW.md](USER_PROFILE_VISUAL_FLOW.md) - Visual diagrams
- [USER_PROFILE_QUICK_START.md](USER_PROFILE_QUICK_START.md) - User guide

### External
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Firebase iOS SDK](https://firebase.google.com/docs/ios/setup)
- [PhotosUI Framework](https://developer.apple.com/documentation/photosui)

## Support

For questions or issues:
1. Check this reference first
2. Review full documentation
3. Check Firebase console
4. Contact development team

---

**Last Updated**: Current implementation
**Status**: ✅ Production Ready
**Lines of Code**: 757 (ProfileSetupView + MyProfileView + SideMenuView changes)
