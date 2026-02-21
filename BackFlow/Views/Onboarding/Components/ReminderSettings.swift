import SwiftUI

struct ReminderSettings: View {
    @Binding var reminderEnabled: Bool
    @Binding var reminderTime: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Reminder")
                .font(.title2)
                .fontWeight(.bold)
            
            Toggle("Enable reminder", isOn: $reminderEnabled)
                .accessibilityLabel("Enable daily reminder")
            
            if reminderEnabled {
                DatePicker(
                    "Reminder time",
                    selection: $reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .accessibilityLabel("Reminder time")
            }
        }
    }
}

#Preview {
    @Previewable @State var enabled = true
    @Previewable @State var time = Date()
    ReminderSettings(reminderEnabled: $enabled, reminderTime: $time)
        .padding()
}
