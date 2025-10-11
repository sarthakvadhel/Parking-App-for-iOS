# Firebase Configuration Guide

## Prerequisites
- Xcode 14.0 or later
- iOS 15.0 or later
- Firebase account

## Setup Steps

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "Parking with Sarthak" (or your preference)
4. Follow the setup wizard

### 2. Add iOS App to Firebase
1. In Firebase Console, click "Add app" → iOS
2. Enter iOS bundle ID: `com.yourcompany.ParkingApp` (match your Xcode project)
3. Download `GoogleService-Info.plist`
4. Add the file to your Xcode project (drag and drop into the project navigator)

### 3. Enable Firebase Services

#### Authentication
1. Go to Authentication → Sign-in method
2. Enable Email/Password authentication
3. Save

#### Firestore Database
1. Go to Firestore Database
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location closest to your users
5. Click "Enable"

#### (Optional) Cloud Storage
1. Go to Storage
2. Click "Get started"
3. Choose "Start in test mode"
4. Click "Done"

### 4. Firestore Security Rules

For development, use these rules (in Firestore → Rules tab):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Vehicles
    match /vehicles/{vehicleId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      request.resource.data.userId == request.auth.uid;
    }
    
    // Parking lots (public read, vendor write)
    match /parkingLots/{lotId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      request.resource.data.vendorId == request.auth.uid;
    }
    
    // Bookings
    match /bookings/{bookingId} {
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      allow write: if request.auth != null && 
                      request.resource.data.userId == request.auth.uid;
    }
    
    // Payments
    match /payments/{paymentId} {
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      allow write: if request.auth != null && 
                      request.resource.data.userId == request.auth.uid;
    }
  }
}
```

For production, tighten these rules based on your requirements.

### 5. Storage Security Rules (if using Cloud Storage)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /parkingLots/{lotId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /vehicles/{vehicleId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### 6. Firestore Indexes

The app uses simple queries, but you may need to create composite indexes if you get errors. Firebase will provide a link to create the required index when needed.

### 7. Build and Run

1. Open `ParkingApp.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Build and run the project

## Data Structure

### Collections

#### users
```json
{
  "id": "user_id",
  "email": "user@example.com",
  "role": "user|vendor",
  "name": "John Doe",
  "phoneNumber": "+1234567890",
  "profileImageURL": "https://...",
  "createdAt": "timestamp",
  "vehicles": ["vehicle_id_1", "vehicle_id_2"]
}
```

#### vehicles
```json
{
  "id": "vehicle_id",
  "userId": "user_id",
  "vehicleNumber": "GJ01AE7828",
  "model": "Swift",
  "manufacturer": "Maruti",
  "color": "White",
  "imageURLs": ["https://..."],
  "isActive": true,
  "createdAt": "timestamp"
}
```

#### parkingLots
```json
{
  "id": "lot_id",
  "vendorId": "vendor_user_id",
  "name": "City Center Parking",
  "description": "Secure parking in city center",
  "address": "123 Main St, City",
  "latitude": 37.7749,
  "longitude": -122.4194,
  "hourlyCharge": 50.0,
  "lateFee": 20.0,
  "terms": "Terms and conditions...",
  "totalSpaces": 100,
  "availableSpaces": 75,
  "imageURLs": ["https://..."],
  "isActive": true,
  "createdAt": "timestamp"
}
```

#### bookings
```json
{
  "id": "booking_id",
  "userId": "user_id",
  "vehicleId": "vehicle_id",
  "parkingLotId": "lot_id",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "plannedHours": 2.0,
  "actualHours": 2.5,
  "status": "active|completed|cancelled",
  "totalAmount": 125.0,
  "createdAt": "timestamp"
}
```

#### payments
```json
{
  "id": "payment_id",
  "bookingId": "booking_id",
  "userId": "user_id",
  "amount": 125.0,
  "method": "cash|card|upi|wallet",
  "status": "pending|completed|failed",
  "transactionId": "txn_123",
  "createdAt": "timestamp"
}
```

## Troubleshooting

### Common Issues

1. **App crashes on launch**
   - Ensure `GoogleService-Info.plist` is properly added to the project
   - Check that Firebase is configured in `ParkingAppApp.swift`

2. **Authentication not working**
   - Verify Email/Password authentication is enabled in Firebase Console
   - Check network connectivity

3. **Can't read/write to Firestore**
   - Review security rules
   - Ensure user is authenticated
   - Check Firestore is in the correct region

4. **Location not working**
   - Ensure location permissions are added to Info.plist
   - Grant location permissions when prompted

## Support

For issues related to:
- Firebase: [Firebase Documentation](https://firebase.google.com/docs)
- iOS Development: [Apple Developer Documentation](https://developer.apple.com/documentation/)

---

**Happy Parking! 🚗**
