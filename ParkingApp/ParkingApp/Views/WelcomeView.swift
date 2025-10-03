//
//  WelcomeView.swift
//  ParkingApp
//
//  Created by Parking App Team
//

import SwiftUI

struct WelcomeView: View {
    @Binding var showWelcome: Bool
    @State private var currentPage = 0
    
    let features = [
        OnboardingFeature(
            icon: "car.fill",
            title: "Find Parking Easily",
            description: "Discover available parking spots near you in real-time"
        ),
        OnboardingFeature(
            icon: "map.fill",
            title: "Book Your Spot",
            description: "Reserve your parking space with just a few taps"
        ),
        OnboardingFeature(
            icon: "indianrupeesign.circle.fill",
            title: "Pay Securely",
            description: "Multiple payment options for your convenience"
        ),
        OnboardingFeature(
            icon: "building.2.fill",
            title: "Become a Vendor",
            description: "Have a parking space? List it and earn money"
        )
    ]
    
    var body: some View {
        VStack {
            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<features.count, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.black : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 40)
            
            // Content
            TabView(selection: $currentPage) {
                ForEach(0..<features.count, id: \.self) { index in
                    OnboardingPage(feature: features[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Action buttons
            VStack(spacing: 15) {
                if currentPage == features.count - 1 {
                    Button(action: {
                        showWelcome = false
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                    }
                } else {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                    }
                }
                
                Button(action: {
                    showWelcome = false
                }) {
                    Text("Skip")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}

struct OnboardingFeature {
    let icon: String
    let title: String
    let description: String
}

struct OnboardingPage: View {
    let feature: OnboardingFeature
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: feature.icon)
                .font(.system(size: 100))
                .foregroundColor(.blue)
            
            VStack(spacing: 15) {
                Text(feature.title)
                    .font(.title)
                    .bold()
                
                Text(feature.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(showWelcome: .constant(true))
    }
}
