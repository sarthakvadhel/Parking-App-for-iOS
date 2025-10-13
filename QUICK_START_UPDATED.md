# Quick Start Guide

## 🚀 Getting Started with Parking App for iOS

This guide will help you set up and run the Parking App on your development machine.

## Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- iOS 16.0+ device or simulator
- Firebase account (free tier is sufficient)
- CocoaPods or Swift Package Manager

## Step 1: Clone the Repository

```bash
git clone https://github.com/sarthakvadhel/Parking-App-for-iOS.git
cd Parking-App-for-iOS
```

## Step 2: Firebase Configuration

### Option A: Request from Team
1. Contact the team lead to get `GoogleService-Info.plist`
2. Place it in the `ParkingApp/` directory

### Option B: Set Up Your Own Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing one
3. Add an iOS app:
   - Bundle ID: `com.yourcompany.ParkingApp` (or update in Xcode)
   - Download `GoogleService-Info.plist`
4. Place the file in `ParkingApp/` directory
5. Enable these services in Firebase Console:
   - **Authentication** → Email/Password
   - **Firestore Database** → Start in test mode
   - **Storage** → Start in test mode (optional)
   - **Crashlytics** (optional, for production)
   - **Analytics** (optional, for production)

### Security Rules

Deploy these Firestore security rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    function hasRole(role) {
      return isSignedIn() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role;
    }
    
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && request.auth.uid == userId;
      allow update: if isOwner(userId);
    }
    
    match /vehicles/{vehicleId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && request.resource.data.userId == request.auth.uid;
    }
    
    match /parkingLots/{lotId} {
      allow read: if true;
      allow write: if hasRole('vendor');
    }
    
    match /bookings/{bookingId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && request.resource.data.userId == request.auth.uid;
      allow update: if isSignedIn();
    }
    
    match /payments/{paymentId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
    }
  }
}
```

## Step 3: Open in Xcode

```bash
open ParkingApp.xcodeproj
```

## Step 4: Configure Signing

1. In Xcode, select the ParkingApp target
2. Go to "Signing & Capabilities"
3. Select your development team
4. Xcode will automatically manage signing

## Step 5: Build and Run

1. Select a simulator or connected device
2. Press `Cmd + R` or click the Run button
3. The app should build and launch

## 🎯 First Time Setup

### Create Test Accounts

#### User Account
1. Launch the app
2. Click "Don't have an account?"
3. Select "User" role
4. Enter:
   - Email: `testuser@example.com`
   - Password: `Test@123`
5. Register vehicle when prompted

#### Vendor Account
1. Sign out if logged in
2. Click "Don't have an account?"
3. Select "Vendor" role
4. Enter:
   - Email: `testvendor@example.com`
   - Password: `Test@123`
5. Add a parking lot when prompted

### Add Sample Data

For testing, you can add sample parking lots via Firebase Console:

```javascript
// In Firestore, add to parkingLots collection:
{
  "name": "AMC Central Parking",
  "address": "123 Main St, Ahmedabad",
  "description": "Secure parking near shopping center",
  "latitude": 23.0225,
  "longitude": 72.5714,
  "totalSpaces": 50,
  "availableSpaces": 35,
  "hourlyCharge": 50,
  "lateFee": 20,
  "terms": "No overnight parking",
  "isActive": true,
  "vendorId": "your-vendor-uid"
}
```

## 🔧 Troubleshooting

### Issue: "Firebase app not configured"
**Solution**: Ensure `GoogleService-Info.plist` is in the project and added to target membership.

### Issue: Build fails with missing plist
**Solution**: 
```bash
# Copy template and fill in your values
cp ParkingApp/GoogleService-Info.plist.template ParkingApp/GoogleService-Info.plist
```

### Issue: "Permission denied" errors in Firestore
**Solution**: Deploy the security rules from Step 2 in Firebase Console.

### Issue: Location not updating
**Solution**: 
1. In simulator: Features → Location → Custom Location
2. Enter coordinates: Lat: 23.0225, Long: 72.5714
3. Or select "Apple" preset

### Issue: Crashes on launch
**Solution**: 
1. Clean build folder: `Cmd + Shift + K`
2. Delete derived data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Rebuild: `Cmd + B`

## 📱 Features to Test

### As User
- [x] Sign up with email/password
- [x] Login
- [x] Register vehicle
- [x] View parking spots on map
- [x] Search for parking
- [x] View parking details
- [x] Book parking space
- [x] Make payment
- [x] View profile in menu

### As Vendor
- [x] Sign up as vendor
- [x] Add parking lot
- [x] View dashboard stats
- [x] View and manage bookings
- [x] Accept/decline booking requests
- [x] Edit parking lot details

## 🔐 Security Features Implemented

✅ Keychain storage for credentials
✅ Secure authentication flow
✅ Firebase security rules
✅ Logout confirmation
✅ Error logging without sensitive data
✅ Encrypted local storage

## 📊 Development Tools

### Firebase Console
- View users: Authentication → Users
- View data: Firestore Database
- Check crashes: Crashlytics (if enabled)
- View analytics: Analytics (if enabled)

### Xcode Debugging
- Console logs: `Cmd + Shift + Y`
- View hierarchy: Debug → View Debugging
- Memory graph: Debug → Memory Graph

### Useful Commands

```bash
# Clean build
xcodebuild clean -project ParkingApp.xcodeproj

# Build for testing
xcodebuild test -project ParkingApp.xcodeproj -scheme ParkingApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# View git status
git status

# Create new branch for feature
git checkout -b feature/your-feature-name
```

## 🚀 Next Steps

1. **Explore the App**: Test both user and vendor flows
2. **Review Code**: Check `ParkingApp/Services/` for new architecture
3. **Read Docs**: Review `PRODUCTION_READINESS.md` for improvements
4. **Add Features**: Follow patterns in existing code
5. **Run Tests**: (When test suite is added)

## 📚 Additional Resources

- [PRODUCTION_READINESS.md](./PRODUCTION_READINESS.md) - Production improvements summary
- [FIREBASE_CONFIG_GUIDE.md](./FIREBASE_CONFIG_GUIDE.md) - Detailed Firebase setup
- [ARCHITECTURE_REDESIGN.md](./ARCHITECTURE_REDESIGN.md) - Architecture documentation
- [GAP_ANALYSIS.md](./GAP_ANALYSIS.md) - Detailed gap analysis

## 🆘 Getting Help

If you encounter issues:
1. Check this guide's troubleshooting section
2. Review Firebase Console for errors
3. Check Xcode console for error logs
4. Review documentation in repository
5. Contact the development team

## 🎉 You're Ready!

The app is now set up and ready for development. Start exploring and building amazing features!

---

**Happy Coding! 🚗📱**
