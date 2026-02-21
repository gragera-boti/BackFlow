import SwiftUI

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack {
            // Placeholder icon
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.title2)
                .foregroundStyle(Theme.Colors.primary)
                .frame(width: 50, height: 50)
                .background(Theme.Colors.primary.opacity(0.1))
                .cornerRadius(Theme.CornerRadius.small)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                Text(exercise.name)
                    .font(Theme.Typography.body)
                    .fontWeight(.medium)
                    .foregroundStyle(Theme.Colors.textPrimary)
                
                HStack {
                    Label(exercise.difficulty.capitalized, systemImage: "chart.bar")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                    
                    if !exercise.equipment.isEmpty && exercise.equipment != ["none"] {
                        Text("•")
                            .foregroundStyle(Theme.Colors.textSecondary)
                        Text(exercise.equipment.joined(separator: ", "))
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }
            }
        }
    }
}