# My Bookings Feature - Visual Flow Diagram

## Screen Hierarchy

```
┌─────────────────────────────────────┐
│         Side Menu                    │
│  ┌────────────────────────────────┐ │
│  │ My Profile                     │ │
│  │ → My Bookings     ←────────────┼─┼─ Opens Modal Sheet
│  │ My Vehicles                    │ │
│  │ Settings                       │ │
│  └────────────────────────────────┘ │
└─────────────────────────────────────┘

                ↓ Opens

┌─────────────────────────────────────────────────┐
│        UserBookingsView (Modal Sheet)           │
│                                                  │
│  ┌─────────────────────────────────────────┐   │
│  │ Pending (2) │ Active (1) │ Previous (5) │   │
│  └─────────────────────────────────────────┘   │
│                                                  │
│  [Tab-specific content shown below]             │
│                                                  │
└─────────────────────────────────────────────────┘
```

## Tab Views

### 1. Pending Tab (Orange)
```
┌───────────────────────────────────────────┐
│ Pending Bookings                          │
├───────────────────────────────────────────┤
│ ┌───────────────────────────────────────┐ │
│ │ Downtown Parking    [⌚ PENDING]      │ │
│ │ Booking #a1b2c3d4                     │ │
│ │                                       │ │
│ │ 📅 Oct 13, 2025, 8:30 AM             │ │
│ │ ⏰ 2 hours planned                    │ │
│ │ ₹ ₹100                                │ │
│ │ 🚗 KA-01-AB-1234                      │ │
│ └───────────────────────────────────────┘ │
│                                           │
│ Status: Awaiting vendor confirmation     │
└───────────────────────────────────────────┘
```

### 2. Active Tab (Blue)
```
┌───────────────────────────────────────────┐
│ Active Bookings                           │
├───────────────────────────────────────────┤
│ ┌───────────────────────────────────────┐ │
│ │ Mall Parking        [🔵 ACTIVE]       │ │
│ │ Booking #e5f6g7h8                     │ │
│ │                                       │ │
│ │ 📅 Oct 13, 2025, 9:00 AM             │ │
│ │ ⏰ 3 hours planned                    │ │
│ │ ₹ ₹150                                │ │
│ │ 🚗 KA-02-CD-5678                      │ │
│ │                                       │ │
│ │ ╔═══════════════════════════════════╗ │ │
│ │ ║ Parking Session                   ║ │ │
│ │ ║                                   ║ │ │
│ │ ║ ⏱️  02:15:43        Ends at 12:00 PM│ │
│ │ ╚═══════════════════════════════════╝ │ │
│ └───────────────────────────────────────┘ │
│                                           │
│ Timer updates every second               │
└───────────────────────────────────────────┘
```

### 2b. Active Tab - Overtime (Blue + Orange Warning)
```
┌───────────────────────────────────────────┐
│ Active Bookings                           │
├───────────────────────────────────────────┤
│ ┌───────────────────────────────────────┐ │
│ │ Airport Parking     [🔵 ACTIVE]       │ │
│ │ Booking #i9j0k1l2                     │ │
│ │                                       │ │
│ │ 📅 Oct 13, 2025, 6:00 AM             │ │
│ │ ⏰ 2 hours planned                    │ │
│ │ ₹ ₹100                                │ │
│ │ 🚗 KA-03-EF-9012                      │ │
│ │                                       │ │
│ │ ╔═══════════════════════════════════╗ │ │
│ │ ║ Parking Session                   ║ │ │
│ │ ║                                   ║ │ │
│ │ ║ ⏱️  02:45:12        Ended at 8:00 AM│ │
│ │ ║                                   ║ │ │
│ │ ║ ⚠️  Overtime - Late fees apply    ║ │ │
│ │ ╚═══════════════════════════════════╝ │ │
│ └───────────────────────────────────────┘ │
└───────────────────────────────────────────┘
```

### 3. Previous Tab (Green/Red)
```
┌───────────────────────────────────────────┐
│ Previous Bookings                         │
├───────────────────────────────────────────┤
│ ┌───────────────────────────────────────┐ │
│ │ City Center Parking [✅ COMPLETED]    │ │
│ │ Booking #m3n4o5p6                     │ │
│ │                                       │ │
│ │ 📅 Oct 12, 2025, 10:00 AM            │ │
│ │ ⏰ 2 hours planned                    │ │
│ │ ₹ ₹100                                │ │
│ │ 🚗 KA-01-AB-1234                      │ │
│ │                                       │ │
│ │ ────────────────────────────          │ │
│ │ Actual Duration:         2.5 hours    │ │
│ │ Late Fee:                ₹25          │ │
│ │ Completed:   Oct 12, 2025, 12:30 PM  │ │
│ └───────────────────────────────────────┘ │
│                                           │
│ ┌───────────────────────────────────────┐ │
│ │ Beach Parking       [❌ CANCELLED]    │ │
│ │ Booking #q7r8s9t0                     │ │
│ │                                       │ │
│ │ 📅 Oct 11, 2025, 3:00 PM             │ │
│ │ ⏰ 1 hour planned                     │ │
│ │ ₹ ₹50                                 │ │
│ │ 🚗 KA-02-CD-5678                      │ │
│ │                                       │ │
│ │ ────────────────────────────          │ │
│ │ ℹ️  Declined by vendor - Slot full    │ │
│ └───────────────────────────────────────┘ │
└───────────────────────────────────────────┘
```

## Booking Lifecycle Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    USER CREATES BOOKING                          │
│                    (From Parking Detail View)                    │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
            ┌────────────────────────┐
            │   Firebase Firestore   │
            │   bookings collection  │
            │   status: "pending"    │
            └────────────┬───────────┘
                         │
                         ├──────────────────────────────────┐
                         ↓                                  ↓
            ┌─────────────────────┐           ┌──────────────────────┐
            │   USER DEVICE       │           │   VENDOR DEVICE      │
            │   Snapshot Listener │           │   Snapshot Listener  │
            │   → Shows in        │           │   → Push Notification│
            │     PENDING Tab 🟠  │           │   → Booking appears  │
            └─────────────────────┘           └──────────────────────┘
                                                         │
                         ┌───────────────────────────────┴──────┐
                         ↓                                      ↓
              ┌────────────────────┐              ┌──────────────────────┐
              │ VENDOR ACCEPTS     │              │ VENDOR DECLINES      │
              │ status: "active"   │              │ status: "cancelled"  │
              │ acceptedAt: now()  │              │ cancelledAt: now()   │
              └─────────┬──────────┘              └─────────┬────────────┘
                        │                                    │
                        ↓                                    ↓
           ┌──────────────────────┐            ┌──────────────────────┐
           │ USER DEVICE          │            │ USER DEVICE          │
           │ → Shows in           │            │ → Moves to           │
           │   ACTIVE Tab 🔵      │            │   PREVIOUS Tab 🔴    │
           │ → Timer starts       │            │ → Shows reason       │
           │ → Updates every 1s   │            └──────────────────────┘
           └──────────┬───────────┘
                      │
                      │ (Parking in progress...)
                      │
                      ↓
           ┌───────────────────────┐
           │ USER LEAVES & PAYS    │
           │ VENDOR COMPLETES      │
           │                       │
           │ Calculate:            │
           │ - actualHours         │
           │ - lateFeeAmount       │
           │                       │
           │ status: "completed"   │
           │ completedAt: now()    │
           │ paymentConfirmedAt    │
           └──────────┬────────────┘
                      │
                      ↓
           ┌──────────────────────┐
           │ USER DEVICE          │
           │ → Moves to           │
           │   PREVIOUS Tab ✅    │
           │ → Shows late fees    │
           │ → Shows actual time  │
           └──────────────────────┘
                      │
                      ↓
           ┌──────────────────────┐
           │ PARKING SLOT FREED   │
           │ availableSpaces += 1 │
           └──────────────────────┘
```

## Real-Time Synchronization

```
┌────────────────────┐
│  Firebase Cloud    │
│  Firestore         │
└─────────┬──────────┘
          │
          │ Snapshot Listeners (Real-time)
          │
    ┌─────┴─────┐
    ↓           ↓
┌────────┐   ┌────────┐
│ USER   │   │ VENDOR │
│ Device │   │ Device │
└────────┘   └────────┘

Updates propagate in < 1 second

Example Flows:
─────────────

1. Vendor Accepts Booking
   Vendor taps "Accept" → Firestore update → User sees "Active" 
   Time: ~500ms

2. Booking Completed
   Vendor marks complete → Firestore update → User sees "Previous"
   Time: ~500ms

3. Timer Updates
   Local only, no network needed
   Updates: Every 1 second
```

## State Machine

```
     ┌─────────┐
     │ PENDING │ ←────── Initial state after booking
     └────┬────┘
          │
    ┌─────┴─────┐
    │           │
    ↓           ↓
┌────────┐   ┌───────────┐
│ ACTIVE │   │ CANCELLED │ ←────── Terminal state
└───┬────┘   └───────────┘
    │
    ↓
┌───────────┐
│ COMPLETED │ ←────── Terminal state
└───────────┘

State Transitions:
─────────────────
PENDING → ACTIVE     : Vendor accepts
PENDING → CANCELLED  : Vendor declines
ACTIVE  → COMPLETED  : Payment confirmed & vehicle released
ACTIVE  → CANCELLED  : (Future: User/Vendor cancels active booking)
```

## Component Architecture

```
┌──────────────────────────────────────────────┐
│           UserBookingsView                   │
│  ┌────────────────────────────────────────┐  │
│  │      UserBookingsViewModel             │  │
│  │  - bookings: [Booking]                 │  │
│  │  - isLoading: Bool                     │  │
│  │  - loadBookings()                      │  │
│  │  - Real-time listener                  │  │
│  └─────────────────┬──────────────────────┘  │
│                    │ Uses                     │
│  ┌─────────────────▼──────────────────────┐  │
│  │     FirestoreManager.shared            │  │
│  │  - Firestore queries                   │  │
│  │  - completeBooking()                   │  │
│  └─────────────────┬──────────────────────┘  │
│                    │ Updates                  │
│  ┌─────────────────▼──────────────────────┐  │
│  │        Booking Model                   │  │
│  │  - id, userId, parkingLotId            │  │
│  │  - status, duration, amount            │  │
│  │  - completedAt, lateFeeAmount          │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  UI Components:                              │
│  ┌────────────────────────────────────────┐  │
│  │     UserBookingCard                    │  │
│  │  - Shows booking details               │  │
│  │  - Real-time timer (if active)         │  │
│  │  - Status badge                        │  │
│  │  - Late fee display (if completed)     │  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

## Integration Points

```
┌─────────────────┐
│  Side Menu      │
│  "My Bookings"  │
└────────┬────────┘
         │ Opens
         ↓
┌─────────────────────┐
│ UserBookingsView    │ ←───── Real-time updates from Firestore
└─────────┬───────────┘
          │ Displays
          ↓
┌─────────────────────┐
│ Booking Data        │ ←───── Synced with VendorBookingsView
│ - Pending           │
│ - Active            │
│ - Previous          │
└─────────────────────┘
```

## Empty State Examples

### Pending Tab - Empty
```
┌───────────────────────────────┐
│                               │
│         🕐                    │
│     (Large icon)              │
│                               │
│  No Pending Bookings          │
│                               │
│  Bookings awaiting vendor     │
│  confirmation will appear here│
│                               │
└───────────────────────────────┘
```

### Active Tab - Empty
```
┌───────────────────────────────┐
│                               │
│         ⏱️                     │
│     (Large icon)              │
│                               │
│  No Active Bookings           │
│                               │
│  Your active parking sessions │
│  will be shown here           │
│                               │
└───────────────────────────────┘
```

### Previous Tab - Empty
```
┌───────────────────────────────┐
│                               │
│         ✅                    │
│     (Large icon)              │
│                               │
│  No Previous Bookings         │
│                               │
│  Completed and cancelled      │
│  bookings will be listed here │
│                               │
└───────────────────────────────┘
```
