# User Profile Management - Visual Flow

## Registration to Profile Setup Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    NEW USER REGISTRATION                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │   SignupView     │
                    │  Enter Email &   │
                    │    Password      │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Select Role:    │
                    │  User or Vendor  │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │ Create Firebase  │
                    │   Auth Account   │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Create User in  │
                    │    Firestore     │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Success Alert   │
                    │   (1 second)     │
                    └──────────────────┘
                              │
                              ▼
         ╔════════════════════════════════════════╗
         ║        ProfileSetupView (NEW!)         ║
         ║                                        ║
         ║  ┌────────────────────────────────┐   ║
         ║  │     Profile Picture Area       │   ║
         ║  │  ┌──────────────────────┐      │   ║
         ║  │  │   [Camera Icon]      │ 📷   │   ║
         ║  │  │   (Tap to add)       │      │   ║
         ║  │  └──────────────────────┘      │   ║
         ║  └────────────────────────────────┘   ║
         ║                                        ║
         ║  Full Name: [_________________]        ║
         ║                                        ║
         ║  Phone:     [_________________]        ║
         ║                                        ║
         ║        [Continue Button]               ║
         ║                                        ║
         ║  (Cannot dismiss - mandatory)          ║
         ╚════════════════════════════════════════╝
                              │
                              ▼
                    ┌──────────────────┐
                    │ Upload Image to  │
                    │ Firebase Storage │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Update User in  │
                    │    Firestore     │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │   Proceed to     │
                    │    Main App      │
                    └──────────────────┘
```

## Side Menu Profile Display

```
╔═══════════════════════════════════════╗
║          SIDE MENU VIEW               ║
╠═══════════════════════════════════════╣
║                                       ║
║  ┌────────┐                      [X]  ║
║  │        │  Profile Picture          ║
║  │  👤/📷 │  (From Firebase Storage)  ║
║  │        │                           ║
║  └────────┘                           ║
║                                       ║
║  John Doe                             ║
║  (Name if available, else email)      ║
║                                       ║
║  john.doe@example.com                 ║
║  (Email always shown)                 ║
║                                       ║
╠═══════════════════════════════════════╣
║                                       ║
║  👤  My Profile       ────────────┐   ║
║                                   │   ║
║  🕐  My Bookings                  │   ║
║                                   │   ║
║  🚗  My Vehicles                  │   ║
║                                   │   ║
║  ⚙️   Settings                    │   ║
║                                   │   ║
║  🚪  Sign out                     │   ║
║                                   │   ║
╚═══════════════════════════════════════╝
                                    │
                                    ▼
               Tapping "My Profile" opens
                    MyProfileView
```

## Profile Editing Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    EDIT PROFILE FLOW                             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  User taps       │
                    │  "My Profile"    │
                    │  in Side Menu    │
                    └──────────────────┘
                              │
                              ▼
         ╔════════════════════════════════════════╗
         ║         MyProfileView (NEW!)           ║
         ║                                        ║
         ║  Navigation Bar: [Close]  My Profile   ║
         ║                                        ║
         ║  ┌────────────────────────────────┐   ║
         ║  │     Current Profile Picture    │   ║
         ║  │  ┌──────────────────────┐      │   ║
         ║  │  │   [Profile Photo]    │ 📷   │   ║
         ║  │  │                      │      │   ║
         ║  │  └──────────────────────┘      │   ║
         ║  │  Tap to change photo           │   ║
         ║  └────────────────────────────────┘   ║
         ║                                        ║
         ║  Email:                                ║
         ║  ┌─────────────────────────────────┐  ║
         ║  │ john.doe@example.com (readonly) │  ║
         ║  └─────────────────────────────────┘  ║
         ║                                        ║
         ║  Full Name:                            ║
         ║  ┌─────────────────────────────────┐  ║
         ║  │ [John Doe____________]          │  ║
         ║  └─────────────────────────────────┘  ║
         ║                                        ║
         ║  Phone Number:                         ║
         ║  ┌─────────────────────────────────┐  ║
         ║  │ [+1 234 567 8900_____]          │  ║
         ║  └─────────────────────────────────┘  ║
         ║                                        ║
         ║  User Role:                            ║
         ║  ┌─────────────────────────────────┐  ║
         ║  │ User (readonly)                 │  ║
         ║  └─────────────────────────────────┘  ║
         ║                                        ║
         ║        [Save Changes Button]           ║
         ║                                        ║
         ╚════════════════════════════════════════╝
                              │
                              ▼
                    ┌──────────────────┐
                    │  User makes      │
                    │  changes and     │
                    │  taps Save       │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │ Upload new image │
                    │ (if changed)     │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Update User in  │
                    │    Firestore     │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Success Alert   │
                    │  "Profile updated│
                    │  successfully!"  │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  View dismisses  │
                    │  Side Menu       │
                    │  refreshes       │
                    └──────────────────┘
```

## Photo Selection Options

```
When user taps camera icon:
┌─────────────────────────────────────┐
│    Choose Photo Source              │
├─────────────────────────────────────┤
│                                     │
│  📷  Camera                         │
│      (Take new photo)               │
│                                     │
│  🖼️   Photo Library                 │
│      (Choose existing)              │
│                                     │
│  ❌  Remove Photo (if exists)       │
│                                     │
│  Cancel                             │
│                                     │
└─────────────────────────────────────┘
         │                │
         │                │
         ▼                ▼
    ┌────────┐      ┌──────────┐
    │ Camera │      │  Photo   │
    │  App   │      │ Library  │
    └────────┘      └──────────┘
         │                │
         └────────┬───────┘
                  ▼
         Image Selected
                  │
                  ▼
         ┌────────────────┐
         │ Compress Image │
         │  (70% quality) │
         └────────────────┘
                  │
                  ▼
         ┌────────────────┐
         │  Upload to     │
         │  Firebase      │
         │  Storage       │
         └────────────────┘
```

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    USER PROFILE DATA FLOW                        │
└─────────────────────────────────────────────────────────────────┘

    UI Layer              Service Layer           Firebase
    ─────────             ─────────────           ────────

┌──────────────┐
│ SignupView   │
└──────┬───────┘
       │
       │ 1. Create user
       │
       ▼
┌──────────────┐
│ProfileSetup  │
│    View      │
└──────┬───────┘
       │
       │ 2. Add details
       │    + photo
       │
       ▼
┌──────────────┐       ┌────────────────┐       ┌─────────────┐
│ MyProfileView│──────▶│ImageUploadHelper│──────▶│  Firebase   │
└──────┬───────┘       └────────────────┘       │  Storage    │
       │                       │                 └─────────────┘
       │                       │
       │                       │ URL
       │                       ▼
       │               ┌────────────────┐       ┌─────────────┐
       │──────────────▶│ Firestore      │──────▶│  Firestore  │
       │               │ Manager        │       │  Database   │
       │               └────────────────┘       └─────────────┘
       │                       │
       │                       │ User data
       │                       ▼
       │               ┌────────────────┐
       └──────────────▶│  SideMenuView  │
                       └────────────────┘
                               │
                               │ Display profile
                               ▼
                       ┌────────────────┐
                       │ Profile Image  │
                       │ Username       │
                       │ Email          │
                       └────────────────┘
```

## Firebase Storage Structure

```
firebase_storage/
│
└── profileImages/
    ├── userId1.jpg  ← Profile picture for user 1
    ├── userId2.jpg  ← Profile picture for user 2
    └── userId3.jpg  ← Profile picture for user 3
```

## Firestore Data Structure

```json
{
  "users": {
    "userId1": {
      "id": "userId1",
      "email": "john@example.com",
      "role": "user",
      "name": "John Doe",                    ← Added by ProfileSetupView
      "phoneNumber": "+1234567890",          ← Added by ProfileSetupView
      "profileImageURL": "https://...",      ← Added by ProfileSetupView
      "createdAt": "2024-01-01T00:00:00Z",
      "vehicles": []
    }
  }
}
```

## State Management

```
ProfileSetupView State:
├── name: String
├── phoneNumber: String
├── selectedImage: UIImage?
├── showImagePicker: Bool
├── showCamera: Bool
├── isUploading: Bool
├── showError: Bool
└── errorMessage: String

MyProfileView State:
├── user: User?
├── name: String
├── phoneNumber: String
├── selectedImage: UIImage?
├── profileImage: UIImage?
├── showImagePicker: Bool
├── showCamera: Bool
├── isLoading: Bool
├── isSaving: Bool
├── showError: Bool
├── errorMessage: String
└── showSuccess: Bool

SideMenuView State:
├── currentUser: User?
├── profileImage: UIImage?
├── showMyProfile: Bool
├── showMyVehicles: Bool
├── showMyBookings: Bool
├── showSettings: Bool
└── showLogoutConfirmation: Bool
```
