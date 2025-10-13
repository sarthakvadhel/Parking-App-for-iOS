//
//  CrashLogger.swift
//  ParkingApp
//
//  Created for production observability
//

import Foundation
#if canImport(FirebaseCrashlytics)
import FirebaseCrashlytics
#endif

/// Centralized crash and error logging service
class CrashLogger {
    static let shared = CrashLogger()
    
    private init() {}
    
    /// Log a fatal error that caused a crash
    func log(error: Error, context: [String: Any] = [:]) {
        #if !DEBUG
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().record(error: error)
        
        for (key, value) in context {
            Crashlytics.crashlytics().setCustomValue(value, forKey: key)
        }
        #endif
        #endif
        
        // Also log to console for development
        print("🔴 ERROR: \(error.localizedDescription)")
        if !context.isEmpty {
            print("Context: \(context)")
        }
    }
    
    /// Log a non-fatal error or warning
    func logNonFatal(_ message: String, metadata: [String: Any] = [:]) {
        #if !DEBUG
        #if canImport(FirebaseCrashlytics)
        let error = NSError(
            domain: "ParkingApp",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: message,
                "metadata": metadata
            ]
        )
        Crashlytics.crashlytics().record(error: error)
        #endif
        #endif
        
        print("⚠️ WARNING: \(message)")
        if !metadata.isEmpty {
            print("Metadata: \(metadata)")
        }
    }
    
    /// Set user identifier for crash reports
    func setUserIdentifier(_ userId: String) {
        #if !DEBUG
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().setUserID(userId)
        #endif
        #endif
    }
    
    /// Set custom key-value pair for crash context
    func setCustomValue(_ value: Any, forKey key: String) {
        #if !DEBUG
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
        #endif
        #endif
    }
    
    /// Log a breadcrumb for debugging
    func log(_ message: String) {
        #if !DEBUG
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().log(message)
        #endif
        #endif
        
        print("📝 LOG: \(message)")
    }
    
    /// Clear all custom keys and user data
    func clearData() {
        #if !DEBUG
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().setUserID("")
        #endif
        #endif
    }
}

/// Convenience extension for Error logging
extension Error {
    func log(context: [String: Any] = [:]) {
        CrashLogger.shared.log(error: self, context: context)
    }
}
