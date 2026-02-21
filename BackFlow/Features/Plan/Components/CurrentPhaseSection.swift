import SwiftUI

struct CurrentPhaseSection: View {
    let exercises: [(name: String, sets: Int, reps: String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Current Phase")
                .font(Theme.Typography.headline)
            
            Text("Focus: Building capacity with controlled progression")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(Theme.Colors.textSecondary)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                ForEach(exercises, id: \.name) { exercise in
                    PhaseExerciseRow(
                        name: exercise.name,
                        sets: exercise.sets,
                        reps: exercise.reps
                    )
                }
            }
            .padding(Theme.Spacing.medium)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(Theme.CornerRadius.medium)
        }
    }
}

struct PhaseExerciseRow: View {
    let name: String
    let sets: Int
    let reps: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(Theme.Typography.body)
            Spacer()
            Text("\(sets) × \(reps)")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
    }
}