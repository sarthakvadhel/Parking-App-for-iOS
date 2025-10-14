# Maps Features - Developer Quick Reference

## Quick Start

### Using Distance Calculations

```swift
// In any view with access to ParkingFinder
@EnvironmentObject var parkingFinder: ParkingFinder

// Get distance to a spot
if let distance = parkingFinder.distanceToSpot(spot) {
    print("Distance: \(distance) meters")
}

// Get formatted distance string
let distanceText = parkingFinder.formattedDistance(to: spot)
// Returns: "450 m" or "2.5 km"

// Get nearest spot
if let nearest = parkingFinder.nearestSpot {
    print("Nearest: \(nearest.name)")
}

// Get all spots sorted by distance
let sortedSpots = parkingFinder.spotsSortedByDistance
```

### Checking User Location

```swift
// Check if location is available
if let location = parkingFinder.userLocation {
    print("Lat: \(location.coordinate.latitude)")
    print("Lon: \(location.coordinate.longitude)")
} else {
    // Location not available yet
    // Show placeholder or disable distance features
}
```

### Opening Directions

```swift
func openDirections(to parkingItem: ParkingItem) {
    let lat = parkingItem.location.latitude
    let lon = parkingItem.location.longitude
    let name = parkingItem.name.addingPercentEncoding(
        withAllowedCharacters: .urlQueryAllowed
    ) ?? "Parking"
    
    if let url = URL(string: "http://maps.apple.com/?daddr=\(lat),\(lon)&dirflg=d&t=m&q=\(name)") {
        UIApplication.shared.open(url)
    }
}
```

## Code Snippets

### Show Distance on Any View

```swift
struct MyParkingView: View {
    let parking: ParkingItem
    @EnvironmentObject var parkingFinder: ParkingFinder
    
    var body: some View {
        HStack {
            Text(parking.name)
            Spacer()
            if parkingFinder.userLocation != nil {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                    Text(parkingFinder.formattedDistance(to: parking))
                }
                .foregroundColor(.blue)
            }
        }
    }
}
```

### Sort Parking List by Distance

```swift
struct ParkingListView: View {
    @EnvironmentObject var parkingFinder: ParkingFinder
    
    var sortedParkings: [ParkingItem] {
        parkingFinder.spotsSortedByDistance
    }
    
    var body: some View {
        List(sortedParkings) { parking in
            ParkingRow(parking: parking)
        }
    }
}
```

### Navigate to Parking on Map

```swift
// Center map on a parking spot
func selectParking(_ parking: ParkingItem) {
    parkingFinder.selectedPlace = parking
    parkingFinder.region = MKCoordinateRegion(
        center: parking.location,
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
}
```

### Show Map with User Location

```swift
Map(
    coordinateRegion: $region,
    showsUserLocation: true,  // Shows blue dot
    annotationItems: parkings
) { parking in
    MapAnnotation(coordinate: parking.location) {
        ParkingPin(parking: parking)
    }
}
```

## Common Patterns

### Pattern 1: Distance-Aware Card

```swift
struct DistanceAwareCard: View {
    let item: ParkingItem
    @EnvironmentObject var parkingFinder: ParkingFinder
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.name)
                .font(.headline)
            
            HStack {
                // Always show
                Label("\(item.carLimit)", systemImage: "car.fill")
                Text("₹\(item.fee, specifier: "%.2f")/h")
                
                Spacer()
                
                // Only show when location available
                if parkingFinder.userLocation != nil {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                        Text(parkingFinder.formattedDistance(to: item))
                    }
                    .foregroundColor(.blue)
                }
            }
            .font(.caption)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
```

### Pattern 2: Auto-Select Nearest

```swift
// In your view model or view's onAppear
func autoSelectNearest() {
    // Only auto-select if no manual selection exists
    if parkingFinder.selectedPlace == nil {
        if let nearest = parkingFinder.nearestSpot {
            parkingFinder.selectedPlace = nearest
        }
    }
}
```

### Pattern 3: Search with Distance Sorting

```swift
struct SearchResultsView: View {
    @EnvironmentObject var parkingFinder: ParkingFinder
    @State private var searchText = ""
    let allParkings: [ParkingItem]
    
    var filteredAndSorted: [ParkingItem] {
        let filtered = searchText.isEmpty ? allParkings : allParkings.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
        
        // Sort by distance if location available
        guard parkingFinder.userLocation != nil else { return filtered }
        
        return filtered.sorted { spot1, spot2 in
            let dist1 = parkingFinder.distanceToSpot(spot1) ?? .infinity
            let dist2 = parkingFinder.distanceToSpot(spot2) ?? .infinity
            return dist1 < dist2
        }
    }
    
    var body: some View {
        List(filteredAndSorted) { parking in
            SearchResultRow(parking: parking)
        }
        .searchable(text: $searchText)
    }
}
```

### Pattern 4: Directions Button

```swift
struct DirectionsButton: View {
    let parking: ParkingItem
    
    var body: some View {
        Button(action: openDirections) {
            HStack {
                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                Text("Get Directions")
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
    }
    
    private func openDirections() {
        let lat = parking.location.latitude
        let lon = parking.location.longitude
        let name = parking.name.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? "Parking"
        
        if let url = URL(string: "http://maps.apple.com/?daddr=\(lat),\(lon)&dirflg=d&t=m&q=\(name)") {
            UIApplication.shared.open(url)
        }
    }
}
```

## API Reference

### ParkingFinder Properties

| Property | Type | Description |
|----------|------|-------------|
| `userLocation` | `CLLocation?` | Current user location |
| `spots` | `[ParkingItem]` | All parking spots |
| `selectedPlace` | `ParkingItem?` | Currently selected spot |
| `region` | `MKCoordinateRegion` | Map region |
| `nearestSpot` | `ParkingItem?` | Computed - nearest spot |
| `spotsSortedByDistance` | `[ParkingItem]` | Computed - sorted array |

### ParkingFinder Methods

```swift
// Calculate distance to a spot
func distanceToSpot(_ spot: ParkingItem) -> Double?

// Get formatted distance string
func formattedDistance(to spot: ParkingItem) -> String

// Update map region to user location
func updateRegionToUserLocation(_ location: CLLocationCoordinate2D)
```

## Distance Formatting Rules

| Distance | Format | Example |
|----------|--------|---------|
| 0-999m | "XXX m" | "450 m" |
| 1000m+ | "X.X km" | "2.5 km" |
| No location | "" | "" |

## Apple Maps URL Parameters

```
http://maps.apple.com/?<parameters>

Required:
  daddr=<lat>,<lon>     Destination coordinates
  
Optional but recommended:
  dirflg=d              Driving directions (d=driving, w=walking)
  t=m                   Map type (m=map, s=satellite, h=hybrid)
  q=<name>              Location name for display
  
Examples:
  Driving:  dirflg=d
  Walking:  dirflg=w
  Transit:  dirflg=r
  Biking:   dirflg=b
```

## Testing Tips

### Simulator Location Testing

```swift
// In Xcode Simulator:
// Debug > Location > Custom Location...
// Or choose preset locations:
// - Apple
// - City Bicycle Ride
// - City Run
// - Freeway Drive
```

### Manual Location Testing

```swift
#if DEBUG
extension ParkingFinder {
    func setTestLocation(lat: Double, lon: Double) {
        userLocation = CLLocation(
            latitude: lat,
            longitude: lon
        )
    }
}
#endif

// Usage in previews or debug builds:
parkingFinder.setTestLocation(lat: 23.0225, lon: 72.5714)
```

### Distance Calculation Testing

```swift
func testDistanceCalculation() {
    let location1 = CLLocation(latitude: 23.0225, longitude: 72.5714)
    let location2 = CLLocation(latitude: 23.0400, longitude: 72.5314)
    
    let distance = location1.distance(from: location2)
    print("Distance: \(distance) meters")
    // Expected: ~3000-4000 meters
}
```

## Common Issues & Solutions

### Issue: Blue dot not appearing
**Solution:**
- Check Info.plist has location permissions
- Verify `showsUserLocation: true` on Map
- Test on real device (simulator may need location simulation)

### Issue: Distance showing as empty
**Solution:**
```swift
// Check if location is available before showing distance
if parkingFinder.userLocation != nil {
    Text(parkingFinder.formattedDistance(to: spot))
}
```

### Issue: Nearest spot not auto-selecting
**Solution:**
```swift
// Make sure location delegate is properly set
locationManager.delegate = self
locationManager.startUpdatingLocation()

// Check that auto-selection logic runs
if selectedPlace == nil, let nearest = nearestSpot {
    selectedPlace = nearest
}
```

### Issue: Directions not opening
**Solution:**
```swift
// Ensure URL encoding
let name = parkingItem.name.addingPercentEncoding(
    withAllowedCharacters: .urlQueryAllowed
) ?? "Parking"

// Check URL is valid
if let url = URL(string: "...") {
    print("Opening: \(url)")  // Debug log
    UIApplication.shared.open(url)
}
```

## Performance Tips

1. **Avoid Unnecessary Recalculations**
```swift
// Bad - recalculates on every render
var body: some View {
    Text(calculateDistance())  // Recalculated each render
}

// Good - use computed property
var distanceText: String {
    parkingFinder.formattedDistance(to: spot)
}

var body: some View {
    Text(distanceText)  // Cached in variable
}
```

2. **Batch Updates**
```swift
// Update multiple properties together
DispatchQueue.main.async {
    self.userLocation = location
    self.spots = updatedSpots
    self.selectedPlace = nearest
}
```

3. **Stop Updates When Not Needed**
```swift
// After getting initial location
locationManager.stopUpdatingLocation()

// Or use significant location changes
locationManager.startMonitoringSignificantLocationChanges()
```

## Integration Checklist

When adding distance features to a new view:

- [ ] Import MapKit if needed
- [ ] Add `@EnvironmentObject var parkingFinder: ParkingFinder`
- [ ] Check `parkingFinder.userLocation != nil` before showing distance
- [ ] Use `formattedDistance(to:)` for consistent formatting
- [ ] Pass environment object to child views
- [ ] Handle nil location gracefully
- [ ] Test with location permission denied
- [ ] Test with location permission granted

## Example: Complete Feature Implementation

```swift
import SwiftUI
import MapKit

struct NearbyParkingView: View {
    @EnvironmentObject var parkingFinder: ParkingFinder
    @State private var selectedParking: ParkingItem?
    
    var nearbyParkings: [ParkingItem] {
        parkingFinder.spotsSortedByDistance.prefix(5).map { $0 }
    }
    
    var body: some View {
        VStack {
            // Header
            Text("Nearby Parking")
                .font(.title2)
                .bold()
            
            // Location status
            if parkingFinder.userLocation == nil {
                HStack {
                    ProgressView()
                    Text("Determining location...")
                }
                .foregroundColor(.gray)
                .padding()
            }
            
            // List of nearby parkings
            ScrollView {
                ForEach(nearbyParkings) { parking in
                    ParkingCard(parking: parking)
                        .onTapGesture {
                            selectParking(parking)
                        }
                }
            }
            
            // Directions button for selected parking
            if let selected = selectedParking {
                Button("Get Directions to \(selected.name)") {
                    openDirections(to: selected)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
    }
    
    private func selectParking(_ parking: ParkingItem) {
        selectedParking = parking
        parkingFinder.selectedPlace = parking
        
        // Center map on selection
        parkingFinder.region = MKCoordinateRegion(
            center: parking.location,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
    
    private func openDirections(to parking: ParkingItem) {
        let lat = parking.location.latitude
        let lon = parking.location.longitude
        let name = parking.name.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? "Parking"
        
        if let url = URL(string: "http://maps.apple.com/?daddr=\(lat),\(lon)&dirflg=d&t=m&q=\(name)") {
            UIApplication.shared.open(url)
        }
    }
}

struct ParkingCard: View {
    let parking: ParkingItem
    @EnvironmentObject var parkingFinder: ParkingFinder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(parking.name)
                    .font(.headline)
                
                HStack {
                    Label("\(parking.carLimit)", systemImage: "car.fill")
                    Text("₹\(parking.fee, specifier: "%.2f")/h")
                    
                    Spacer()
                    
                    if parkingFinder.userLocation != nil {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                            Text(parkingFinder.formattedDistance(to: parking))
                        }
                        .foregroundColor(.blue)
                        .font(.caption)
                    }
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
```

## Summary

This implementation provides:
- ✅ User location tracking
- ✅ Distance calculations
- ✅ Nearest parking identification
- ✅ Distance-based sorting
- ✅ Turn-by-turn directions
- ✅ Consistent formatting
- ✅ Performance optimization
- ✅ Error handling

All features are production-ready and follow iOS best practices.
