//
//  AnalyticsService.swift
//  ParkingApp
//
//  Created for production analytics
//

import Foundation
#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

/// Analytics events for tracking user behavior
enum AnalyticsEvent {
    case appLaunched
    case userLoggedIn(role: String)
    case userSignedUp(role: String)
    case userLoggedOut
    case parkingBooked(lotId: String, duration: Double, amount: Double)
    case bookingCancelled(bookingId: String, reason: String)
    case vendorLotCreated(lotId: String)
    case vendorLotUpdated(lotId: String)
    case searchPerformed(query: String, resultsCount: Int)
    case vehicleRegistered(vehicleId: String)
    case paymentCompleted(amount: Double, method: String)
    case paymentFailed(reason: String)
    case errorOccurred(screen: String, error: String)
    case passwordChanged
    case userDeleted
    
    var name: String {
        switch self {
        case .appLaunched: return "app_launched"
        case .userLoggedIn: return "user_logged_in"
        case .userSignedUp: return "user_signed_up"
        case .userLoggedOut: return "user_logged_out"
        case .parkingBooked: return "parking_booked"
        case .bookingCancelled: return "booking_cancelled"
        case .vendorLotCreated: return "vendor_lot_created"
        case .vendorLotUpdated: return "vendor_lot_updated"
        case .searchPerformed: return "search_performed"
        case .vehicleRegistered: return "vehicle_registered"
        case .paymentCompleted: return "payment_completed"
        case .paymentFailed: return "payment_failed"
        case .errorOccurred: return "error_occurred"
        case .passwordChanged: return "password_changed"
        case .userDeleted: return "user_deleted"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .appLaunched:
            return ["timestamp": Date().timeIntervalSince1970]
            
        case .userLoggedIn(let role):
            return ["role": role]
            
        case .userSignedUp(let role):
            return ["role": role]
            
        case .userLoggedOut:
            return [:]
            
        case .parkingBooked(let lotId, let duration, let amount):
            return [
                "lot_id": lotId,
                "duration": duration,
                "amount": amount
            ]
            
        case .bookingCancelled(let bookingId, let reason):
            return [
                "booking_id": bookingId,
                "reason": reason
            ]
            
        case .vendorLotCreated(let lotId):
            return ["lot_id": lotId]
            
        case .vendorLotUpdated(let lotId):
            return ["lot_id": lotId]
            
        case .searchPerformed(let query, let resultsCount):
            return [
                "query": query,
                "results_count": resultsCount
            ]
            
        case .vehicleRegistered(let vehicleId):
            return ["vehicle_id": vehicleId]
            
        case .paymentCompleted(let amount, let method):
            return [
                "amount": amount,
                "payment_method": method
            ]
            
        case .paymentFailed(let reason):
            return ["reason": reason]
            
        case .errorOccurred(let screen, let error):
            return [
                "screen": screen,
                "error": error
            ]
            
        case .passwordChanged:
            return ["timestamp": Date().timeIntervalSince1970]
            
        case .userDeleted:
            return ["timestamp": Date().timeIntervalSince1970]
        }
    }
}

/// Service for tracking analytics events
class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    /// Track an analytics event
    func track(_ event: AnalyticsEvent) {
        #if !DEBUG
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(event.name, parameters: event.parameters)
        #endif
        #endif
        
        // Log to console in debug mode
        print("📊 ANALYTICS: \(event.name) - \(event.parameters)")
    }
    
    /// Set user property for analytics
    func setUserProperty(_ value: String?, forName name: String) {
        #if !DEBUG
        #if canImport(FirebaseAnalytics)
        Analytics.setUserProperty(value, forName: name)
        #endif
        #endif
    }
    
    /// Set user ID for analytics
    func setUserId(_ userId: String?) {
        #if !DEBUG
        #if canImport(FirebaseAnalytics)
        Analytics.setUserID(userId)
        #endif
        #endif
    }
    
    /// Track screen view
    func trackScreen(_ screenName: String, screenClass: String? = nil) {
        #if !DEBUG
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass ?? screenName
        ])
        #endif
        #endif
        
        print("📱 SCREEN: \(screenName)")
    }
}
