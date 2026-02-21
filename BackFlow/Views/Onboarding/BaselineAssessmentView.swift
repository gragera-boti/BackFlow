import SwiftUI
import SwiftData

struct BaselineAssessmentView: View {
    let onComplete: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var templates: [ProgramTemplate]
    
    @State private var painNow = 5
    @State private var worstPainLast7Days = 7
    @State private var walkingMinutes = 10
    @State private var functionTasks: [FunctionTask] = [
        FunctionTask(name: "Sit for 30 minutes", difficulty: 5),
        FunctionTask(name: "Bend to pick up object", difficulty: 5),
        FunctionTask(name: "Walk for 20 minutes", difficulty: 5)
    ]
    
    var body: some View {
        let _ = print("BaselineAssessmentView rendered")
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Text("Baseline Assessment")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("This helps us create the right starting plan for you")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // Pain Assessment
                VStack(alignment: .leading, spacing: 16) {
                    Text("Pain Right Now")
                        .font(.headline)
                    
                    PainSlider(value: $painNow)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Worst Pain (Last 7 Days)")
                        .font(.headline)
                    
                    PainSlider(value: $worstPainLast7Days)
                }
                
                Divider()
                
                // Function Tasks
                VStack(alignment: .leading, spacing: 16) {
                    Text("Daily Activities")
                        .font(.headline)
                    
                    Text("How difficult are these tasks right now? (0 = easy, 10 = impossible)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    ForEach(functionTasks.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(functionTasks[index].name)
                                .font(.body)
                            
                            Slider(value: .init(
                                get: { Double(functionTasks[index].difficulty) },
                                set: { functionTasks[index].difficulty = Int($0) }
                            ), in: 0...10, step: 1)
                            
                            HStack {
                                Text("Easy")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(functionTasks[index].difficulty)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("Impossible")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                Divider()
                
                // Walking Baseline
                VStack(alignment: .leading, spacing: 16) {
                    Text("Walking Baseline")
                        .font(.headline)
                    
                    Text("How many minutes can you walk comfortably today?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Stepper(value: $walkingMinutes, in: 0...120, step: 5) {
                        Text("\(walkingMinutes) minutes")
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Button(action: completeAssessment) {
                    Text("Start My Program")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .padding(.top)
            }
            .padding()
        }
    }
    
    private func completeAssessment() {
        print("completeAssessment called")
        print("Profiles count: \(profiles.count)")
        print("Templates count: \(templates.count)")
        
        guard let profile = profiles.first else {
            print("ERROR: No UserProfile found")
            // Still complete onboarding even if profile is missing
            onComplete()
            return
        }
        
        // Get template or use default programId
        let templateId = templates.first(where: { $0.programId == "lbp-primary-10wk" })?.programId ?? "lbp-primary-10wk"
        print("Using template ID: \(templateId)")
        
        // Create baseline symptom log
        let symptomLog = SymptomLog(
            timestamp: Date(),
            painNow: painNow,
            notes: "Baseline: worst pain last 7 days = \(worstPainLast7Days)"
        )
        modelContext.insert(symptomLog)
        
        // Create baseline function log
        let tasksData = try? JSONEncoder().encode(functionTasks)
        let tasksJSON = tasksData != nil ? String(data: tasksData!, encoding: .utf8) ?? "[]" : "[]"
        let avgScore = functionTasks.map { $0.difficulty }.reduce(0, +) / functionTasks.count
        let overallScore = Double(10 - avgScore) * 10 // Convert to 0-100 scale
        
        let functionLog = FunctionLog(
            date: Date(),
            tasksJSON: tasksJSON,
            overallScore: overallScore
        )
        modelContext.insert(functionLog)
        
        // Create walking baseline log
        let walkingLog = WalkingLog(
            date: Date(),
            durationMinutes: walkingMinutes,
            source: "manual",
            notes: "Baseline"
        )
        modelContext.insert(walkingLog)
        
        // Create program plan
        let plan = PlanEngine.shared.createPlan(
            from: templateId,
            baselinePain: worstPainLast7Days,
            sessionDaysPerWeek: profile.sessionsPerWeek,
            modelContext: modelContext
        )
        modelContext.insert(plan)
        
        do {
            try modelContext.save()
            print("Successfully saved baseline assessment and plan")
        } catch {
            print("Error saving: \(error)")
        }
        
        print("Calling onComplete()")
        onComplete()
    }
}

struct FunctionTask: Codable {
    let name: String
    var difficulty: Int
}

struct PainSlider: View {
    @Binding var value: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Slider(value: .init(
                get: { Double(value) },
                set: { value = Int($0) }
            ), in: 0...10, step: 1)
            
            HStack {
                Text("No pain")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(value)/10")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(painColor(for: value))
                Spacer()
                Text("Worst pain")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func painColor(for value: Int) -> Color {
        switch value {
        case 0...3: return .green
        case 4...6: return .orange
        default: return .red
        }
    }
}

#Preview {
    BaselineAssessmentView(onComplete: {})
        .modelContainer(for: [UserProfile.self, ProgramTemplate.self], inMemory: true)
}
