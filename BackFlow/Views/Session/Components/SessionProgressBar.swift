import SwiftUI

struct SessionProgressBar: View {
    let current: Int
    let total: Int
    
    var body: some View {
        ProgressView(value: Double(current), total: Double(total))
            .tint(.white)
            .padding()
            .accessibilityLabel("Exercise \(current) of \(total)")
    }
}

#Preview {
    ZStack {
        Color.black
        SessionProgressBar(current: 2, total: 4)
    }
}
