//
//  Extensions.swift
//  ParkingApp
//
//  Created by Parking App Team
//

import Foundation
import SwiftUI

// Date formatting extensions
extension Date {
    func formatted(as format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var timeAgo: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: self, to: now)
        
        if let day = components.day, day > 0 {
            return day == 1 ? "1 day ago" : "\(day) days ago"
        }
        if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        }
        if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        }
        return "Just now"
    }
}

// Currency formatting
extension Double {
    var asCurrency: String {
        return "₹\(String(format: "%.2f", self))"
    }
    
    var asRoundedCurrency: String {
        return "₹\(String(format: "%.0f", self))"
    }
}

// Color extensions for theme support
extension Color {
    static let theme = ThemeColors()
}

struct ThemeColors {
    let primary = Color.black
    let secondary = Color.gray
    let accent = Color.blue
    let success = Color.green
    let warning = Color.orange
    let error = Color.red
    let background = Color.white
    let cardBackground = Color.white
    let textPrimary = Color.black
    let textSecondary = Color.gray
}
