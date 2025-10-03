//
//  ParkingItem.swift
//  ParkingApp
//
//  Created by Anik on 2/12/20.
//

import Foundation
import MapKit

struct ParkingItem: Identifiable {
    var id: String = UUID().uuidString
    let name: String
    let address: String
    let photoName: String
    let place: String
    let carLimit: Int
    let location: CLLocationCoordinate2D
    let fee: CGFloat
    var hour: String
    var description: String?
    var lateFee: Double?
    var terms: String?
}
