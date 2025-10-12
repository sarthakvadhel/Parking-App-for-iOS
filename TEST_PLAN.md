# Test Strategy & Implementation Plan
## Comprehensive Testing for iOS Parking App

**Version:** 1.0  
**Date:** 2025-10-11  
**Target Coverage:** 70% minimum

---

## Testing Pyramid

```
         ╱╲
        ╱ E2E╲         5% - End-to-end flows
       ╱──────╲
      ╱   UI   ╲       15% - XCUITest
     ╱──────────╲
    ╱Integration ╲     30% - API, Services
   ╱──────────────╲
  ╱     Unit       ╲   50% - Business logic
 ╱──────────────────╲
```

**Distribution:**
- Unit Tests: 50% (business logic, utilities, view models)
- Integration Tests: 30% (services, repositories, API)
- UI Tests: 15% (critical user flows)
- E2E Tests: 5% (complete booking flow, payment)

---

## Test Infrastructure Setup

### 1. Create Test Targets

```bash
# In Xcode:
# File → New → Target → iOS Unit Testing Bundle
# Name: ParkingAppTests

# File → New → Target → iOS UI Testing Bundle  
# Name: ParkingAppUITests
```

### 2. Test Configuration

**`ParkingAppTests/TestConfig.swift`**
```swift
import XCTest
@testable import ParkingApp

class TestConfig {
    static let shared = TestConfig()
    
    // Mock Firebase
    static let mockFirebaseConfig = [
        "apiKey": "mock-api-key",
        "projectId": "mock-project",
        "storageBucket": "mock-storage"
    ]
    
    // Test users
    static let testUser = User(
        id: "test-user-123",
        email: "test@example.com",
        name: "Test User",
        role: .user,
        phoneNumber: "1234567890"
    )
    
    static let testVendor = User(
        id: "test-vendor-123",
        email: "vendor@example.com",
        name: "Test Vendor",
        role: .vendor
    )
    
    // Test data
    static let testParkingLot = ParkingLot(
        id: "lot-123",
        name: "Test Parking",
        address: "123 Test St",
        latitude: 23.0,
        longitude: 72.5,
        hourlyCharge: 50.0,
        totalSpaces: 100,
        availableSpaces: 50,
        vendorId: "test-vendor-123"
    )
}

// Base test class
class ParkingAppTestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDown() {
        super.tearDown()
        // Clean up
    }
}
```

---

## Unit Tests

### 1. Model Tests

**`ParkingAppTests/Models/BookingTests.swift`**
```swift
import XCTest
@testable import ParkingApp

class BookingTests: ParkingAppTestCase {
    
    func testBookingCreation() {
        let booking = Booking(
            id: "booking-123",
            userId: "user-123",
            parkingLotId: "lot-123",
            vehicleId: "vehicle-123",
            status: .pending,
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            totalAmount: 50.0,
            createdAt: Date()
        )
        
        XCTAssertNotNil(booking)
        XCTAssertEqual(booking.status, .pending)
        XCTAssertEqual(booking.totalAmount, 50.0)
    }
    
    func testBookingDuration() {
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(7200) // 2 hours
        
        let booking = Booking(
            userId: "user-123",
            parkingLotId: "lot-123",
            vehicleId: "vehicle-123",
            status: .active,
            startTime: startTime,
            endTime: endTime,
            totalAmount: 100.0
        )
        
        let duration = booking.duration
        XCTAssertEqual(duration, 2.0, accuracy: 0.1)
    }
    
    func testBookingCanBeModified() {
        let booking = Booking(
            userId: "user-123",
            parkingLotId: "lot-123",
            vehicleId: "vehicle-123",
            status: .completed,
            startTime: Date().addingTimeInterval(-7200),
            endTime: Date().addingTimeInterval(-3600),
            totalAmount: 50.0
        )
        
        let canModify = BookingService.shared.canUserModifyBooking(booking)
        XCTAssertTrue(canModify, "Completed booking should be modifiable")
    }
    
    func testActiveBookingCannotBeModified() {
        let booking = Booking(
            userId: "user-123",
            parkingLotId: "lot-123",
            vehicleId: "vehicle-123",
            status: .active,
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            totalAmount: 50.0
        )
        
        let canModify = BookingService.shared.canUserModifyBooking(booking)
        XCTAssertFalse(canModify, "Active booking should be immutable")
    }
}
```

### 2. ViewModel Tests

**`ParkingAppTests/ViewModels/ParkingFinderTests.swift`**
```swift
import XCTest
import CoreLocation
@testable import ParkingApp

class ParkingFinderTests: ParkingAppTestCase {
    
    var sut: ParkingFinder!
    
    override func setUp() {
        super.setUp()
        sut = ParkingFinder()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertFalse(sut.spots.isEmpty, "Should have static fallback data")
        XCTAssertNotNil(sut.selectedPlace)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testLoadParkingLots() async {
        let expectation = expectation(description: "Load parking lots")
        
        sut.loadParkingLots()
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        await MainActor.run {
            XCTAssertFalse(sut.isLoading)
            XCTAssertGreaterThan(sut.spots.count, 0)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 3)
    }
    
    func testNearestParkingSorting() {
        let userLocation = CLLocation(latitude: 23.0, longitude: 72.5)
        
        sut.calculateNearestParking(to: userLocation)
        
        // Verify sorting by distance
        for i in 0..<(sut.spots.count - 1) {
            let distance1 = userLocation.distance(
                from: CLLocation(
                    latitude: sut.spots[i].location.latitude,
                    longitude: sut.spots[i].location.longitude
                )
            )
            
            let distance2 = userLocation.distance(
                from: CLLocation(
                    latitude: sut.spots[i + 1].location.latitude,
                    longitude: sut.spots[i + 1].location.longitude
                )
            )
            
            XCTAssertLessThanOrEqual(distance1, distance2, "Spots should be sorted by distance")
        }
    }
    
    func testRegionUpdateToUserLocation() {
        let testLocation = CLLocationCoordinate2D(latitude: 23.0, longitude: 72.5)
        
        sut.updateRegionToUserLocation(testLocation)
        
        XCTAssertEqual(sut.region.center.latitude, testLocation.latitude, accuracy: 0.01)
        XCTAssertEqual(sut.region.center.longitude, testLocation.longitude, accuracy: 0.01)
    }
}
```

### 3. Service Tests

**`ParkingAppTests/Services/KeychainServiceTests.swift`**
```swift
import XCTest
@testable import ParkingApp

class KeychainServiceTests: ParkingAppTestCase {
    
    var sut: KeychainService!
    let testKey = "test-key"
    let testValue = "test-value-123"
    
    override func setUp() {
        super.setUp()
        sut = KeychainService()
        // Clean up any existing test data
        sut.delete(forKey: testKey)
    }
    
    override func tearDown() {
        sut.delete(forKey: testKey)
        sut = nil
        super.tearDown()
    }
    
    func testSaveAndRetrieve() throws {
        try sut.save(testValue, forKey: testKey)
        let retrieved = try sut.load(forKey: testKey)
        
        XCTAssertEqual(retrieved, testValue)
    }
    
    func testDelete() throws {
        try sut.save(testValue, forKey: testKey)
        sut.delete(forKey: testKey)
        
        let retrieved = try? sut.load(forKey: testKey)
        XCTAssertNil(retrieved)
    }
    
    func testOverwrite() throws {
        try sut.save(testValue, forKey: testKey)
        let newValue = "new-value"
        try sut.save(newValue, forKey: testKey)
        
        let retrieved = try sut.load(forKey: testKey)
        XCTAssertEqual(retrieved, newValue)
    }
}
```

### 4. Utility Tests

**`ParkingAppTests/Utils/ValidationTests.swift`**
```swift
import XCTest
@testable import ParkingApp

class ValidationTests: ParkingAppTestCase {
    
    func testEmailValidation() {
        XCTAssertTrue("test@example.com".isValidEmail())
        XCTAssertTrue("user+tag@domain.co.uk".isValidEmail())
        XCTAssertFalse("invalid-email".isValidEmail())
        XCTAssertFalse("@example.com".isValidEmail())
        XCTAssertFalse("test@".isValidEmail())
    }
    
    func testPhoneValidation() {
        XCTAssertTrue("1234567890".isValidPhoneNumber())
        XCTAssertTrue("+911234567890".isValidPhoneNumber())
        XCTAssertFalse("123".isValidPhoneNumber())
        XCTAssertFalse("abcdefghij".isValidPhoneNumber())
    }
    
    func testVehicleNumberValidation() {
        XCTAssertTrue("GJ01AB1234".isValidVehicleNumber())
        XCTAssertTrue("MH-12-CD-5678".isValidVehicleNumber())
        XCTAssertFalse("INVALID".isValidVehicleNumber())
    }
}
```

---

## Integration Tests

### 1. Firebase Integration

**`ParkingAppTests/Integration/FirestoreManagerTests.swift`**
```swift
import XCTest
import FirebaseFirestore
@testable import ParkingApp

class FirestoreManagerTests: ParkingAppTestCase {
    
    var sut: FirestoreManager!
    var testUserId: String!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = FirestoreManager.shared
        testUserId = "test-user-\(UUID().uuidString)"
    }
    
    override func tearDown() async throws {
        // Clean up test data
        if let testUserId = testUserId {
            try? await sut.deleteUser(userId: testUserId)
        }
        sut = nil
        try await super.tearDown()
    }
    
    func testCreateAndFetchUser() async throws {
        let user = User(
            id: testUserId,
            email: "test@example.com",
            name: "Test User",
            role: .user
        )
        
        try await sut.createUser(user)
        let fetched = try await sut.fetchUser(userId: testUserId)
        
        XCTAssertEqual(fetched.id, testUserId)
        XCTAssertEqual(fetched.email, user.email)
    }
    
    func testCreateVehicle() async throws {
        let vehicle = Vehicle(
            id: nil,
            userId: testUserId,
            vehicleNumber: "GJ01AB1234",
            model: "Swift",
            manufacturer: "Maruti",
            color: "White",
            isActive: true
        )
        
        let vehicleId = try await sut.createVehicle(vehicle)
        XCTAssertFalse(vehicleId.isEmpty)
        
        let vehicles = try await sut.fetchVehicles(userId: testUserId)
        XCTAssertEqual(vehicles.count, 1)
        XCTAssertEqual(vehicles.first?.vehicleNumber, "GJ01AB1234")
    }
    
    func testBookingFlow() async throws {
        let booking = Booking(
            userId: testUserId,
            parkingLotId: "lot-123",
            vehicleId: "vehicle-123",
            status: .pending,
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            totalAmount: 50.0
        )
        
        let bookingId = try await sut.createBooking(booking)
        XCTAssertFalse(bookingId.isEmpty)
        
        var fetchedBooking = try await sut.fetchActiveBooking(userId: testUserId)
        XCTAssertNotNil(fetchedBooking)
        XCTAssertEqual(fetchedBooking?.status, .pending)
        
        // Update to active
        fetchedBooking?.status = .active
        try await sut.updateBooking(fetchedBooking!)
        
        let updatedBooking = try await sut.fetchActiveBooking(userId: testUserId)
        XCTAssertEqual(updatedBooking?.status, .active)
    }
}
```

### 2. Network Layer Tests

**`ParkingAppTests/Integration/NetworkServiceTests.swift`**
```swift
import XCTest
@testable import ParkingApp

class NetworkServiceTests: ParkingAppTestCase {
    
    var sut: RetryService!
    
    override func setUp() {
        super.setUp()
        sut = RetryService()
    }
    
    func testRetryOnTransientError() async throws {
        var attemptCount = 0
        
        let result = try await sut.execute {
            attemptCount += 1
            if attemptCount < 3 {
                throw URLError(.timedOut)
            }
            return "Success"
        }
        
        XCTAssertEqual(result, "Success")
        XCTAssertEqual(attemptCount, 3)
    }
    
    func testNoRetryOnNonRetryableError() async {
        var attemptCount = 0
        
        do {
            _ = try await sut.execute {
                attemptCount += 1
                throw URLError(.badURL)
            }
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertEqual(attemptCount, 1, "Should not retry non-retryable errors")
        }
    }
}
```

---

## UI Tests

### 1. Critical User Flows

**`ParkingAppUITests/UserFlowTests.swift`**
```swift
import XCTest

class UserFlowTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing", "Reset-State"]
        app.launch()
    }
    
    func testCompleteBookingFlow() throws {
        // Login
        loginAsUser()
        
        // Wait for map
        let map = app.otherElements["Map"]
        XCTAssertTrue(map.waitForExistence(timeout: 5))
        
        // Select parking spot
        let annotation = app.buttons["ParkingAnnotation"].firstMatch
        XCTAssertTrue(annotation.waitForExistence(timeout: 3))
        annotation.tap()
        
        // Tap on parking card to open detail
        let parkingCard = app.otherElements["ParkingCard"]
        XCTAssertTrue(parkingCard.waitForExistence(timeout: 2))
        parkingCard.tap()
        
        // Select duration
        let durationSlider = app.sliders["Duration"]
        XCTAssertTrue(durationSlider.exists)
        durationSlider.adjust(toNormalizedSliderPosition: 0.5) // 6 hours
        
        // Tap Book Now
        let bookButton = app.buttons["Book Now"]
        XCTAssertTrue(bookButton.exists)
        bookButton.tap()
        
        // Select payment method
        let cashOption = app.buttons["Cash Payment"]
        XCTAssertTrue(cashOption.waitForExistence(timeout: 2))
        cashOption.tap()
        
        // Confirm booking
        let confirmButton = app.buttons["Confirm Booking"]
        XCTAssertTrue(confirmButton.exists)
        confirmButton.tap()
        
        // Verify success
        let successAlert = app.alerts["Booking Confirmed"]
        XCTAssertTrue(successAlert.waitForExistence(timeout: 5))
        
        successAlert.buttons["OK"].tap()
    }
    
    func testSearchFlow() throws {
        loginAsUser()
        
        // Tap search
        let searchButton = app.buttons["Search For Parking"]
        XCTAssertTrue(searchButton.waitForExistence(timeout: 3))
        searchButton.tap()
        
        // Enter search query
        let searchField = app.textFields["Search by name or address"]
        XCTAssertTrue(searchField.exists)
        searchField.tap()
        searchField.typeText("AMC")
        
        // Verify results
        let resultsList = app.tables.firstMatch
        XCTAssertTrue(resultsList.waitForExistence(timeout: 2))
        XCTAssertGreaterThan(resultsList.cells.count, 0)
        
        // Tap result
        resultsList.cells.firstMatch.tap()
        
        // Verify detail view appeared
        let detailView = app.otherElements["ParkingDetailView"]
        XCTAssertTrue(detailView.waitForExistence(timeout: 2))
    }
    
    func testVendorDashboard() throws {
        loginAsVendor()
        
        // Verify dashboard loaded
        let dashboard = app.staticTexts["Vendor Dashboard"]
        XCTAssertTrue(dashboard.waitForExistence(timeout: 5))
        
        // Tap Add Parking Lot
        let addButton = app.buttons["Add Parking Lot"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()
        
        // Fill form
        fillParkingLotForm()
        
        // Save
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()
        
        // Verify lot appears in list
        let lotCard = app.otherElements.matching(identifier: "ParkingLotCard").firstMatch
        XCTAssertTrue(lotCard.waitForExistence(timeout: 3))
    }
    
    // Helper methods
    private func loginAsUser() {
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 2))
        emailField.tap()
        emailField.typeText("user@test.com")
        
        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText("password123")
        
        app.buttons["Login"].tap()
    }
    
    private func loginAsVendor() {
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 2))
        emailField.tap()
        emailField.typeText("vendor@test.com")
        
        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText("password123")
        
        app.buttons["Login"].tap()
    }
    
    private func fillParkingLotForm() {
        app.textFields["Name"].tap()
        app.textFields["Name"].typeText("Test Parking Lot")
        
        app.textFields["Address"].tap()
        app.textFields["Address"].typeText("123 Test Street")
        
        app.textFields["Hourly Charge"].tap()
        app.textFields["Hourly Charge"].typeText("50")
        
        app.textFields["Total Spaces"].tap()
        app.textFields["Total Spaces"].typeText("100")
    }
}
```

### 2. Screenshot Tests

**`ParkingAppUITests/ScreenshotTests.swift`**
```swift
import XCTest

class ScreenshotTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing", "Screenshots"]
        setupSnapshot(app)
        app.launch()
    }
    
    func testScreenshots() {
        // Login screen
        snapshot("01Login")
        
        // Login
        loginAsUser()
        
        // Main map view
        sleep(2) // Wait for map to load
        snapshot("02MainMap")
        
        // Search
        app.buttons["Search For Parking"].tap()
        sleep(1)
        snapshot("03Search")
        
        // Search results
        app.textFields.firstMatch.tap()
        app.textFields.firstMatch.typeText("AMC")
        sleep(1)
        snapshot("04SearchResults")
        
        // Close search
        app.buttons["Cancel"].tap()
        
        // Select parking spot
        app.buttons["ParkingAnnotation"].firstMatch.tap()
        sleep(1)
        snapshot("05ParkingCard")
        
        // Detail view
        app.otherElements["ParkingCard"].tap()
        sleep(1)
        snapshot("06ParkingDetail")
        
        // Payment
        app.buttons["Book Now"].tap()
        sleep(1)
        snapshot("07Payment")
    }
    
    private func loginAsUser() {
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("user@test.com")
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("password123")
        app.buttons["Login"].tap()
        sleep(2)
    }
}
```

---

## Performance Tests

**`ParkingAppTests/Performance/PerformanceTests.swift`**
```swift
import XCTest
@testable import ParkingApp

class PerformanceTests: ParkingAppTestCase {
    
    func testParkingListPerformance() {
        let parkingFinder = ParkingFinder()
        
        measure {
            parkingFinder.loadParkingLots()
            RunLoop.main.run(until: Date().addingTimeInterval(0.5))
        }
    }
    
    func testNearestParkingCalculation() {
        let parkingFinder = ParkingFinder()
        let userLocation = CLLocation(latitude: 23.0, longitude: 72.5)
        
        measure {
            parkingFinder.calculateNearestParking(to: userLocation)
        }
    }
    
    func testDataParsing() {
        measure {
            _ = try? JSONDecoder().decode([ParkingLot].self, from: mockParkingLotsData)
        }
    }
}
```

---

## Test Data Management

### Mock Data

**`ParkingAppTests/Mocks/MockData.swift`**
```swift
import Foundation
@testable import ParkingApp

struct MockData {
    static let parkingLots: [ParkingLot] = [
        ParkingLot(
            id: "mock-lot-1",
            name: "Mock Parking 1",
            address: "123 Mock Street",
            latitude: 23.0,
            longitude: 72.5,
            hourlyCharge: 50.0,
            totalSpaces: 100,
            availableSpaces: 50,
            vendorId: "vendor-1"
        ),
        ParkingLot(
            id: "mock-lot-2",
            name: "Mock Parking 2",
            address: "456 Mock Avenue",
            latitude: 23.1,
            longitude: 72.6,
            hourlyCharge: 60.0,
            totalSpaces: 150,
            availableSpaces: 75,
            vendorId: "vendor-2"
        )
    ]
    
    static let users: [User] = [
        User(
            id: "mock-user-1",
            email: "user1@test.com",
            name: "Test User 1",
            role: .user
        ),
        User(
            id: "mock-vendor-1",
            email: "vendor1@test.com",
            name: "Test Vendor 1",
            role: .vendor
        )
    ]
}
```

### Mock Services

**`ParkingAppTests/Mocks/MockFirestoreManager.swift`**
```swift
import Foundation
@testable import ParkingApp

class MockFirestoreManager: FirestoreManager {
    var shouldSucceed = true
    var mockDelay: TimeInterval = 0.5
    
    override func fetchParkingLots() async throws -> [ParkingLot] {
        try await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        
        if shouldSucceed {
            return MockData.parkingLots
        } else {
            throw NSError(domain: "MockError", code: -1)
        }
    }
    
    override func createBooking(_ booking: Booking) async throws -> String {
        try await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        
        if shouldSucceed {
            return "mock-booking-id"
        } else {
            throw NSError(domain: "MockError", code: -1)
        }
    }
}
```

---

## Coverage Reports

### Xcode Coverage

```bash
# Generate coverage report
xcodebuild test \
  -scheme ParkingApp \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults.xcresult

# View coverage
xcrun xccov view --report --json TestResults.xcresult > coverage.json

# Install xcov for better reports
gem install xcov

# Generate HTML report
xcov \
  --scheme ParkingApp \
  --output_directory ./coverage \
  --html_report \
  --minimum_coverage_percentage 70.0
```

### Coverage Thresholds

```yaml
# .codecov.yml
coverage:
  precision: 2
  round: down
  range: "70...100"
  
  status:
    project:
      default:
        target: 70%
        threshold: 5%
        base: auto
    patch:
      default:
        target: 80%
        threshold: 5%
        
ignore:
  - "**/*App.swift"
  - "**/*Preview*.swift"
  - "**/Mock*.swift"
  - "**/Test*.swift"
  - "**/Generated/*"
```

---

## Test Execution

### Local Testing

```bash
# Run all tests
xcodebuild test -scheme ParkingApp \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run specific test class
xcodebuild test -scheme ParkingApp \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:ParkingAppTests/BookingTests

# Run UI tests only
xcodebuild test -scheme ParkingApp \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:ParkingAppUITests
```

### Fastlane

```ruby
# fastlane/Fastfile
lane :test do
  run_tests(
    scheme: "ParkingApp",
    devices: ["iPhone 15 Pro", "iPhone SE (3rd generation)"],
    code_coverage: true,
    skip_slack: true
  )
end

lane :test_quick do
  run_tests(
    scheme: "ParkingApp",
    devices: ["iPhone 15 Pro"],
    skip_testing: ["ParkingAppUITests"],
    code_coverage: true
  )
end
```

---

## Quality Gates

### Minimum Requirements

| Metric | Threshold | Current | Status |
|--------|-----------|---------|--------|
| Overall Coverage | ≥ 70% | TBD | ⏸️ |
| Unit Test Coverage | ≥ 80% | TBD | ⏸️ |
| Critical Path Coverage | 100% | TBD | ⏸️ |
| Test Success Rate | ≥ 99% | TBD | ⏸️ |
| Test Execution Time | < 10 min | TBD | ⏸️ |

### Blocking Conditions

Tests **must pass** before merging:
- All unit tests passing
- All integration tests passing
- Critical UI tests passing
- No flaky tests (retry limit: 1)
- Coverage ≥ 70%

---

## Continuous Testing

### Pre-commit Hook

```bash
#!/bin/sh
# .git/hooks/pre-commit

echo "Running tests..."
xcodebuild test -scheme ParkingApp \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -quiet

if [ $? -ne 0 ]; then
  echo "❌ Tests failed. Commit aborted."
  exit 1
fi

echo "✅ Tests passed!"
exit 0
```

### CI Integration

See `CI_CD_SETUP.md` for GitHub Actions configuration.

---

## Test Maintenance

### Weekly Tasks
- [ ] Review flaky tests
- [ ] Update test data
- [ ] Archive old test results
- [ ] Review coverage trends

### Monthly Tasks
- [ ] Audit test relevance
- [ ] Remove obsolete tests
- [ ] Update mock data
- [ ] Performance baseline review

---

## Troubleshooting

### Common Issues

**1. Simulator Not Found**
```bash
xcrun simctl list devices
xcode-select --install
```

**2. Test Timeout**
```swift
// Increase timeout
let expectation = expectation(description: "...")
await fulfillment(of: [expectation], timeout: 30) // Instead of 5
```

**3. UI Test Fails on CI**
```swift
// Add explicit waits
XCTAssertTrue(element.waitForExistence(timeout: 10))
```

---

## Success Metrics

**Target (30 days):**
- ✅ 70% code coverage
- ✅ 150+ unit tests
- ✅ 50+ integration tests
- ✅ 20+ UI tests
- ✅ < 5 minute test execution
- ✅ 0 flaky tests

---

**Document Owner:** QA Team  
**Last Updated:** 2025-10-11  
**Next Review:** After test infrastructure setup
