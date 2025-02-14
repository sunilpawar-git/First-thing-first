import SwiftUI

struct PreviewView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .environmentObject(PreviewContainer.dataService)
            .environmentObject(PreviewContainer.taskViewModel)
            .environmentObject(PreviewContainer.themeManager)
            .onAppear {
                PreviewContainer.setupSampleData()
            }
    }
} 