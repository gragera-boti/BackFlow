import SwiftUI

struct ExerciseLibraryList: View {
    let groupedExercises: [(String, [Exercise])]
    let onExerciseSelected: (Exercise) -> Void
    
    var body: some View {
        List {
            ForEach(groupedExercises, id: \.0) { category, exercises in
                Section(header: Text(category.capitalized)) {
                    ForEach(exercises, id: \.slug) { exercise in
                        Button(action: { onExerciseSelected(exercise) }) {
                            ExerciseRow(exercise: exercise)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}