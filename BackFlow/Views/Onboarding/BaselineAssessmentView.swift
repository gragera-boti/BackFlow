import SwiftUI
import SwiftData

struct BaselineAssessmentView: View {
    let onComplete: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.services) private var services
    
    @State private var viewModel: BaselineAssessmentViewModel?
    
    var body: some View {
        Group {
            if let vm = viewModel {
                contentView(vm: vm)
            } else {
                ProgressView()
                    .task {
                        guard let services = services else { return }
                        viewModel = BaselineAssessmentViewModel(
                            programService: services.programService,
                            modelContext: modelContext
                        )
                    }
            }
        }
    }
    
    @ViewBuilder
    private func contentView(vm: BaselineAssessmentViewModel) -> some View {
        @Bindable var bindableVM = vm
        
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                headerSection
                painAssessmentSection(vm: bindableVM)
                Divider()
                functionTasksSection(vm: bindableVM)
                Divider()
                WalkingBaselinePicker(minutes: $bindableVM.walkingMinutes)
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
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Baseline Assessment")
                .font(.title)
                .fontWeight(.bold)
            
            Text("This helps us create the right starting plan for you")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private func painAssessmentSection(vm: BaselineAssessmentViewModel) -> some View {
        @Bindable var bindableVM = vm
        
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pain Right Now")
                    .font(.headline)
                PainSlider(value: $bindableVM.painNow)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Worst Pain (Last 7 Days)")
                    .font(.headline)
                PainSlider(value: $bindableVM.worstPainLast7Days)
            }
        }
    }
    
    @ViewBuilder
    private func functionTasksSection(vm: BaselineAssessmentViewModel) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Activities")
                .font(.headline)
            
            Text("How difficult are these tasks right now? (0 = easy, 10 = impossible)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ForEach(vm.functionTasks.indices, id: \.self) { index in
                FunctionTaskRow(
                    task: vm.functionTasks[index],
                    difficulty: Binding(
                        get: { vm.functionTasks[index].difficulty },
                        set: { vm.functionTasks[index].difficulty = $0 }
                    )
                )
            }
        }
    }
    
    @ViewBuilder
    private func submitButton(vm: BaselineAssessmentViewModel) -> some View {
        Button(action: { handleComplete(vm: vm) }) {
            if vm.isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text("Start My Program")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .background(Color.blue)
        .foregroundStyle(.white)
        .cornerRadius(12)
        .disabled(vm.isLoading)
        .padding(.top)
        .accessibilityLabel("Start my program")
        .accessibilityHint("Completes baseline assessment and creates your personalized program")
    }
    
    // MARK: - Actions
    
    private func handleComplete(vm: BaselineAssessmentViewModel) {
        Task {
            let success = await vm.completeAssessment()
            if success {
                onComplete()
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: UserProfile.self,
        ProgramTemplate.self,
        SymptomLog.self,
        FunctionLog.self,
        WalkingLog.self,
        configurations: config
    )
    let context = container.mainContext
    
    // Create a test profile
    let profile = UserProfile(
        createdAt: Date(),
        goal: "Test",
        sessionsPerWeek: 3
    )
    context.insert(profile)
    try! context.save()
    
    return BaselineAssessmentView(onComplete: {})
        .modelContainer(container)
        .serviceContainer(ServiceContainer(modelContext: context))
}
