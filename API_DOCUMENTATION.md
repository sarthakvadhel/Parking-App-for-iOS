# API Documentation

## FirestoreManager

The `FirestoreManager` is a singleton class that handles all Firestore database operations.

### Usage

```swift
let manager = FirestoreManager.shared
```

### User Operations

#### Create User
```swift
func createUser(_ user: User) async throws
```
Creates a new user document in Firestore.

**Parameters:**
- `user`: User object with id, email, role, etc.

**Throws:** Error if user ID is nil or creation fails

**Example:**
```swift
let user = User(id: "user123", email: "user@example.com", role: .user)
try await FirestoreManager.shared.createUser(user)
```

#### Fetch User
```swift
func fetchUser(userId: String) async throws -> User
```
Retrieves a user by their ID.

**Returns:** User object

**Example:**
```swift
let user = try await FirestoreManager.shared.fetchUser(userId: "user123")
```

#### Update User
```swift
func updateUser(_ user: User) async throws
```
Updates an existing user's information.

### Vehicle Operations

#### Create Vehicle
```swift
func createVehicle(_ vehicle: Vehicle) async throws -> String
```
Creates a new vehicle and returns its document ID.

**Returns:** Vehicle document ID

**Example:**
```swift
let vehicle = Vehicle(userId: "user123", vehicleNumber: "GJ01AE7828", model: "Swift")
let vehicleId = try await FirestoreManager.shared.createVehicle(vehicle)
```

#### Fetch Vehicles
```swift
func fetchVehicles(userId: String) async throws -> [Vehicle]
```
Gets all vehicles for a user.

**Returns:** Array of Vehicle objects

#### Set Active Vehicle
```swift
func setActiveVehicle(_ vehicle: Vehicle, userId: String) async throws
```
Sets a vehicle as active and deactivates others.

#### Fetch Active Vehicle
```swift
func fetchActiveVehicle(userId: String) async throws -> Vehicle?
```
Gets the currently active vehicle for a user.

### Parking Lot Operations

#### Create Parking Lot
```swift
func createParkingLot(_ parkingLot: ParkingLot) async throws -> String
```
Creates a new parking lot.

**Returns:** Parking lot document ID

#### Fetch Parking Lots
```swift
func fetchParkingLots() async throws -> [ParkingLot]
```
Gets all active parking lots.

#### Fetch Vendor Parking Lots
```swift
func fetchVendorParkingLots(vendorId: String) async throws -> [ParkingLot]
```
Gets all parking lots owned by a vendor.

#### Update Parking Lot
```swift
func updateParkingLot(_ parkingLot: ParkingLot) async throws
```
Updates parking lot information.

### Booking Operations

#### Create Booking
```swift
func createBooking(_ booking: Booking) async throws -> String
```
Creates a new booking and decrements available spaces.

**Returns:** Booking document ID

#### Fetch User Bookings
```swift
func fetchUserBookings(userId: String) async throws -> [Booking]
```
Gets all bookings for a user, ordered by creation date.

#### Fetch Active Booking
```swift
func fetchActiveBooking(userId: String) async throws -> Booking?
```
Gets the current active booking for a user.

#### Update Booking
```swift
func updateBooking(_ booking: Booking) async throws
```
Updates booking status and increments available spaces if completed/cancelled.

### Payment Operations

#### Create Payment
```swift
func createPayment(_ payment: Payment) async throws -> String
```
Creates a payment record.

**Returns:** Payment document ID

#### Fetch Payments
```swift
func fetchPayments(userId: String) async throws -> [Payment]
```
Gets all payments for a user.

#### Update Payment
```swift
func updatePayment(_ payment: Payment) async throws
```
Updates payment status.

## ParkingFinder

Location-based parking discovery service.

### Properties

```swift
@Published var spots: [ParkingItem]
@Published var selectedPlace: ParkingItem?
@Published var showDetail: Bool
@Published var isLoading: Bool
@Published var region: MKCoordinateRegion
```

### Methods

#### Load Parking Lots
```swift
func loadParkingLots()
```
Fetches parking lots from Firestore and updates the spots array.

#### Update Region
```swift
func updateRegionToUserLocation(_ location: CLLocationCoordinate2D)
```
Centers the map on the user's location.

## Models

### User
```swift
struct User: Codable, Identifiable {
    var id: String?
    var email: String
    var role: UserRole
    var name: String?
    var phoneNumber: String?
    var profileImageURL: String?
    var createdAt: Date
    var vehicles: [String]?
}
```

### UserRole
```swift
enum UserRole: String, Codable {
    case user = "user"
    case vendor = "vendor"
}
```

### Vehicle
```swift
struct Vehicle: Codable, Identifiable {
    var id: String?
    var userId: String
    var vehicleNumber: String
    var model: String
    var manufacturer: String?
    var color: String?
    var imageURLs: [String]?
    var isActive: Bool
    var createdAt: Date
}
```

### ParkingLot
```swift
struct ParkingLot: Codable, Identifiable {
    var id: String?
    var vendorId: String
    var name: String
    var description: String
    var address: String
    var latitude: Double
    var longitude: Double
    var hourlyCharge: Double
    var lateFee: Double
    var terms: String
    var totalSpaces: Int
    var availableSpaces: Int
    var imageURLs: [String]?
    var isActive: Bool
    var createdAt: Date
    
    var coordinate: CLLocationCoordinate2D { get }
}
```

### Booking
```swift
struct Booking: Codable, Identifiable {
    var id: String?
    var userId: String
    var vehicleId: String
    var parkingLotId: String
    var startTime: Date
    var endTime: Date?
    var plannedHours: Double
    var actualHours: Double?
    var status: BookingStatus
    var totalAmount: Double?
    var createdAt: Date
}

enum BookingStatus: String, Codable {
    case active = "active"
    case completed = "completed"
    case cancelled = "cancelled"
}
```

### Payment
```swift
struct Payment: Codable, Identifiable {
    var id: String?
    var bookingId: String
    var userId: String
    var amount: Double
    var method: PaymentMethod
    var status: PaymentStatus
    var transactionId: String?
    var createdAt: Date
}

enum PaymentMethod: String, Codable {
    case cash = "cash"
    case card = "card"
    case upi = "upi"
    case wallet = "wallet"
}

enum PaymentStatus: String, Codable {
    case pending = "pending"
    case completed = "completed"
    case failed = "failed"
}
```

## Helper Extensions

### Date Extensions
```swift
extension Date {
    func formatted(as format: String) -> String
    var timeAgo: String
}
```

### Double Extensions
```swift
extension Double {
    var asCurrency: String  // Returns "₹123.45"
    var asRoundedCurrency: String  // Returns "₹123"
}
```

### String Extensions
```swift
extension String {
    func isValidEmail() -> Bool
}
```

## Error Handling

All async functions throw errors that should be caught using try-catch blocks:

```swift
do {
    let user = try await FirestoreManager.shared.fetchUser(userId: userId)
    // Success
} catch {
    // Handle error
    print("Error: \(error.localizedDescription)")
}
```

## Best Practices

1. **Always use async/await** for Firestore operations
2. **Handle errors gracefully** with user-friendly messages
3. **Use MainActor** when updating UI from background tasks
4. **Validate data** before creating/updating documents
5. **Check user authentication** before operations
6. **Use loading states** to indicate progress
7. **Optimize queries** by limiting results when possible

## Example Workflows

### User Registration Flow
```swift
// 1. Create authentication
Auth.auth().createUser(withEmail: email, password: password) { result, error in
    // 2. Create user profile
    let user = User(id: result.user.uid, email: email, role: .user)
    try await FirestoreManager.shared.createUser(user)
    
    // 3. Create vehicle
    let vehicle = Vehicle(userId: user.id!, vehicleNumber: "ABC123", model: "Swift")
    try await FirestoreManager.shared.createVehicle(vehicle)
}
```

### Booking Flow
```swift
// 1. Get active vehicle
let vehicle = try await FirestoreManager.shared.fetchActiveVehicle(userId: userId)

// 2. Create booking
let booking = Booking(
    userId: userId,
    vehicleId: vehicle.id!,
    parkingLotId: selectedLot.id!,
    startTime: Date(),
    plannedHours: 2.0,
    status: .active
)
let bookingId = try await FirestoreManager.shared.createBooking(booking)

// 3. Create payment
let payment = Payment(
    bookingId: bookingId,
    userId: userId,
    amount: 100.0,
    method: .cash,
    status: .pending
)
try await FirestoreManager.shared.createPayment(payment)
```

---

**For more details, see the inline documentation in the source code.**
