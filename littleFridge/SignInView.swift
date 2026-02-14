import SwiftUI

struct SignInView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showGroupSelection = false  // Add this
    
    var body: some View {
        ZStack {
            // White background
            Color(red: 1, green: 1, blue: 1)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Title
                Text("little fridge")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.94, green: 0.44, blue: 0.44))
                    .padding(.bottom, -30)
                

                // Logo
                Image("fridge_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .padding(.bottom, 0)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Username field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email:")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        
                        TextField("johndoe@gmail.com", text: $username)
                            .foregroundColor(.black)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .frame(maxWidth: 350)
                    }
                    
                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password:")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        
                        SecureField("**********", text: $password)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .frame(maxWidth: 350)
                        
                        // Forgot Password
                        Button(action: {
                            print("Forgot password tapped")
                        }) {
                            Text("Forgot Password?")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0.94, green: 0.44, blue: 0.44))
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 30)
                
                // Sign In button
                Button(action: {
                    // Handle sign in action
                    print("Sign in tapped - Username: \(username)")
                }) {
                    Text("SIGN IN")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(width: 250, height: 60)
                        .background(Color(red: 0.71, green: 0.79, blue: 0.58))
                        .cornerRadius(12)
                }
                .padding(.top, 40)
                
                // Create Account button
                Button(action: {
                    showGroupSelection = true  // Change this
                }) {
                    Text("Create Account")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.94, green: 0.44, blue: 0.44))
                }
                .padding(.top, 15)
                
                Spacer()
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showGroupSelection) {  // Add this
            GroupSelectionView()
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
