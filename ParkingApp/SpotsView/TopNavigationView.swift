//
//  TopNavigationView.swift
//  ParkingApp
//
//  Created by Anik on 2/12/20.
//

import SwiftUI
import FirebaseAuth

struct TopNavigationView: View {
    @AppStorage("uid") var userID: String = ""
    var body: some View {
        HStack {
            VStack(spacing: 8) {
                
                Button(action: {
                    let firebaseAuth = Auth.auth()
                    do {
                        try firebaseAuth.signOut()
                        withAnimation {
                            userID = ""
                        }
                    } catch let signOutError as NSError {
                        print("Error signing out: %@", signOutError)
                    }
                }){
                    Image("shutdown")
                        .scaledToFit()
                }
                .font(.system(size: 26))
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
