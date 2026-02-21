import SwiftUI
import SwiftData

struct QuickLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var painNow: Int? = nil
    @State private var painAfterActivity: Int? = nil
    @State private var notes = ""
    @State private var showRedFlagWarning = false
    
    // Red flags
    @State private var bowelBladderChange = false
    @State private var saddleNumbness = false
    @State private var progressiveWeakness = false
    @State private var fever = false
    @State private var majorTrauma = false
    @State private var unexplainedWeightLoss = false
    @State private var severeNightPain = false
    
    var hasRedFlags: Bool {
        bowelBladderChange || saddleNumbness || progressiveWeakness ||
        fever || majorTrauma || unexplainedWeightLoss || severeNightPain
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Pain Level") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pain right now")
                            .font(.subheadline)
                        
                        if let pain = painNow {
                            Slider(value: .init(
                                get: { Double(pain) },
                                set: { painNow = Int($0) }
                            ), in: 0...10, step: 1)
                            
                            HStack {
                                Text("No pain")
                                    .font(.caption)
                                Spacer()
                                Text("\(pain)/10")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                Spacer()
                                Text("Worst pain")
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        } else {
                            Button("Add pain rating") {
                                painNow = 5
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pain after activity (optional)")
                            .font(.subheadline)
                        
                        if let pain = painAfterActivity {
                            Slider(value: .init(
                                get: { Double(pain) },
                                set: { painAfterActivity = Int($0) }
                            ), in: 0...10, step: 1)
                            
                            HStack {
                                Text("No pain")
                                    .font(.caption)
                                Spacer()
                                Text("\(pain)/10")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                Spacer()
                                Text("Worst pain")
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        } else {
                            Button("Add pain after activity") {
                                painAfterActivity = 5
                            }
                        }
                    }
                }
                
                Section("Red Flag Symptoms") {
                    Toggle("Bowel/bladder changes", isOn: $bowelBladderChange)
                    Toggle("Saddle numbness", isOn: $saddleNumbness)
                    Toggle("Progressive weakness", isOn: $progressiveWeakness)
                    Toggle("Fever with pain", isOn: $fever)
                    Toggle("Major trauma", isOn: $majorTrauma)
                    Toggle("Unexplained weight loss", isOn: $unexplainedWeightLoss)
                    Toggle("Severe night pain", isOn: $severeNightPain)
                    
                    if hasRedFlags {
                        Text("⚠️ Red flags detected. Please consult a healthcare provider.")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                
                Section("Notes") {
                    TextField("Additional notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Quick Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveLog()
                    }
                }
            }
            .alert("Red Flags Detected", isPresented: $showRedFlagWarning) {
                Button("I Understand", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("You've indicated symptoms that may require medical attention. Please consult a healthcare provider.")
            }
        }
    }
    
    private func saveLog() {
        let symptomLog = SymptomLog(
            painNow: painNow,
            painAfterActivity: painAfterActivity,
            bowelBladderChange: bowelBladderChange,
            saddleNumbness: saddleNumbness,
            progressiveWeakness: progressiveWeakness,
            fever: fever,
            majorTrauma: majorTrauma,
            unexplainedWeightLoss: unexplainedWeightLoss,
            severeNightPain: severeNightPain,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(symptomLog)
        try? modelContext.save()
        
        if hasRedFlags {
            showRedFlagWarning = true
        } else {
            dismiss()
        }
    }
}

#Preview {
    QuickLogSheet()
        .modelContainer(for: SymptomLog.self, inMemory: true)
}
