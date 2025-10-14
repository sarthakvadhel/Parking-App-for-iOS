# Vehicle Management Code Examples

## How to Use the New Vehicle Management System

### 1. Adding a Vehicle (from MyVehiclesView)

The system automatically handles adding vehicles through VehicleRegistrationView:

```swift
// In MyVehiclesView
.sheet(isPresented: $showAddVehicle) {
    VehicleRegistrationView()  // isOptional defaults to true
        .onDisappear {
            loadVehicles()  // Refresh list
        }
}
```

### 2. Fetching All Vehicles

```swift
// Get all vehicles for current user
Task {
    do {
        let vehicles = try await FirestoreManager.shared.fetchVehicles(userId: userID)
        // vehicles is [Vehicle]
    } catch {
        print("Error: \(error)")
    }
}
```

### 3. Getting the Active Vehicle

```swift
// Get currently active vehicle
Task {
    do {
        if let activeVehicle = try await FirestoreManager.shared.fetchActiveVehicle(userId: userID) {
            print("Active: \(activeVehicle.vehicleNumber)")
        }
    } catch {
        print("Error: \(error)")
    }
}
```

### 4. Setting a Vehicle as Active

```swift
// Switch to different vehicle
Task {
    do {
        try await FirestoreManager.shared.setActiveVehicle(vehicle, userId: userID)
        // This automatically:
        // - Deactivates all other vehicles
        // - Activates the selected vehicle
        // - Updates currentVehicle in FirestoreManager
    } catch {
        print("Error: \(error)")
    }
}
```

### 5. Updating Vehicle Details

```swift
// Modify and update vehicle
var updatedVehicle = vehicle
updatedVehicle.color = "Red"
updatedVehicle.manufacturer = "Toyota"

Task {
    do {
        try await FirestoreManager.shared.updateVehicle(updatedVehicle)
        // If this was the active vehicle, currentVehicle is updated
    } catch {
        print("Error: \(error)")
    }
}
```

### 6. Deleting a Vehicle

```swift
// Delete vehicle by ID
guard let vehicleId = vehicle.id else { return }

Task {
    do {
        try await FirestoreManager.shared.deleteVehicle(vehicleId)
        // If this was the active vehicle, currentVehicle is set to nil
    } catch {
        print("Error: \(error)")
    }
}
```

### 7. Accessing Current Vehicle

The current vehicle is available globally through FirestoreManager:

```swift
// In any view
@ObservedObject var firestoreManager = FirestoreManager.shared

// In body
Text(firestoreManager.currentVehicle?.vehicleNumber ?? "No Vehicle")
```

### 8. Making Vehicle Registration Mandatory

```swift
// For new users (cannot be dismissed)
VehicleRegistrationView(isOptional: false)
    .interactiveDismissDisabled(true)

// For existing users adding more vehicles (can be dismissed)
VehicleRegistrationView()  // or VehicleRegistrationView(isOptional: true)
```

### 9. Vehicle Card Component

The VehicleCard is reusable:

```swift
VehicleCard(
    vehicle: vehicle,
    isActive: vehicle.isActive,
    onEdit: {
        // Show edit view
    },
    onDelete: {
        // Show delete confirmation
    },
    onSetActive: {
        // Make this vehicle active
    }
)
```

### 10. Complete Example: Vehicle List with Actions

```swift
struct MyCustomVehicleView: View {
    @AppStorage("uid") var userID: String = ""
    @State private var vehicles: [Vehicle] = []
    
    var body: some View {
        List(vehicles) { vehicle in
            VStack(alignment: .leading) {
                Text(vehicle.vehicleNumber)
                    .font(.headline)
                Text(vehicle.model)
                    .font(.subheadline)
                
                HStack {
                    // Set Active
                    if !vehicle.isActive {
                        Button("Set Active") {
                            setActive(vehicle)
                        }
                    }
                    
                    // Edit
                    Button("Edit") {
                        edit(vehicle)
                    }
                    
                    // Delete
                    Button("Delete", role: .destructive) {
                        delete(vehicle)
                    }
                }
            }
        }
        .onAppear {
            loadVehicles()
        }
    }
    
    private func loadVehicles() {
        Task {
            vehicles = try await FirestoreManager.shared.fetchVehicles(userId: userID)
        }
    }
    
    private func setActive(_ vehicle: Vehicle) {
        Task {
            try await FirestoreManager.shared.setActiveVehicle(vehicle, userId: userID)
            loadVehicles()
        }
    }
    
    private func edit(_ vehicle: Vehicle) {
        // Show EditVehicleView
    }
    
    private func delete(_ vehicle: Vehicle) {
        guard let id = vehicle.id else { return }
        Task {
            try await FirestoreManager.shared.deleteVehicle(id)
            loadVehicles()
        }
    }
}
```

## Vehicle Model Structure

```swift
struct Vehicle: Codable, Identifiable {
    var id: String?              // Firestore document ID
    var userId: String           // Owner's user ID
    var vehicleNumber: String    // e.g., "GJ01AE7828"
    var model: String            // e.g., "Swift"
    var manufacturer: String?    // e.g., "Maruti" (optional)
    var color: String?           // e.g., "White" (optional)
    var imageURLs: [String]?     // Future: vehicle photos
    var isActive: Bool           // Only one vehicle can be active
    var createdAt: Date          // Creation timestamp
}
```

## Color Theming Best Practices

Always use theme colors for new views:

```swift
struct MyNewView: View {
    var body: some View {
        VStack {
            Text("Title")
                .foregroundColor(Color.theme.textPrimary)  // ✅ Good
            
            Text("Subtitle")
                .foregroundColor(Color.theme.textSecondary)  // ✅ Good
            
            Image(systemName: "icon")
                .foregroundColor(Color.theme.iconSecondary)  // ✅ Good
        }
        .background(Color.theme.background)  // ✅ Good
    }
}
```

Don't use hardcoded colors:

```swift
// ❌ Bad - Poor contrast, no dark mode support
Text("Title").foregroundColor(.black)
Text("Subtitle").foregroundColor(.gray)
VStack { }.background(Color.white)
```

## Error Handling Pattern

Follow this pattern for Firestore operations:

```swift
@State private var showError = false
@State private var errorMessage = ""

private func someFirestoreOperation() {
    Task {
        do {
            // Perform operation
            try await FirestoreManager.shared.someMethod()
            
            // Success handling
            await MainActor.run {
                // Update UI
            }
        } catch {
            // Error handling
            await MainActor.run {
                errorMessage = "Operation failed: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}

// In view
.alert("Error", isPresented: $showError) {
    Button("OK", role: .cancel) {}
} message: {
    Text(errorMessage)
}
```

## State Management Pattern

Use @ObservedObject for shared state:

```swift
@ObservedObject var firestoreManager = FirestoreManager.shared

// Automatically updates when currentVehicle changes
Text(firestoreManager.currentVehicle?.vehicleNumber ?? "No Vehicle")
```

Use @State for local view state:

```swift
@State private var isLoading = false
@State private var vehicles: [Vehicle] = []
```

## Navigation Patterns

### Sheet Presentation (Modal):
```swift
.sheet(isPresented: $showSheet) {
    MyModalView()
}
```

### Full Screen Cover:
```swift
.fullScreenCover(isPresented: $showFullScreen) {
    MyFullScreenView()
}
```

### Navigation Link (Push):
```swift
NavigationLink(destination: MyDetailView()) {
    Text("Go to Detail")
}
```

## Loading States

Show loading indicators during async operations:

```swift
if isLoading {
    ProgressView("Loading...")
        .foregroundColor(Color.theme.textSecondary)
} else {
    // Content
}
```

## Empty States

Always show helpful empty states:

```swift
if items.isEmpty {
    VStack(spacing: 20) {
        Image(systemName: "icon")
            .font(.system(size: 60))
            .foregroundColor(Color.theme.iconSecondary)
        
        Text("No Items")
            .font(.title2)
            .foregroundColor(Color.theme.textPrimary)
        
        Text("Add your first item to get started")
            .foregroundColor(Color.theme.textSecondary)
        
        Button("Add Item") {
            // Action
        }
    }
}
```

## Confirmation Dialogs

Always confirm destructive actions:

```swift
.alert("Delete Vehicle", isPresented: $showDeleteConfirmation) {
    Button("Cancel", role: .cancel) {}
    Button("Delete", role: .destructive) {
        performDelete()
    }
} message: {
    Text("Are you sure you want to delete this vehicle? This action cannot be undone.")
}
```

## Testing the Implementation

### Manual Testing Steps:

1. **New User Flow:**
   ```
   - Sign up as new user
   - Verify vehicle registration appears
   - Try to dismiss (should not work)
   - Add vehicle
   - Verify appears in top navigation
   ```

2. **Vehicle Management:**
   ```
   - Open side menu
   - Tap "My Vehicles"
   - Add new vehicle
   - Edit existing vehicle
   - Switch active vehicle
   - Delete vehicle (confirm)
   ```

3. **Color Verification:**
   ```
   - Check in light mode (all text visible)
   - Check in dark mode (all text visible)
   - Verify contrast ratios
   ```

### Unit Test Examples (Future):

```swift
import XCTest
@testable import ParkingApp

class VehicleManagementTests: XCTestCase {
    
    func testCreateVehicle() async throws {
        let vehicle = Vehicle(
            userId: "test-user",
            vehicleNumber: "TEST123",
            model: "TestModel",
            isActive: true
        )
        
        let vehicleId = try await FirestoreManager.shared.createVehicle(vehicle)
        XCTAssertFalse(vehicleId.isEmpty)
    }
    
    func testSetActiveVehicle() async throws {
        // Create two vehicles
        // Set one as active
        // Verify only one is active
    }
    
    func testDeleteVehicle() async throws {
        // Create vehicle
        // Delete it
        // Verify it's gone
    }
}
```

## Future Enhancements

Possible improvements for the future:

1. **Vehicle Images:**
   - Allow users to upload vehicle photos
   - Display photos in vehicle cards

2. **Vehicle Types:**
   - Add vehicle type (car, bike, SUV, etc.)
   - Different parking rates for different types

3. **Quick Switch:**
   - Tap vehicle number in top nav to quick-switch
   - Show mini list of vehicles in popup

4. **Vehicle History:**
   - Track parking history per vehicle
   - Show statistics (total parkings, amount spent)

5. **Multiple Active Vehicles:**
   - For users with families
   - Book parking for different vehicles simultaneously

6. **Vehicle Verification:**
   - Upload registration documents
   - Verified badge on vehicle cards

7. **Smart Suggestions:**
   - Suggest parking based on vehicle type
   - Remember frequently used vehicles

## Support and Troubleshooting

### Common Issues:

**Issue:** Vehicle not showing in top nav
**Solution:** Ensure vehicle.isActive is true and currentVehicle is set

**Issue:** Cannot delete last vehicle
**Solution:** This is allowed; consider adding warning

**Issue:** Multiple active vehicles
**Solution:** setActiveVehicle() deactivates others automatically

**Issue:** Color contrast issues
**Solution:** Always use Color.theme.* instead of hardcoded colors

### Debug Tips:

```swift
// Check current vehicle
print("Current: \(FirestoreManager.shared.currentVehicle?.vehicleNumber ?? "None")")

// Check all vehicles
Task {
    let all = try await FirestoreManager.shared.fetchVehicles(userId: userID)
    print("Total vehicles: \(all.count)")
    all.forEach { print("- \($0.vehicleNumber): \($0.isActive ? "Active" : "Inactive")") }
}
```
