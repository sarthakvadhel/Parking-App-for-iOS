# Quick Start Guide

Get the Parking with Sarthak app running in minutes!

## Prerequisites

- **macOS** with Xcode 14.0 or later
- **iOS 15.0+** device or simulator
- **Firebase account** (free tier is sufficient)
- **Apple Developer account** (for device testing)

## Setup Steps

### 1. Clone the Repository

```bash
git clone https://github.com/sarthakvadhel/Parking-App-for-iOS.git
cd Parking-App-for-iOS
```

### 2. Firebase Setup (5 minutes)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project: "ParkingApp" or any name
3. Add an iOS app:
   - Bundle ID: `com.sarthak.ParkingApp` (or match your Xcode project)
   - Download `GoogleService-Info.plist`
4. Add the file to your project:
   - Drag `GoogleService-Info.plist` into Xcode project navigator
   - Check "Copy items if needed"
   - Ensure it's in the ParkingApp target

### 3. Enable Firebase Services

#### Enable Authentication
```
Firebase Console → Authentication → Sign-in method → Email/Password → Enable → Save
```

#### Create Firestore Database
```
Firebase Console → Firestore Database → Create database → Test mode → Next → Enable
```

#### (Optional) Enable Storage
```
Firebase Console → Storage → Get started → Test mode → Done
```

### 4. Configure Security Rules

Copy these rules to Firestore (Console → Firestore → Rules):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5. Open in Xcode

```bash
open ParkingApp.xcodeproj
```

### 6. Configure Signing

1. Select the project in Xcode
2. Go to "Signing & Capabilities"
3. Select your Team
4. Xcode will automatically fix signing

### 7. Build and Run

1. Select a simulator or connected device
2. Press `Cmd + R` or click Run (▶️)
3. Grant location permission when prompted

## First Run

### Test as User
1. Click "Don't have an account?" on login
2. Enter email and password
3. Select "User (Finding Parking)" role
4. Create account
5. Add a vehicle (e.g., GJ01AE7828, Swift)
6. You're in! 🎉

### Test as Vendor
1. Sign out from the menu
2. Create a new account
3. Select "Vendor (Providing Space)" role
4. Register a parking lot
5. View your dashboard 📊

## Troubleshooting

### Build Fails
- Ensure `GoogleService-Info.plist` is in the project
- Check Bundle ID matches Firebase
- Clean build folder: `Cmd + Shift + K`

### Authentication Error
- Verify Email/Password is enabled in Firebase Console
- Check internet connection
- Review Firebase configuration

### Location Not Working
- Allow location permissions when prompted
- Check Info.plist has location usage descriptions
- For simulator: Debug → Location → Custom Location

### Firestore Error
- Ensure Firestore is created in Firebase Console
- Check security rules allow authenticated access
- Verify user is signed in

## Quick Test Data

### Sample Vehicles
- GJ01AE7828, Maruti Swift, White
- MH02AB1234, Honda City, Silver
- DL05CD5678, Hyundai i20, Red

### Sample Parking Lots
- City Center Parking, ₹50/hr
- Mall Parking, ₹30/hr
- Airport Parking, ₹100/hr

## Development Tips

### Hot Reload
Use Xcode previews for faster UI development:
```swift
struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        MyView()
    }
}
```

### Debug Mode
Enable Firebase debug logging in AppDelegate:
```swift
FirebaseConfiguration.shared.setLoggerLevel(.debug)
```

### Test Mode
Use test data for development to avoid cluttering production:
```swift
#if DEBUG
let testUser = User(email: "test@example.com", role: .user)
#endif
```

## Project Structure

```
📁 ParkingApp
├── 📁 Model - Data models
├── 📁 Views - UI screens
├── 📁 Services - Business logic
├── 📁 ViewModel - View models
├── 📁 Extensions - Helper extensions
└── 📄 GoogleService-Info.plist
```

## Key Files

- `ContentView.swift` - Main app entry
- `FirestoreManager.swift` - Database operations
- `ParkingFinder.swift` - Location & parking logic
- `AuthView.swift` - Authentication flow

## Common Tasks

### Add New Field to User
1. Update `User` model
2. Update Firestore operations
3. Update UI forms

### Add Payment Method
1. Update `PaymentMethod` enum
2. Add button in `PaymentOptionsView`
3. Implement gateway logic

### Customize Theme
1. Edit `ThemeColors` in `Extensions.swift`
2. Update color references in views

## Next Steps

- [ ] Review [API Documentation](API_DOCUMENTATION.md)
- [ ] Read [Firebase Setup Guide](FIREBASE_SETUP.md)
- [ ] Check [Implementation Summary](IMPLEMENTATION_SUMMARY.md)
- [ ] Explore the code and customize!

## Support

- **Firebase Issues**: [Firebase Docs](https://firebase.google.com/docs)
- **iOS Development**: [Apple Docs](https://developer.apple.com/documentation/)
- **SwiftUI**: [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

## Quick Commands

```bash
# Clean build
Cmd + Shift + K

# Build
Cmd + B

# Run
Cmd + R

# Stop
Cmd + .

# Show console
Cmd + Shift + Y
```

## Validation Checklist

- [x] Firebase configured ✅
- [x] Authentication enabled ✅
- [x] Firestore created ✅
- [x] App builds successfully ✅
- [x] Can create account ✅
- [x] Can add vehicle/parking lot ✅
- [x] Location permissions work ✅
- [x] Can view parking spots ✅
- [x] Can create booking ✅

---

**You're all set! Start building amazing parking experiences! 🚗💨**

For detailed information, see:
- [README.md](README.md) - Full feature overview
- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Detailed Firebase guide
- [API_DOCUMENTATION.md](API_DOCUMENTATION.md) - API reference
- [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) - What was built
