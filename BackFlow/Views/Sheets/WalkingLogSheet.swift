import SwiftUI
import SwiftData

struct WalkingLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel: WalkingLogViewModel?
    
    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    contentView(vm: vm)
                } else {
                    ProgressView()
                        .onAppear {
                            viewModel = WalkingLogViewModel(modelContext: modelContext)
                        }
                }
            }
            .navigationTitle("Log Walking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarItems
            }
        }
    }
    
    @ViewBuilder
    private func contentView(vm: WalkingLogViewModel) -> some View {
        @Bindable var bindableVM = vm
        
        Form {
            Section("Duration") {
                Stepper(value: $bindableVM.durationMinutes, in: 1...240, step: 5) {
                    HStack {
                        Text("Minutes")
                        Spacer()
                        Text("\(vm.durationMinutes)")
                            .fontWeight(.semibold)
                    }
                }
                .accessibilityLabel("Walking duration")
                .accessibilityValue("\(vm.durationMinutes) minutes")
            }
            
            Section("Source") {
                Picker("Source", selection: $bindableVM.source) {
                    ForEach(WalkingSource.allCases) { source in
                        Text(source.displayName).tag(source)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("Notes") {
                TextField("Additional notes (optional)", text: $bindableVM.notes, axis: .vertical)
                    .lineLimit(3...6)
            }
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
                        let success = await vm.saveLog()
                        if success {
                            dismiss()
                        }
                    }
                }
                .disabled(vm.isSaving)
            }
        }
    }
}

#Preview {
    WalkingLogSheet()
        .modelContainer(for: WalkingLog.self, inMemory: true)
}
