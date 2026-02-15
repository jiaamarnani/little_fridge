import SwiftUI

struct AddItemsView: View {
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var showSortPage = false
    @State private var selectedImage: UIImage?
    
    // HARDCODED ITEMS FOR DEMO (matches Fresh Mart receipt)
    let hardcodedItems: [ScannedItem] = [
        ScannedItem(name: "Milk 1 Gal", category: "dairy", quantity: "1"),
        ScannedItem(name: "Eggs Large 12ct", category: "protein", quantity: "1"),
        ScannedItem(name: "Bread Wheat", category: "carbs", quantity: "1"),
        ScannedItem(name: "Bananas", category: "fruits", quantity: "1"),
        ScannedItem(name: "Spinach Bag", category: "veggies", quantity: "1"),
        ScannedItem(name: "Chicken Breast", category: "protein", quantity: "1"),
        ScannedItem(name: "Orange Juice", category: "drinks", quantity: "1"),
        ScannedItem(name: "Cheese Cheddar", category: "dairy", quantity: "1"),
        ScannedItem(name: "Ketchup", category: "condiments", quantity: "1"),
        ScannedItem(name: "Rice White 2lb", category: "carbs", quantity: "1"),
        ScannedItem(name: "Apples Gala 4ct", category: "fruits", quantity: "1"),
        ScannedItem(name: "Yogurt Greek 3pk", category: "dairy", quantity: "1")
    ]
    
    var body: some View {
        ZStack {
            // Pink background
            Color(red: 1.0, green: 0.9, blue: 0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Title
                VStack(spacing: 8) {
                    Text("ADD ITEMS")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.96, green: 0.44, blue: 0.44))
                    
                    Rectangle()
                        .fill(Color(red: 0.96, green: 0.44, blue: 0.44))
                        .frame(width: 160, height: 4)
                }
                
                // Receipt icon
                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 0.96, green: 0.44, blue: 0.44))
                    .padding(.vertical, 20)
                
                // Take a Photo button
                Button(action: {
                    showCamera = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 22))
                        Text("Take a Photo")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.black)
                    .frame(width: 280, height: 65)
                    .background(Color(red: 0.71, green: 0.79, blue: 0.58))
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 4)
                }
                
                // OR text
                Text("OR")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.96, green: 0.44, blue: 0.44))
                
                // Upload a Photo button
                Button(action: {
                    showPhotoLibrary = true
                }) {
                    HStack {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 22))
                        Text("Upload a Photo")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.black)
                    .frame(width: 280, height: 65)
                    .background(Color(red: 0.71, green: 0.79, blue: 0.58))
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 4)
                }
                
                Spacer()
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
        }
        .sheet(isPresented: $showPhotoLibrary) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .fullScreenCover(isPresented: $showSortPage) {
            SortItemsView(items: hardcodedItems)
        }
        .onChange(of: selectedImage) { newImage in
            if newImage != nil {
                selectedImage = nil
                showSortPage = true
            }
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct AddItemsView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemsView()
    }
}
