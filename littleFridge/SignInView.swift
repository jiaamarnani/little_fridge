import SwiftUI

struct SignInView: View {

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showGroupSelection = false
    @State private var isPasswordVisible: Bool = false
    
    // MARK: - Animation States
    @State private var logoVisible = false
    @State private var titleVisible = false
    @State private var emailFieldVisible = false
    @State private var passwordFieldVisible = false
    @State private var signInButtonVisible = false
    @State private var createAccountVisible = false
    @State private var isSignInPressed = false
    @State private var isCreatePressed = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
                .onTapGesture { focusedField = nil }
            
            GeometryReader { geo in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                        // MARK: - TOP 1/3: Brand
                        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                        VStack(spacing: 0) {
                            Spacer()
                                .frame(height: geo.safeAreaInsets.top + 40)
                            
                            Text("little fridge")
                                .font(.system(size: 42, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(red: 0.94, green: 0.44, blue: 0.44))
                                .opacity(titleVisible ? 1 : 0)
                                .scaleEffect(titleVisible ? 1 : 0.8)
                            
                            Image("fridge_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                                .opacity(logoVisible ? 1 : 0)
                                .scaleEffect(logoVisible ? 1 : 0.6)
                                .padding(.top, -8)
                        }
                        .frame(height: geo.size.height * 0.35)
                        
                        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                        // MARK: - MIDDLE 1/3: Inputs
                        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                        VStack(alignment: .leading, spacing: 16) {
                            // Email
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(.secondaryLabel))
                                    .textCase(.uppercase)
                                    .tracking(0.8)
                                
                                TextField("", text: $username, prompt:
                                    Text("johndoe＠example.com")
                                        .foregroundColor(Color(.placeholderText))
                                )
                                .font(.system(size: 17, weight: .regular, design: .rounded))
                                .tint(Color(red: 0.94, green: 0.44, blue: 0.44))
                                .textFieldStyle(PlainTextFieldStyle())
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .focused($focusedField, equals: .email)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            focusedField == .email
                                                ? Color(red: 0.94, green: 0.44, blue: 0.44)
                                                : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                                .scaleEffect(focusedField == .email ? 1.015 : 1.0)
                                .shadow(
                                    color: focusedField == .email
                                        ? Color(red: 0.94, green: 0.44, blue: 0.44).opacity(0.12)
                                        : Color.clear,
                                    radius: 8, x: 0, y: 2
                                )
                                .animation(.easeOut(duration: 0.2), value: focusedField)
                            }
                            .opacity(emailFieldVisible ? 1 : 0)
                            .offset(y: emailFieldVisible ? 0 : 20)
                            
                            // Password
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Password")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(.secondaryLabel))
                                    .textCase(.uppercase)
                                    .tracking(0.8)
                                
                                HStack(spacing: 12) {
                                    Group {
                                        if isPasswordVisible {
                                            TextField("Enter password", text: $password)
                                                .foregroundColor(.primary)
                                                .textFieldStyle(PlainTextFieldStyle())
                                                .focused($focusedField, equals: .password)
                                        } else {
                                            SecureField("Enter password", text: $password)
                                                .textFieldStyle(PlainTextFieldStyle())
                                                .focused($focusedField, equals: .password)
                                        }
                                    }
                                    .font(.system(size: 17, weight: .regular, design: .rounded))
                                    .textContentType(.password)
                                    
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            isPasswordVisible.toggle()
                                        }
                                    } label: {
                                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Color(.tertiaryLabel))
                                            .contentTransition(.symbolEffect(.replace))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            focusedField == .password
                                                ? Color(red: 0.94, green: 0.44, blue: 0.44)
                                                : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                                .scaleEffect(focusedField == .password ? 1.015 : 1.0)
                                .shadow(
                                    color: focusedField == .password
                                        ? Color(red: 0.94, green: 0.44, blue: 0.44).opacity(0.12)
                                        : Color.clear,
                                    radius: 8, x: 0, y: 2
                                )
                                .animation(.easeOut(duration: 0.2), value: focusedField)
                                
                                HStack {
                                    Spacer()
                                    Button {
                                        print("Forgot password tapped")
                                    } label: {
                                        Text("Forgot Password?")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(Color(red: 0.94, green: 0.44, blue: 0.44))
                                    }
                                }
                                .padding(.top, 2)
                            }
                            .opacity(passwordFieldVisible ? 1 : 0)
                            .offset(y: passwordFieldVisible ? 0 : 20)
                        }
                        .padding(.horizontal, 28)
                        
                        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                        // MARK: - BOTTOM 1/3: Actions
                        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                        VStack(spacing: 16) {
                            // Sign In button - NOW NAVIGATES TO GROUP SELECTION
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    isSignInPressed = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                        isSignInPressed = false
                                    }
                                    showGroupSelection = true
                                }
                            } label: {
                                Text("Sign In")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(Color(red: 0.94, green: 0.44, blue: 0.44))
                                    .cornerRadius(14)
                                    .scaleEffect(isSignInPressed ? 0.95 : 1.0)
                                    .shadow(
                                        color: Color(red: 0.94, green: 0.44, blue: 0.44).opacity(isSignInPressed ? 0.15 : 0.35),
                                        radius: isSignInPressed ? 2 : 10,
                                        x: 0, y: isSignInPressed ? 1 : 5
                                    )
                            }
                            .opacity(signInButtonVisible ? 1 : 0)
                            .scaleEffect(signInButtonVisible ? 1 : 0.8)
                            
                            // Divider
                            HStack(spacing: 12) {
                                Rectangle()
                                    .fill(Color(.separator))
                                    .frame(height: 0.5)
                                Text("or")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(.tertiaryLabel))
                                Rectangle()
                                    .fill(Color(.separator))
                                    .frame(height: 0.5)
                            }
                            .opacity(createAccountVisible ? 1 : 0)
                            
                            // Create Account button - ALSO NAVIGATES TO GROUP SELECTION
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    isCreatePressed = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                        isCreatePressed = false
                                    }
                                    showGroupSelection = true
                                }
                            } label: {
                                Text("Create Account")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0.94, green: 0.44, blue: 0.44))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(Color.white)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color(red: 0.94, green: 0.44, blue: 0.44), lineWidth: 1.5)
                                    )
                                    .scaleEffect(isCreatePressed ? 0.95 : 1.0)
                            }
                            .opacity(createAccountVisible ? 1 : 0)
                            
                            // Legal footer
                            Text("By continuing, you agree to our Terms of Service and Privacy Policy.")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(Color(.quaternaryLabel))
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)
                                .opacity(createAccountVisible ? 1 : 0)
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 32)
                        .padding(.bottom, 40)
                    }
                    .frame(minHeight: geo.size.height)
                }
            }
        }
        // MARK: - Staggered Entrance
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                titleVisible = true
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.25)) {
                logoVisible = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                emailFieldVisible = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.65)) {
                passwordFieldVisible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.85)) {
                signInButtonVisible = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(1.0)) {
                createAccountVisible = true
            }
        }
        .fullScreenCover(isPresented: $showGroupSelection) {
            GroupSelectionView()
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
