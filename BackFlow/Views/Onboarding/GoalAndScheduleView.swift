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
                
                Button(action: {
                    print("Button action triggered")
                    if selectedGoals.isEmpty {
                        print("ERROR: No goals selected but button was tapped")
                    } else {
                        print("Goals selected: \(selectedGoals)")
                        Task {
                            await saveAndContinue()
                        }
                    }
                }) {
                    Text("Create My Plan")
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
    
    @MainActor
    private func saveAndContinue() async {
        print("saveAndContinue called - selectedGoals: \(selectedGoals)")
        
        // Make sure we have goals selected
        guard !selectedGoals.isEmpty else {
            print("No goals selected - this shouldn't happen as button should be disabled")
            return
        }
        
        // Create user profile
        let components = reminderEnabled ? Calendar.current.dateComponents([.hour, .minute], from: reminderTime) : nil
        let profile = UserProfile(
            createdAt: Date(),
            goal: Array(selectedGoals).joined(separator: ", "),
            sessionsPerWeek: sessionsPerWeek,
            equipment: Array(selectedEquipment),
            reminderHour: components?.hour,
            reminderMinute: components?.minute
        )
        
        modelContext.insert(profile)
        print("UserProfile created and inserted")
        
        // Create initial program plan
        let weekdays = generateWeekdaySchedule(sessionsPerWeek: sessionsPerWeek)
        let programPlan = ProgramPlan(
            programId: "standard-rehab-program",
            startDate: Date(),
            currentPhaseId: "phase-1",
            currentWeek: 1,
            activityLadderLevel: 0,
            isPaused: false,
            weekdays: weekdays
        )
        modelContext.insert(programPlan)
        print("ProgramPlan created and inserted")
        
        do {
            try modelContext.save()
            print("Profile and program plan saved successfully")
            
            // Schedule reminder if enabled
            if reminderEnabled {
                let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                NotificationService.shared.scheduleDailyReminder(at: components)
                print("Reminder scheduled")
            }
            
            print("About to call onContinue")
            // Add a small delay to ensure SwiftUI has processed the save
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            await MainActor.run {
                onContinue()
                print("onContinue called on MainActor")
            }
        } catch {
            print("Error saving: \(error)")
            // Still continue even if save fails for now
            print("Calling onContinue despite error")
            await MainActor.run {
                onContinue()
            }
        }
    }
    
    private func generateWeekdaySchedule(sessionsPerWeek: Int) -> [Int] {
        // Evenly distribute sessions across the week
        // 0 = Sunday, 1 = Monday, etc.
        switch sessionsPerWeek {
        case 1:
            return [3] // Wednesday
        case 2:
            return [1, 4] // Monday, Thursday
        case 3:
            return [1, 3, 5] // Monday, Wednesday, Friday
        case 4:
            return [1, 2, 4, 5] // Monday, Tuesday, Thursday, Friday
        case 5:
            return [1, 2, 3, 4, 5] // Weekdays
        case 6:
            return [1, 2, 3, 4, 5, 6] // Monday through Saturday
        case 7:
            return [0, 1, 2, 3, 4, 5, 6] // Every day
        default:
            return [1, 3, 5] // Default to Mon/Wed/Fri
        }
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
