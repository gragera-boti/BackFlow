import SwiftUI
import SwiftData

struct GoalAndScheduleView: View {
    let onContinue: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: GoalAndScheduleViewModel?
    
    var body: some View {
        Group {
            if let vm = viewModel {
                contentView(vm: vm)
            } else {
                ProgressView()
                    .onAppear {
                        viewModel = GoalAndScheduleViewModel(modelContext: modelContext)
                    }
            }
        }
    }
    
    @ViewBuilder
    private func contentView(vm: GoalAndScheduleViewModel) -> some View {
        @Bindable var bindableVM = vm
        
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                goalsSection(vm: vm)
                Divider()
                SessionsPerWeekPicker(sessionsPerWeek: $bindableVM.sessionsPerWeek)
                Divider()
                equipmentSection(vm: vm)
                Divider()
                ReminderSettings(
                    reminderEnabled: $bindableVM.reminderEnabled,
                    reminderTime: $bindableVM.reminderTime
                )
                submitButton(vm: vm)
            }
            .padding()
        }
        .alert("Error", isPresented: .init(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.clearError() } }
        )) {
            Button("OK", role: .cancel) { vm.clearError() }
        } message: {
            if let error = vm.errorMessage {
                Text(error)
            }
        }
    }
    
    // MARK: - View Sections
    
    @ViewBuilder
    private func goalsSection(vm: GoalAndScheduleViewModel) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Goals")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("What would you like to achieve? (Select all that apply)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ForEach(vm.availableGoals, id: \.self) { goal in
                GoalToggle(
                    goal: goal,
                    isSelected: vm.selectedGoals.contains(goal),
                    action: { vm.toggleGoal(goal) }
                )
            }
        }
    }
    
    @ViewBuilder
    private func equipmentSection(vm: GoalAndScheduleViewModel) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Equipment")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("What equipment do you have access to?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ForEach(vm.availableEquipment, id: \.self) { item in
                EquipmentToggle(
                    item: item,
                    isSelected: vm.selectedEquipment.contains(item),
                    action: { vm.toggleEquipment(item) }
                )
            }
        }
    }
    
    @ViewBuilder
    private func submitButton(vm: GoalAndScheduleViewModel) -> some View {
        Button(action: { handleContinue(vm: vm) }) {
            if vm.isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text("Create My Plan")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .background(vm.canContinue ? Color.blue : Color.gray)
        .foregroundStyle(.white)
        .cornerRadius(12)
        .disabled(!vm.canContinue || vm.isLoading)
        .padding(.top)
        .accessibilityLabel("Create my plan")
        .accessibilityHint("Saves your profile and continues to baseline assessment")
    }
    
    // MARK: - Actions
    
    private func handleContinue(vm: GoalAndScheduleViewModel) {
        Task {
            let success = await vm.saveProfile()
            if success {
                onContinue()
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: UserProfile.self,
        ProgramPlan.self,
        configurations: config
    )
    
    return GoalAndScheduleView(onContinue: {})
        .modelContainer(container)
}
