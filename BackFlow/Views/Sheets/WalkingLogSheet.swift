import SwiftUI
import SwiftData

public struct WalkingLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var walkingMinutes: Double = 10
    @State private var notes: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let minMinutes: Double = 0
    private let maxMinutes: Double = 120
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.large) {
                // Header
                VStack(spacing: Theme.Spacing.small) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("Log Walking")
                        .font(Theme.Typography.title2)
                    
                    Text("How many minutes did you walk today?")
                        .font(Theme.Typography.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Theme.Spacing.large)
                
                // Minutes Slider
                VStack(spacing: Theme.Spacing.medium) {
                    HStack {
                        Text("\(Int(walkingMinutes))")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(.primary)
                        Text("minutes")
                            .font(Theme.Typography.title3)
                            .foregroundStyle(.secondary)
                    }
                    
                    Slider(
                        value: $walkingMinutes,
                        in: minMinutes...maxMinutes,
                        step: 5
                    )
                    .accentColor(.blue)
                    
                    HStack {
                        Text("\(Int(minMinutes)) min")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(maxMinutes)) min")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, Theme.Spacing.large)
                
                // Notes Field
                VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                    Text("Notes (optional)")
                        .font(Theme.Typography.footnote)
                        .foregroundStyle(.secondary)
                    
                    TextField("e.g., Walked with friend, felt good", text: $notes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Save Button
                Button(action: saveLog) {
                    Text("Save Walking Log")
                        .font(Theme.Typography.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(Theme.CornerRadius.medium)
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { showError = false }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveLog() {
        guard walkingMinutes > 0 else {
            errorMessage = "Please log at least 1 minute of walking"
            showError = true
            return
        }
        
        let walkingLog = WalkingLog(
            date: Date(),
            durationMinutes: Int(walkingMinutes),
            source: "manual",
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(walkingLog)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save walking log"
            showError = true
        }
    }
}

#Preview {
    WalkingLogSheet()
        .modelContainer(for: WalkingLog.self, inMemory: true)
}