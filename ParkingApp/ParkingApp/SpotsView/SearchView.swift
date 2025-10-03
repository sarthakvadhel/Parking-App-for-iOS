//
//  SearchView.swift
//  ParkingApp
//
//  Created by Anik on 2/12/20.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 22))
                .padding()
                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            Text("Search For Parking")
                .foregroundColor(.gray)
            Spacer()
            Image(systemName: "chevron.left")
                .padding()
        }
    }
}
