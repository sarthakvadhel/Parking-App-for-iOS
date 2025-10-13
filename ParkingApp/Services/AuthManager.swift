//
//  AuthManager.swift
//  ParkingApp
//
//  Created for secure authentication management
//

import Foundation
import SwiftUI

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var userID: String = ""
    @Published var userRole: UserRole?
    
    private let storage: SecureStorage = KeychainStorage.shared
    
    // Keys for Keychain storage
    private let uidKey = "user_id"
    private let roleKey = "user_role"
    
    private init() {
        // Load authentication state from Keychain on init
        loadAuthState()
    }
    
    private func loadAuthState() {
        do {
            if let uid = try storage.retrieve(forKey: uidKey), !uid.isEmpty {
                self.userID = uid
                self.isAuthenticated = true
                
                if let roleStr = try storage.retrieve(forKey: roleKey),
                   let role = UserRole(rawValue: roleStr) {
                    self.userRole = role
                }
            }
        } catch {
            print("Error loading auth state: \(error.localizedDescription)")
            // Reset state on error
            self.isAuthenticated = false
            self.userID = ""
            self.userRole = nil
        }
    }
    
    func login(uid: String, role: UserRole) throws {
        try storage.save(uid, forKey: uidKey)
        try storage.save(role.rawValue, forKey: roleKey)
        
        // Also save to UserDefaults for backwards compatibility during migration
        UserDefaults.standard.set(uid, forKey: "uid")
        UserDefaults.standard.set(role.rawValue, forKey: "userRole")
        
        self.userID = uid
        self.userRole = role
        self.isAuthenticated = true
    }
    
    func logout() throws {
        try storage.delete(forKey: uidKey)
        try storage.delete(forKey: roleKey)
        
        // Clear UserDefaults as well
        UserDefaults.standard.removeObject(forKey: "uid")
        UserDefaults.standard.removeObject(forKey: "userRole")
        
        self.userID = ""
        self.userRole = nil
        self.isAuthenticated = false
    }
    
    func migrateFromUserDefaults() {
        // Check if we need to migrate data from UserDefaults
        let userDefaults = UserDefaults.standard
        
        if let uid = userDefaults.string(forKey: "uid"), !uid.isEmpty {
            do {
                // Check if already in Keychain
                if try storage.retrieve(forKey: uidKey) == nil {
                    try storage.save(uid, forKey: uidKey)
                    print("Migrated UID to Keychain")
                }
            } catch {
                print("Error migrating UID: \(error.localizedDescription)")
            }
        }
        
        if let roleStr = userDefaults.string(forKey: "userRole"), !roleStr.isEmpty {
            do {
                // Check if already in Keychain
                if try storage.retrieve(forKey: roleKey) == nil {
                    try storage.save(roleStr, forKey: roleKey)
                    print("Migrated role to Keychain")
                }
            } catch {
                print("Error migrating role: \(error.localizedDescription)")
            }
        }
    }
}
