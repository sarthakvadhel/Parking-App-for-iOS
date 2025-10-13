# Settings Feature Documentation

## Overview

The Settings feature provides users with comprehensive control over their account, notifications, security, and preferences.

## Features Implemented

### 1. Account Management
- **Change Password**: Allows users to update their password with proper re-authentication
  - Validates current password before allowing change
  - Requires minimum 6 characters for new password
  - Confirmation field to prevent typos
  - Firebase Authentication integration

- **Delete Account**: Complete account deletion with safety confirmations
  - Two-step confirmation process to prevent accidental deletion
  - Deletes user data from Firestore
  - Removes all associated vehicles
  - Anonymizes booking history (preserves analytics while removing PII)
  - Deletes Firebase Authentication account
  - Clears local Keychain data

### 2. Notifications
- **All Notifications Toggle**: Master switch for all notifications
- **Booking Updates Toggle**: Specific control for booking-related notifications
  - Automatically disabled when All Notifications is off
  - Preferences stored in Firestore under `userPreferences` collection

### 3. Payment Methods
- **Current Status Display**:
  - Cash Payment: ✅ Available
  - UPI Payment: 🔜 Coming Soon
  - Card Payment: 🔜 Coming Soon
- Placeholder view for future payment method management

### 4. Receipts & History
- **Booking History View**:
  - Displays all user bookings (past and present)
  - Shows booking details: location, date/time, amount, vehicle
  - Color-coded status badges
  - Sorted by date (newest first)

### 5. Privacy & Security
- **Biometric Authentication**:
  - Face ID support on compatible devices
  - Touch ID support on compatible devices
  - Automatic detection of available biometric type
  - Toggle to enable/disable biometric lock
  - Preferences persisted across sessions

### 6. App Information
- Displays current app version

## Technical Architecture

### Files Created/Modified

#### New Files:
1. **ParkingApp/Model/UserPreferences.swift**
   - Model for storing user preferences
   - Fields: notifications, biometric auth settings
   - Codable for Firestore integration

2. **ParkingApp/Views/SettingsView.swift**
   - Main settings interface
   - Subviews: ChangePasswordView, PaymentMethodsView, ReceiptsHistoryView
   - ViewModels: SettingsViewModel, ReceiptsViewModel

#### Modified Files:
1. **ParkingApp/Services/FirestoreManager.swift**
   - Added `deleteUser()` method
   - Added `fetchUserPreferences()` method
   - Added `updateUserPreferences()` method

2. **ParkingApp/Services/AnalyticsService.swift**
   - Added `passwordChanged` event
   - Added `userDeleted` event

3. **ParkingApp/Views/SideMenuView.swift**
   - Added navigation to Settings
   - Added `showSettings` state variable
   - Added sheet presentation for SettingsView

## Data Models

### UserPreferences
```swift
struct UserPreferences: Codable {
    var id: String?
    var userId: String
    var notificationsEnabled: Bool
    var bookingUpdatesEnabled: Bool
    var biometricAuthEnabled: Bool
    var createdAt: Date
    var updatedAt: Date
}
```

## Firestore Collections

### userPreferences
- Document ID: `userId`
- Fields:
  - `userId`: String
  - `notificationsEnabled`: Boolean
  - `bookingUpdatesEnabled`: Boolean
  - `biometricAuthEnabled`: Boolean
  - `createdAt`: Timestamp
  - `updatedAt`: Timestamp

## Security Considerations

### Account Deletion
- Implements GDPR "Right to be Forgotten"
- Follows security best practices from SECURITY_CHECKLIST.md
- Anonymizes data instead of deleting where required for analytics
- Clears all PII (Personally Identifiable Information)

### Password Change
- Requires re-authentication with current password
- Uses Firebase's secure password update mechanism
- Minimum 6 characters enforced
- Confirmation field prevents typos

### Biometric Authentication
- Uses LocalAuthentication framework
- Respects device capabilities
- Preference stored securely in Firestore
- No biometric data stored locally

## User Experience Flow

### Accessing Settings
1. User opens side menu
2. Taps "Settings" option
3. Settings screen appears as a modal sheet

### Changing Password
1. Navigate to Settings → Change Password
2. Enter current password
3. Enter new password (min 6 chars)
4. Confirm new password
5. Tap "Change Password"
6. Success message displayed
7. Auto-dismiss to Settings

### Deleting Account
1. Navigate to Settings → Delete Account
2. First confirmation dialog appears
3. User confirms intention to delete
4. Second confirmation dialog (final warning)
5. User confirms final deletion
6. Account deletion process executes
7. User logged out automatically

### Managing Notifications
1. Navigate to Settings
2. Toggle "All Notifications" or "Booking Updates"
3. Preference saved automatically to Firestore
4. UI updates immediately

### Enabling Biometric Lock
1. Navigate to Settings
2. Toggle Face ID/Touch ID (if available)
3. Preference saved to Firestore
4. Future app launches will require biometric auth (when implemented)

## Analytics Tracking

The following events are tracked:
- `password_changed`: When user successfully changes password
- `user_deleted`: When user deletes their account

## Future Enhancements

1. **Biometric Lock Implementation**: Require biometric auth on app launch when enabled
2. **Payment Methods**: Add UPI and card payment integration
3. **Export Data**: Allow users to download their data (GDPR compliance)
4. **Theme Selection**: Dark mode preference
5. **Language Selection**: Multi-language support
6. **Notification Categories**: More granular notification controls
7. **Privacy Policy**: In-app privacy policy viewer
8. **Terms of Service**: In-app terms viewer

## Testing Checklist

- [ ] Settings menu opens from side menu
- [ ] Password change with valid credentials
- [ ] Password change with invalid current password (error handling)
- [ ] Password change with mismatched confirmation (validation)
- [ ] Account deletion with both confirmations
- [ ] Account deletion cancellation at any step
- [ ] Notification toggle saves to Firestore
- [ ] Booking updates toggle respects master toggle
- [ ] Biometric toggle appears only on compatible devices
- [ ] Biometric toggle saves to Firestore
- [ ] Payment methods view displays correctly
- [ ] Receipts history loads user bookings
- [ ] Empty state shown when no bookings
- [ ] App version displayed correctly
- [ ] All navigation flows work smoothly
- [ ] Proper error messages for all failure cases

## Accessibility

- All buttons have proper labels
- Toggle switches have descriptive labels
- Alert messages are clear and concise
- Color-coded status badges with text labels
- Proper font sizes for readability
- Support for Dynamic Type (iOS accessibility feature)

## Performance Considerations

- Lazy loading of bookings history
- Preferences cached after first load
- Efficient Firestore queries
- Async/await for non-blocking operations
- Main thread updates for UI changes
