# My Bookings - Quick Reference Guide

## 📱 For Users

### How to Access
1. Open side menu (swipe from left or tap hamburger icon)
2. Tap "My Bookings"
3. View bookings in three tabs

### Understanding Status Badges

| Badge | Color | Meaning |
|-------|-------|---------|
| 🟠 PENDING | Orange | Waiting for vendor to accept |
| 🔵 ACTIVE | Blue | Currently parking (timer running) |
| 🟢 COMPLETED | Green | Successfully finished |
| 🔴 CANCELLED | Red | Declined or cancelled |

### Tab Guide

#### Pending Tab
- **What it shows**: Bookings awaiting vendor confirmation
- **What to do**: Wait for vendor to accept or decline
- **Updates**: Real-time when vendor responds

#### Active Tab
- **What it shows**: Current parking session
- **Timer**: Shows elapsed time (HH:MM:SS)
- **End time**: When parking should end
- **Warning**: Orange alert if you go overtime
- **What to do**: Return before end time to avoid late fees

#### Previous Tab
- **What it shows**: Completed and cancelled bookings
- **Details shown**:
  - Actual duration
  - Late fees (if any)
  - Completion/cancellation date
- **Use for**: History and receipt records

## 👨‍💼 For Vendors

### What Happens When You Accept/Decline

**Accept Booking:**
1. Booking status → ACTIVE
2. User sees timer start immediately
3. Slot marked as occupied
4. User notified

**Decline Booking:**
1. Booking status → CANCELLED
2. User sees cancellation reason
3. Slot remains available
4. User notified

### Completing a Booking

When user leaves and pays:
1. Calculate actual parking duration
2. Calculate late fee if overtime
3. Confirm payment
4. Mark booking as COMPLETED
5. Release vehicle
6. Free up parking slot

**System automatically:**
- Calculates late fees
- Updates user's Previous tab
- Increments available spaces
- Records timestamps

## 🔧 For Developers

### Key Files

```
ParkingApp/
├── Model/
│   └── Booking.swift (enhanced)
├── Services/
│   └── FirestoreManager.swift (completeBooking method)
└── Views/
    ├── UserBookingsView.swift (new, 416 lines)
    └── SideMenuView.swift (navigation wired)
```

### New Booking Fields

```swift
completedAt: Date?        // Completion timestamp
lateFeeAmount: Double?    // Calculated late fee
paymentConfirmedAt: Date? // Payment confirmation time
```

### Complete Booking Method

```swift
FirestoreManager.shared.completeBooking(
    bookingId: "booking-id",
    actualHours: 2.5,
    hourlyRate: 50.0,
    lateFeeRate: 75.0
)
```

### Real-time Listener Setup

```swift
Firestore.firestore()
    .collection("bookings")
    .whereField("userId", isEqualTo: userId)
    .order(by: "createdAt", descending: true)
    .addSnapshotListener { snapshot, error in
        // Handle updates
    }
```

## 🎨 UI Components

### UserBookingsView
- Main container with tab selector
- Three filtered views
- Loading and error states

### UserBookingCard
- Status badge (top right)
- Booking details (center)
- Timer section (if active)
- Completion details (if previous)

### Timer Display
- Format: `HH:MM:SS`
- Updates: Every 1 second
- Color: Blue (primary)
- Position: Below booking details

## 📊 Status Flow

```
CREATE → PENDING → ACTIVE → COMPLETED
                     ↓
                 CANCELLED
```

### Transitions

| From | To | Trigger | Who |
|------|-----|---------|-----|
| - | PENDING | User books | User |
| PENDING | ACTIVE | Vendor accepts | Vendor |
| PENDING | CANCELLED | Vendor declines | Vendor |
| ACTIVE | COMPLETED | Payment confirmed | Vendor |

## 💡 Tips & Best Practices

### For Users
- ✅ Check active bookings regularly
- ✅ Return before end time to avoid late fees
- ✅ Keep previous bookings for records
- ⚠️ Watch for overtime warnings

### For Vendors
- ✅ Accept/decline bookings promptly
- ✅ Calculate actual hours accurately
- ✅ Confirm payment before releasing vehicle
- ⚠️ Double-check late fee calculations

### For Developers
- ✅ Test real-time sync thoroughly
- ✅ Verify Firestore indexes exist
- ✅ Monitor error logs
- ✅ Check timer performance on low-end devices
- ⚠️ Clean up listeners in deinit

## 🔍 Troubleshooting

### User doesn't see booking
- Check network connection
- Verify userId is correct
- Check Firestore security rules

### Timer not updating
- Verify booking status is ACTIVE
- Check acceptedAt field exists
- Restart app if stuck

### Late fee incorrect
- Verify actualHours is correct
- Check lateFeeRate parameter
- Verify calculation formula

### Real-time sync slow
- Check network latency
- Verify Firestore listener is active
- Check for errors in logs

## 📞 Support

### Documentation
1. **MY_BOOKINGS_FEATURE.md** - Feature overview
2. **MY_BOOKINGS_VISUAL_FLOW.md** - Visual diagrams
3. **MY_BOOKINGS_SUMMARY.md** - Complete implementation details

### Testing
- Manual testing checklist in **MY_BOOKINGS_SUMMARY.md**
- Test all three tabs
- Test real-time sync
- Test error handling

## 🚀 Quick Start (Development)

### 1. Setup
```bash
# Already integrated, no setup needed
# Just run the app
```

### 2. Test Flow
```
1. Create booking → Check Pending tab
2. Accept as vendor → Check Active tab, verify timer
3. Complete booking → Check Previous tab, verify late fee
```

### 3. Verify
- [ ] Three tabs visible
- [ ] Real-time updates work
- [ ] Timer updates every second
- [ ] Late fees calculate correctly
- [ ] Navigation opens from side menu

## 📈 Metrics to Monitor

### User Engagement
- Number of bookings per user
- Time spent in Active tab
- Frequency of checking bookings

### Performance
- Snapshot listener latency
- Timer accuracy
- UI responsiveness
- Memory usage

### Business
- Late fee revenue
- Booking completion rate
- Cancellation rate
- Average parking duration

## 🎯 Success Criteria

✅ Users can see all their bookings
✅ Status updates appear within 1 second
✅ Timer updates every second accurately
✅ Late fees calculate correctly
✅ Empty states display helpfully
✅ Navigation works smoothly
✅ Error handling is user-friendly

---

**Version**: 1.0
**Last Updated**: October 13, 2025
**Status**: Production Ready ✅
