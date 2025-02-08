import SwiftUI

// Helper view to generate the icon
// You can use this temporarily to generate the icon if needed
struct AppIconView: View {
    var body: some View {
        ZStack {
            // Background
            Color.white
            
            // Text
            Text("First\nthing,\nfirst")
                .font(.system(size: 40, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(hex: "666666"))  // Medium grey color
        }
        .frame(width: 1024, height: 1024) // App icon dimensions
        .ignoresSafeArea()
    }
}

// Preview provider
#Preview {
    AppIconView()
} 