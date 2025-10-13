# Production-Grade Architecture Redesign Plan
## Parking App for iOS - Enterprise Readiness Assessment

**Version:** 1.0  
**Date:** 2025-10-11  
**Status:** Analysis Complete, Implementation Pending

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Gap Analysis](#gap-analysis)
3. [Target Architecture Blueprint](#target-architecture-blueprint)
4. [Security & Privacy Checklist](#security--privacy-checklist)
5. [Test Strategy](#test-strategy)
6. [CI/CD Plan](#cicd-plan)
7. [Observability Plan](#observability-plan)
8. [Feature Specifications](#feature-specifications)
9. [Roadmap](#roadmap)
10. [Open Questions](#open-questions)

---

## Executive Summary

### Top Gaps (Priority Risk Assessment)

| Risk | Finding | Impact | Effort | ROI |
|------|---------|--------|--------|-----|
| **P0** | Startup crash with internet connection | App unusable, 100% crash rate | S | Critical |
| **P0** | Hardcoded Firebase credentials in repo | Security breach, compliance failure | S | Critical |
| **P1** | No real-time updates (vendor→user) | Stale data, poor UX | L | High |
| **P1** | Vendor dashboard incomplete (static) | No vendor value proposition | L | High |
| **P1** | No booking immutability enforcement | Data integrity issues | M | High |
| **P2** | Zero test coverage | Quality risks, regression prone | L | High |
| **P2** | No CI/CD pipeline | Manual QA, slow releases | M | High |
| **P2** | Inconsistent theming/contrast | Accessibility issues, poor UX | M | Medium |
| **P3** | No crash reporting/analytics | Blind to production issues | S | High |
| **P3** | Monolithic architecture | Hard to maintain, scale | XL | Medium |

### Current State
- **Architecture Pattern**: Basic MVVM with minimal separation
- **Tech Stack**: SwiftUI, Firebase (Auth, Firestore, Storage), MapKit, CoreLocation
- **Test Coverage**: 0% (no test targets)
- **CI/CD**: None
- **Observability**: Print statements only
- **Security**: Hardcoded secrets, no certificate pinning, no encryption at rest
- **Distribution**: Development only (no TestFlight/App Store config)

### Target State
- **Architecture**: Clean Architecture + Coordinator pattern, modularized features
- **Test Coverage**: ≥70% (unit + integration + UI tests)
- **CI/CD**: GitHub Actions + fastlane with automated TestFlight deployment
- **Observability**: Firebase Crashlytics, Analytics, MetricKit, custom dashboards
- **Security**: OWASP MASVS L2 compliant, encrypted storage, ATS enforcement
- **Distribution**: Phased rollout with feature flags, App Store ready

---

## Gap Analysis

### A) Architecture and Code Quality

#### Current State
**File:** `ParkingApp/` - Single module monolith  
**Pattern:** Informal MVVM

**Evidence:**
- [`ContentView.swift:16`](https://github.com/sarthakvadhel/Parking-App-for-iOS/blob/17cd4d4c49eb8e248486777dc5e4bd8655fadd49/ParkingApp/SpotsView/ContentView.swift#L16) - `@StateObject var parkingFinder = ParkingFinder()` - ViewModel instantiated directly in view
- [`ParkingFinder.swift:34`](https://github.com/sarthakvadhel/Parking-App-for-iOS/blob/17cd4d4c49eb8e248486777dc5e4bd8655fadd49/ParkingApp/ViewModel/ParkingFinder.swift#L34) - `loadParkingLots()` called in `init()` - Network call on main thread init
- [`FirestoreManager.swift:13`](https://github.com/sarthakvadhel/Parking-App-for-iOS/blob/17cd4d4c49eb8e248486777dc5e4bd8655fadd49/ParkingApp/Services/FirestoreManager.swift#L13) - Singleton pattern with `@Published` properties mixing concerns

**Issues:**
| Finding | Severity | File:Line | Recommendation |
|---------|----------|-----------|----------------|
| No dependency injection | P1 | Throughout | Implement protocol-based DI container |
| Business logic in ViewModels | P1 | `ParkingFinder.swift` | Extract to Use Cases/Interactors |
| Tight coupling to Firebase | P1 | `FirestoreManager.swift` | Abstract with Repository pattern |
| No modularization | P2 | Project structure | Split into SPM packages |
| Mixed async patterns | P2 | Various | Standardize on async/await |

**Recommendation:**
```
Target Architecture (Clean + Coordinators):

ParkingApp/
├── Core/
│   ├── Domain/              # Entities, Use Cases, Repository Protocols
│   ├── Data/                # Repository Implementations, DTOs
│   └── DI/                  # Dependency Container
├── Features/
│   ├── Auth/
│   │   ├── Presentation/    # Views, ViewModels, Coordinators
│   │   ├── Domain/          # Auth Use Cases
│   │   └── Data/            # Auth Repository
│   ├── UserParking/
│   ├── VendorDashboard/
│   └── Booking/
├── Shared/
│   ├── DesignSystem/        # Tokens, Components
│   ├── Networking/          # API Client, Interceptors
│   ├── Persistence/         # Core Data, Keychain
│   └── Utils/
└── App/                     # AppDelegate, SceneDelegate, DI setup
```

**Migration Strategy:**
1. Phase 1: Extract protocols (Repositories, Use Cases) - 2 days
2. Phase 2: Implement DI container - 1 day  
3. Phase 3: Refactor to feature modules - 1 week
4. Phase 4: Extract to SPM packages - 3 days

---

### B) Networking and Offline

#### Current State
**File:** [`FirestoreManager.swift`](https://github.com/sarthakvadhel/Parking-App-for-iOS/blob/17cd4d4c49eb8e248486777dc5e4bd8655fadd49/ParkingApp/Services/FirestoreManager.swift)

**Evidence:**
- Line 41: `try await FirestoreManager.shared.fetchParkingLots()` - No retry logic
- Line 76-77: Fallback to static data on error - No offline persistence
- No network reachability checks
- No request cancellation
- No pagination (all records fetched)

**Issues:**
| Finding | Severity | Impact | Recommendation |
|---------|----------|--------|----------------|
| No retry with exponential backoff | P1 | Flaky network = failures | Implement retry interceptor |
| No offline-first architecture | P1 | Poor UX in low connectivity | Core Data + sync engine |
| No request cancellation | P2 | Memory leaks, wasted bandwidth | Task cancellation on view disappear |
| No pagination | P2 | Performance issues at scale | Cursor-based pagination |
| No certificate pinning | P0 | MITM vulnerability | Implement SSL pinning |

**Recommendation:**
```swift
// Networking Layer Architecture

protocol NetworkService {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

class RetryNetworkService: NetworkService {
    private let maxRetries = 3
    private let baseDelay: TimeInterval = 1.0
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        var lastError: Error?
        
        for attempt in 0..<maxRetries {
            do {
                return try await performRequest(endpoint)
            } catch {
                lastError = error
                if !isRetryableError(error) { throw error }
                
                let delay = baseDelay * pow(2.0, Double(attempt))
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        throw lastError!
    }
}

// Offline-First Repository
class ParkingLotRepository {
    private let networkService: NetworkService
    private let localStorage: LocalStorage
    
    func fetchParkingLots() async throws -> [ParkingLot] {
        // Try network first
        do {
            let lots = try await networkService.request(.getParkingLots)
            await localStorage.save(lots)
            return lots
        } catch {
            // Fallback to local cache
            return try await localStorage.fetchParkingLots()
        }
    }
}
```

**Security Enhancements:**
- [ ] App Transport Security (ATS) enforcement
- [ ] Certificate pinning for Firebase domain
- [ ] PII redaction in network logs
- [ ] Token refresh flow with secure storage

---

### C) Data and Persistence

#### Current State
**Files:**
- [`Model/`](https://github.com/sarthakvadhel/Parking-App-for-iOS/blob/17cd4d4c49eb8e248486777dc5e4bd8655fadd49/ParkingApp/Model/) - 7 model files
- No local persistence beyond UserDefaults
- No encryption at rest

**Evidence:**
- [`ContentView.swift:13-14`](https://github.com/sarthakvadhel/Parking-App-for-iOS/blob/17cd4d4c49eb8e248486777dc5e4bd8655fadd49/ParkingApp/SpotsView/ContentView.swift#L13-L14) - Sensitive data in UserDefaults (uid, role)
- No Core Data stack
- No migration strategy
- Images not cached locally

**Issues:**
| Finding | Severity | File:Line | Recommendation |
|---------|----------|-----------|----------------|
| Sensitive data in UserDefaults | P0 | `ContentView.swift:13` | Move to Keychain |
| No offline data persistence | P1 | N/A | Implement Core Data |
| No image caching | P2 | N/A | Add SDWebImage/Kingfisher |
| No data encryption | P0 | Throughout | FileProtection + Keychain |

**Recommendation:**
```swift
// Secure Storage
protocol SecureStorage {
    func save<T: Codable>(_ value: T, forKey key: String) throws
    func retrieve<T: Codable>(forKey key: String) throws -> T?
    func delete(forKey key: String) throws
}

class KeychainStorage: SecureStorage {
    func save<T: Codable>(_ value: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(value)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.saveFailed }
    }
}

// Core Data Stack
class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "ParkingApp")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
        
        // Enable encryption
        container.persistentStoreDescriptions.first?.setOption(
            FileProtectionType.complete as NSObject,
            forKey: NSPersistentStoreFileProtectionKey
        )
    }
}
```

**Media Storage Strategy:**
- Upload: Background URLSession for reliability
- Compression: 80% JPEG quality, max 1024x1024
- EXIF stripping for privacy
- CDN: Firebase Storage with signed URLs
- Local cache: Kingfisher with 100MB limit

---

### D) Security and Privacy

#### Current State - OWASP MASVS Mapping

| MASVS Control | Status | Evidence | Remediation |
|--------------|--------|----------|-------------|
| **MSTG-STORAGE-1** (Sensitive data storage) | ❌ FAIL | UserDefaults for uid | Use Keychain |
| **MSTG-STORAGE-2** (No sensitive logs) | ❌ FAIL | `print()` statements | Redact PII, use os_log |
| **MSTG-STORAGE-6** (No data in keyboard cache) | ⚠️ PARTIAL | No autocorrect disabling | Disable for sensitive fields |
| **MSTG-STORAGE-14** (Encrypted local storage) | ❌ FAIL | No encryption | FileProtection.complete |
| **MSTG-NETWORK-1** (TLS for all connections) | ⚠️ PARTIAL | Firebase uses TLS | Enforce ATS, no plaintext |
| **MSTG-NETWORK-2** (Certificate pinning) | ❌ FAIL | No pinning | Pin Firebase certs |
| **MSTG-NETWORK-3** (Secure channel verified) | ❌ FAIL | No validation | Implement TLS validation |
| **MSTG-AUTH-1** (Server-side authentication) | ✅ PASS | Firebase Auth | Maintain |
| **MSTG-AUTH-6** (Biometric auth) | ❌ MISSING | No Face/Touch ID | Implement LocalAuthentication |
| **MSTG-CODE-2** (Debug disabled in release) | ⚠️ UNKNOWN | Not verified | Add build settings check |
| **MSTG-CODE-3** (No debug symbols) | ⚠️ UNKNOWN | Not verified | Strip in release |
| **MSTG-RESILIENCE-1** (Jailbreak detection) | ❌ MISSING | No detection | Add runtime checks (optional) |

**Critical Security Fixes:**

```swift
// 1. Secure credential storage
class AuthService {
    private let secureStorage: SecureStorage
    
    func saveCredentials(_ token: String, userId: String) throws {
        try secureStorage.save(token, forKey: "authToken")
        try secureStorage.save(userId, forKey: "userId")
    }
}

// 2. Certificate Pinning
class PinnedURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let serverCertData = SecCertificateCopyData(certificate) as Data
        let pinnedCertData = // Load from bundle
        
        if serverCertData == pinnedCertData {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

// 3. PII Redaction
extension OSLog {
    static func safePrint(_ message: String, file: String = #file, function: String = #function) {
        let redacted = message.replacingOccurrences(
            of: "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b",
            with: "[EMAIL REDACTED]",
            options: .regularExpression
        )
        os_log("%{public}@", log: .default, type: .info, redacted)
    }
}
```

**Privacy Manifest (Required for App Store):**
```xml
<!-- PrivacyInfo.xcprivacy -->
<key>NSPrivacyTracking</key>
<false/>
<key>NSPrivacyTrackingDomains</key>
<array/>
<key>NSPrivacyCollectedDataTypes</key>
<array>
    <dict>
        <key>NSPrivacyCollectedDataType</key>
        <string>NSPrivacyCollectedDataTypeLocation</string>
        <key>NSPrivacyCollectedDataTypeLinked</key>
        <true/>
        <key>NSPrivacyCollectedDataTypePurposes</key>
        <array>
            <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
        </array>
    </dict>
</array>
```

---

### E) UI/UX, Theming, and Accessibility

#### Current State
**Files:** 
- [`ContentView.swift:217-221`](https://github.com/sarthakvadhel/Parking-App-for-iOS/blob/17cd4d4c49eb8e248486777dc5e4bd8655fadd49/ParkingApp/SpotsView/ContentView.swift#L217-L221) - Hardcoded colors
- [`HourSliderView.swift`](https://github.com/sarthakvadhel/Parking-App-for-iOS/blob/17cd4d4c49eb8e248486777dc5e4bd8655fadd49/ParkingApp/DetailView/HourSliderView.swift) - Slider component

**Issues:**
| Finding | Severity | Evidence | Impact |
|---------|----------|----------|--------|
| Hardcoded colors, no dark mode | P2 | `Color.init(red:...)` | Poor UX |
| Slider not visible | P2 | `HourSliderView:44-47` | Broken feature |
| No Dynamic Type support | P2 | Fixed font sizes | Accessibility issue |
| No VoiceOver labels | P2 | Missing `.accessibility` | Screen reader broken |
| Insufficient contrast | P2 | Black on dark backgrounds | WCAG AA failure |

**Design System Architecture:**

```swift
// Design Tokens
enum DesignTokens {
    enum Colors {
        static let primary = Color("Primary")  // Asset catalog
        static let secondary = Color("Secondary")
        static let background = Color("Background")
        static let surface = Color("Surface")
        static let error = Color("Error")
        
        // Semantic colors with contrast guarantee
        static let textOnLight = Color.black
        static let textOnDark = Color.white
        static let textOnPrimary = Color.white  // WCAG AA: 4.5:1
    }
    
    enum Typography {
        static let largeTitle = Font.system(.largeTitle, design: .rounded)
        static let title = Font.system(.title, design: .rounded)
        static let headline = Font.system(.headline, design: .rounded)
        static let body = Font.system(.body, design: .default)
        static let caption = Font.system(.caption, design: .default)
    }
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }
}

// Dark Mode Support
extension Color {
    static let adaptiveBackground = Color(
        light: .white,
        dark: .black
    )
    
    static let adaptiveText = Color(
        light: .black,
        dark: .white
    )
    
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// Accessibility
extension View {
    func parkingAccessibility(
        label: String,
        hint: String? = nil,
        value: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
    }
}
```

**Fixed Slider Component:**
```swift
struct ImprovedHourSlider: View {
    @Binding var selectedHours: Double
    @State private var availableSlots: [TimeSlot] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            // Next available slot indicator
            if let nextSlot = availableSlots.first {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(DesignTokens.Colors.primary)
                    Text("Next available: \(nextSlot.formatted)")
                        .font(DesignTokens.Typography.caption)
                }
            }
            
            // Modern slider with visibility
            Slider(
                value: $selectedHours,
                in: 0...12,
                step: 1
            ) {
                Text("Duration")
            } minimumValueLabel: {
                Text("0h")
                    .foregroundColor(DesignTokens.Colors.textOnLight)
            } maximumValueLabel: {
                Text("12h")
                    .foregroundColor(DesignTokens.Colors.textOnLight)
            }
            .tint(DesignTokens.Colors.primary)
            .parkingAccessibility(
                label: "Parking duration",
                hint: "Swipe to select hours",
                value: "\(Int(selectedHours)) hours"
            )
        }
        .padding()
        .background(DesignTokens.Colors.surface)
        .cornerRadius(12)
    }
}
```

**Acceptance Criteria:**
- [ ] WCAG AA contrast ratio (4.5:1 for text) verified with snapshot tests
- [ ] Dynamic Type scaling tested with all sizes
- [ ] VoiceOver navigation complete and tested
- [ ] Dark mode support with proper color inversion
- [ ] 60fps UI performance on iPhone SE (oldest target)

---

### F) Location, Maps, and Background Work

#### Current State
**File:** [`ParkingFinder.swift`](https://github.com/sarthakvadhel/Parking-App-for-iOS/blob/17cd4d4c49eb8e248486777dc5e4bd8655fadd49/ParkingApp/ViewModel/ParkingFinder.swift)

**Evidence:**
- Line 30: `requestWhenInUseAuthorization()` - Basic permission request
- Line 31: `startUpdatingLocation()` - Continuous updates (battery drain)
- No background location
- No geofencing

**Issues:**
| Finding | Severity | Impact | Recommendation |
|---------|----------|--------|----------------|
| Continuous location updates | P2 | Battery drain | Use significant location change |
| No permission flow UI | P2 | Confusing UX | Add custom permission screen |
| No fallback for denied permissions | P2 | App unusable | Allow manual location entry |
| No nearest parking calculation | P1 | Poor UX | Add distance sorting |

**Improved Location Service:**
```swift
class LocationService: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var nearestParkingSpots: [ParkingLot] = []
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100 // Update every 100m
    }
    
    func requestPermission() {
        // Show custom permission primer first
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func calculateNearestParking(_ parkingLots: [ParkingLot]) {
        guard let userLocation = currentLocation else { return }
        
        let sorted = parkingLots.sorted { lot1, lot2 in
            let distance1 = userLocation.distance(from: CLLocation(
                latitude: lot1.latitude,
                longitude: lot1.longitude
            ))
            let distance2 = userLocation.distance(from: CLLocation(
                latitude: lot2.latitude,
                longitude: lot2.longitude
            ))
            return distance1 < distance2
        }
        
        DispatchQueue.main.async {
            self.nearestParkingSpots = sorted
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            // Show fallback UI
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        locationManager.stopUpdatingLocation() // Save battery
    }
}
```

**Bottom Card with Nearest Parking:**
```swift
struct NearestParkingCard: View {
    @ObservedObject var locationService: LocationService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nearest Parking")
                .font(.headline)
            
            ForEach(locationService.nearestParkingSpots.prefix(3)) { spot in
                HStack {
                    VStack(alignment: .leading) {
                        Text(spot.name)
                            .font(.subheadline)
                        if let distance = locationService.currentLocation?.distance(
                            from: CLLocation(latitude: spot.latitude, longitude: spot.longitude)
                        ) {
                            Text("\(Int(distance))m away")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    Text("₹\(spot.hourlyCharge, specifier: "%.0f")/h")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}
```

---

## Feature Specifications

### Issue #1: Startup Crash with Internet

**Root Cause Analysis:**
- **File:** [`ContentView.swift:188, 211`](https://github.com/sarthakvadhel/Parking-App-for-iOS/blob/17cd4d4c49eb8e248486777dc5e4bd8655fadd49/ParkingApp/SpotsView/ContentView.swift#L188)
- **Issue:** `parkingFinder.spots[0]` accessed before async `loadParkingLots()` completes
- **Trigger:** When internet is ON, Firebase query is fast but not instant; array is empty during view setup
- **When offline:** Static fallback data loads synchronously in `Data.spots`

**Fix:**
```swift
// Before (CRASHES):
ParkingCardView(parkingPlace: parkingFinder.selectedPlace ?? parkingFinder.spots[0])

// After (SAFE):
if let selectedPlace = parkingFinder.selectedPlace {
    ParkingCardView(parkingPlace: selectedPlace)
} else if !parkingFinder.spots.isEmpty {
    ParkingCardView(parkingPlace: parkingFinder.spots[0])
} else {
    ParkingPlaceholderCard()
}

// Also fix in .onAppear:
.onAppear {
    if !parkingFinder.spots.isEmpty {
        parkingFinder.selectedPlace = parkingFinder.spots[0]
    }
}
```

**Acceptance Criteria:**
- [ ] App launches successfully with internet ON
- [ ] App launches successfully with internet OFF
- [ ] No crashes when toggling airplane mode
- [ ] Loading state shown while data fetches
- [ ] MetricKit crash-free sessions ≥ 99.9%

**Test Cases:**
```swift
func testStartupWithInternet() async throws {
    let viewModel = ParkingFinder()
    
    // Wait for async load
    try await Task.sleep(nanoseconds: 1_000_000_000)
    
    XCTAssertFalse(viewModel.spots.isEmpty)
    XCTAssertNotNil(viewModel.selectedPlace)
}

func testStartupOffline() async throws {
    // Disable network
    let viewModel = ParkingFinder()
    
    XCTAssertFalse(viewModel.spots.isEmpty, "Should have static fallback")
}
```

---

### Issue #2: Vendor Dashboard - Make Dynamic and Complete

**Current State:**
- Basic dashboard with statistics
- Add/Edit parking lots working
- Missing: Bookings, Photos, Reports, Settings

**Required Vendor Menu:**
```
┌─────────────────────────────┐
│     Vendor Dashboard        │
├─────────────────────────────┤
│ 📊 Overview (Stats)         │
│ 🏢 Manage Outlets           │ ← Working
│ 🅿️  Parking Spots           │ ← Working
│ 📋 Bookings & Leads         │ ← TO BUILD
│ 📸 Photos & Media           │ ← TO BUILD
│ 💰 Pricing & Availability   │ ← TO BUILD
│ 📈 Reports & Analytics      │ ← TO BUILD
│ ⚙️  Profile & Settings      │ ← TO BUILD
│ 🆘 Support                  │ ← TO BUILD
└─────────────────────────────┘
```

**Implementation Plan:**

1. **Bookings & Leads Screen**
```swift
struct VendorBookingsView: View {
    @State private var bookings: [Booking] = []
    @State private var filter: BookingFilter = .pending
    
    enum BookingFilter: String, CaseIterable {
        case pending = "Pending"
        case active = "Active"
        case completed = "Completed"
    }
    
    var body: some View {
        VStack {
            Picker("Filter", selection: $filter) {
                ForEach(BookingFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            
            List(filteredBookings) { booking in
                BookingLeadCard(booking: booking) {
                    // Accept/Decline actions
                    acceptBooking(booking)
                }
            }
        }
        .navigationTitle("Bookings & Leads")
    }
    
    private func acceptBooking(_ booking: Booking) async {
        var updatedBooking = booking
        updatedBooking.status = .active
        
        try? await FirestoreManager.shared.updateBooking(updatedBooking)
        
        // Send push notification to user
        await NotificationService.shared.sendBookingConfirmation(
            userId: booking.userId,
            parkingLotName: booking.parkingLotName
        )
    }
}
```

2. **Photos & Media Screen**
```swift
struct VendorPhotosView: View {
    @State private var selectedLot: ParkingLot?
    @State private var showImagePicker = false
    @State private var images: [ParkingImage] = []
    
    var body: some View {
        VStack {
            // Parking lot selector
            Picker("Select Outlet", selection: $selectedLot) {
                // List of vendor's parking lots
            }
            
            // Photo grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(images) { image in
                    AsyncImage(url: image.thumbnailURL) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    .clipped()
                }
                
                // Add photo button
                Button {
                    showImagePicker = true
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 100, height: 100)
                        .background(Color.gray.opacity(0.2))
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { image in
                uploadImage(image, for: selectedLot)
            }
        }
    }
    
    private func uploadImage(_ image: UIImage, for lot: ParkingLot?) async {
        guard let lot = lot else { return }
        
        // Compress
        guard let compressed = image.jpegData(compressionQuality: 0.8) else { return }
        
        // Strip EXIF
        let stripped = stripEXIF(compressed)
        
        // Upload to Firebase Storage
        let url = try? await StorageService.shared.uploadImage(
            stripped,
            path: "parkingLots/\(lot.id)/\(UUID().uuidString).jpg"
        )
        
        // Save reference to Firestore
        // Update UI
    }
}
```

3. **Reports & Analytics**
```swift
struct VendorReportsView: View {
    @State private var dateRange: DateRange = .thisMonth
    @State private var analytics: VendorAnalytics?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Key metrics
                HStack {
                    MetricCard(
                        title: "Total Revenue",
                        value: "₹\(analytics?.totalRevenue ?? 0)",
                        trend: .up
                    )
                    MetricCard(
                        title: "Bookings",
                        value: "\(analytics?.totalBookings ?? 0)",
                        trend: .up
                    )
                }
                
                // Charts
                BookingChart(data: analytics?.bookingsByDay ?? [])
                RevenueChart(data: analytics?.revenueByDay ?? [])
                
                // Download report button
                Button("Download PDF Report") {
                    generatePDFReport()
                }
            }
        }
        .navigationTitle("Reports & Analytics")
    }
}
```

**Acceptance Criteria:**
- [ ] All 8 menu items navigate to functional screens
- [ ] Each screen has proper loading/empty/error states
- [ ] Bookings screen shows real-time updates
- [ ] Photos upload with progress indicator
- [ ] Reports generate accurate data
- [ ] All screens have unit + UI tests

---

### Issue #3: Booking Immutability

**Business Rules:**
1. User cannot modify booking during active time window
2. Vendor can perform admin actions (cancel with policy)
3. Audit log for all changes

**Implementation:**
```swift
class BookingService {
    func canUserModifyBooking(_ booking: Booking) -> Bool {
        guard booking.status == .active else { return true }
        
        let now = Date()
        let bookingEndTime = booking.endTime
        
        // Immutable during active window
        return now > bookingEndTime
    }
    
    func canVendorCancelBooking(_ booking: Booking) -> Bool {
        // Vendor can cancel with policy
        return true
    }
    
    func vendorCancelBooking(
        _ booking: Booking,
        reason: CancellationReason,
        vendorId: String
    ) async throws {
        var updatedBooking = booking
        updatedBooking.status = .cancelled
        updatedBooking.cancellationReason = reason
        
        // Audit log
        let audit = AuditLog(
            action: .bookingCancelled,
            performedBy: vendorId,
            entityId: booking.id,
            reason: reason.rawValue,
            timestamp: Date()
        )
        
        try await FirestoreManager.shared.createAuditLog(audit)
        try await FirestoreManager.shared.updateBooking(updatedBooking)
        
        // Notify user
        await NotificationService.shared.sendCancellationNotice(
            userId: booking.userId,
            reason: reason
        )
        
        // Refund if applicable
        if reason == .vendorFault {
            await processRefund(booking)
        }
    }
}

// UI Validation
struct BookingDetailView: View {
    let booking: Booking
    @State private var showModifySheet = false
    
    var canModify: Bool {
        BookingService.shared.canUserModifyBooking(booking)
    }
    
    var body: some View {
        VStack {
            // ... booking details
            
            Button("Modify Booking") {
                showModifySheet = true
            }
            .disabled(!canModify)
            .opacity(canModify ? 1.0 : 0.5)
        }
        .alert(isPresented: $showImmutableWarning) {
            Alert(
                title: Text("Cannot Modify"),
                message: Text("Booking cannot be modified during active time window."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
```

**API Contract:**
```
PATCH /bookings/{bookingId}

Headers:
  Authorization: Bearer <token>
  X-User-Role: user|vendor

Body:
{
  "status": "cancelled",
  "vendorOverride": true,  // Only if role=vendor
  "reason": "vendor_fault"
}

Response (403 Forbidden):
{
  "error": "BOOKING_IMMUTABLE",
  "message": "Booking cannot be modified during active time",
  "immutable_until": "2025-10-11T18:00:00Z"
}
```

**Acceptance Criteria:**
- [ ] User modification blocked during active window (client + server)
- [ ] Vendor can cancel with reason selection
- [ ] All changes logged to audit trail
- [ ] Optimistic UI with rollback on error
- [ ] Push notification sent on vendor action
- [ ] Refund processed for vendor fault

---

### Issue #6: Real-Time Updates (Vendor → User)

**Architecture:**
```
Vendor Creates/Updates Spot
         ↓
   Firestore Write
         ↓
   Snapshot Listener (User devices)
         ↓
   Local Cache Update
         ↓
   UI Refresh (Diff-based)
```

**Implementation:**
```swift
class RealtimeParkingService: ObservableObject {
    @Published var parkingLots: [ParkingLot] = []
    private var listener: ListenerRegistration?
    
    func startListening() {
        listener = Firestore.firestore()
            .collection("parkingLots")
            .whereField("isActive", isEqualTo: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let lots = documents.compactMap { 
                    try? $0.data(as: ParkingLot.self) 
                }
                
                DispatchQueue.main.async {
                    self?.parkingLots = lots
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}

// In View
struct UserMapView: View {
    @StateObject private var realtimeService = RealtimeParkingService()
    
    var body: some View {
        Map(/* ... */)
            .onAppear {
                realtimeService.startListening()
            }
            .onDisappear {
                realtimeService.stopListening()
            }
    }
}
```

**Fallback: Short Polling**
```swift
class PollingParkingService {
    private var pollingTask: Task<Void, Never>?
    
    func startPolling(interval: TimeInterval = 3.0) {
        pollingTask = Task {
            while !Task.isCancelled {
                await fetchLatestParkingLots()
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }
    
    func stopPolling() {
        pollingTask?.cancel()
    }
}
```

**Acceptance Criteria:**
- [ ] Updates appear in user UI within 3 seconds
- [ ] Battery usage < 5% over 1 hour
- [ ] Smooth animations on updates
- [ ] Fallback to polling if snapshot fails
- [ ] Proper loading/error states

---

### Issue #7: Booking Flow - Vendor Notification

**Flow:**
```
User Books Spot → Booking Status: PENDING
                       ↓
                 APNs to Vendor
                       ↓
              Vendor Sees Lead
                       ↓
         Accept ← → Decline
            ↓              ↓
    Status: ACTIVE    Status: DECLINED
            ↓              ↓
      User Notified    Suggest Alternatives
```

**Push Notification Setup:**
```swift
// AppDelegate
func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    
    // Save to Firestore
    Task {
        try? await FirestoreManager.shared.saveDeviceToken(token)
    }
}

// Notification Service
class NotificationService {
    func sendBookingRequest(
        vendorId: String,
        bookingId: String,
        userName: String
    ) async throws {
        let message: [String: Any] = [
            "to": try await getVendorToken(vendorId),
            "notification": [
                "title": "New Booking Request",
                "body": "\(userName) wants to book your parking spot",
                "sound": "default"
            ],
            "data": [
                "type": "booking_request",
                "bookingId": bookingId,
                "action": "vendor_accept"
            ]
        ]
        
        // Send via Firebase Cloud Messaging
        try await sendFCM(message)
    }
    
    func handleBookingAccepted(booking: Booking) async {
        // Update booking status
        var updated = booking
        updated.status = .active
        try? await FirestoreManager.shared.updateBooking(updated)
        
        // Notify user
        try? await sendUserNotification(
            userId: booking.userId,
            title: "Booking Confirmed",
            body: "Your parking request was accepted"
        )
    }
}

// Vendor UI
struct BookingRequestCard: View {
    let booking: Booking
    @State private var isProcessing = false
    
    var body: some View {
        VStack {
            Text("Booking Request from \(booking.userName)")
            
            HStack {
                Button("Accept") {
                    acceptBooking()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Decline") {
                    declineBooking()
                }
                .buttonStyle(.bordered)
            }
            .disabled(isProcessing)
        }
    }
    
    private func acceptBooking() {
        isProcessing = true
        Task {
            try? await NotificationService.shared.handleBookingAccepted(booking)
            isProcessing = false
        }
    }
}
```

**Acceptance Criteria:**
- [ ] Vendor receives push within 5s of user booking
- [ ] Accept/decline actions update in real-time
- [ ] User notified of vendor decision
- [ ] Declined bookings suggest alternatives
- [ ] Notification delivery rate > 95%
- [ ] E2E notification test in CI

---

## CI/CD Plan

### GitHub Actions Workflow

```yaml
name: iOS CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  XCODE_VERSION: '15.0'
  IOS_SIMULATOR: 'iPhone 15 Pro'

jobs:
  lint:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      
      - name: Install SwiftLint
        run: brew install swiftlint
      
      - name: Run SwiftLint
        run: swiftlint lint --strict
      
      - name: Run SwiftFormat
        run: |
          brew install swiftformat
          swiftformat --lint .

  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_${{ env.XCODE_VERSION }}.app
      
      - name: Cache SPM
        uses: actions/cache@v3
        with:
          path: .build
          key: ${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}
      
      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -scheme ParkingApp \
            -destination "platform=iOS Simulator,name=${{ env.IOS_SIMULATOR }}" \
            -resultBundlePath TestResults.xcresult \
            -enableCodeCoverage YES
      
      - name: Generate Coverage Report
        run: |
          xcrun xccov view --report --json TestResults.xcresult > coverage.json
          bash <(curl -s https://codecov.io/bash)
      
      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: TestResults.xcresult

  ui-test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      
      - name: Run UI Tests
        run: |
          xcodebuild test \
            -scheme ParkingAppUITests \
            -destination "platform=iOS Simulator,name=${{ env.IOS_SIMULATOR }}" \
            -resultBundlePath UITestResults.xcresult
      
      - name: Upload Screenshots
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: ui-test-screenshots
          path: UITestResults.xcresult

  security-scan:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      
      - name: Run MobSF Scan
        run: |
          # Static analysis for security
          brew install libimobiledevice
          # Custom security checks
      
      - name: Check for Secrets
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./

  build-testflight:
    needs: [lint, test, ui-test]
    if: github.ref == 'refs/heads/main'
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Fastlane
        run: gem install fastlane
      
      - name: Setup Certificates
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          FASTLANE_PASSWORD: ${{ secrets.FASTLANE_PASSWORD }}
        run: fastlane match appstore --readonly
      
      - name: Build & Upload to TestFlight
        env:
          APP_STORE_CONNECT_API_KEY: ${{ secrets.ASC_API_KEY }}
        run: |
          fastlane beta \
            changelog:"$(git log -1 --pretty=%B)" \
            build_number:${{ github.run_number }}
      
      - name: Notify Slack
        if: always()
        run: |
          curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
            -H 'Content-Type: application/json' \
            -d '{"text":"TestFlight build ${{ github.run_number }} - ${{ job.status }}"}'
```

### Fastlane Configuration

```ruby
# fastlane/Fastfile

default_platform(:ios)

platform :ios do
  desc "Run tests"
  lane :test do
    scan(
      scheme: "ParkingApp",
      devices: ["iPhone 15 Pro"],
      code_coverage: true
    )
  end

  desc "Build and upload to TestFlight"
  lane :beta do |options|
    increment_build_number(build_number: options[:build_number])
    
    build_app(
      scheme: "ParkingApp",
      export_method: "app-store",
      export_options: {
        provisioningProfiles: {
          "com.parking.app" => "match AppStore com.parking.app"
        }
      }
    )
    
    upload_to_testflight(
      api_key_path: ENV['APP_STORE_CONNECT_API_KEY'],
      changelog: options[:changelog],
      distribute_external: true,
      groups: ["Beta Testers"],
      notify_external_testers: true
    )
  end

  desc "Release to App Store"
  lane :release do
    capture_screenshots
    upload_to_app_store(
      submit_for_review: true,
      automatic_release: false,
      phased_release: true,
      submission_information: {
        add_id_info_uses_idfa: false
      }
    )
  end
end
```

---

## Observability Plan

### Crash Reporting Setup

```swift
// ParkingAppApp.swift
import FirebaseCrashlytics

@main
struct ParkingAppApp: App {
    init() {
        FirebaseApp.configure()
        
        #if !DEBUG
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        #endif
    }
}

// Custom Crash Logging
class CrashLogger {
    static func log(error: Error, context: [String: Any] = [:]) {
        Crashlytics.crashlytics().record(error: error)
        
        for (key, value) in context {
            Crashlytics.crashlytics().setCustomValue(value, forKey: key)
        }
    }
    
    static func logNonFatal(_ message: String, metadata: [String: Any] = [:]) {
        let error = NSError(
            domain: "ParkingApp",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: message,
                "metadata": metadata
            ]
        )
        Crashlytics.crashlytics().record(error: error)
    }
}
```

### Analytics Events

```swift
enum AnalyticsEvent {
    case appLaunched
    case userLoggedIn(role: String)
    case parkingBooked(lotId: String, duration: Int)
    case bookingCancelled(reason: String)
    case vendorLotCreated
    case searchPerformed(query: String, results: Int)
    case paymentCompleted(amount: Double, method: String)
    
    var name: String {
        switch self {
        case .appLaunched: return "app_launched"
        case .userLoggedIn: return "user_logged_in"
        case .parkingBooked: return "parking_booked"
        // ...
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .userLoggedIn(let role):
            return ["role": role]
        case .parkingBooked(let lotId, let duration):
            return ["lot_id": lotId, "duration": duration]
        // ...
        default:
            return [:]
        }
    }
}

class AnalyticsService {
    static let shared = AnalyticsService()
    
    func track(_ event: AnalyticsEvent) {
        // Redact PII before logging
        let safeParams = redactPII(event.parameters)
        
        #if !DEBUG
        Analytics.logEvent(event.name, parameters: safeParams)
        #else
        print("[Analytics] \(event.name): \(safeParams)")
        #endif
    }
    
    private func redactPII(_ params: [String: Any]) -> [String: Any] {
        var safe = params
        
        // Remove email, phone, etc.
        safe.removeValue(forKey: "email")
        safe.removeValue(forKey: "phone")
        
        return safe
    }
}
```

### Performance Monitoring

```swift
import FirebasePerformance

class PerformanceMonitor {
    static func trace(_ name: String, operation: () async throws -> Void) async rethrows {
        let trace = Performance.startTrace(name: name)
        defer { trace.stop() }
        
        try await operation()
    }
}

// Usage
await PerformanceMonitor.trace("load_parking_lots") {
    let lots = try await FirestoreManager.shared.fetchParkingLots()
}
```

### MetricKit Integration

```swift
class MetricsManager: NSObject, MXMetricManagerSubscriber {
    override init() {
        super.init()
        MXMetricManager.shared.add(self)
    }
    
    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            // App hang rate
            if let hangData = payload.applicationTimeMetrics {
                print("Hang time: \(hangData.cumulativeForegroundTime)")
            }
            
            // Memory footprint
            if let memoryData = payload.memoryMetrics {
                print("Peak memory: \(memoryData.peakMemoryUsage)")
            }
            
            // Battery usage
            if let batteryData = payload.cpuMetrics {
                print("CPU time: \(batteryData.cumulativeCPUTime)")
            }
        }
    }
}
```

### Dashboards & SLIs

```yaml
# Observability SLIs/SLOs

app_startup_time:
  sli: p95 < 2 seconds
  slo: 99.5%
  alert_threshold: 98%

crash_free_sessions:
  sli: >= 99.9%
  slo: 99.9%
  alert_threshold: 99.5%

booking_success_rate:
  sli: >= 99%
  slo: 99%
  alert_threshold: 97%

api_latency:
  sli: p95 < 1 second
  slo: 99%
  alert_threshold: 95%

search_latency:
  sli: p95 < 500ms
  slo: 99.5%
  alert_threshold: 98%
```

---

## 30/60/90-Day Roadmap

### Days 1-30: Critical Fixes & Foundation

| Priority | Task | Acceptance Criteria | Effort | Owner |
|----------|------|---------------------|--------|-------|
| P0 | Fix startup crash | Zero crashes on launch | 1d | iOS Dev |
| P0 | Secure Firebase config | Credentials in Keychain | 0.5d | iOS Dev |
| P0 | Implement crash reporting | Crashlytics integrated | 0.5d | iOS Dev |
| P1 | Add basic test infrastructure | XCTest target + 20% coverage | 2d | iOS Dev |
| P1 | Setup CI/CD pipeline | GitHub Actions + fastlane | 2d | DevOps |
| P1 | Implement booking immutability | Business rules enforced | 3d | iOS + Backend |
| P2 | Design system foundation | Color tokens + typography | 2d | iOS Dev |
| P2 | Location improvements | Permission flow + nearest parking | 3d | iOS Dev |

**Milestone 1:** Stable app with automated builds (Day 14)  
**Milestone 2:** Core UX improvements deployed (Day 30)

---

### Days 31-60: Core Features & Vendor Experience

| Priority | Task | Acceptance Criteria | Effort | Owner |
|----------|------|---------------------|--------|-------|
| P1 | Vendor bookings screen | Full CRUD + real-time updates | 5d | iOS Dev |
| P1 | Photo upload feature | Camera + compression + CDN | 4d | iOS + Backend |
| P1 | Real-time sync (vendor→user) | <3s latency | 3d | iOS + Backend |
| P1 | Push notifications setup | APNs + vendor accept flow | 4d | iOS + Backend |
| P2 | Reports & analytics | Charts + PDF export | 5d | iOS Dev |
| P2 | Search with images | Grid layout + tap navigation | 3d | iOS Dev |
| P3 | Profile management | Avatar + editable fields | 3d | iOS Dev |

**Milestone 3:** Complete vendor dashboard (Day 45)  
**Milestone 4:** Full booking flow with notifications (Day 60)

---

### Days 61-90: Polish & Launch Prep

| Priority | Task | Acceptance Criteria | Effort | Owner |
|----------|------|---------------------|--------|-------|
| P2 | Dark mode support | All screens + WCAG AA | 3d | iOS Dev |
| P2 | Accessibility audit | VoiceOver + Dynamic Type | 2d | iOS Dev |
| P2 | Slider redesign | Visible + 60fps | 2d | iOS Dev |
| P2 | All menu screens | Settings, payments, etc. | 5d | iOS Dev |
| P3 | Architecture refactor | Feature modules + DI | 5d | iOS Dev |
| P3 | Performance optimization | 60fps + <2s startup | 3d | iOS Dev |
| P3 | App Store assets | Screenshots + metadata | 2d | Marketing |
| P3 | Beta testing | TestFlight + feedback | 1w | QA |

**Milestone 5:** Feature complete (Day 75)  
**Milestone 6:** App Store submission (Day 90)

---

## Open Questions & Assumptions

### Questions Requiring Stakeholder Input:

1. **Target Users & Environment**
   - [ ] Is this B2C, B2B, or hybrid?
   - [ ] Enterprise/MDM distribution needed?
   - [ ] Geographic regions (impacts localization, currency)

2. **Backend/API Ownership**
   - [ ] Who owns Firebase project (access, billing)?
   - [ ] SLAs for Firebase services?
   - [ ] Need custom backend or Firebase only?

3. **Compliance & Security**
   - [ ] GDPR/CCPA requirements?
   - [ ] PCI-DSS for payments (if not Apple Pay)?
   - [ ] Data retention policies?

4. **iOS Version & Devices**
   - [ ] Minimum iOS version (recommend iOS 16+)?
   - [ ] iPad support required?
   - [ ] Apple Watch companion app?

5. **Payment Integration**
   - [ ] Apple Pay only or other gateways?
   - [ ] Refund policy and flow?
   - [ ] Subscription model or pay-per-booking?

6. **Feature Prioritization**
   - [ ] Which of issues #1-14 are must-have for v1.0?
   - [ ] Any features to defer to v1.1?

### Assumptions Made:

1. **Technical**
   - Using Firebase as primary backend (Auth, Firestore, Storage, FCM)
   - SwiftUI for all new screens
   - iOS 15+ minimum (90% market coverage)
   - iPhone only (iPad nice-to-have)

2. **Business**
   - Indian market (₹ currency)
   - B2C model (users book, vendors manage)
   - Cash + digital payments
   - No subscription (pay-per-use)

3. **Security**
   - OWASP MASVS L2 compliance target
   - Standard App Store privacy requirements
   - No regulated data (health, finance)

4. **Timeline**
   - 90-day delivery for MVP
   - 2-3 iOS developers available
   - Backend/DevOps support available
   - QA/Design resources available

---

## TL;DR - Top 10 Priorities

1. **[P0] Fix startup crash** - Array bounds check in ContentView (1 day)
2. **[P0] Secure credentials** - Move Firebase config to Keychain (0.5 days)
3. **[P1] Real-time sync** - Firestore listeners for vendor→user updates (3 days)
4. **[P1] Complete vendor dashboard** - Bookings, photos, reports screens (10 days)
5. **[P1] Booking immutability** - Enforce business rules client+server (3 days)
6. **[P1] Push notifications** - APNs for vendor accept flow (4 days)
7. **[P2] Test infrastructure** - XCTest + 70% coverage target (5 days)
8. **[P2] CI/CD pipeline** - GitHub Actions + fastlane (2 days)
9. **[P2] Design system** - Tokens + dark mode + accessibility (5 days)
10. **[P3] Crash reporting** - Firebase Crashlytics + analytics (1 day)

**Estimated Total Effort:** ~50 person-days (2 months with 2 devs)  
**Critical Path:** Crash fix → Vendor features → Real-time → Notifications → Testing → Launch

---

## Next Steps

1. **Review this document** with stakeholders
2. **Answer open questions** to refine scope
3. **Prioritize roadmap** based on business goals
4. **Assign team members** to each workstream
5. **Start with P0 crash fix** (immediate)
6. **Setup CI/CD** in parallel (Day 1-2)
7. **Weekly syncs** to track progress

---

**Document Status:** ✅ Ready for Review  
**Last Updated:** 2025-10-11  
**Prepared By:** iOS Architecture Team
