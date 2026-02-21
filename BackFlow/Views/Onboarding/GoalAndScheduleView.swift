import SwiftUI
import SwiftData

struct GoalAndScheduleView: View {
    let onContinue: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedGoals: Set<String> = []
    @State private var sessionsPerWeek = 3
    @State private var selectedEquipment: Set<String> = []
    @State private var reminderEnabled = true
    @State private var reminderTime = Date()
    
    let goals = [
        "Reduce flare-ups",
        "Move more comfortably",
        "Return to gym/sports",
        "Build daily strength"
    ]
    
    let equipment = ["None", "Resistance band", "Weights"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Goals")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("What would you like to achieve? (Select all that apply)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    ForEach(goals, id: \.self) { goal in
                        GoalToggle(goal: goal, isSelected: selectedGoals.contains(goal)) {
                            if selectedGoals.contains(goal) {
                                selectedGoals.remove(goal)
                            } else {
                                selectedGoals.insert(goal)
                            }
                        }
                    }
                }
                
                Divider()
                
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
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Equipment")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("What equipment do you have access to?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    ForEach(equipment, id: \.self) { item in
                        EquipmentToggle(item: item, isSelected: selectedEquipment.contains(item)) {
                            if selectedEquipment.contains(item) {
                                selectedEquipment.remove(item)
                            } else {
                                selectedEquipment.insert(item)
                            }
                        }
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Daily Reminder")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Toggle("Enable reminder", isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        DatePicker("Reminder time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Button(action: saveAndContinue) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedGoals.isEmpty ? Color.gray : Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .disabled(selectedGoals.isEmpty)
                .padding(.top)
            }
            .padding()
        }
    }
    
    private func saveAndContinue() {
        // Create user profile
        let profile = UserProfile(
            goal: Array(selectedGoals).joined(separator: ", "),
            sessionsPerWeek: sessionsPerWeek,
            equipment: Array(selectedEquipment),
            reminderTime: reminderEnabled ? Calendar.current.dateComponents([.hour, .minute], from: reminderTime) : nil
        )
        
        modelContext.insert(profile)
        try? modelContext.save()
        
        // Schedule reminder if enabled
        if reminderEnabled {
            let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
            NotificationService.shared.scheduleDailyReminder(at: components)
        }
        
        onContinue()
    }
}

struct GoalToggle: View {
    let goal: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .blue : .gray)
                Text(goal)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct EquipmentToggle: View {
    let item: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .blue : .gray)
                Text(item)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    GoalAndScheduleView(onContinue: {})
        .modelContainer(for: UserProfile.self, inMemory: true)
}
