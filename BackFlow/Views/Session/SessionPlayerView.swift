import SwiftUI
import SwiftData

struct SessionPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let session: Session
    @Query private var exercises: [Exercise]
    
    @State private var currentExerciseIndex = 0
    @State private var currentSet = 1
    @State private var isResting = false
    @State private var showPostSession = false
    
    // TODO: Load actual session exercises from template
    let sessionExercises = ["cat-cow", "bird-dog", "dead-bug", "glute-bridge"]
    
    var currentExercise: Exercise? {
        exercises.first { $0.slug == sessionExercises[currentExerciseIndex] }
    }
    
    var body: some View {
        NavigationStack {
            if showPostSession {
                PostSessionView(session: session, onComplete: {
                    dismiss()
                })
            } else {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Progress bar
                        ProgressView(value: Double(currentExerciseIndex + 1), total: Double(sessionExercises.count))
                            .tint(.white)
                            .padding()
                        
                        if let exercise = currentExercise {
                            ScrollView {
                                VStack(spacing: 24) {
                                    // Exercise illustration
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 300)
                                        
                                        Image(systemName: "figure.strengthtraining.traditional")
                                            .font(.system(size: 100))
                                            .foregroundStyle(.white.opacity(0.8))
                                    }
                                    .cornerRadius(16)
                                    
                                    // Exercise info
                                    VStack(spacing: 16) {
                                        Text(exercise.name)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                        
                                        Text("Set \(currentSet) of \(exercise.setsDefault)")
                                            .font(.title3)
                                            .foregroundStyle(.white.opacity(0.8))
                                        
                                        if let reps = exercise.repsDefault {
                                            Text("\(reps) reps")
                                                .font(.largeTitle)
                                                .fontWeight(.bold)
                                                .foregroundStyle(.blue)
                                        } else if let hold = exercise.holdSecDefault {
                                            Text("\(hold) seconds")
                                                .font(.largeTitle)
                                                .fontWeight(.bold)
                                                .foregroundStyle(.blue)
                                        }
                                        
                                        // Primary cues
                                        VStack(alignment: .leading, spacing: 12) {
                                            ForEach(Array(exercise.primaryCues.enumerated()), id: \.offset) { index, cue in
                                                HStack(alignment: .top, spacing: 12) {
                                                    Text("\(index + 1)")
                                                        .font(.headline)
                                                        .foregroundStyle(.blue)
                                                        .frame(width: 24)
                                                    Text(cue)
                                                        .font(.body)
                                                        .foregroundStyle(.white)
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                    .padding()
                                }
                            }
                            
                            // Action buttons
                            VStack(spacing: 16) {
                                Button(action: completeSet) {
                                    Text(currentSet < exercise.setsDefault ? "Next Set" : "Next Exercise")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundStyle(.white)
                                        .cornerRadius(12)
                                }
                                
                                Button(action: { /* Log pain */ }) {
                                    Text("Log Pain During Exercise")
                                        .font(.subheadline)
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                            }
                            .padding()
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Exit") {
                            dismiss()
                        }
                        .foregroundStyle(.white)
                    }
                }
            }
        }
    }
    
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
            // Next set
            currentSet += 1
        } else if currentExerciseIndex < sessionExercises.count - 1 {
            // Next exercise
            currentExerciseIndex += 1
            currentSet = 1
        } else {
            // Session complete
            session.completed = true
            try? modelContext.save()
            showPostSession = true
        }
    }
}

struct PostSessionView: View {
    @Environment(\.modelContext) private var modelContext
    let session: Session
    let onComplete: () -> Void
    
    @State private var painAfter = 3
    @State private var notes = ""
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
            
            Text("Session Complete!")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("How do you feel right now?")
                    .font(.headline)
                
                PainSlider(value: $painAfter)
            }
            .padding()
            
            TextField("Notes (optional)", text: $notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: saveAndContinue) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .padding()
        }
        .padding()
    }
    
    private func saveAndContinue() {
        session.painAfterSession = painAfter
        session.notes = notes.isEmpty ? nil : notes
        try? modelContext.save()
        
        // Schedule next-day check-in
        NotificationService.shared.scheduleNextDayCheckIn(sessionDate: session.date)
        
        onComplete()
    }
}

#Preview {
    SessionPlayerView(session: Session(templateId: "test", phaseId: "phase-1"))
        .modelContainer(for: [Exercise.self, Session.self], inMemory: true)
}
