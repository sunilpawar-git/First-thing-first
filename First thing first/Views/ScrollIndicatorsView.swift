import SwiftUI

struct ScrollIndicatorsView: View {
    let scrollOffset: CGFloat
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            VStack {
                // Top scroll indicator (shows when scrolled down)
                if scrollOffset < -50 {
                    ScrollIndicator(isAtTop: false, isAtBottom: true)
                        .padding(.top, geometry.size.height * 0.05)
                }
                Spacer()
            }
            
            VStack {
                Spacer()
                // Bottom scroll indicator (always visible at start)
                ScrollIndicator(isAtTop: true, isAtBottom: false)
                    .padding(.bottom, geometry.size.height * 0.05)
                    .opacity(scrollOffset < -geometry.size.height * 0.8 ? 0 : 1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: scrollOffset)
    }
}

#Preview {
    PreviewView {
        GeometryReader { geometry in
            ScrollIndicatorsView(
                scrollOffset: 0,
                geometry: geometry
            )
        }
        .frame(height: 400)
    }
} 