import SwiftUI
import SwiftData

struct QuickLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel: QuickLogViewModel?
    
    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    contentView(vm: vm)
                } else {
                    ProgressView()
                        .onAppear {
                            viewModel = QuickLogViewModel(modelContext: modelContext)
                        }
                }
            }
            .navigationTitle("Quick Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarItems
            }
        }
    }
    
    @ViewBuilder
    private func contentView(vm: QuickLogViewModel) -> some View {
        @Bindable var bindableVM = vm
        
        Form {
            painSection(vm: bindableVM)
            redFlagsSection(vm: bindableVM)
            notesSection(vm: bindableVM)
        }
        .alert("Red Flags Detected", isPresented: $bindableVM.showRedFlagWarning) {
            Button("I Understand", role: .cancel) {
                vm.dismissWarning()
                dismiss()
            }
        } message: {
            Text("You've indicated symptoms that may require medical attention. Please consult a healthcare provider.")
        }
    }
    
    // MARK: - View Sections
    
    @ViewBuilder
    private func painSection(vm: QuickLogViewModel) -> some View {
        @Bindable var bindableVM = vm
        
        Section("Pain Level") {
            painSlider(title: "Pain right now", value: $bindableVM.painNow)
            painSlider(title: "Pain after activity (optional)", value: $bindableVM.painAfterActivity)
        }
    }
    
    @ViewBuilder
    private func painSlider(title: String, value: Binding<Int?>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
            
            if let painValue = value.wrappedValue {
                Slider(value: .init(
                    get: { Double(painValue) },
                    set: { value.wrappedValue = Int($0) }
                ), in: 0...10, step: 1)
                
                HStack {
                    Text("No pain")
                        .font(.caption)
                    Spacer()
                    Text("\(painValue)/10")
                        .font(.caption)
                        .fontWeight(.bold)
                    Spacer()
                    Text("Worst pain")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            } else {
                Button("Add \(title.lowercased())") {
                    value.wrappedValue = 5
                }
            }
        }
    }
    
    @ViewBuilder
    private func redFlagsSection(vm: QuickLogViewModel) -> some View {
        @Bindable var bindableVM = vm
        
        Section("Red Flag Symptoms") {
            Toggle("Bowel/bladder changes", isOn: $bindableVM.bowelBladderChange)
            Toggle("Saddle numbness", isOn: $bindableVM.saddleNumbness)
            Toggle("Progressive weakness", isOn: $bindableVM.progressiveWeakness)
            Toggle("Fever with pain", isOn: $bindableVM.fever)
            Toggle("Major trauma", isOn: $bindableVM.majorTrauma)
            Toggle("Unexplained weight loss", isOn: $bindableVM.unexplainedWeightLoss)
            Toggle("Severe night pain", isOn: $bindableVM.severeNightPain)
            
            if vm.hasRedFlags {
                Text("⚠️ Red flags detected. Please consult a healthcare provider.")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }
    
    @ViewBuilder
    private func notesSection(vm: QuickLogViewModel) -> some View {
        @Bindable var bindableVM = vm
        
        Section("Notes") {
            TextField("Additional notes (optional)", text: $bindableVM.notes, axis: .vertical)
                .lineLimit(3...6)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            if let vm = viewModel {
                Button("Save") {
                    Task {
                        let result = await vm.saveLog()
                        if result == .success {
                            dismiss()
                        }
                    }
                }
                .disabled(vm.isSaving || !vm.canSave)
            }
        }
    }
}

#Preview {
    QuickLogSheet()
        .modelContainer(for: SymptomLog.self, inMemory: true)
}
