# UI Flow Diagrams

## VehicleRegistrationView - Before and After

### BEFORE (Color Issue):
```
┌──────────────────────────────────┐
│  Add Your Vehicle (BLACK)        │  ← Hard to see on white
│  Register your vehicle...        │  ← Gray on white (poor contrast)
│                                  │
│  Vehicle Number                  │  ← Black text (OK)
│  [GJ01AE7828          ]         │
│                                  │
│  Model                          │  ← Black text (OK)
│  [Swift               ]         │
│                                  │
│  [Save Vehicle]                 │
│  [Skip for Now]                 │  ← Gray text (poor contrast)
└──────────────────────────────────┘
Background: Color.white (hardcoded)
```

### AFTER (Fixed):
```
┌──────────────────────────────────┐
│  Add Your Vehicle                │  ← Color.theme.textPrimary (visible)
│  Register your vehicle...        │  ← Color.theme.textSecondary (good contrast)
│                                  │
│  Vehicle Number                  │  ← Color.theme.textPrimary (visible)
│  [GJ01AE7828          ]         │
│                                  │
│  Model                          │  ← Color.theme.textPrimary (visible)
│  [Swift               ]         │
│                                  │
│  [Save Vehicle]                 │
│  [Skip for Now]*                │  ← Color.theme.textSecondary (visible)
└──────────────────────────────────┘
Background: Color.theme.background (adaptive)
*Only shown if isOptional = true
```

## New User Flow

### Step 1: User Signs Up
```
┌──────────────────────────────────┐
│         Welcome!                 │
│                                  │
│  Email: user@example.com        │
│  Password: ••••••••             │
│                                  │
│  [Sign Up]                      │
└──────────────────────────────────┘
```

### Step 2: Mandatory Vehicle Registration (NEW)
```
┌──────────────────────────────────┐
│  Add Your Vehicle ✓              │
│  Register your vehicle details   │
│                                  │
│  Vehicle Number *                │
│  [GJ01AB1234        ]           │
│                                  │
│  Model *                        │
│  [Swift             ]           │
│                                  │
│  Manufacturer (Optional)         │
│  [Maruti            ]           │
│                                  │
│  Color (Optional)                │
│  [White             ]           │
│                                  │
│  [Save Vehicle]                 │
│  (No Skip button for new users)  │
└──────────────────────────────────┘
Cannot be dismissed - must add vehicle!
```

### Step 3: Access Main App
```
┌──────────────────────────────────┐
│  ☰    My car          🚗        │
│       GJ01AB1234                │
│  ┌────────────────────────────┐ │
│  │ Map with parking spots     │ │
│  │         📍 ₹100            │ │
│  │    📍 ₹80    📍 ₹120       │ │
│  └────────────────────────────┘ │
│  [Search for Parking]           │
└──────────────────────────────────┘
```

## My Vehicles Screen (NEW)

### When Vehicles Exist:
```
┌──────────────────────────────────┐
│ ✕  My Vehicles               +  │
│                                  │
│ ┌────────────────────────────┐  │
│ │ GJ01AB1234        ✓ Active │  │
│ │ Swift                      │  │
│ │ Maruti                     │  │
│ │ ● White                    │  │
│ │ ─────────────────────────  │  │
│ │ ✏️ Edit          🗑️ Delete  │  │
│ └────────────────────────────┘  │
│                                  │
│ ┌────────────────────────────┐  │
│ │ MH02XY5678                 │  │
│ │ City                       │  │
│ │ Honda                      │  │
│ │ ● Black                    │  │
│ │ ─────────────────────────  │  │
│ │ ✓ Set Active ✏️ Edit 🗑️ Delete│ │
│ └────────────────────────────┘  │
└──────────────────────────────────┘
```

### Empty State:
```
┌──────────────────────────────────┐
│ ✕  My Vehicles                   │
│                                  │
│                                  │
│           🚗                     │
│                                  │
│      No Vehicles                │
│                                  │
│  Add your first vehicle to      │
│  start booking parking           │
│                                  │
│      [Add Vehicle]              │
│                                  │
└──────────────────────────────────┘
```

## Edit Vehicle Screen (NEW)
```
┌──────────────────────────────────┐
│  Edit Vehicle                    │
│  Update your vehicle details     │
│                                  │
│  Vehicle Number *                │
│  [GJ01AB1234        ]           │
│                                  │
│  Model *                        │
│  [Swift             ]           │
│                                  │
│  Manufacturer (Optional)         │
│  [Maruti            ]           │
│                                  │
│  Color (Optional)                │
│  [Red               ]  ← Changed │
│                                  │
│  [Update Vehicle]               │
│  [Cancel]                       │
└──────────────────────────────────┘
```

## Side Menu Integration

### Before:
```
┌──────────────────────────────────┐
│  U                          ✕   │
│  user@example.com               │
│  ─────────────────────────────  │
│  👤 My Profile                  │
│  🕐 My Bookings                 │
│  🚗 My Vehicles  (no action)    │
│  ⚙️  Settings                   │
│                                  │
│  ➡️  Sign out                   │
└──────────────────────────────────┘
```

### After:
```
┌──────────────────────────────────┐
│  U                          ✕   │
│  user@example.com               │
│  ─────────────────────────────  │
│  👤 My Profile                  │
│  🕐 My Bookings                 │
│  🚗 My Vehicles ← Opens sheet!  │
│  ⚙️  Settings                   │
│                                  │
│  ➡️  Sign out                   │
└──────────────────────────────────┘
```

## Vehicle Management Actions

### Set Active Vehicle:
```
User taps "Set Active" on vehicle
    ↓
All vehicles deactivated
    ↓
Selected vehicle activated
    ↓
currentVehicle updated in FirestoreManager
    ↓
UI updates immediately (green checkmark)
    ↓
TopNavigationView shows new vehicle number
```

### Delete Vehicle:
```
User taps "Delete" on vehicle
    ↓
Confirmation dialog appears
    ↓
User confirms deletion
    ↓
Vehicle removed from Firestore
    ↓
If deleted vehicle was active:
    currentVehicle = nil
    ↓
Vehicle list refreshes
```

### Edit Vehicle:
```
User taps "Edit" on vehicle
    ↓
EditVehicleView appears with current data
    ↓
User modifies fields
    ↓
Taps "Update Vehicle"
    ↓
Vehicle updated in Firestore
    ↓
If vehicle was active:
    currentVehicle updated
    ↓
Success message → Dismisses
    ↓
Vehicle list refreshes with new data
```

## Color Scheme Compliance

### Light Mode:
- Background: White (#FFFFFF)
- Primary Text: Black (#000000)
- Secondary Text: Dark Gray (#4A4A4A)
- Cards: White with shadow

### Dark Mode:
- Background: Black (#000000)
- Primary Text: White (#FFFFFF)
- Secondary Text: Light Gray (#B8B8B8)
- Cards: Dark Gray (#1C1C1E)

All views automatically adapt between modes using `Color.theme.*` properties.

## Key Improvements

1. ✅ **Visibility**: All text readable in both light and dark modes
2. ✅ **Mandatory Flow**: New users must add vehicle
3. ✅ **Complete CRUD**: Create, Read, Update, Delete vehicles
4. ✅ **Active Management**: Switch between vehicles easily
5. ✅ **User Feedback**: Success/error messages for all actions
6. ✅ **Consistent Design**: All views follow app design language
7. ✅ **Safety**: Confirmation before deletion
8. ✅ **State Sync**: currentVehicle always reflects reality

## Testing Checklist

- [ ] New user signup → vehicle registration appears
- [ ] Cannot dismiss vehicle registration without adding
- [ ] Added vehicle appears in TopNavigationView
- [ ] Side menu → My Vehicles opens sheet
- [ ] Can add multiple vehicles
- [ ] Can switch active vehicle
- [ ] Active vehicle shown with checkmark
- [ ] Can edit vehicle details
- [ ] Changes reflect immediately
- [ ] Can delete vehicle with confirmation
- [ ] Deleting active vehicle clears currentVehicle
- [ ] All text visible in light mode
- [ ] All text visible in dark mode
