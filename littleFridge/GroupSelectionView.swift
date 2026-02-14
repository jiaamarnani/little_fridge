import SwiftUI

struct GroupSelectionView: View {
    @State private var groupCode: String = ""
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Animation States
    @State private var logoVisible = false
    @State private var headerVisible = false
    @State private var createButtonVisible = false
    @State private var dividerVisible = false
    @State private var joinCardVisible = false
    
    @State private var isCreatePressed = false
    @State private var isJoinPressed = false
    
    @FocusState private var isCodeFocused: Bool
    
    // Brand colors
    private let coral = Color(red: 0.94, green: 0.44, blue: 0.44)
    private let green = Color(red: 0.71, green: 0.79, blue: 0.58)
    private let pinkBg = Color(red: 1.0, green: 0.91, blue: 0.91)
    
    var body: some View {
        ZStack {
            // Background
            pinkBg.ignoresSafeArea()
                .onTapGesture { isCodeFocused = false }
            
            VStack(spacing: 0) {
                Spacer()
                
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // LOGO
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                Image("fridge_logo")
                                 .resizable()
                                 .scaledToFit()
                                 .frame(width: 180, height: 180)
                                 .opacity(logoVisible ? 1 : 0)
                                 .scaleEffect(logoVisible ? 1 : 0.5)
                                 .padding(.bottom, 16)
                
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // MARK: - Header Text
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                VStack(spacing: 8) {
                    Text("track. share. chill.")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(coral)
                    
                    Text("Start a new fridge group or join\nan existing one to stay synced.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(Color(.secondaryLabel))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .opacity(headerVisible ? 1 : 0)
                .offset(y: headerVisible ? 0 : 12)
                .padding(.bottom, 36)
                
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // MARK: - Create a Group Button
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        isCreatePressed = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            isCreatePressed = false
                        }
                        print("Create group tapped")
                    }
                } label: {
                    Text("CREATE A GROUP")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .tracking(0.5)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(coral)
                        .cornerRadius(16)
                        .scaleEffect(isCreatePressed ? 0.95 : 1.0)
                        .shadow(
                            color: coral.opacity(isCreatePressed ? 0.15 : 0.35),
                            radius: isCreatePressed ? 2 : 10,
                            x: 0, y: isCreatePressed ? 1 : 5
                        )
                }
                .padding(.horizontal, 40)
                .opacity(createButtonVisible ? 1 : 0)
                .offset(y: createButtonVisible ? 0 : 20)
                
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // MARK: - Divider
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                HStack(spacing: 14) {
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(height: 0.5)
                    Text("or join with a code")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color(.tertiaryLabel))
                        .fixedSize()
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(height: 0.5)
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 24)
                .opacity(dividerVisible ? 1 : 0)
                
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                // MARK: - Join Card
                // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                VStack(spacing: 14) {
                    // Code input with QR icon
                    TextField("", text: $groupCode, prompt:
                        Text("Enter Code")
                            .foregroundColor(Color(.placeholderText))
                    )
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .focused($isCodeFocused)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isCodeFocused
                                    ? coral
                                    : Color(.separator).opacity(0.3),
                                lineWidth: isCodeFocused ? 1.5 : 0.5
                            )
                    )
                    .scaleEffect(isCodeFocused ? 1.015 : 1.0)
                    .shadow(
                        color: isCodeFocused
                            ? coral.opacity(0.1)
                            : Color.clear,
                        radius: 8, x: 0, y: 2
                    )
                    .animation(.easeOut(duration: 0.2), value: isCodeFocused)
                    
                    // Join button
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            isJoinPressed = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                isJoinPressed = false
                            }
                            print("Join group tapped with code: \(groupCode)")
                        }
                    } label: {
                        Text("JOIN GROUP")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .tracking(0.5)
                            .foregroundColor(.black.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                groupCode.isEmpty
                                    ? green.opacity(0.45)
                                    : green
                            )
                            .cornerRadius(16)
                            .scaleEffect(isJoinPressed ? 0.95 : 1.0)
                            .shadow(
                                color: green.opacity(isJoinPressed ? 0.1 : 0.25),
                                radius: isJoinPressed ? 2 : 8,
                                x: 0, y: isJoinPressed ? 1 : 4
                            )
                    }
                    .disabled(groupCode.isEmpty)
                    .animation(.easeOut(duration: 0.2), value: groupCode.isEmpty)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.5))
                        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
                )
                .padding(.horizontal, 28)
                .opacity(joinCardVisible ? 1 : 0)
                .offset(y: joinCardVisible ? 0 : 25)
                
                Spacer()
                Spacer()
            }
        }
        // MARK: - Staggered Entrance
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.1)) {
                logoVisible = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                headerVisible = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                createButtonVisible = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.65)) {
                dividerVisible = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.75)) {
                joinCardVisible = true
            }
        }
    }
}

struct GroupSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        GroupSelectionView()
    }
}
