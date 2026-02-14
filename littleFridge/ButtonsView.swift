import SwiftUI

struct FridgeMenuView: View {
    // MARK: - Navigation
    @State private var showAlerts = false
    @State private var showAddItems = false
    @State private var showViewFridge = false
    
    // MARK: - Animation States
    @State private var greetingVisible = false
    @State private var card1Visible = false
    @State private var card2Visible = false
    @State private var card3Visible = false
    @State private var animateBlobs = false
    
    @State private var pressedCard: Int? = nil
    
    // Brand colors
    private let coral = Color(red: 0.94, green: 0.44, blue: 0.44)
    private let green = Color(red: 0.71, green: 0.79, blue: 0.58)
    private let greenDark = Color(red: 0.50, green: 0.60, blue: 0.35)
    private let pinkBg = Color(red: 1.0, green: 0.93, blue: 0.93)
    
    var body: some View {
        ZStack {
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // MARK: - Background + Blobs
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            pinkBg.ignoresSafeArea()
            
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [coral.opacity(0.12), Color.clear],
                            center: .center, startRadius: 20, endRadius: 160
                        )
                    )
                    .frame(width: 320, height: 320)
                    .offset(x: 130, y: animateBlobs ? -300 : -340)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [green.opacity(0.15), Color.clear],
                            center: .center, startRadius: 30, endRadius: 180
                        )
                    )
                    .frame(width: 360, height: 360)
                    .offset(x: -110, y: animateBlobs ? 320 : 360)
                    .blur(radius: 25)
            }
            .ignoresSafeArea()
            
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // MARK: - Content
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            GeometryReader { geo in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                        // MARK: - TOP: Greeting
                        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                        VStack(spacing: 6) {
                            Spacer()
                                .frame(height: geo.safeAreaInsets.top + 50)
                            
                            Image("fridge_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            
                            Text("Your Fridge")
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                            
                            Text("What would you like to do?")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Color(.secondaryLabel))
                        }
                        .opacity(greetingVisible ? 1 : 0)
                        .offset(y: greetingVisible ? 0 : 15)
                        .padding(.bottom, 40)
                        
                        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                        // MARK: - Menu Cards
                        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                        VStack(spacing: 14) {
                            // VIEW FRIDGE
                            MenuCard(
                                icon: "refrigerator.fill",
                                title: "View Fridge",
                                subtitle: "See what's inside",
                                iconBgColor: green.opacity(0.2),
                                iconColor: greenDark,
                                isPressed: pressedCard == 0
                            ) {
                                pressCard(0) { showViewFridge = true }
                            }
                            .opacity(card1Visible ? 1 : 0)
                            .offset(y: card1Visible ? 0 : 25)
                            
                            // ALERTS
                            MenuCard(
                                icon: "bell.badge.fill",
                                title: "Alerts",
                                subtitle: "Expiring soon & reminders",
                                iconBgColor: coral.opacity(0.15),
                                iconColor: coral,
                                isPressed: pressedCard == 1
                            ) {
                                pressCard(1) { showAlerts = true }
                            }
                            .opacity(card2Visible ? 1 : 0)
                            .offset(y: card2Visible ? 0 : 25)
                            
                            // ADD ITEMS
                            MenuCard(
                                icon: "plus.circle.fill",
                                title: "Add Items",
                                subtitle: "Scan or add groceries",
                                iconBgColor: Color(red: 0.94, green: 0.87, blue: 0.7).opacity(0.5),
                                iconColor: Color(red: 0.75, green: 0.6, blue: 0.3),
                                isPressed: pressedCard == 2
                            ) {
                                pressCard(2) { showAddItems = true }
                            }
                            .opacity(card3Visible ? 1 : 0)
                            .offset(y: card3Visible ? 0 : 25)
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                            .frame(height: 60)
                    }
                    .frame(minHeight: geo.size.height)
                }
            }
        }
        // MARK: - Staggered Entrance
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                animateBlobs = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                greetingVisible = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                card1Visible = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.45)) {
                card2Visible = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
                card3Visible = true
            }
        }
        .fullScreenCover(isPresented: $showAlerts) {
            AlertsView()
        }
        .fullScreenCover(isPresented: $showAddItems) {
            AddItemsView()
        }
        .fullScreenCover(isPresented: $showViewFridge) {
            ViewFridgeView()
        }
    }
    
    // MARK: - Button Press Helper
    private func pressCard(_ index: Int, action: @escaping () -> Void) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            pressedCard = index
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                pressedCard = nil
            }
            action()
        }
    }
}

// MARK: - Menu Card Component
struct MenuCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconBgColor: Color
    let iconColor: Color
    let isPressed: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(iconBgColor)
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color(.secondaryLabel))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.6))
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
    }
}

struct FridgeMenuView_Previews: PreviewProvider {
    static var previews: some View {
        FridgeMenuView()
    }
}
