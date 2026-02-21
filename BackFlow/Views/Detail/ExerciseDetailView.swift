import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ExerciseIllustration(assetName: exercise.illustrationAssetName)
                
                VStack(alignment: .leading, spacing: 16) {
                    ExerciseInfoSection(
                        name: exercise.name,
                        difficulty: exercise.difficulty,
                        equipment: exercise.equipment,
                        category: exercise.category
                    )
                    
                    Divider()
                    
                    PrimaryCuesSection(cues: exercise.primaryCues)
                    
                    Divider()
                    
                    DosageSection(
                        reps: exercise.repsDefault,
                        holdSec: exercise.holdSecDefault,
                        sets: exercise.setsDefault,
                        notes: exercise.dosageNotes
                    )
                    
                    if !exercise.commonMistakes.isEmpty {
                        Divider()
                        CommonMistakesSection(mistakes: exercise.commonMistakes)
                    }
                    
                    if !exercise.regressions.isEmpty || !exercise.progressions.isEmpty {
                        Divider()
                        VariationsSection(
                            regressions: exercise.regressions,
                            progressions: exercise.progressions
                        )
                    }
                    
                    if !exercise.evidenceRefs.isEmpty {
                        Divider()
                        evidenceSection
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - View Sections
    
    private var evidenceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Evidence")
                .font(.headline)
            
            Text("\(exercise.evidenceRefs.count) references")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
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
