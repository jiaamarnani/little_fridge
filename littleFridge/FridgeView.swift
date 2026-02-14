import SwiftUI

enum FoodCategory: String, CaseIterable {
    case veggies = "VEGGIES"
    case fruits = "FRUITS"
    case dairy = "DAIRY"
    case carbs = "CARBS"
    case condiments = "CONDIMENTS"
    case protein = "PROTEIN"
    case drinks = "DRINKS"
    case extras = "EXTRAS"
}

// MARK: - Main View
struct ViewFridgeView: View {
    @State private var doorOpen = false
    @State private var selectedCategory: FoodCategory? = nil
    @State private var showIngredients = false
    
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
                    .frame(width: 310, height: 520)
                    .offset(x: 8, y: 8)
                
                // Fridge body (black interior)
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                    .frame(width: 300, height: 500)
                
                // Fridge interior with shelves
                FridgeInterior(
                    selectedCategory: $selectedCategory,
                    showIngredients: $showIngredients
                )
                
                // Fridge door
                FridgeDoorLarge(isOpen: doorOpen)
                    .zIndex(10)
            }
            .offset(x: 20)
            
            // Bottom drawer
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.75, green: 0.75, blue: 0.75))
                    .frame(width: 260, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                            .frame(width: 80, height: 12)
                    )
                    .offset(x: 20, y: -58)
            }
            
            // Ingredients bottom sheet
            if showIngredients, let category = selectedCategory {
                IngredientSheet(
                    category: category,
                    isPresented: $showIngredients
                )
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
                    doorOpen = true
                }
            }
        }
    }
}

// MARK: - Fridge Interior
struct FridgeInterior: View {
    @Binding var selectedCategory: FoodCategory?
    @Binding var showIngredients: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Top shelf
            ShelfRow(
                categories: [.veggies, .fruits, .dairy],
                selectedCategory: $selectedCategory,
                showIngredients: $showIngredients
            )
            
            ShelfDivider()
            
            // Middle shelf
            ShelfRow(
                categories: [.carbs, .condiments, .protein],
                selectedCategory: $selectedCategory,
                showIngredients: $showIngredients
            )
            
            ShelfDivider()
            
            // Bottom shelf
            ShelfRow(
                categories: [.drinks, .extras],
                selectedCategory: $selectedCategory,
                showIngredients: $showIngredients
            )
        }
        .frame(width: 270, height: 420)
        .background(Color(red: 0.92, green: 0.90, blue: 0.90))
        .cornerRadius(8)
    }
}

struct ShelfRow: View {
    let categories: [FoodCategory]
    @Binding var selectedCategory: FoodCategory?
    @Binding var showIngredients: Bool
    
    var body: some View {
        HStack(spacing: categories.count == 2 ? 40 : 20) {
            ForEach(categories, id: \.self) { category in
                CategoryButton(category: category) {
                    selectedCategory = category
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showIngredients = true
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
    }
}

struct ShelfDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.black)
            .frame(height: 4)
            .padding(.horizontal, 5)
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: FoodCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                CategoryIcon(category: category)
                    .frame(width: 50, height: 50)
                
                Text(category.rawValue)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
            }
        }
    }
}

// MARK: - Category Icons
struct CategoryIcon: View {
    let category: FoodCategory
    
    var body: some View {
        Group {
            switch category {
            case .veggies:
                Text("🥗")
                    .font(.system(size: 40))
            case .fruits:
                Text("🍌")
                    .font(.system(size: 40))
            case .dairy:
                Text("🥛")
                    .font(.system(size: 40))
            case .carbs:
                Text("🍞")
                    .font(.system(size: 40))
            case .condiments:
                Text("🍯")
                    .font(.system(size: 40))
            case .protein:
                Text("🥩")
                    .font(.system(size: 40))
            case .drinks:
                Text("🧃")
                    .font(.system(size: 40))
            case .extras:
                Text("❓")
                    .font(.system(size: 40))
            }
        }
    }
}

// MARK: - Custom Icons
struct SaladBowlIcon: View {
    var body: some View {
        ZStack {
            // Bowl
            Ellipse()
                .stroke(Color.black, lineWidth: 2.5)
                .frame(width: 45, height: 25)
                .offset(y: 10)
            
            // Veggies sticking out
            Path { path in
                path.move(to: CGPoint(x: 15, y: 15))
                path.addQuadCurve(to: CGPoint(x: 20, y: 5), control: CGPoint(x: 12, y: 8))
                path.move(to: CGPoint(x: 25, y: 12))
                path.addLine(to: CGPoint(x: 25, y: 2))
                path.move(to: CGPoint(x: 35, y: 15))
                path.addQuadCurve(to: CGPoint(x: 32, y: 5), control: CGPoint(x: 38, y: 8))
            }
            .stroke(Color.black, lineWidth: 2.5)
        }
    }
}

struct BananaIcon: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 25, y: 5))
            path.addQuadCurve(to: CGPoint(x: 10, y: 40), control: CGPoint(x: 5, y: 20))
            path.addQuadCurve(to: CGPoint(x: 25, y: 10), control: CGPoint(x: 20, y: 35))
        }
        .stroke(Color.black, lineWidth: 2.5)
    }
}

struct MilkCartonIcon: View {
    var body: some View {
        ZStack {
            // Carton body
            Path { path in
                path.move(to: CGPoint(x: 12, y: 15))
                path.addLine(to: CGPoint(x: 12, y: 45))
                path.addLine(to: CGPoint(x: 38, y: 45))
                path.addLine(to: CGPoint(x: 38, y: 15))
                // Roof
                path.addLine(to: CGPoint(x: 25, y: 5))
                path.addLine(to: CGPoint(x: 12, y: 15))
            }
            .stroke(Color.black, lineWidth: 2.5)
        }
    }
}

struct BreadIcon: View {
    var body: some View {
        ZStack {
            // Bread loaf shape
            Path { path in
                path.move(to: CGPoint(x: 10, y: 35))
                path.addLine(to: CGPoint(x: 10, y: 20))
                path.addQuadCurve(to: CGPoint(x: 25, y: 10), control: CGPoint(x: 10, y: 10))
                path.addQuadCurve(to: CGPoint(x: 40, y: 20), control: CGPoint(x: 40, y: 10))
                path.addLine(to: CGPoint(x: 40, y: 35))
                path.addLine(to: CGPoint(x: 10, y: 35))
            }
            .stroke(Color.black, lineWidth: 2.5)
        }
    }
}

struct KetchupIcon: View {
    var body: some View {
        ZStack {
            // Bottle
            Path { path in
                // Body
                path.move(to: CGPoint(x: 15, y: 45))
                path.addLine(to: CGPoint(x: 15, y: 20))
                path.addLine(to: CGPoint(x: 20, y: 15))
                path.addLine(to: CGPoint(x: 20, y: 8))
                path.addLine(to: CGPoint(x: 30, y: 8))
                path.addLine(to: CGPoint(x: 30, y: 15))
                path.addLine(to: CGPoint(x: 35, y: 20))
                path.addLine(to: CGPoint(x: 35, y: 45))
                path.addLine(to: CGPoint(x: 15, y: 45))
            }
            .stroke(Color.black, lineWidth: 2.5)
            
            // Cap
            Rectangle()
                .stroke(Color.black, lineWidth: 2.5)
                .frame(width: 14, height: 6)
                .offset(y: -20)
        }
    }
}

struct SteakIcon: View {
    var body: some View {
        ZStack {
            // Steak shape
            Ellipse()
                .stroke(Color.black, lineWidth: 2.5)
                .frame(width: 40, height: 30)
            
            // Fat marbling
            Path { path in
                path.move(to: CGPoint(x: 18, y: 22))
                path.addQuadCurve(to: CGPoint(x: 32, y: 22), control: CGPoint(x: 25, y: 28))
            }
            .stroke(Color.black, lineWidth: 2)
        }
    }
}

struct WaterBottleIcon: View {
    var body: some View {
        Path { path in
            // Bottle body with curves
            path.move(to: CGPoint(x: 18, y: 45))
            path.addLine(to: CGPoint(x: 18, y: 35))
            path.addQuadCurve(to: CGPoint(x: 15, y: 25), control: CGPoint(x: 15, y: 30))
            path.addQuadCurve(to: CGPoint(x: 18, y: 15), control: CGPoint(x: 15, y: 20))
            path.addLine(to: CGPoint(x: 20, y: 12))
            path.addLine(to: CGPoint(x: 20, y: 8))
            path.addLine(to: CGPoint(x: 30, y: 8))
            path.addLine(to: CGPoint(x: 30, y: 12))
            path.addLine(to: CGPoint(x: 32, y: 15))
            path.addQuadCurve(to: CGPoint(x: 35, y: 25), control: CGPoint(x: 35, y: 20))
            path.addQuadCurve(to: CGPoint(x: 32, y: 35), control: CGPoint(x: 35, y: 30))
            path.addLine(to: CGPoint(x: 32, y: 45))
            path.addLine(to: CGPoint(x: 18, y: 45))
        }
        .stroke(Color.black, lineWidth: 2.5)
    }
}

struct QuestionMarkIcon: View {
    var body: some View {
        Text("?")
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .foregroundColor(.black)
    }
}

// MARK: - Ingredient Sheet
struct IngredientSheet: View {
    let category: FoodCategory
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                // Header with X button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                            .padding(12)
                    }
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
                
                // Category title - centered, underlined, cute font
                VStack(spacing: 4) {
                    Text(category.rawValue)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.96, green: 0.44, blue: 0.44))
                    
                    Rectangle()
                        .fill(Color(red: 0.96, green: 0.44, blue: 0.44))
                        .frame(width: 120, height: 3)
                }
                .padding(.top, -10)
                .padding(.bottom, 20)
                
                // Scrollable content area for future ingredients
                ScrollView {
                    VStack(spacing: 12) {
                        // Ingredients will go here
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height * 0.85)
            .background(Color.white)
            .cornerRadius(24, corners: [.topLeft, .topRight])
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -5)
        }
        .ignoresSafeArea()
        .transition(.move(edge: .bottom))
    }
}

// Corner radius extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Large Fridge Door
struct FridgeDoorLarge: View {
    var isOpen: Bool
    
    var body: some View {
        ZStack {
            // SOLID door base
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.82, green: 0.82, blue: 0.82))
                .frame(width: 300, height: 440)
            
            // Door inner panel
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.78, green: 0.78, blue: 0.78))
                .frame(width: 270, height: 410)
            
            // Door border
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black, lineWidth: 6)
                .frame(width: 300, height: 440)
            
            // Handle
            HStack {
                VStack(spacing: 50) {
                    HandlePieceLarge()
                    HandlePieceLarge()
                    HandlePieceLarge()
                }
                .offset(x: -125)
                
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

struct HandlePieceLarge: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.70, green: 0.70, blue: 0.70))
                .frame(width: 30, height: 50)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
            
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.55, green: 0.55, blue: 0.55))
                .frame(width: 10, height: 45)
                .offset(x: -15)
        }
    }
}

struct ViewFridgeView_Previews: PreviewProvider {
    static var previews: some View {
        ViewFridgeView()
    }
}
