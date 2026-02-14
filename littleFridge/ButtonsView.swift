import SwiftUI

struct FridgeMenuView: View {
    @State private var doorOpen = false
    @State private var zoomIn = false
    @State private var showAlerts = false
    @State private var showAddItems = false
    @State private var showViewFridge = false
    
    var body: some View {
        ZStack {
            // Pink background
            Color(red: 1.0, green: 0.9, blue: 0.9)
                .ignoresSafeArea()
            
            // Fridge container
            ZStack {
                // Shadow behind fridge
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 290, height: 420)
                    .offset(x: 8, y: 8)
                
                // Fridge body (black interior)
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                    .frame(width: 280, height: 400)
                
                // Interior back wall
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                    .frame(width: 260, height: 380)
                
                // Green panel with buttons (inside fridge)
                VStack(spacing: 0) {
                    MenuButton(title: "VIEW FRIDGE") {
                        showViewFridge = true
                    }
                    
                    MenuButton(title: "ALERTS") {
                        showAlerts = true
                    }
                    
                    MenuButton(title: "ADD ITEMS") {
                        showAddItems = true
                    }
                }
                .frame(width: 250, height: 360)
                .background(Color(red: 0.71, green: 0.79, blue: 0.58))
                .cornerRadius(8)
                .scaleEffect(zoomIn ? 1.15 : 1.0)
                .offset(x: zoomIn ? -20 : 0)
                
                // Fridge door - ON TOP of everything
                FridgeDoor(isOpen: doorOpen)
                    .zIndex(10)
                    .opacity(zoomIn ? 0 : 1)
            }
            .offset(x: 20)
        }
        .onAppear {
            // Stage 1: Open door after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
                    doorOpen = true
                }
            }
            
            // Stage 2: Zoom into fridge
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    zoomIn = true
                }
            }
        }
        .fullScreenCover(isPresented: $showAlerts) {
            AlertsView()
        }
        .fullScreenCover(isPresented: $showAddItems) {
            // AddItemsView()
            Text("Add Items View")
        }
        .fullScreenCover(isPresented: $showViewFridge) {
            // ViewFridgeView()
            Text("View Fridge View")
        }
    }
}

struct MenuButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(Color(red: 0.78, green: 0.85, blue: 0.65))
                .overlay(
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(height: 4)
                    }
                )
        }
    }
}

struct FridgeDoor: View {
    var isOpen: Bool
    
    var body: some View {
        ZStack {
            // SOLID door base - completely opaque
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.82, green: 0.82, blue: 0.82))
                .frame(width: 280, height: 400)
            
            // Door inner panel detail
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.78, green: 0.78, blue: 0.78))
                .frame(width: 250, height: 370)
            
            // Freezer line detail
            Rectangle()
                .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                .frame(width: 250, height: 3)
                .offset(y: -80)
            
            // Door border
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black, lineWidth: 6)
                .frame(width: 280, height: 400)
            
            // Handle
            HStack {
                VStack(spacing: 40) {
                    HandlePiece()
                    HandlePiece()
                    HandlePiece()
                }
                .offset(x: -120)
                
                Spacer()
            }
        }
        .compositingGroup()
        .rotation3DEffect(
            .degrees(isOpen ? -105 : 0),
            axis: (x: 0, y: 1, z: 0),
            anchor: .leading,
            perspective: 0.3
        )
    }
}

struct HandlePiece: View {
    var body: some View {
        ZStack {
            // Handle mount
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.70, green: 0.70, blue: 0.70))
                .frame(width: 30, height: 50)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
            
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.55, green: 0.55, blue: 0.55))
                .frame(width: 10, height: 45)
                .offset(x: -15)
        }
    }
}

struct FridgeMenuView_Previews: PreviewProvider {
    static var previews: some View {
        FridgeMenuView()
    }
}
