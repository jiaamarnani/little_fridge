//
//  GroupSelectionView.swift
//  littleFridge
//
//  Created by Jia Amarnani on 2/14/26.
//


import SwiftUI

struct GroupSelectionView: View {
    @State private var groupCode: String = ""
    
    var body: some View {
        ZStack {
            // Pink background
            Color(red: 1.0, green: 0.9, blue: 0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo at top
                Image("fridge_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 2, y: 5)
                    .padding(.bottom, 20)
                
                // Create Group Button
                Button(action: {
                    print("Create group tapped")
                }) {
                    Text("CREATE GROUP")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(width: 320, height: 70)
                        .background(Color(red: 0.71, green: 0.79, blue: 0.58))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 4)
                }
                
                // OR text
                Text("OR")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.96, green: 0.44, blue: 0.44))
                    .padding(.vertical, 10)
                
                // Enter Code TextField
                VStack(spacing: 15) {
                    TextField("Enter Code", text: $groupCode)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        .frame(width: 320)
                    
                    // Join Group Button
                    Button(action: {
                        print("Join group tapped with code: \(groupCode)")
                    }) {
                        Text("JOIN GROUP")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(width: 320, height: 70)
                            .background(Color(red: 0.71, green: 0.79, blue: 0.58))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 4)
                    }
                }
                
                Spacer()
                Spacer()
            }
            .padding(.horizontal, 30)
        }
    }
}

struct GroupSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        GroupSelectionView()
    }
}