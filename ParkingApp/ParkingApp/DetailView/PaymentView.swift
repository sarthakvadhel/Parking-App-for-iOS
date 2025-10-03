//
//  PaymentView.swift
//  ParkingApp
//
//  Created by Anik on 2/12/20.
//

import SwiftUI

struct PaymentView: View {
    @Binding var selectedHour: CGFloat
    let perHourFee: CGFloat
    let parkingItem: ParkingItem?
    
    @AppStorage("uid") var userID: String = ""
    @State private var showPaymentOptions = false
    @State private var showBookingConfirmation = false
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var totalAmount: Double {
        selectedHour/2 * perHourFee
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("₹\(String.init(format: "%.2f", totalAmount))")
                    .font(.system(size: 22, weight: .bold))
                Text("\(String(format: "%.1f", selectedHour/2)) hours")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: {
                showPaymentOptions = true
            }, label: {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .frame(width: 180, height: 60)
                } else {
                    Text("Book Now")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 180, height: 60)
                }
            })
            .background(Color.yellowColor)
            .cornerRadius(20)
            .disabled(isProcessing)
        }
        .sheet(isPresented: $showPaymentOptions) {
            PaymentOptionsView(
                amount: totalAmount,
                selectedHour: selectedHour/2,
                parkingItem: parkingItem,
                onBookingComplete: {
                    showBookingConfirmation = true
                }
            )
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Booking Confirmed!", isPresented: $showBookingConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your parking space has been booked successfully!")
        }
    }
}

struct PaymentOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("uid") var userID: String = ""
    
    let amount: Double
    let selectedHour: Double
    let parkingItem: ParkingItem?
    let onBookingComplete: () -> Void
    
    @State private var selectedPaymentMethod: PaymentMethod = .cash
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Amount Summary
                VStack(spacing: 10) {
                    Text("Payment Summary")
                        .font(.title2)
                        .bold()
                    
                    HStack {
                        Text("Duration:")
                        Spacer()
                        Text("\(String(format: "%.1f", selectedHour)) hours")
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Rate:")
                        Spacer()
                        Text("₹\(String(format: "%.2f", parkingItem?.fee ?? 0))/hour")
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    HStack {
                        Text("Total Amount:")
                            .font(.headline)
                        Spacer()
                        Text("₹\(String(format: "%.2f", amount))")
                            .font(.title2)
                            .bold()
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                .padding()
                
                // Payment Methods
                VStack(alignment: .leading, spacing: 15) {
                    Text("Select Payment Method")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    PaymentMethodButton(
                        method: .cash,
                        isSelected: selectedPaymentMethod == .cash,
                        onSelect: { selectedPaymentMethod = .cash }
                    )
                    
                    // Coming soon options
                    VStack(spacing: 10) {
                        PaymentMethodButton(
                            method: .upi,
                            isSelected: false,
                            isDisabled: true,
                            onSelect: {}
                        )
                        PaymentMethodButton(
                            method: .card,
                            isSelected: false,
                            isDisabled: true,
                            onSelect: {}
                        )
                        
                        Text("🚀 More payment options coming soon!")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.top, 5)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                Button(action: processBooking) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Confirm Booking")
                            .foregroundColor(.white)
                            .font(.title3)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black)
                )
                .padding(.horizontal)
                .disabled(isProcessing)
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func processBooking() {
        guard let parkingItem = parkingItem else {
            errorMessage = "Invalid parking selection"
            showError = true
            return
        }
        
        isProcessing = true
        
        Task {
            do {
                // Get active vehicle
                guard let vehicle = try await FirestoreManager.shared.fetchActiveVehicle(userId: userID) else {
                    await MainActor.run {
                        errorMessage = "Please add a vehicle first"
                        showError = true
                        isProcessing = false
                    }
                    return
                }
                
                // Create booking
                let booking = Booking(
                    userId: userID,
                    vehicleId: vehicle.id ?? "",
                    parkingLotId: parkingItem.id,
                    startTime: Date(),
                    plannedHours: selectedHour,
                    status: .active
                )
                
                let bookingId = try await FirestoreManager.shared.createBooking(booking)
                
                // Create payment
                let payment = Payment(
                    bookingId: bookingId,
                    userId: userID,
                    amount: amount,
                    method: selectedPaymentMethod,
                    status: selectedPaymentMethod == .cash ? .pending : .completed
                )
                
                _ = try await FirestoreManager.shared.createPayment(payment)
                
                await MainActor.run {
                    isProcessing = false
                    dismiss()
                    onBookingComplete()
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = "Booking failed: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

struct PaymentMethodButton: View {
    let method: PaymentMethod
    let isSelected: Bool
    var isDisabled: Bool = false
    let onSelect: () -> Void
    
    var methodInfo: (icon: String, name: String) {
        switch method {
        case .cash:
            return ("banknote", "Cash")
        case .upi:
            return ("qrcode", "UPI")
        case .card:
            return ("creditcard", "Card")
        case .wallet:
            return ("wallet.pass", "Wallet")
        }
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: methodInfo.icon)
                    .font(.title2)
                Text(methodInfo.name)
                    .font(.headline)
                Spacer()
                if isDisabled {
                    Text("Coming Soon")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
        .foregroundColor(isDisabled ? .gray : .primary)
        .disabled(isDisabled)
        .padding(.horizontal)
    }
}
