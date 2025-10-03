//
//  ParkingInfoView.swift
//  ParkingApp
//
//  Created by Anik on 2/12/20.
//

import SwiftUI

struct ParkingInfoView: View {
    let parkingItem: ParkingItem
    @Binding var showSelectHourView: Bool
    @Binding var selectedHour: CGFloat
    @State private var showFullDescription = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text(parkingItem.name)
                .font(.system(size: 30, weight: .bold))
            
            Text(parkingItem.address)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // Description if available
            if let description = parkingItem.description, !description.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(showFullDescription ? nil : 2)
                    
                    if description.count > 100 {
                        Button(action: {
                            showFullDescription.toggle()
                        }) {
                            Text(showFullDescription ? "Show less" : "Show more")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            HStack {
                Image(systemName: "car.fill")
                    .foregroundColor(.gray)
                Text("\(parkingItem.carLimit)")
                    .foregroundColor(.gray)
                    .padding(.trailing, 16)
                
                Image(systemName: "indianrupeesign.circle.fill")
                    .foregroundColor(.gray)
                Text("₹\(String.init(format: "%0.2f", parkingItem.fee))/h")
                    .foregroundColor(.gray)
                
                if let lateFee = parkingItem.lateFee {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .padding(.leading, 8)
                    Text("₹\(String.init(format: "%0.2f", lateFee)) late")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            .font(.system(size: 16))
            
            // Terms if available
            if let terms = parkingItem.terms, !terms.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Terms & Conditions")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(terms)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                .padding(.horizontal)
            }
            
            HStack(spacing: 10) {
                InfoItemView(imageName: "place", value: parkingItem.place, title: "Parking Place")
                
                InfoItemView(imageName: "cost", value: getHour(), title: "Time")
                    .onTapGesture {
                        withAnimation {
                            showSelectHourView = true
                        }
                    }
            }
        }
    }
    
    func getHour() -> String {
        let hourSeparated = modf(selectedHour/2)
        let hourData = String.init(format: "%0.0f", hourSeparated.0)
        let minuteData = hourSeparated.1 == 0.0 ? "0" : "30"
        
        return "\(hourData) h \(minuteData) m"
    }
}

