import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Placeholder illustration
                ZStack {
                    Rectangle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 250)
                    
                    VStack {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue)
                        Text("Illustration: \(exercise.illustrationAssetName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Exercise Info
                    Text(exercise.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 16) {
                        InfoChip(icon: "chart.bar", text: exercise.difficulty.capitalized)
                        InfoChip(icon: "dumbbell", text: exercise.equipment.joined(separator: ", "))
                        InfoChip(icon: "figure.stand", text: exercise.category)
                    }
                    
                    Divider()
                    
                    // Primary Cues
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How to Perform")
                            .font(.headline)
                        
                        ForEach(Array(exercise.primaryCues.enumerated()), id: \.offset) { index, cue in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1).")
                                    .fontWeight(.medium)
                                    .foregroundStyle(.blue)
                                Text(cue)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Default Dosage
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommended Dosage")
                            .font(.headline)
                        
                        HStack {
                            if let reps = exercise.repsDefault {
                                DosageCard(label: "Reps", value: "\(reps)")
                            }
                            if let hold = exercise.holdSecDefault {
                                DosageCard(label: "Hold", value: "\(hold)s")
                            }
                            DosageCard(label: "Sets", value: "\(exercise.setsDefault)")
                        }
                        
                        if !exercise.dosageNotes.isEmpty {
                            Text(exercise.dosageNotes)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Common Mistakes
                    if !exercise.commonMistakes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Common Mistakes")
                                .font(.headline)
                            
                            ForEach(exercise.commonMistakes, id: \.self) { mistake in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundStyle(.orange)
                                    Text(mistake)
                                }
                            }
                        }
                        
                        Divider()
                    }
                    
                    // Progressions & Regressions
                    HStack(spacing: 16) {
                        if !exercise.regressions.isEmpty {
                            VariationSection(title: "Easier", items: exercise.regressions, color: .green)
                        }
                        
                        if !exercise.progressions.isEmpty {
                            VariationSection(title: "Harder", items: exercise.progressions, color: .orange)
                        }
                    }
                    
                    // Evidence References
                    if !exercise.evidenceRefs.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Evidence")
                                .font(.headline)
                            
                            Text("\(exercise.evidenceRefs.count) references")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoChip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct DosageCard: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

struct VariationSection: View {
    let title: String
    let items: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            ForEach(items, id: \.self) { item in
                Text("• \(item)")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(exercise: Exercise(
            slug: "cat-cow",
            name: "Cat-Cow",
            category: "mobility",
            regions: ["lumbar"],
            equipment: ["none"],
            difficulty: "beginner",
            setsDefault: 2,
            repsDefault: 8,
            restSecDefault: 30,
            primaryCues: ["Start on hands and knees", "Arch back (cow)", "Round back (cat)"],
            commonMistakes: ["Moving too fast"],
            progressions: ["Add holds"],
            regressions: ["Smaller range"],
            dosageNotes: "Slow and controlled",
            rangeOfMotionNotes: "Pain-free range only",
            evidenceRefs: [],
            illustrationAssetName: "cat-cow.svg"
        ))
    }
}
