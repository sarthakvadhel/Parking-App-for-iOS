//
//  TopNavigationView.swift
//  ParkingApp
//
//  Created by Anik on 2/12/20.
//

import SwiftUI

struct TopNavigationView: View {
    var onMenuTap: () -> Void

    var body: some View {
        HStack {
            Button(action: onMenuTap) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 66, height: 66)
                    .background(Color.white)
                    .cornerRadius(25)
            }

            Spacer()

            HStack {
                Image("car")

                VStack(alignment: .leading, spacing: 2) {
                    Text("My car")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Text("GJ01AE7828")
                        .font(.system(size: 17))
                }
            }
            .frame(width: 182, height: 66)
            .background(Color.white)
            .cornerRadius(25)
        }
    }
}
