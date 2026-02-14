//
//  AddItemsView.swift
//  littleFridge
//
//  Created by Jia Amarnani on 2/14/26.
//


import SwiftUI

struct AddItemsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var foodName: String = ""
    @State private var quantity: String = "1"
    @State private var selectedCategory: FoodCategory = .extras
    @State private var expiresIn: Int = 7
    
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var errorMessage: String? = nil
    @State private var isAddPressed = false
    
    // Animation
    @State private var headerVisible = false
    @State private var formVisible = false
    @State private var buttonVisible = false
    @State private var animateBlobs = false
    
    @FocusState private var focusedField: AddField?
    
    enum AddField {
        case name, quantity
    }
    
    private let coral = Color(red: 0.94, green: 0.44, blue: 0.44)
    private let green = Color(red: 0.71, green: 0.79, blue: 0.58)
    private let pinkBg = Color(red: 1.0, green: 0.93, blue: 0.93)
    
    var body: some View {
        ZStack {
            pinkBg.ignoresSafeArea()
                .onTapGesture { focusedField = nil }
            
            // Blobs
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [coral.opacity(0.12), .clear], center: .center, startRadius: 20, endRadius: 160))
                    .frame(width: 320, height: 320)
                    .offset(x: 130, y: animateBlobs ? -300 : -340)
                    .blur(radius: 20)
                Circle()
                    .fill(RadialGradient(colors: [green.opacity(0.15), .clear], center: .center, startRadius: 30, endRadius: 180))
                    .frame(width: 360, height: 360)
                    .offset(x: -110, y: animateBlobs ? 320 : 360)
                    .blur(radius: 25)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Nav bar
                HStack {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17, weight: .regular, design: .rounded))
                        }
                        .foregroundColor(coral)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 4)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        VStack(spacing: 6) {
                            Text("Add Items")
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                            
                            Text("What did you pick up?")
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(Color(.secondaryLabel))
                        }
                        .opacity(headerVisible ? 1 : 0)
                        .offset(y: headerVisible ? 0 : 12)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                        
                        // Form
                        VStack(spacing: 18) {
                            // Food name
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Item Name")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(.secondaryLabel))
                                    .textCase(.uppercase)
                                    .tracking(0.8)
                                
                                TextField("", text: $foodName, prompt:
                                    Text("e.g. Spinach").foregroundColor(Color(.placeholderText))
                                )
                                .font(.system(size: 17, weight: .regular, design: .rounded))
                                .focused($focusedField, equals: .name)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .name ? coral : Color(.separator).opacity(0.3), lineWidth: focusedField == .name ? 1.5 : 0.5)
                                )
                                .animation(.easeOut(duration: 0.2), value: focusedField)
                            }
                            
                            // Quantity
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Quantity")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(.secondaryLabel))
                                    .textCase(.uppercase)
                                    .tracking(0.8)
                                
                                TextField("", text: $quantity, prompt:
                                    Text("1").foregroundColor(Color(.placeholderText))
                                )
                                .font(.system(size: 17, weight: .regular, design: .rounded))
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .quantity)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .quantity ? coral : Color(.separator).opacity(0.3), lineWidth: focusedField == .quantity ? 1.5 : 0.5)
                                )
                                .animation(.easeOut(duration: 0.2), value: focusedField)
                            }
                            
                            // Category picker
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Category")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(.secondaryLabel))
                                    .textCase(.uppercase)
                                    .tracking(0.8)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(FoodCategory.allCases, id: \.self) { cat in
                                            Button {
                                                withAnimation(.easeOut(duration: 0.15)) {
                                                    selectedCategory = cat
                                                }
                                            } label: {
                                                VStack(spacing: 4) {
                                                    Text(cat.emoji).font(.system(size: 24))
                                                    Text(cat.rawValue)
                                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                                        .foregroundColor(selectedCategory == cat ? .white : .primary)
                                                }
                                                .frame(width: 72, height: 64)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(selectedCategory == cat ? coral : Color.white.opacity(0.6))
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 2)
                                    .padding(.vertical, 2)
                                }
                            }
                            
                            // Expiry
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Expires In")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(.secondaryLabel))
                                    .textCase(.uppercase)
                                    .tracking(0.8)
                                
                                HStack(spacing: 12) {
                                    ForEach([3, 5, 7, 14, 30], id: \.self) { days in
                                        Button {
                                            withAnimation(.easeOut(duration: 0.15)) {
                                                expiresIn = days
                                            }
                                        } label: {
                                            Text("\(days)d")
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                .foregroundColor(expiresIn == days ? .white : .primary)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 42)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(expiresIn == days ? green : Color.white.opacity(0.6))
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .opacity(formVisible ? 1 : 0)
                        .offset(y: formVisible ? 0 : 20)
                        
                        // Error
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(coral)
                                .padding(.top, 12)
                        }
                        
                        // Success
                        if showSuccess {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(green)
                                Text("Added!")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 0.50, green: 0.60, blue: 0.35))
                            }
                            .padding(.top, 12)
                            .transition(.opacity.combined(with: .scale))
                        }
                        
                        // Add button
                        Button {
                            Task { await addItem() }
                        } label: {
                            Group {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Add to Fridge")
                                }
                            }
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(foodName.isEmpty ? coral.opacity(0.4) : coral)
                            .cornerRadius(14)
                            .shadow(color: coral.opacity(0.3), radius: 10, x: 0, y: 5)
                            .scaleEffect(isAddPressed ? 0.95 : 1.0)
                        }
                        .disabled(foodName.isEmpty || isLoading)
                        .animation(.easeOut(duration: 0.2), value: foodName.isEmpty)
                        .padding(.horizontal, 24)
                        .padding(.top, 28)
                        .opacity(buttonVisible ? 1 : 0)
                        
                        Spacer().frame(height: 60)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) { animateBlobs = true }
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) { headerVisible = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.25)) { formVisible = true }
            withAnimation(.easeOut(duration: 0.4).delay(0.45)) { buttonVisible = true }
        }
    }
    
    // MARK: - POST to backend
    private func addItem() async {
        focusedField = nil
        isLoading = true
        errorMessage = nil
        showSuccess = false
        
        let expiryDate = Calendar.current.date(byAdding: .day, value: expiresIn, to: Date())!
        let isoFormatter = ISO8601DateFormatter()
        
        do {
            try await FridgeAPI.shared.addItem(
                foodName: foodName,
                quantity: Int(quantity) ?? 1,
                expiresAt: isoFormatter.string(from: expiryDate)
            )
            isLoading = false
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showSuccess = true
            }
            // Reset form
            foodName = ""
            quantity = "1"
            expiresIn = 7
            
            // Hide success after 2s
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { showSuccess = false }
            }
        } catch {
            isLoading = false
            errorMessage = "Failed to add item. Try again."
        }
    }
}

struct AddItemsView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemsView()
    }
}