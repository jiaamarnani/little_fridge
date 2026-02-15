import SwiftUI

struct GroupSelectionView: View {
    @State private var groupCode: String = ""
    @State private var showGroupCreated = false
    @State private var showButtonsView = false
    
    // Hardcoded group code
    let createdGroupCode = "FRG7K"
    
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
                    showGroupCreated = true
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
                        showButtonsView = true
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
            
            // MARK: - Group Created Popup
            if showGroupCreated {
                // Dim background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Don't dismiss on tap
                    }
                
                // Popup card
                VStack(spacing: 20) {
                    // Checkmark icon
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(red: 0.71, green: 0.79, blue: 0.58))
                    
                    // Title
                    Text("Group Created!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    
                    // Subtitle
                    Text("Share this code with your group members:")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    // Group code display
                    Text(createdGroupCode)
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.96, green: 0.44, blue: 0.44))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.96, green: 0.44, blue: 0.44).opacity(0.3), lineWidth: 2)
                        )
                    
                    // Next button
                    Button(action: {
                        showGroupCreated = false
                        showButtonsView = true
                    }) {
                        Text("NEXT")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(width: 200, height: 55)
                            .background(Color(red: 0.71, green: 0.79, blue: 0.58))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 4)
                    }
                    .padding(.top, 10)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 30)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showGroupCreated)
        .fullScreenCover(isPresented: $showButtonsView) {
            ButtonsView()
        }
    }
}

struct GroupSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        GroupSelectionView()
    }
}
