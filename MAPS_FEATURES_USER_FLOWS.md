# Maps Features - User Flow Diagrams

## Flow 1: App Launch with Location

```
┌─────────────────────────────────────────────────────────────┐
│                      USER OPENS APP                         │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│           Location Permission Request (if needed)           │
│  "Allow 'ParkingApp' to use your location while using?"    │
│                                                              │
│           [Don't Allow]    [Allow Once]    [Allow]          │
└─────────────────────────┬───────────────────────────────────┘
                          │ (User allows)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    MAP VIEW LOADS                           │
│  ┌────────────────────────────────────────────────────┐    │
│  │                                                      │    │
│  │    🅿️ ($30)                                         │    │
│  │                      🗺️ Map                         │    │
│  │                                                      │    │
│  │                🔵 (User Location - Blue Dot)        │    │
│  │                                                      │    │
│  │         🅿️ ($40)                                    │    │
│  │                                                      │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│             NEAREST PARKING AUTO-SELECTED                   │
│  ╔══════════════════════════════════════════════════════╗  │
│  ║  AMC Multilevel Parking - Navrangpura                ║  │
│  ║  Navrangpura, Ahmedabad, Gujarat                     ║  │
│  ║                                                       ║  │
│  ║  🚗 200    ₹30.00/h    📍 450 m                      ║  │
│  ╚══════════════════════════════════════════════════════╝  │
│                                                              │
│  🔍 Search For Parking                              >       │
└─────────────────────────────────────────────────────────────┘
```

## Flow 2: Searching for Parking

```
┌─────────────────────────────────────────────────────────────┐
│                    MAIN MAP VIEW                            │
│                                                              │
│  🔍 [Search For Parking]                            >       │
└─────────────────────────┬───────────────────────────────────┘
                          │ (User taps search)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   SEARCH VIEW OPENS                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  🔍 Search by name or address...               ✕    │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  Results sorted by distance:                                │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ AMC Parking - Navrangpura                          │    │
│  │ Navrangpura, Ahmedabad...                          │    │
│  │ 🚗 200 spaces        ₹30/h        📍 450 m         │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Sabarmati Riverfront Parking                       │    │
│  │ Opposite Atal Bridge...                            │    │
│  │ 🚗 1700 spaces       ₹50/h        📍 1.2 km        │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Kankaria Parking                                   │    │
│  │ Near Gate No 3...                                  │    │
│  │ 🚗 250 spaces        ₹40/h        📍 2.5 km        │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────┬───────────────────────────────────┘
                          │ (User taps result)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              MAP CENTERS ON SELECTED SPOT                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │                                                      │    │
│  │                  🗺️ Map                             │    │
│  │                                                      │    │
│  │         🅿️ ($50) ← SELECTED & HIGHLIGHTED          │    │
│  │                                                      │    │
│  │    🔵 (User Location)                               │    │
│  │                                                      │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ╔══════════════════════════════════════════════════════╗  │
│  ║  Sabarmati Riverfront Parking                        ║  │
│  ║  Opposite Atal Bridge, Sabarmati Riverfront          ║  │
│  ║                                                       ║  │
│  ║  🚗 1700    ₹50.00/h    📍 1.2 km                    ║  │
│  ╚══════════════════════════════════════════════════════╝  │
└─────────────────────────────────────────────────────────────┘
```

## Flow 3: Booking and Getting Directions

```
┌─────────────────────────────────────────────────────────────┐
│                  PARKING CARD VIEW                          │
│  ╔══════════════════════════════════════════════════════╗  │
│  ║  AMC Parking - Navrangpura                           ║  │
│  ║  Navrangpura, Ahmedabad                              ║  │
│  ║  🚗 200    ₹30.00/h    📍 450 m                      ║  │
│  ╚══════════════════════════════════════════════════════╝  │
└─────────────────────────┬───────────────────────────────────┘
                          │ (User taps card)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│               PARKING DETAIL VIEW OPENS                     │
│  ┌────────────────────────────────────────────────────┐    │
│  │              🗺️ Mini Map                           │    │
│  │                  🅿️ ($30)                          │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  AMC Multilevel Parking - Navrangpura                       │
│  📍 Navrangpura, Ahmedabad, Gujarat                         │
│  ⏰ Open 24 Hours                                           │
│  🚗 Available: 200 spaces                                   │
│                                                              │
│  Duration: [  🕐  ] 2.0 hours                               │
│                                                              │
│  ₹60.00                    [    Book Now    ]               │
│  2.0 hours                                                  │
└─────────────────────────┬───────────────────────────────────┘
                          │ (User clicks Book Now)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                 PAYMENT OPTIONS                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │              Payment Summary                        │    │
│  │  Duration:                           2.0 hours      │    │
│  │  Rate:                               ₹30.00/hour    │    │
│  │  ─────────────────────────────────────────────────  │    │
│  │  Total Amount:                       ₹60.00         │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  Select Payment Method                                      │
│  ┌────────────────────────────────────────────────────┐    │
│  │  💵 Cash                                      ✓    │    │
│  └────────────────────────────────────────────────────┘    │
│  ┌────────────────────────────────────────────────────┐    │
│  │  📱 UPI                           Coming Soon       │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│              [    Confirm Booking    ]                      │
└─────────────────────────┬───────────────────────────────────┘
                          │ (Booking successful)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              BOOKING CONFIRMATION ALERT                     │
│  ┌────────────────────────────────────────────────────┐    │
│  │         Booking Confirmed! ✓                        │    │
│  │                                                      │    │
│  │  Your parking space has been booked successfully!   │    │
│  │  Tap 'Get Directions' to navigate to the parking    │    │
│  │  spot.                                               │    │
│  │                                                      │    │
│  │         [Get Directions]        [OK]                │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────┬───────────────────────────────────┘
                          │ (User taps Get Directions)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              BACK TO DETAIL VIEW                            │
│                                                              │
│  "Get Directions" button now visible:                       │
│                                                              │
│  ₹60.00              [  🧭  Directions  ]                   │
│  2.0 hours                                                  │
└─────────────────────────┬───────────────────────────────────┘
                          │ (User taps Directions)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│               APPLE MAPS OPENS                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │                                                      │    │
│  │    🔵 Your Location                                 │    │
│  │     │                                                │    │
│  │     │ ➡️ Turn right onto Main St                    │    │
│  │     │                                                │    │
│  │     │ ➡️ Continue for 0.3 km                        │    │
│  │     │                                                │    │
│  │     └──➡️                                            │    │
│  │           🅿️ Destination                            │    │
│  │           AMC Parking - Navrangpura                  │    │
│  │                                                      │    │
│  │  ⏱️ 8 min (450 m)                    [   Start   ]  │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Flow 4: Distance-Based Features

### When User is Close (< 1 km)

```
Card Display:
╔══════════════════════════════════════════════════════╗
║  AMC Parking - Navrangpura                           ║
║  Navrangpura, Ahmedabad                              ║
║  🚗 200    ₹30.00/h    📍 450 m    ← METERS          ║
╚══════════════════════════════════════════════════════╝

Search Result:
┌────────────────────────────────────────────────────┐
│ AMC Parking - Navrangpura                          │
│ Navrangpura, Ahmedabad...                          │
│ 🚗 200 spaces        ₹30/h        📍 450 m         │
└────────────────────────────────────────────────────┘
```

### When User is Far (≥ 1 km)

```
Card Display:
╔══════════════════════════════════════════════════════╗
║  Sabarmati Riverfront Parking                        ║
║  Opposite Atal Bridge, Sabarmati...                  ║
║  🚗 1700    ₹50.00/h    📍 2.5 km   ← KILOMETERS     ║
╚══════════════════════════════════════════════════════╝

Search Result:
┌────────────────────────────────────────────────────┐
│ Sabarmati Riverfront Parking                       │
│ Opposite Atal Bridge, Sabarmati...                 │
│ 🚗 1700 spaces       ₹50/h        📍 2.5 km        │
└────────────────────────────────────────────────────┘
```

## Flow 5: Map Interaction States

### State 1: Initial Load
```
- Blue dot appears at user location
- Map centered on user
- Nearest parking spot auto-selected
- Card shows nearest spot with distance
```

### State 2: User Selects Different Spot
```
- User taps parking annotation on map
- Selection changes (previous spot deselected)
- Card updates to show new spot
- Distance updated for new spot
```

### State 3: User Searches
```
- Search sheet opens
- Results sorted by distance
- User can see all options
- Each shows distance from current location
```

### State 4: After Search Selection
```
- Map centers on selected spot
- Selected spot highlighted
- Card shows selected spot details
- User can proceed to book
```

### State 5: After Booking
```
- "Get Directions" button available
- User can navigate to parking spot
- Apple Maps provides turn-by-turn directions
```

## Key Interactions Summary

| Action | Result |
|--------|--------|
| 📍 **Location Permission Granted** | Blue dot appears, nearest spot selected |
| 🔍 **Search Button Tap** | Opens search with sorted results |
| 📝 **Search Result Tap** | Map centers, spot selected, card updates |
| 🎯 **Map Annotation Tap** | Spot selected, card updates |
| 🎫 **Book Now Tap** | Opens payment flow |
| ✅ **Booking Success** | "Get Directions" button appears |
| 🧭 **Directions Tap** | Opens Apple Maps with navigation |

## Distance Display Logic

```
Distance Calculation:
    CLLocation.distance(from:)
           ↓
    Returns meters (Double)
           ↓
    Formatting Logic:
           ↓
    ┌──────┴──────┐
    │             │
distance < 1000   distance ≥ 1000
    │             │
    ▼             ▼
"XXX m"       "X.X km"
```

## Auto-Selection Priority

```
When location updates:
    1. Check if user has manually selected a spot
       ├─ YES → Keep current selection
       └─ NO  → Auto-select nearest
    
    2. Calculate distances to all spots
    
    3. Sort by distance
    
    4. Select first (nearest) spot
    
    5. Update card view
```

## Error Handling

### No Location Permission
```
┌─────────────────────────────────────────┐
│  Location Permission Denied             │
│                                          │
│  - Map shows default view               │
│  - No blue dot                          │
│  - No distance calculations             │
│  - No auto-selection                    │
│  - User can still search and book       │
└─────────────────────────────────────────┘
```

### No Parking Spots Found
```
┌─────────────────────────────────────────┐
│  No Parking Spots Available             │
│                                          │
│  "No parking spots available"           │
│  "Please check back later"              │
└─────────────────────────────────────────┘
```

### Location Not Yet Determined
```
┌─────────────────────────────────────────┐
│  Determining Location...                │
│                                          │
│  - Shows loading state                  │
│  - Distances not yet shown              │
│  - First spot selected as fallback      │
└─────────────────────────────────────────┘
```

## Platform Integration

### Apple Maps URL Scheme
```
http://maps.apple.com/
    ?daddr=<latitude>,<longitude>    ← Destination
    &dirflg=d                         ← Driving mode
    &t=m                              ← Map type
    &q=<parking_name>                 ← Location name
```

### Supported Navigation Apps
- ✅ Apple Maps (default)
- ⚠️ Google Maps (via system setting)
- ⚠️ Waze (via system setting)

*Note: When user has set a different default maps app in iOS settings, the URL will open that app instead.*
