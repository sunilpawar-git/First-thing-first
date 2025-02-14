import SwiftUI
import UIKit // For haptics

struct ScrollIndicator: View {
    @State private var offsetY: CGFloat = 0
    let isAtTop: Bool
    let isAtBottom: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if !isAtBottom {
                VStack(spacing: 4) {
                    Text("Scroll Up")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black.opacity(0.4))
                    Image(systemName: "chevron.up")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black.opacity(0.4))
                }
                .offset(y: -offsetY)
            }
            
            if !isAtTop {
                VStack(spacing: 4) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black.opacity(0.4))
                    Text("Scroll Down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black.opacity(0.4))
                }
                .offset(y: offsetY)
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
            ) {
                offsetY = 8
            }
        }
    }
}

#Preview {
    VStack(spacing: 50) {
        ScrollIndicator(isAtTop: false, isAtBottom: true)
        ScrollIndicator(isAtTop: true, isAtBottom: false)
    }
    .padding()
} 