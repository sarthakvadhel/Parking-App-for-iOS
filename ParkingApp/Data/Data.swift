//
//  Data.swift
//  ParkingApp


import Foundation
import MapKit

struct Data {
    static let spots = [
        ParkingItem(
                    name: "AMC Multilevel Parking - Navrangpura",
                    address: "Navrangpura, Ahmedabad, Gujarat 380009",
                    photoName: "navrangpura",
                    place: "NAV-01",
                    carLimit: 200,
                    location: CLLocationCoordinate2D(latitude: 23.036406, longitude: 72.561066),
                    fee: 30.0,
                    hour: "per hour"
                ),
                ParkingItem(
                    name: "AMC Multilevel Parking - Kankaria",
                    address: "Near Gate No 3, Kankaria Lake, Ahmedabad, Gujarat 380022",
                    photoName: "kankaria",
                    place: "KANK-01",
                    carLimit: 250,
                    location: CLLocationCoordinate2D(latitude: 23.006741, longitude: 72.596245),
                    fee: 40.0,
                    hour: "per hour"
                ),
                ParkingItem(
                    name: "AMC Parking - Prahladnagar",
                    address: "100 Feet Road, Prahladnagar, Satellite, Ahmedabad, Gujarat 380015",
                    photoName: "prahladnagar",
                    place: "PRAH-01",
                    carLimit: 180,
                    location: CLLocationCoordinate2D(latitude: 23.0117045, longitude: 72.5061682),
                    fee: 35.0,
                    hour: "per hour"
                ),
                ParkingItem(
                    name: "Sindhu Bhavan Multilevel Parking",
                    address: "Sindhu Bhavan Road, Bodakdev, Ahmedabad, Gujarat 380054",
                    photoName: "sindhubhavan",
                    place: "SIND-01",
                    carLimit: 150,
                    location: CLLocationCoordinate2D(latitude: 23.040517, longitude: 72.503878),
                    fee: 30.0,
                    hour: "per hour"
                ),
                ParkingItem(
                    name: "Sabarmati Riverfront Parking (near Atal Bridge)",
                    address: "Opposite Atal Bridge, Sabarmati Riverfront, Ahmedabad",
                    photoName: "riverfront",
                    place: "RIV-01",
                    carLimit: 1700,
                    location: CLLocationCoordinate2D(latitude: 23.014467, longitude: 72.573876),
                    fee: 50.0,
                    hour: "per hour"
                ),
                ParkingItem(
                    name: "Ahmedabad One (Vastrapur) Mall Parking",
                    address: "Ahmedabad One (AlphaOne), Vastrapur, Ahmedabad",
                    photoName: "vastrapur",
                    place: "VAS-01",
                    carLimit: 600,
                    location: CLLocationCoordinate2D(latitude: 23.0400083, longitude: 72.5313642),
                    fee: 40.0,
                    hour: "per hour"
                ),
                ParkingItem(
                    name: "C.G. Road / Stadium-area Parking (AMC bays)",
                    address: "C.G. Road / Stadium area, Ahmedabad",
                    photoName: "cgroad",
                    place: "CGR-01",
                    carLimit: 300,
                    location: CLLocationCoordinate2D(latitude: 23.0216238, longitude: 72.5797068),
                    fee: 20.0,
                    hour: "per hour"
                ),
                ParkingItem(
                    name: "Ellis Bridge / Parimal Garden Parking",
                    address: "Ellis Bridge / Parimal Garden area, Ahmedabad",
                    photoName: "ellisbridge",
                    place: "ELL-01",
                    carLimit: 120,
                    location: CLLocationCoordinate2D(latitude: 23.0262331, longitude: 72.5623124),
                    fee: 25.0,
                    hour: "per hour"
                ),
                ParkingItem(
                    name: "Maninagar / Kankaria Vicinity Parking",
                    address: "Maninagar area (near Kankaria / The Arena), Ahmedabad",
                    photoName: "maninagar",
                    place: "MAN-01",
                    carLimit: 200,
                    location: CLLocationCoordinate2D(latitude: 22.996170, longitude: 72.599586),
                    fee: 35.0,
                    hour: "per hour"
                ),
                ParkingItem(
                    name: "Jamalpur / Old City Parking (AMC pay-and-park)",
                    address: "Jamalpur Market, Ahmedabad",
                    photoName: "jamalpur",
                    place: "JAM-01",
                    carLimit: 120,
                    location: CLLocationCoordinate2D(latitude: 23.010526, longitude: 72.580064),
                    fee: 20.0,
                    hour: "per hour"
                )
    ]
}
