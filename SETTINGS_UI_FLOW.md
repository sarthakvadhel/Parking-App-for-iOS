# Settings UI Flow Diagram

## Navigation Flow

```
┌─────────────────────────────────────┐
│     Side Menu                       │
│                                     │
│  👤 My Profile                      │
│  🕐 My Bookings                     │
│  🚗 My Vehicles                     │
│  ⚙️  Settings  ← TAP HERE          │
│                                     │
│  ➡️  Sign out                       │
└─────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│  Settings                    [Done] │
│─────────────────────────────────────│
│                                     │
│  ACCOUNT                            │
│  🔑 Change Password              > │
│  🗑️  Delete Account              > │
│                                     │
│  NOTIFICATIONS                      │
│  🔔 All Notifications          [ON] │
│  📅 Booking Updates            [ON] │
│                                     │
│  PAYMENT METHODS                    │
│  💳 Payment Methods              > │
│                                     │
│  RECEIPTS & HISTORY                 │
│  📄 View Receipts                > │
│                                     │
│  PRIVACY & SECURITY                 │
│  👤 Face ID                    [OFF]│
│                                     │
│  ABOUT                              │
│  Version                       1.0  │
│                                     │
└─────────────────────────────────────┘
```

## Change Password Flow

```
┌─────────────────────────────────────┐
│  Change Password          [Cancel] │
│─────────────────────────────────────│
│                                     │
│  CURRENT PASSWORD                   │
│  ┌─────────────────────────────┐   │
│  │ ••••••••                    │   │
│  └─────────────────────────────┘   │
│                                     │
│  NEW PASSWORD                       │
│  ┌─────────────────────────────┐   │
│  │ ••••••••                    │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ ••••••••                    │   │
│  └─────────────────────────────┘   │
│                                     │
│  Password must be at least 6        │
│  characters long                    │
│                                     │
│  ┌─────────────────────────────┐   │
│  │   Change Password           │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

## Delete Account Flow

```
Step 1: First Confirmation
┌─────────────────────────────────────┐
│           Delete Account            │
│                                     │
│  Are you sure you want to delete    │
│  your account? This action cannot   │
│  be undone.                         │
│                                     │
│  ┌────────────┐  ┌────────────┐    │
│  │   Cancel   │  │   Delete   │    │
│  └────────────┘  └────────────┘    │
└─────────────────────────────────────┘
             │
             ▼ (User taps Delete)
┌─────────────────────────────────────┐
│       Final Confirmation            │
│                                     │
│  All your data including bookings,  │
│  vehicles, and payment history will │
│  be permanently deleted. Type your  │
│  password to confirm.               │
│                                     │
│  ┌────────────┐  ┌────────────┐    │
│  │   Cancel   │  │Delete Forever│  │
│  └────────────┘  └────────────┘    │
└─────────────────────────────────────┘
             │
             ▼ (Account Deleted)
┌─────────────────────────────────────┐
│       Welcome Back!                 │
│                                     │
│  (Login Screen)                     │
└─────────────────────────────────────┘
```

## Payment Methods View

```
┌─────────────────────────────────────┐
│  Payment Methods          [Cancel] │
│─────────────────────────────────────│
│                                     │
│         💳                          │
│                                     │
│    Payment Methods                  │
│                                     │
│  Additional payment methods like    │
│  UPI and Cards will be available    │
│  soon.                              │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ₹  Cash Payment             │   │
│  │                   Available │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 📱 UPI Payment              │   │
│  │               Coming Soon   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 💳 Card Payment             │   │
│  │               Coming Soon   │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

## Receipts & History View

```
┌─────────────────────────────────────┐
│  Receipts & History       [Cancel] │
│─────────────────────────────────────│
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Mall Parking          ₹100  │   │
│  │ Oct 13, 2025, 3:30 PM       │   │
│  │ Vehicle: GJ01AB1234         │   │
│  │                  [COMPLETED] │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Airport Parking       ₹250  │   │
│  │ Oct 12, 2025, 8:00 AM       │   │
│  │ Vehicle: GJ01AB1234         │   │
│  │                    [ACTIVE] │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ City Center           ₹80   │   │
│  │ Oct 10, 2025, 2:15 PM       │   │
│  │ Vehicle: GJ01AB1234         │   │
│  │                  [CANCELLED] │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

## Empty States

### No Receipts
```
┌─────────────────────────────────────┐
│  Receipts & History       [Cancel] │
│─────────────────────────────────────│
│                                     │
│                                     │
│            🔍📄                     │
│                                     │
│         No Receipts                 │
│                                     │
│  Your booking receipts will         │
│  appear here                        │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

## Feature Highlights

### ✅ Implemented Features

1. **Change Password**
   - Current password validation
   - New password requirements (min 6 chars)
   - Confirmation field
   - Re-authentication before change

2. **Delete Account**
   - Two-step confirmation
   - Complete data deletion
   - Anonymized booking history
   - GDPR compliant

3. **Notifications**
   - Master toggle for all notifications
   - Booking updates toggle
   - Real-time persistence to Firestore

4. **Biometric Lock**
   - Face ID/Touch ID detection
   - Enable/disable toggle
   - Preference persistence

5. **Payment Methods**
   - Current methods display
   - Coming soon indicators
   - Ready for future expansion

6. **Receipts & History**
   - Complete booking history
   - Status badges (Active, Completed, Cancelled, Pending)
   - Date/time formatting
   - Vehicle information
   - Amount display

## Color Scheme

- **Status Colors**:
  - Active: Blue
  - Completed: Green
  - Cancelled: Red
  - Pending: Orange

- **Icons**:
  - 🔑 Change Password - Blue
  - 🗑️ Delete Account - Red
  - 🔔 Notifications - Orange
  - 📅 Booking Updates - Green
  - 💳 Payment Methods - Purple
  - 📄 Receipts - Indigo
  - 👤 Face ID/Touch ID - Teal

## Accessibility Features

- Clear, descriptive labels
- Proper color contrast
- Support for VoiceOver
- Large touch targets
- Confirmation dialogs for destructive actions
- Loading indicators for async operations
- Error messages with context

## Integration Points

### FirebaseAuth
- Password change with re-authentication
- Account deletion

### Firestore
- User preferences storage
- Booking history queries
- User data deletion

### LocalAuthentication
- Biometric capability detection
- Face ID/Touch ID support

### Analytics
- Password change tracking
- Account deletion tracking
- Feature usage metrics

### Keychain
- Secure credential storage
- Data clearing on logout/deletion
