import SwiftUI

struct AlertsView: View {
    @State private var alerts: [String] = []
    @State private var newAlertText: String = ""
    
    var body: some View {
        ZStack {
            // Pink background
            Color(red: 1.0, green: 0.9, blue: 0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Title with underline
                VStack(spacing: 8) {
                    Text("ALERTS!")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.94, green: 0.44, blue: 0.44))
                    
                    Rectangle()
                        .fill(Color(red: 0.94, green: 0.44, blue: 0.44))
                        .frame(width: 220, height: 4)
                }
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                // Scrollable alerts list
                List {
                    ForEach(alerts.indices, id: \.self) { index in
                        Text(alerts[index])
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(red: 1.0, green: 0.9, blue: 0.9))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2.5)
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 9, leading: 30, bottom: 9, trailing: 30))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteAlert(at: index)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                
                // Fixed bottom section
                VStack(spacing: 20) {
                    // Divider line
                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(height: 1)
                    
                    // Text field for new alert
                    TextField("Type your alert here...", text: $newAlertText)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2.5)
                        )
                        .padding(.horizontal, 30)
                    
                    // Add Alert button
                    Button(action: {
                        addAlert()
                    }) {
                        Text("ADD ALERT")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(width: 220, height: 55)
                            .background(Color(red: 0.71, green: 0.79, blue: 0.58))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 4)
                    }
                    .padding(.bottom, 40)
                }
                .background(Color(red: 1.0, green: 0.9, blue: 0.9))
            }
        }
    }
    
    private func addAlert() {
        let trimmed = newAlertText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            alerts.insert(trimmed, at: 0)
            newAlertText = ""
        }
    }
    
    private func deleteAlert(at index: Int) {
        alerts.remove(at: index)
    }
}

struct AlertsView_Previews: PreviewProvider {
    static var previews: some View {
        AlertsView()
    }
}
