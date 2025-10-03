//
//  ContentView.swift
//  ParkingApp
//
//  Created by Anik on 24/10/20.
//

import SwiftUI
import MapKit

struct ContentView: View {

    @AppStorage("uid") var userID: String = ""
    @AppStorage("userRole") var userRole: String = ""
    @StateObject var parkingFinder = ParkingFinder()

    @State private var showMenu: Bool = false
    @State private var showVehicleRegistration = false
    @State private var showVendorRegistration = false
    @State private var hasCheckedRegistration = false

    // 75% width menu
    private var menuWidth: CGFloat { UIScreen.screenWidth * 0.75 }

    var body: some View {
        if userID == "" {
            AuthView()
        } else if userRole == UserRole.vendor.rawValue {
            // Vendor flow
            if !hasCheckedRegistration {
                ProgressView("Loading...")
                    .onAppear {
                        checkVendorRegistration()
                    }
            } else {
                VendorDashboardView()
                    .sheet(isPresented: $showVendorRegistration) {
                        VendorRegistrationView()
                            .onDisappear {
                                hasCheckedRegistration = false
                            }
                    }
            }
        } else {
            // User flow
            if !hasCheckedRegistration {
                ProgressView("Loading...")
                    .onAppear {
                        checkUserRegistration()
                    }
            } else {
                userMainView
                    .sheet(isPresented: $showVehicleRegistration) {
                        VehicleRegistrationView()
                            .onDisappear {
                                hasCheckedRegistration = false
                            }
                    }
            }
        }
    }
    
    private func checkUserRegistration() {
        Task {
            do {
                let vehicles = try await FirestoreManager.shared.fetchVehicles(userId: userID)
                await MainActor.run {
                    hasCheckedRegistration = true
                    if vehicles.isEmpty {
                        showVehicleRegistration = true
                    } else {
                        // Load active vehicle
                        if let activeVehicle = vehicles.first(where: { $0.isActive }) {
                            FirestoreManager.shared.currentVehicle = activeVehicle
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    hasCheckedRegistration = true
                    showVehicleRegistration = true
                }
            }
        }
    }
    
    private func checkVendorRegistration() {
        Task {
            do {
                let parkingLots = try await FirestoreManager.shared.fetchVendorParkingLots(vendorId: userID)
                await MainActor.run {
                    hasCheckedRegistration = true
                    if parkingLots.isEmpty {
                        showVendorRegistration = true
                    }
                }
            } catch {
                await MainActor.run {
                    hasCheckedRegistration = true
                    showVendorRegistration = true
                }
            }
        }
    }
    
    private var userMainView: some View {
    private var userMainView: some View {
        ZStack(alignment: .leading) {
                // Main content (unchanged position/scale to avoid black bars and stretch)
                mainContent
                    .allowsHitTesting(!showMenu) // block touches when menu is open

                // Dim overlay above content, behind menu
                if showMenu {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                showMenu = false
                            }
                        }
                        .transition(.opacity)
                }

                // Slide-in Side Menu covering 75% of the screen
                if showMenu {
                    SideMenuView(isOpen: $showMenu)
                        .frame(width: menuWidth)
                        .transition(.move(edge: .leading))
                        .zIndex(1)
                }
            }
        }
    }

    // MARK: - Main content view (map + UI)
    private var mainContent: some View {
        ZStack(alignment: .top) {
            // background
            Color.white.ignoresSafeArea()

            // map view
            Map(
                coordinateRegion: $parkingFinder.region,
                annotationItems: parkingFinder.spots
            ) { spot in
                MapAnnotation(
                    coordinate: spot.location,
                    anchorPoint: CGPoint(x: 0.5, y: 0.5)
                ) {
                    Button(action: {
                        parkingFinder.selectedPlace = spot
                    }, label: {
                        SpotAnnotatonView(
                            fee: "\(Int(spot.fee))",
                            selected: spot.id == parkingFinder.selectedPlace?.id
                        )
                    })
                }
            }
            .cornerRadius(60)
            .edgesIgnoringSafeArea(.top)
            .offset(y: -70)

            VStack {
                // top navigation with menu button
                TopNavigationView {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        showMenu.toggle()
                    }
                }

                Spacer()

                // parking card view
                ParkingCardView(parkingPlace: parkingFinder.selectedPlace ?? parkingFinder.spots[0])
                    .offset(y: -30)
                    .onTapGesture {
                        parkingFinder.showDetail = true
                    }

                // search view
                SearchView()
            }
            .padding(.horizontal)

            if parkingFinder.showDetail {
                // parking detail view when click on card
                ParkingDetailView(
                    parkingFinder: parkingFinder,
                    region: MKCoordinateRegion(
                        center: parkingFinder.selectedPlace?.location ?? parkingFinder.spots[0].location,
                        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                    )
                )
            }
        }
        .onAppear {
            parkingFinder.selectedPlace = parkingFinder.spots[0]
        }
    }
}

// color
extension Color {
    static let darkColor = Color.init(red: 46/255, green: 45/255, blue: 45/255)
    static let lightColor = Color.init(red: 254/255, green: 254/255, blue: 254/255)
    static let yellowColor = Color.init(red: 245/255, green: 210/255, blue: 49/255)
}

extension UIScreen {
   static let screenWidth   = UIScreen.main.bounds.size.width
   static let screenHeight  = UIScreen.main.bounds.size.height
   static let screenSize    = UIScreen.main.bounds.size
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
