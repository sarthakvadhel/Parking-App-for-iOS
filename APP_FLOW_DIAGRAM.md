# App Flow Diagram

## User Journey

```
┌─────────────────────────────────────────────────────────────┐
│                    App Launch                                │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
                  ┌────────────────┐
                  │ First Launch?  │
                  └────────┬───────┘
                           │
              ┌────────────┴────────────┐
              │                         │
          YES │                         │ NO
              ▼                         ▼
    ┌──────────────────┐      ┌──────────────┐
    │ Welcome Screen   │      │ Auth Check   │
    │ (Onboarding)     │      └──────┬───────┘
    └────────┬─────────┘             │
             │                       │
             └──────────┬────────────┘
                        │
                        ▼
              ┌──────────────────┐
              │ Authenticated?   │
              └────────┬─────────┘
                       │
          ┌────────────┴────────────┐
          │                         │
      NO  │                         │ YES
          ▼                         ▼
    ┌──────────┐            ┌──────────────┐
    │  Login/  │            │  Load User   │
    │ Signup   │            │  Profile     │
    └────┬─────┘            └──────┬───────┘
         │                         │
         └──────────┬──────────────┘
                    │
                    ▼
          ┌──────────────────┐
          │  User Role?      │
          └────────┬─────────┘
                   │
      ┌────────────┴────────────┐
      │                         │
  USER│                         │VENDOR
      ▼                         ▼
┌─────────────┐         ┌──────────────────┐
│ Has Vehicle?│         │ Has Parking Lot? │
└─────┬───────┘         └────────┬─────────┘
      │                          │
  NO  │    YES             NO    │    YES
      ▼     │                      ▼   │
┌──────────┐│              ┌──────────┐│
│ Vehicle  ││              │  Lot     ││
│ Register ││              │ Register ││
└──────────┘│              └──────────┘│
      │     │                    │     │
      └──┬──┘                    └──┬──┘
         │                          │
         ▼                          ▼
   ┌──────────┐              ┌──────────┐
   │   User   │              │  Vendor  │
   │   Main   │              │ Dashboard│
   │   View   │              └──────────┘
   └──────────┘
```

## User Flow (Finding Parking)

```
┌────────────────┐
│   User Main    │
│   View (Map)   │
└───────┬────────┘
        │
   ┌────┴────┐
   │         │
   ▼         ▼
┌─────┐   ┌────────┐
│ Top │   │  Map   │
│ Nav │   │ w/Pins │
└──┬──┘   └────┬───┘
   │           │
   ▼           ▼
┌──────┐    ┌────────────┐
│Select│    │   Parking  │
│Vehicle    │    Card    │
└──────┘    └─────┬──────┘
                  │
                  ▼
            ┌──────────┐
            │  Tap to  │
            │  Detail  │
            └─────┬────┘
                  │
                  ▼
         ┌────────────────┐
         │ Parking Detail │
         │   - Info       │
         │   - Map        │
         │   - Hours      │
         │   - Payment    │
         └────────┬───────┘
                  │
                  ▼
           ┌────────────┐
           │   Select   │
           │   Hours    │
           └─────┬──────┘
                 │
                 ▼
          ┌─────────────┐
          │   Payment   │
          │   Options   │
          └──────┬──────┘
                 │
                 ▼
          ┌─────────────┐
          │   Booking   │
          │  Confirmed  │
          └─────────────┘
```

## Vendor Flow (Managing Parking)

```
┌──────────────────┐
│ Vendor Dashboard │
│  - Statistics    │
│  - Lot List      │
└────────┬─────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌────────┐  ┌──────────┐
│  Add   │  │   Edit   │
│  New   │  │ Existing │
│  Lot   │  │   Lot    │
└───┬────┘  └────┬─────┘
    │            │
    ▼            ▼
┌─────────────────┐
│  Lot Details    │
│  - Name         │
│  - Location     │
│  - Pricing      │
│  - Terms        │
└────────┬────────┘
         │
         ▼
    ┌─────────┐
    │  Save   │
    └────┬────┘
         │
         ▼
    ┌─────────┐
    │  Lot    │
    │  Active │
    └─────────┘
```

## Search Flow

```
┌──────────────┐
│  Search Bar  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  Enter Text  │
└──────┬───────┘
       │
       ▼
┌──────────────────┐
│  Filter Results  │
│  - By Name       │
│  - By Address    │
└────────┬─────────┘
         │
         ▼
  ┌──────────────┐
  │  Show List   │
  │  of Results  │
  └──────┬───────┘
         │
         ▼
   ┌──────────┐
   │  Select  │
   │  Result  │
   └─────┬────┘
         │
         ▼
  ┌─────────────┐
  │   Parking   │
  │   Details   │
  └─────────────┘
```

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────┐
│                    SwiftUI Views                    │
│  - ContentView                                      │
│  - VendorDashboard                                  │
│  - UserMainView                                     │
└───────────────────────┬─────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│                  View Models                        │
│  - ParkingFinder (ObservableObject)                 │
│  - VendorDashboardViewModel                         │
└───────────────────────┬─────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│                    Services                         │
│  - FirestoreManager (Singleton)                     │
│  - ImageUploadHelper                                │
└───────────────────────┬─────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│                 Firebase Backend                    │
│  - Authentication                                   │
│  - Firestore Database                               │
│  - Cloud Storage                                    │
└─────────────────────────────────────────────────────┘
```

## Authentication Flow

```
┌──────────┐
│  Signup  │
└────┬─────┘
     │
     ▼
┌──────────────┐
│ Enter Email  │
│ & Password   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Select Role  │
│ User/Vendor  │
└──────┬───────┘
       │
       ▼
┌──────────────────┐
│ Create Firebase  │
│ Auth Account     │
└────────┬─────────┘
         │
         ▼
┌────────────────────┐
│ Create Firestore   │
│ User Document      │
└─────────┬──────────┘
          │
     ┌────┴────┐
     │         │
 USER│         │VENDOR
     ▼         ▼
┌─────────┐  ┌──────────┐
│ Vehicle │  │ Parking  │
│  Reg.   │  │ Lot Reg. │
└────┬────┘  └─────┬────┘
     │             │
     └──────┬──────┘
            │
            ▼
      ┌──────────┐
      │   Main   │
      │   App    │
      └──────────┘
```

## Booking Flow with Payment

```
┌────────────────┐
│ Select Parking │
└───────┬────────┘
        │
        ▼
┌────────────────┐
│  Select Hours  │
└───────┬────────┘
        │
        ▼
┌────────────────────┐
│  Calculate Amount  │
│  Hours × Rate      │
└─────────┬──────────┘
          │
          ▼
┌──────────────────────┐
│  Choose Payment      │
│  - Cash (Available)  │
│  - UPI (Coming Soon) │
│  - Card (Coming Soon)│
└──────────┬───────────┘
           │
           ▼
┌────────────────────────┐
│  Create Booking        │
│  - Link to Vehicle     │
│  - Link to Parking     │
│  - Set Status: Active  │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│  Create Payment Record │
│  - Link to Booking     │
│  - Set Method: Cash    │
│  - Set Status: Pending │
└───────────┬────────────┘
            │
            ▼
┌──────────────────────────┐
│  Update Parking Lot      │
│  Available Spaces - 1    │
└───────────┬──────────────┘
            │
            ▼
     ┌──────────────┐
     │   Show       │
     │ Confirmation │
     └──────────────┘
```

## State Management

```
┌─────────────────────────────────────┐
│        @Published Properties        │
│  - Automatic UI updates             │
│  - Reactive data binding            │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│         @AppStorage                 │
│  - User ID persistence              │
│  - User Role persistence            │
│  - Welcome screen flag              │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│      Firestore Documents            │
│  - Long-term data storage           │
│  - Cross-device sync                │
└─────────────────────────────────────┘
```

## Key Components Interaction

```
┌──────────────┐     ┌──────────────┐
│ TopNavView   │────▶│ FirestoreMan.│
│ (Vehicle)    │     │(Load Vehicle)|
└──────────────┘     └──────────────┘

┌──────────────┐     ┌──────────────┐
│ SearchView   │────▶│ ParkingFinder│
│              │     │(Filter Lots) │
└──────────────┘     └──────────────┘

┌──────────────┐     ┌──────────────┐
│ PaymentView  │────▶│ FirestoreMan.│
│              │     │(Create Book.)|
└──────────────┘     └──────────────┘

┌──────────────┐     ┌──────────────┐
│ VendorDash.  │────▶│ FirestoreMan.│
│              │     │ (Fetch Lots) │
└──────────────┘     └──────────────┘
```

---

## Navigation Hierarchy

```
App Root
├── AuthView
│   ├── LoginView
│   └── SignupView
│       └── Role Selection
│
├── User Flow
│   ├── VehicleRegistrationView (if no vehicle)
│   └── UserMainView (Map)
│       ├── TopNavigationView
│       ├── SideMenuView
│       ├── ParkingCardView
│       ├── SearchView
│       └── ParkingDetailView
│           ├── ParkingInfoView
│           ├── HourChangeView
│           └── PaymentView
│
└── Vendor Flow
    ├── VendorRegistrationView (if no lots)
    └── VendorDashboardView
        ├── Stats Display
        ├── Lots List
        └── VendorEditParkingLotView
```

---

**This visual guide helps understand the complete app flow and architecture!** 📊
