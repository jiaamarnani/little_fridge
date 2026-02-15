import Foundation
import SwiftUI

// MARK: - Data Models

struct Ingredient: Identifiable {
    var id: String
    var name: String
    var category: String
    var isShared: Bool
    var quantity: String?
    
    init(id: String = UUID().uuidString, name: String, category: String, isShared: Bool = false, quantity: String? = nil) {
        self.id = id
        self.name = name
        self.category = category.lowercased()
        self.isShared = isShared
        self.quantity = quantity
    }
}

struct ScannedItem {
    let name: String
    let category: String
    let quantity: String?
}

// MARK: - Fridge Data Store (Local Storage)

class FridgeStore: ObservableObject {
    static let shared = FridgeStore()
    
    @Published var ingredients: [String: [Ingredient]] = [
        "veggies": [],
        "fruits": [],
        "dairy": [],
        "carbs": [],
        "condiments": [],
        "protein": [],
        "drinks": [],
        "extras": []
    ]
    
    private init() {}
    
    func addIngredients(_ items: [Ingredient]) {
        for item in items {
            let category = item.category.lowercased()
            if ingredients[category] != nil {
                ingredients[category]?.append(item)
            } else {
                ingredients["extras"]?.append(item)
            }
        }
        sortAllCategories()
    }
    
    private func sortAllCategories() {
        for key in ingredients.keys {
            ingredients[key]?.sort { $0.isShared && !$1.isShared }
        }
    }
    
    func getIngredients(for category: String) -> [Ingredient] {
        let key = category.lowercased()
        let items = ingredients[key] ?? []
        return items.sorted { $0.isShared && !$1.isShared }
    }
    
    func clearAll() {
        for key in ingredients.keys {
            ingredients[key] = []
        }
    }
}
