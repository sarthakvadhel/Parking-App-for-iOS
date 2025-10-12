# Firebase Configuration Setup

## Overview
This guide explains how to properly configure Firebase for the Parking App without committing sensitive credentials to the repository.

## Prerequisites
- Xcode 14.0 or later
- Firebase account
- Firebase project created

## Setup Steps

### 1. Download Your Firebase Configuration

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Navigate to Project Settings (gear icon)
4. Under "Your apps", select the iOS app (or add a new iOS app)
5. Download the `GoogleService-Info.plist` file

### 2. Install the Configuration File

1. **DO NOT** add `GoogleService-Info.plist` to Git
2. Copy the downloaded file to: `ParkingApp/GoogleService-Info.plist`
3. Ensure the file is in your local project but not tracked by Git (already in .gitignore)

### 3. Configure Xcode

1. Open `ParkingApp.xcodeproj` in Xcode
2. Drag `GoogleService-Info.plist` into the project navigator
3. Ensure "Copy items if needed" is checked
4. Make sure the target membership includes "ParkingApp"

### 4. Verify Installation

The app should now be able to connect to Firebase. You can verify by:
- Running the app
- Checking Xcode console for Firebase initialization logs
- Testing authentication features

## Firebase Services Used

### Authentication
- Email/Password authentication
- User role-based access (User/Vendor)

### Firestore Database
Collections:
- `users` - User profiles and roles
- `vehicles` - User vehicle registrations
- `parkingLots` - Vendor parking lot information
- `bookings` - Parking bookings (requires vendorId field)
- `payments` - Payment records

**Required Composite Index:**
- Collection: `bookings`
- Fields: `vendorId` (Ascending), `startTime` (Descending)
- This index enables vendors to view their bookings sorted by time

### Cloud Storage (Optional)
- User profile pictures
- Parking lot images
- Vehicle images

## Security Considerations

### What's Protected
- ✅ `GoogleService-Info.plist` is in `.gitignore`
- ✅ User credentials stored in Keychain (not UserDefaults)
- ✅ API keys not exposed in code
- ✅ Firestore security rules enforced

### Firebase Security Rules

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
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
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && request.auth.uid == userId;
      allow update: if isOwner(userId);
      allow delete: if false; // Prevent deletion
    }
    
    // Vehicles collection
    match /vehicles/{vehicleId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && 
                     request.resource.data.userId == request.auth.uid;
      allow delete: if isSignedIn() && 
                      resource.data.userId == request.auth.uid;
    }
    
    // Parking lots collection
    match /parkingLots/{lotId} {
      allow read: if true; // Public read for discovery
      allow write: if hasRole('vendor') && 
                     (request.resource.data.vendorId == request.auth.uid ||
                      resource.data.vendorId == request.auth.uid);
      allow delete: if hasRole('vendor') && 
                      resource.data.vendorId == request.auth.uid;
    }
    
    // Bookings collection
    match /bookings/{bookingId} {
      allow read: if isSignedIn() && 
                    (resource.data.userId == request.auth.uid || 
                     hasRole('vendor'));
      allow create: if isSignedIn() && 
                      request.resource.data.userId == request.auth.uid;
      allow update: if isSignedIn() && 
                      (resource.data.userId == request.auth.uid || 
                       hasRole('vendor'));
      allow delete: if false; // Prevent deletion, use status updates
    }
    
    // Payments collection
    match /payments/{paymentId} {
      allow read: if isSignedIn() && 
                    (resource.data.userId == request.auth.uid || 
                     hasRole('vendor'));
      allow create: if isSignedIn() && 
                      request.resource.data.userId == request.auth.uid;
      allow update, delete: if false; // Immutable payment records
    }
  }
}
```

#### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile pictures
    match /profiles/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024 // 5MB limit
                   && request.resource.contentType.matches('image/.*');
    }
    
    // Parking lot images
    match /parkingLots/{vendorId}/{lotId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == vendorId
                   && request.resource.size < 10 * 1024 * 1024 // 10MB limit
                   && request.resource.contentType.matches('image/.*');
    }
    
    // Vehicle images
    match /vehicles/{userId}/{vehicleId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024 // 5MB limit
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Team Setup

### For New Team Members

1. Request `GoogleService-Info.plist` from team lead (via secure channel)
2. Follow installation steps above
3. Never commit the file to Git
4. If accidentally committed, immediately:
   - Remove from Git: `git rm --cached ParkingApp/GoogleService-Info.plist`
   - Rotate Firebase API keys in Firebase Console
   - Commit the removal

### For CI/CD

GitHub Actions requires Firebase configuration:

1. Create a GitHub secret named `FIREBASE_CONFIG`
2. Base64 encode your `GoogleService-Info.plist`:
   ```bash
   base64 -i ParkingApp/GoogleService-Info.plist | pbcopy
   ```
3. Paste the encoded string as the secret value
4. Update CI workflow to decode and use it

## Troubleshooting

### Issue: "Firebase app not configured"
- Ensure `GoogleService-Info.plist` is in the project
- Check that FirebaseApp.configure() is called in AppDelegate

### Issue: "Permission denied" errors
- Verify Firestore security rules are deployed
- Check that user authentication is working
- Ensure user has correct role assigned

### Issue: Build fails with missing plist
- Copy the template: `cp ParkingApp/GoogleService-Info.plist.template ParkingApp/GoogleService-Info.plist`
- Fill in actual values from Firebase Console

## References

- [Firebase iOS Setup Guide](https://firebase.google.com/docs/ios/setup)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Storage Security](https://firebase.google.com/docs/storage/security)
