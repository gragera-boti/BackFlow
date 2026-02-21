import SwiftUI
import SwiftData

struct SessionPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let session: Session
    @Query private var exercises: [Exercise]
    
    @State private var currentExerciseIndex = 0
    @State private var currentSet = 1
    @State private var showPostSession = false
    
    // TODO: Load actual session exercises from template
    let sessionExercises = ["cat-cow", "bird-dog", "dead-bug", "glute-bridge"]
    
    var currentExercise: Exercise? {
        exercises.first { $0.slug == sessionExercises[currentExerciseIndex] }
    }
    
    var body: some View {
        NavigationStack {
            if showPostSession {
                PostSessionView(session: session, onComplete: { dismiss() })
            } else {
                activeSessionView
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            exitButton
                        }
                    }
            }
        }
    }
    
    // MARK: - View Sections
    
    private var activeSessionView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                SessionProgressBar(
                    current: currentExerciseIndex + 1,
                    total: sessionExercises.count
                )
                
                if let exercise = currentExercise {
                    exerciseContent(exercise)
                    actionButtons(for: exercise)
                }
            }
        }
    }
    
    @ViewBuilder
    private func exerciseContent(_ exercise: Exercise) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                SessionExerciseIllustration()
                
                SessionExerciseInfo(
                    name: exercise.name,
                    currentSet: currentSet,
                    totalSets: exercise.setsDefault,
                    reps: exercise.repsDefault,
                    holdSec: exercise.holdSecDefault
                )
                
                SessionCuesCard(cues: exercise.primaryCues)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func actionButtons(for exercise: Exercise) -> some View {
        SessionActionButtons(
            isLastSet: currentSet >= exercise.setsDefault,
            isLastExercise: currentExerciseIndex >= sessionExercises.count - 1,
            onComplete: completeSet,
            onLogPain: { /* TODO: Log pain */ }
        )
    }
    
    private var exitButton: some View {
        Button("Exit") { dismiss() }
            .foregroundStyle(.white)
            .accessibilityLabel("Exit session")
    }
    
    // MARK: - Actions
    
    private func completeSet() {
        guard let exercise = currentExercise else { return }
        
        // Create set log
        let setLog = SetLog(
            session: session,
            exerciseSlug: exercise.slug,
            setIndex: currentSet,
            targetReps: exercise.repsDefault,
            targetHoldSec: exercise.holdSecDefault,
            actualReps: exercise.repsDefault, // Assuming completed as prescribed
            actualHoldSec: exercise.holdSecDefault
        )
        modelContext.insert(setLog)
        
        if currentSet < exercise.setsDefault {
            currentSet += 1
        } else if currentExerciseIndex < sessionExercises.count - 1 {
            currentExerciseIndex += 1
            currentSet = 1
        } else {
            session.completed = true
            try? modelContext.save()
            showPostSession = true
        }
    }
}

#Preview {
    SessionPlayerView(session: Session(date: Date(), templateId: "test", phaseId: "phase-1"))
        .modelContainer(for: [Exercise.self, Session.self], inMemory: true)
}
