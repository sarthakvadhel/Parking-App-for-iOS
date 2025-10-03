# Parking with Sarthak - iOS App

A fully functional, production-ready parking space finder and vendor management app built with SwiftUI and Firebase.

## Overview

## Features

### 🔐 Authentication & User Management
- Modern authentication UI with "Parking with Sarthak" branding
- Role-based registration: **User** (finding parking) or **Vendor** (providing parking)
- Proper credential validation with error handling
- Success/error notifications with alerts

### 👤 User Features
- **Vehicle Management**
  - Register multiple vehicles with details (number, model, manufacturer, color)
  - Select active vehicle for bookings
  - Dynamic vehicle display in navigation
  
- **Parking Discovery**
  - Real-time location tracking
  - Dynamic display of nearby parking spots from Firestore
  - Functional search by name or address
  - View detailed parking information (description, charges, terms, late fees)

- **Booking System**
  - Book parking spaces linked to selected vehicle
  - Flexible duration selection
  - Payment integration with cash option
  - Booking confirmation and validation
  - 🚀 More payment modes coming soon (UPI, Card, Wallet)

- **User Menu**
  - Profile display with user information
  - Access to bookings, vehicles, and settings
  - Quick sign-out option

### 🏢 Vendor Features
- **Parking Lot Registration**
  - Detailed lot information (name, description, address)
  - Pricing configuration (hourly charges, late fees)
  - Terms and conditions setup
  - Interactive map location picker
  - Capacity management

- **Vendor Dashboard**
  - Real-time statistics (total lots, spaces, availability)
  - View all registered parking lots
  - Edit lot details and pricing
  - Manage lot status (active/inactive)
  - Business insights at a glance

### 💳 Payment & Bookings
- Cash payment option available
- Dynamic booking creation
- Payment tracking and history
- Future-ready for payment gateway integration

### 🎨 UI/UX Enhancements
- Modern, clean interface design
- Proper color contrast for all UI elements
- Responsive layouts and animations
- Loading states and progress indicators
- Error handling with user-friendly messages

## Tech Stack

- **Frontend**: SwiftUI
- **Backend**: Firebase
  - Authentication
  - Firestore Database
  - Cloud Storage (for images)
- **Maps**: MapKit
- **Location Services**: CoreLocation

## Architecture

### Data Models
- `User` - User profile with role-based access
- `Vehicle` - User vehicle information
- `ParkingLot` - Vendor parking lot details
- `Booking` - Parking bookings with status tracking
- `Payment` - Payment records and transactions

### Services
- `FirestoreManager` - Centralized database operations
- `ParkingFinder` - Location-based parking discovery with CLLocationManager

### Views
- Authentication flow with role selection
- User main view with map and search
- Vendor dashboard with management features
- Dynamic registration flows for both roles

## Getting Started

1. Clone the repository
2. Open `ParkingApp.xcodeproj` in Xcode
3. Configure Firebase:
   - Add your `GoogleService-Info.plist` to the project
   - Enable Authentication and Firestore in Firebase Console
4. Build and run the project

## Firebase Setup

### Firestore Collections
- `users` - User profiles
- `vehicles` - Vehicle registrations
- `parkingLots` - Vendor parking lots
- `bookings` - Parking bookings
- `payments` - Payment records

### Security Rules
Ensure proper security rules are configured in Firestore for production use.

## Currency
All pricing is displayed in Indian Rupees (₹).

## Future Enhancements
- [ ] Profile picture upload
- [ ] Multiple payment gateway integration (UPI, Card, Wallet)
- [ ] Push notifications for bookings
- [ ] Rating and review system
- [ ] Analytics and reporting
- [ ] Advanced search filters
- [ ] Booking history and receipts
- [ ] Theme customization

## License

This project is available for educational purposes.

---

**Developed with ❤️ for seamless parking experiences**
#### Dribble Design Inspiration: https://dribbble.com/shots/14408667-Parking-Space-Finder-Concept
