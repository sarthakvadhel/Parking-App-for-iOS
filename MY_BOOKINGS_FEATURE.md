# My Bookings Feature Documentation

## Overview
The My Bookings page allows users to view and track their parking bookings in real-time. Bookings are categorized into three states: Pending, Active, and Previous.

## User Flow

### 1. Accessing My Bookings
- Users can access "My Bookings" from the side menu
- Opens as a modal sheet with three tabs

### 2. Booking States

#### Pending Bookings (Orange Badge)
- **Description**: Bookings awaiting vendor confirmation
- **User Action**: Wait for vendor to accept or decline
- **Status**: "Pending"
- **Info Displayed**:
  - Parking lot name
  - Booking ID (first 8 characters)
  - Booking date and time
  - Planned duration
  - Total amount
  - Vehicle number

#### Active Bookings (Blue Badge)
- **Description**: Live parking session after vendor confirmation
- **Status**: "Active"
- **Info Displayed**:
  - All pending booking info
  - **Real-time Timer**: Shows elapsed time in HH:MM:SS format
  - **Planned End Time**: When parking is expected to end
  - **Overtime Warning**: If parking exceeds planned duration
- **Timer Updates**: Every second for accurate tracking

#### Previous Bookings (Green/Red Badge)
- **Description**: Completed or cancelled bookings
- **Status**: "Completed" (green) or "Cancelled" (red)
- **Info Displayed for Completed**:
  - All standard booking info
  - Actual duration (vs planned)
  - Late fees (if overtime occurred)
  - Completion timestamp
- **Info Displayed for Cancelled**:
  - All standard booking info
  - Cancellation reason

## Booking Lifecycle

```
1. USER BOOKS SLOT
   └─> Status: PENDING (awaiting vendor)
       │
       ├─> VENDOR ACCEPTS
       │   └─> Status: ACTIVE (timer starts)
       │       └─> USER LEAVES & PAYS
       │           └─> Status: COMPLETED (in Previous)
       │
       └─> VENDOR DECLINES
           └─> Status: CANCELLED (in Previous)
```

## Real-Time Synchronization

### How It Works
- Uses Firebase Firestore snapshot listeners
- Updates propagate in near real-time (typically < 1 second)
- Both user and vendor views stay synchronized

### What Gets Synced
1. **Vendor Actions**:
   - Accept booking → User sees status change to Active
   - Decline booking → User sees status change to Cancelled
   
2. **Booking Completion**:
   - Vendor marks complete → User sees in Previous tab
   - Late fees calculated → Displayed to user
   - Parking slot freed → Available for others

3. **Status Updates**:
   - Pending count updates
   - Active count updates
   - Previous count updates

## Late Fee Calculation

### Formula
```swift
if actualHours > plannedHours {
    extraHours = actualHours - plannedHours
    lateFee = extraHours × lateFeeRate
}
```

### Example
- Planned: 2 hours @ ₹50/hour = ₹100
- Actual: 3 hours
- Late fee rate: ₹75/hour
- Extra hours: 1 hour
- Late fee: ₹75
- **Total: ₹175**

## Technical Implementation

### Models
**Enhanced Booking Model** with new fields:
- `completedAt: Date?` - Completion timestamp
- `lateFeeAmount: Double?` - Calculated late fees
- `paymentConfirmedAt: Date?` - Payment confirmation time

### Services
**FirestoreManager.completeBooking()**:
```swift
func completeBooking(
    bookingId: String,
    actualHours: Double,
    hourlyRate: Double,
    lateFeeRate: Double?
) async throws
```
- Calculates late fees automatically
- Updates booking status to completed
- Records completion and payment timestamps
- Frees parking slot for others

### Views
**UserBookingsView** components:
- `UserBookingsViewModel` - Manages booking data and real-time updates
- `UserBookingCard` - Displays booking details with status-specific UI
- Real-time timer for active bookings
- Overtime detection and warnings

## UI Features

### Active Booking Timer
- Updates every second
- Format: HH:MM:SS
- Color: Blue (primary accent)
- Shows planned end time on the right

### Overtime Warning
- Triggers when elapsed time > planned duration
- Visual: Orange warning icon + text
- Message: "Overtime - Late fees apply"
- Helps users avoid unexpected charges

### Empty States
- Custom messages for each tab
- Icon matching the tab context
- Helpful guidance for users

### Status Badges
- Pending: Orange background, white text
- Active: Blue background, white text
- Completed: Green background, white text
- Cancelled: Red background, white text

## Data Flow

### Loading Bookings
```
User Opens "My Bookings"
    ↓
UserBookingsViewModel.loadBookings()
    ↓
Firestore Query (userId filter)
    ↓
Snapshot Listener Setup
    ↓
Real-time Updates → UI Refresh
```

### Timer Updates (Active Bookings)
```
Timer fires every 1 second
    ↓
Calculate elapsed time
    ↓
Format as HH:MM:SS
    ↓
Check if overtime
    ↓
Update UI
```

## Error Handling
- Connection errors: Shows alert to user
- Missing data: Graceful fallbacks (e.g., "Unknown Parking")
- Load failures: Error message with retry option

## Accessibility
- All icons have semantic meaning
- Color-coded status badges
- Clear time formatting
- Readable font sizes
- Good contrast ratios

## Performance
- Lazy loading of booking cards
- Real-time updates only for displayed data
- Timer only runs for active bookings
- Efficient Firestore queries with proper indexing

## Future Enhancements
1. Pull-to-refresh
2. Booking details drill-down
3. Receipt generation/download
4. Push notifications for status changes
5. Dispute/Support requests
6. Booking history filters (date range)
7. Search functionality
