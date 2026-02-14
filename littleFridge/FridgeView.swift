import SwiftUI

// MARK: - Food Category
enum FoodCategory: String, CaseIterable {
    case veggies = "Veggies"
    case fruits = "Fruits"
    case dairy = "Dairy"
    case carbs = "Carbs"
    case condiments = "Condiments"
    case protein = "Protein"
    case drinks = "Drinks"
    case extras = "Extras"
    
    var emoji: String {
        switch self {
        case .veggies: return "🥗"
        case .fruits: return "🍌"
        case .dairy: return "🥛"
        case .carbs: return "🍞"
        case .condiments: return "🍯"
        case .protein: return "🥩"
        case .drinks: return "🧃"
        case .extras: return "❓"
        }
    }
}

// MARK: - Models (matches Prisma/Supabase schema)
struct FoodDetail: Codable {
    let foodName: String
    let foodCategory: String
    let defaultExpiryDays: Int?
    
    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case foodCategory = "food_category"
        case defaultExpiryDays = "default_expiry_days"
    }
}

struct FridgeItem: Identifiable, Codable {
    let id: String
    let fridgeId: String
    let foodName: String
    let quantity: Int
    let addedByUserId: String?
    let addedAt: String
    let expiresAt: String?
    let foods: FoodDetail?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fridgeId = "fridge_id"
        case foodName = "food_name"
        case quantity
        case addedByUserId = "added_by_user_id"
        case addedAt = "added_at"
        case expiresAt = "expires_at"
        case foods
    }
    
    /// Calculates "X days" until expiry from expiresAt date
    var expiresInText: String {
        guard let expiresAt = expiresAt,
              let date = ISO8601DateFormatter().date(from: expiresAt) else {
            return "No expiry"
        }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days < 0 { return "Expired" }
        if days == 0 { return "Today" }
        if days == 1 { return "1 day" }
        return "\(days) days"
    }
    
    /// Days until expiry as Int for freshness color
    var daysUntilExpiry: Int? {
        guard let expiresAt = expiresAt,
              let date = ISO8601DateFormatter().date(from: expiresAt) else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: date).day
    }
}

// MARK: - API Service
class FridgeAPI {
    static let shared = FridgeAPI()
    
    // TODO: Replace with your actual backend URL
    private let baseURL = "https://your-backend-url.com/api"
    
    // TODO: Set this after user logs in / joins a group
    var currentFridgeId: String = ""
    
    /// GET /:fridgeId/category/:category
    func fetchItems(for category: FoodCategory) async throws -> [FridgeItem] {
        let categoryParam = category.rawValue.lowercased()
        let url = URL(string: "\(baseURL)/fridge/\(currentFridgeId)/category/\(categoryParam)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode([FridgeItem].self, from: data)
    }
    
    /// GET /:fridgeId/items (all items)
    func fetchAllItems() async throws -> [FridgeItem] {
        let url = URL(string: "\(baseURL)/fridge/\(currentFridgeId)/items")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([FridgeItem].self, from: data)
    }
    
    /// DELETE /fridge/items/:itemId
    func deleteItem(id: String) async throws {
        let url = URL(string: "\(baseURL)/fridge/items/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let (_, _) = try await URLSession.shared.data(for: request)
    }
    
    /// POST /:fridgeId/items
    func addItem(foodName: String, quantity: Int, expiresAt: String) async throws {
        let url = URL(string: "\(baseURL)/fridge/\(currentFridgeId)/items")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "foodName": foodName,
            "quantity": quantity,
            "expiresAt": expiresAt
            // TODO: "addedByUserId": currentUserId — set after auth
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (_, _) = try await URLSession.shared.data(for: request)
    }
}

// MARK: - Main View
struct ViewFridgeView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Fridge door animation
    @State private var doorOpen = false
    @State private var fridgeScale: CGFloat = 1.0
    @State private var fridgeOpacity: Double = 1.0
    @State private var whiteFlash: Double = 0.0
    @State private var showFridge = true
    
    // Grid
    @State private var showGrid = false
    @State private var headerVisible = false
    @State private var gridVisible: [Bool] = Array(repeating: false, count: 8)
    @State private var animateBlobs = false
    
    // Sheet
    @State private var selectedCategory: FoodCategory? = nil
    @State private var showIngredients = false
    
    private let coral = Color(red: 0.94, green: 0.44, blue: 0.44)
    private let green = Color(red: 0.71, green: 0.79, blue: 0.58)
    private let pinkBg = Color(red: 1.0, green: 0.93, blue: 0.93)
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    var body: some View {
        ZStack {
            pinkBg.ignoresSafeArea()
            
            // Background blobs
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
            .opacity(showGrid ? 1 : 0)
            
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // MARK: - Fridge Layer
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            if showFridge {
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.black.opacity(0.12))
                        .frame(width: 260, height: 400)
                        .offset(x: 5, y: 8)
                        .blur(radius: 10)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.10, green: 0.10, blue: 0.12))
                        .frame(width: 250, height: 380)
                    
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.94, green: 0.93, blue: 0.91), Color(red: 0.88, green: 0.87, blue: 0.85)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(width: 230, height: 358)
                    
                    // Interior glow
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(doorOpen ? 0.3 : 0), .clear],
                                center: .top, startRadius: 10, endRadius: 250
                            )
                        )
                        .frame(width: 230, height: 358)
                    
                    // Mini category hints inside fridge
                    VStack(spacing: 0) {
                        miniShelfRow([.veggies, .fruits, .dairy])
                        miniShelfLine()
                        miniShelfRow([.carbs, .condiments, .protein])
                        miniShelfLine()
                        miniShelfRow([.drinks, .extras])
                    }
                    .frame(width: 220, height: 340)
                    .opacity(doorOpen ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.6), value: doorOpen)
                    
                    // Door
                    ViewFridgeDoor(isOpen: doorOpen)
                        .zIndex(10)
                }
                .scaleEffect(fridgeScale)
                .opacity(fridgeOpacity)
            }
            
            // White flash
            Color.white
                .ignoresSafeArea()
                .opacity(whiteFlash)
                .zIndex(15)
            
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // MARK: - Grid Layer
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            if showGrid {
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
                    .opacity(headerVisible ? 1 : 0)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            VStack(spacing: 6) {
                                Text("Your Fridge")
                                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                                
                                Text("Tap a category to see what's inside")
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(.secondaryLabel))
                            }
                            .opacity(headerVisible ? 1 : 0)
                            .offset(y: headerVisible ? 0 : 12)
                            .padding(.top, 8)
                            .padding(.bottom, 28)
                            
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(Array(FoodCategory.allCases.enumerated()), id: \.element) { index, category in
                                    CategoryCard(category: category, isVisible: gridVisible.indices.contains(index) ? gridVisible[index] : false) {
                                        selectedCategory = category
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                            showIngredients = true
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // MARK: - Ingredient Sheet
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            if showIngredients, let category = selectedCategory {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            showIngredients = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(25)
                
                IngredientSheetView(
                    category: category,
                    isPresented: $showIngredients,
                    coral: coral
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(30)
            }
        }
        // MARK: - Animation Sequence
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                animateBlobs = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    doorOpen = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeIn(duration: 0.4)) {
                    fridgeScale = 4.0
                    fridgeOpacity = 0.0
                }
                withAnimation(.easeIn(duration: 0.25).delay(0.15)) {
                    whiteFlash = 1.0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                showFridge = false
                showGrid = true
                withAnimation(.easeOut(duration: 0.3)) {
                    whiteFlash = 0.0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeOut(duration: 0.3)) {
                    headerVisible = true
                }
            }
            for i in 0..<8 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 + Double(i) * 0.06) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                        if gridVisible.indices.contains(i) {
                            gridVisible[i] = true
                        }
                    }
                }
            }
        }
    }
    
    // Mini shelf items inside fridge
    private func miniShelfRow(_ categories: [FoodCategory]) -> some View {
        HStack(spacing: categories.count == 2 ? 20 : 10) {
            ForEach(categories, id: \.self) { cat in
                VStack(spacing: 2) {
                    Text(cat.emoji).font(.system(size: 22))
                    Text(cat.rawValue.uppercased())
                        .font(.system(size: 7, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                }
                .frame(width: 60, height: 50)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.5)))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func miniShelfLine() -> some View {
        Rectangle()
            .fill(LinearGradient(colors: [Color(red: 0.75, green: 0.75, blue: 0.73), Color(red: 0.68, green: 0.68, blue: 0.66)], startPoint: .top, endPoint: .bottom))
            .frame(height: 5)
            .padding(.horizontal, 6)
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: FoodCategory
    let isVisible: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) { isPressed = false }
                action()
            }
        } label: {
            VStack(spacing: 8) {
                Text(category.emoji).font(.system(size: 40))
                Text(category.rawValue)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.6)))
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
            .scaleEffect(isPressed ? 0.94 : 1.0)
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
    }
}

// MARK: - Ingredient Sheet (fetches from backend)
struct IngredientSheetView: View {
    let category: FoodCategory
    @Binding var isPresented: Bool
    let coral: Color
    
    @State private var items: [FridgeItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                
                // Header
                HStack {
                    Text("\(category.emoji) \(category.rawValue)")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(.secondaryLabel))
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 0.5)
                    .padding(.horizontal, 24)
                
                // Content
                if isLoading {
                    Spacer()
                    ProgressView()
                        .tint(coral)
                    Spacer()
                } else if let error = errorMessage {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 28))
                            .foregroundColor(Color(.tertiaryLabel))
                        Text(error)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                } else if items.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("Nothing here yet")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                        Text("Add items to your fridge to see them here")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                HStack(spacing: 14) {
                                    Circle()
                                        .fill(freshnessColor(item: item))
                                        .frame(width: 10, height: 10)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.foodName)
                                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                        Text(item.expiresInText)
                                            .font(.system(size: 13, weight: .regular, design: .rounded))
                                            .foregroundColor(Color(.secondaryLabel))
                                    }
                                    
                                    Spacer()
                                    
                                    Text("×\(item.quantity)")
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(.tertiaryLabel))
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                
                                if index < items.count - 1 {
                                    Rectangle()
                                        .fill(Color(.separator).opacity(0.5))
                                        .frame(height: 0.5)
                                        .padding(.leading, 48)
                                        .padding(.trailing, 24)
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height * 0.55)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: -8)
            )
        }
        .ignoresSafeArea()
        .task {
            await loadItems()
        }
    }
    
    // MARK: - Fetch from backend
    private func loadItems() async {
        isLoading = true
        errorMessage = nil
        
        do {
            items = try await FridgeAPI.shared.fetchItems(for: category)
            isLoading = false
        } catch {
            errorMessage = "Couldn't load items.\nCheck your connection."
            isLoading = false
        }
    }
    
    private func freshnessColor(item: FridgeItem) -> Color {
        guard let days = item.daysUntilExpiry else { return Color(.systemGray4) }
        if days < 0 { return Color(red: 0.70, green: 0.20, blue: 0.20) }  // Expired
        if days <= 1 { return Color(red: 0.94, green: 0.35, blue: 0.35) }  // Red
        if days <= 3 { return Color(red: 0.95, green: 0.70, blue: 0.30) }  // Orange
        return Color(red: 0.55, green: 0.78, blue: 0.45)                    // Green
    }
}

// MARK: - Fridge Door
struct ViewFridgeDoor: View {
    var isOpen: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.86, green: 0.86, blue: 0.86), Color(red: 0.78, green: 0.78, blue: 0.78)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .frame(width: 250, height: 380)
            
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.82, green: 0.82, blue: 0.82), Color(red: 0.76, green: 0.76, blue: 0.76)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 220, height: 350)
            
            Rectangle()
                .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                .frame(width: 220, height: 2)
                .offset(y: -70)
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(red: 0.3, green: 0.3, blue: 0.3), lineWidth: 3)
                .frame(width: 250, height: 380)
            
            HStack {
                VStack(spacing: 100) {
                    DoorHandleView()
                    DoorHandleView()
                }
                .offset(x: -104)
                Spacer()
            }
        }
        .compositingGroup()
        .shadow(
            color: Color.black.opacity(isOpen ? 0.2 : 0.08),
            radius: isOpen ? 16 : 4, x: isOpen ? -10 : 0, y: 2
        )
        .rotation3DEffect(
            .degrees(isOpen ? -105 : 0),
            axis: (x: 0, y: 1, z: 0),
            anchor: .leading,
            perspective: 0.3
        )
    }
}

struct DoorHandleView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.68, green: 0.68, blue: 0.68))
                .frame(width: 24, height: 44)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 1, y: 1)
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.58, green: 0.58, blue: 0.58), Color(red: 0.50, green: 0.50, blue: 0.50)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 8, height: 40)
                .offset(x: -12)
        }
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
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
}

struct ViewFridgeView_Previews: PreviewProvider {
    static var previews: some View {
        ViewFridgeView()
    }
}
