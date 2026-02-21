import SwiftUI

struct SessionsPerWeekPicker: View {
    @Binding var sessionsPerWeek: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sessions Per Week")
                .font(.title2)
                .fontWeight(.bold)
            
            Picker("Sessions", selection: $sessionsPerWeek) {
                ForEach(2...6, id: \.self) { count in
                    Text("\(count) sessions").tag(count)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Sessions per week")
            .accessibilityValue("\(sessionsPerWeek) sessions")
        }
    }
}

#Preview {
    @Previewable @State var sessions = 3
    SessionsPerWeekPicker(sessionsPerWeek: $sessions)
        .padding()
}
