//
//  ParkingCardView.swift
//  ParkingApp
//
//  Created by Anik on 2/12/20.
//

import SwiftUI

struct ParkingCardView: View {
    let parkingPlace: ParkingItem
    @EnvironmentObject var parkingFinder: ParkingFinder
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(parkingPlace.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.theme.textPrimary)
                Text(parkingPlace.address)
                    .font(.system(size: 14))
                    .foregroundColor(Color.theme.textSecondary)
                    .padding(.bottom, 20)
                
                HStack {
                    Image(systemName: "car.fill")
                        .foregroundColor(Color.theme.iconSecondary)
                    Text("\(parkingPlace.carLimit)")
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Image(systemName: "indianrupeesign.circle.fill")
                        .foregroundColor(Color.theme.iconSecondary)
                    Text("₹\(String.init(format: "%0.2f", parkingPlace.fee))/h")
                        .foregroundColor(Color.theme.textPrimary)
                    
                    // Show distance if user location is available
                    if parkingFinder.userLocation != nil {
                        Spacer()
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text(parkingFinder.formattedDistance(to: parkingPlace))
                            .foregroundColor(.blue)
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
            }
            
            Spacer()
            
            Image(parkingPlace.photoName)
                .resizable()
                .frame(width: 80, height: 80)
                .scaledToFit()
                .cornerRadius(15)
        }
        .padding()
        .frame(height: 150)
        .background(Color.theme.cardBackground)
        .cornerRadius(40)
    }
}
