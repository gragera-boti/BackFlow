import SwiftUI
import SwiftData

struct PostSessionView: View {
    @Environment(\.modelContext) private var modelContext
    
    let session: Session
    let onComplete: () -> Void
    
    @State private var painAfter = 3
    @State private var notes = ""
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            completionIcon
            
            VStack(alignment: .leading, spacing: 16) {
                Text("How do you feel right now?")
                    .font(.headline)
                
                PainSlider(value: $painAfter)
            }
            .padding()
            
            notesField
            
            Spacer()
            
            doneButton
        }
        .padding()
    }
    
    // MARK: - View Sections
    
    private var completionIcon: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
            
            Text("Session Complete!")
                .font(.title)
                .fontWeight(.bold)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Session complete")
    }
    
    private var notesField: some View {
        TextField("Notes (optional)", text: $notes, axis: .vertical)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
            .accessibilityLabel("Session notes")
    }
    
    private var doneButton: some View {
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
        .accessibilityLabel("Finish and save session")
    }
    
    // MARK: - Actions
    
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
    PostSessionView(
        session: Session(date: Date(), templateId: "test", phaseId: "phase-1"),
        onComplete: {}
    )
    .modelContainer(for: Session.self, inMemory: true)
}
