import SwiftUI

struct SortableItem: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let quantity: String?
    var isShared: Bool = false
}

struct SortItemsView: View {
    let items: [ScannedItem]
    
    @State private var sortableItems: [SortableItem] = []
    @State private var showFridge = false
    @Environment(\.dismiss) var dismiss
    @ObservedObject var fridgeStore = FridgeStore.shared
    
    var body: some View {
        ZStack {
            // Pink background
            Color(red: 1.0, green: 0.9, blue: 0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("SORT ITEMS")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.96, green: 0.44, blue: 0.44))
                    
                    Rectangle()
                        .fill(Color(red: 0.96, green: 0.44, blue: 0.44))
                        .frame(width: 180, height: 4)
                    
                    Text("Select items to share with your group")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // Items list
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach($sortableItems) { $item in
                            SortItemRow(item: $item)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                
                // Bottom button area
                VStack(spacing: 16) {
                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(height: 1)
                    
                    // Shared count
                    let sharedCount = sortableItems.filter { $0.isShared }.count
                    Text("\(sharedCount) of \(sortableItems.count) items marked as shared")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    
                    // Enter button
                    Button(action: {
                        saveItemsToFridge()
                    }) {
                        Text("ENTER")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.black)
                    .frame(width: 200, height: 60)
                    .background(Color(red: 0.71, green: 0.79, blue: 0.58))
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 4)
                    .padding(.bottom, 40)
                }
                .background(Color(red: 1.0, green: 0.9, blue: 0.9))
            }
        }
        .fullScreenCover(isPresented: $showFridge) {
            ViewFridgeView()
        }
        .onAppear {
            sortableItems = items.map { item in
                SortableItem(
                    name: item.name,
                    category: item.category,
                    quantity: item.quantity,
                    isShared: false
                )
            }
        }
    }
    
    func saveItemsToFridge() {
        let ingredients = sortableItems.map { item in
            Ingredient(
                name: item.name,
                category: item.category.lowercased(),
                isShared: item.isShared,
                quantity: item.quantity
            )
        }
        
        fridgeStore.addIngredients(ingredients)
        showFridge = true
    }
}

struct SortItemRow: View {
    @Binding var item: SortableItem
    
    var body: some View {
        Button(action: {
            item.isShared.toggle()
        }) {
            HStack(spacing: 16) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: 28, height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(item.isShared ? Color(red: 0.71, green: 0.79, blue: 0.58) : Color.white)
                        )
                    
                    if item.isShared {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                
                // Item details
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                    
                    // Category badge
                    Text(item.category.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(red: 0.96, green: 0.44, blue: 0.44))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                // Shared indicator
                if item.isShared {
                    Text("SHARED")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.71, green: 0.79, blue: 0.58))
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SortItemsView_Previews: PreviewProvider {
    static var previews: some View {
        SortItemsView(
            items: [
                ScannedItem(name: "Milk", category: "dairy", quantity: "1"),
                ScannedItem(name: "Bananas", category: "fruits", quantity: "1"),
                ScannedItem(name: "Chicken Breast", category: "protein", quantity: "2")
            ]
        )
    }
}
