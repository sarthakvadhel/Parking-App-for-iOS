# User Profile Management Feature

## Overview
This feature allows users to set up and manage their profile after registration, including adding a profile picture, name, and phone number.

## Components

### 1. ProfileSetupView
**Location:** `ParkingApp/Views/ProfileSetupView.swift`

**Purpose:** 
- Shown immediately after successful user registration
- Collects basic user information (name, phone number)
- Allows users to upload or capture a profile picture
- Can be shown as mandatory (after signup) or optional (profile updates)

**Features:**
- Profile picture selection via camera or photo library
- Name input (required)
- Phone number input (optional)
- Image upload to Firebase Storage
- Profile data saved to Firestore

**User Flow:**
1. User completes signup with email and password
2. ProfileSetupView appears automatically (mandatory)
3. User can add profile picture by tapping camera icon
4. User enters name (required) and phone number (optional)
5. On "Continue", data is saved to Firebase
6. View dismisses and user proceeds to main app

### 2. MyProfileView
**Location:** `ParkingApp/Views/MyProfileView.swift`

**Purpose:**
- Allows users to view and edit their profile information
- Accessible from side menu "My Profile" option
- Shows current profile data and allows updates

**Features:**
- Display and update profile picture
- Display email (read-only)
- Edit name
- Edit phone number
- Display user role (read-only)
- Remove profile picture option
- Save changes to Firestore

**User Flow:**
1. User opens side menu
2. User taps "My Profile"
3. MyProfileView opens with current profile data
4. User can edit name, phone, or profile picture
5. User taps "Save Changes"
6. Updates are saved to Firebase
7. Success message shown
8. View dismisses and side menu refreshes

### 3. SideMenuView Updates
**Location:** `ParkingApp/Views/SideMenuView.swift`

**Changes:**
- Profile picture now displays from Firebase Storage URL
- Falls back to initial letter if no image available
- Username displayed as heading (name or email if name not set)
- Email displayed below username
- "My Profile" button now opens MyProfileView
- Profile refreshes when MyProfileView closes

**Visual Layout:**
```
┌─────────────────────────┐
│  [Profile Picture] [X]  │
│                         │
│  Username/Name          │
│  user@email.com         │
├─────────────────────────┤
│  👤 My Profile          │
│  🕐 My Bookings         │
│  🚗 My Vehicles         │
│  ⚙️  Settings           │
│  🚪 Sign out            │
└─────────────────────────┘
```

### 4. SignupView Updates
**Location:** `ParkingApp/Views/SignupView.swift`

**Changes:**
- Added `showProfileSetup` state variable
- After successful registration, shows ProfileSetupView as a sheet
- ProfileSetupView is mandatory (cannot be dismissed without completing)

## Technical Details

### Data Model
The existing `User` model already supports:
- `name: String?` - User's full name
- `phoneNumber: String?` - User's phone number
- `profileImageURL: String?` - Firebase Storage URL for profile picture

### Firebase Storage
Profile images are stored at:
```
profileImages/{userId}.jpg
```

### Image Upload Process
1. User selects image from camera or photo library
2. Image is compressed to 70% quality (JPEG)
3. Image uploaded to Firebase Storage
4. Download URL received
5. URL saved to user document in Firestore

### Profile Image Loading
1. Fetch user document from Firestore
2. If `profileImageURL` exists, download image data
3. Convert data to UIImage
4. Display image in UI
5. Cache image in memory for session

## Usage Examples

### After Signup
```swift
// In SignupView, after successful authentication:
showSuccess = true
DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    showSuccess = false
    showProfileSetup = true  // Opens ProfileSetupView
}
```

### Opening Profile Editor
```swift
// In SideMenuView:
ButtonRow(title: "My Profile", systemImage: "person") {
    showMyProfile = true  // Opens MyProfileView
}
```

### Profile Image Display
```swift
// In SideMenuView:
if let image = profileImage {
    Image(uiImage: image)
        .resizable()
        .scaledToFill()
        .frame(width: 60, height: 60)
        .clipShape(Circle())
} else {
    // Show initial or placeholder
    Circle()
        .fill(Color.blue.opacity(0.2))
        .overlay(
            Text(currentUser?.name?.prefix(1).uppercased() ?? "U")
        )
}
```

## Testing Checklist

### New User Registration Flow
- [ ] Create new account with email and password
- [ ] Verify ProfileSetupView appears automatically
- [ ] Test adding profile picture from camera
- [ ] Test adding profile picture from photo library
- [ ] Enter name and phone number
- [ ] Verify "Continue" button disabled when name is empty
- [ ] Tap "Continue" and verify profile is saved
- [ ] Verify user proceeds to main app after setup
- [ ] Verify profile picture appears in side menu
- [ ] Verify username appears in side menu

### Profile Editing Flow
- [ ] Open side menu
- [ ] Tap "My Profile"
- [ ] Verify current data loads correctly
- [ ] Test changing profile picture
- [ ] Test removing profile picture
- [ ] Update name and phone number
- [ ] Verify email is read-only
- [ ] Verify role is read-only
- [ ] Tap "Save Changes"
- [ ] Verify success message appears
- [ ] Verify side menu refreshes with new data
- [ ] Close and reopen app to verify persistence

### Edge Cases
- [ ] Test with no internet connection
- [ ] Test with very large image files
- [ ] Test with special characters in name
- [ ] Test with empty name (should be prevented)
- [ ] Test removing profile picture
- [ ] Test rapid save clicks (should be disabled)
- [ ] Test navigation during upload

## Future Enhancements

1. **Image Optimization**
   - Resize images to consistent dimensions before upload
   - Generate thumbnails for better performance
   - Add image caching to reduce network usage

2. **Additional Profile Fields**
   - Address
   - Date of birth
   - Gender
   - Emergency contact

3. **Profile Picture Features**
   - Image cropping tool
   - Filters and adjustments
   - Multiple profile pictures
   - Avatar selection option

4. **Privacy Settings**
   - Control profile visibility
   - Choose what information to share
   - Privacy policy acceptance

5. **Profile Verification**
   - Email verification badge
   - Phone verification
   - Document verification for vendors

## Related Files
- `ParkingApp/Model/User.swift` - User data model
- `ParkingApp/Services/FirestoreManager.swift` - User CRUD operations
- `ParkingApp/Services/ImagePickerHelper.swift` - Image picker and upload utilities
- `ParkingApp/Views/SideMenuView.swift` - Side menu with profile display
- `ParkingApp/Views/SignupView.swift` - User registration
- `ParkingApp/Views/ProfileSetupView.swift` - Profile setup after registration
- `ParkingApp/Views/MyProfileView.swift` - Profile viewing and editing
