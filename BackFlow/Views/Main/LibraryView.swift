import SwiftUI
import SwiftData

struct LibraryView: View {
    @Query(sort: \Exercise.category) private var exercises: [Exercise]
    @Query private var educationCards: [EducationCard]
    
    @State private var selectedTab: LibraryTab = .exercises
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Library", selection: $selectedTab) {
                    ForEach(LibraryTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                switch selectedTab {
                case .exercises:
                    ExerciseLibraryList(exercises: filteredExercises)
                case .education:
                    EducationLibraryList(cards: filteredEducationCards)
                }
            }
            .navigationTitle("Library")
            .searchable(text: $searchText, prompt: "Search...")
        }
    }
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter { exercise in
            exercise.name.localizedCaseInsensitiveContains(searchText) ||
            exercise.category.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var filteredEducationCards: [EducationCard] {
        if searchText.isEmpty {
            return educationCards
        }
        return educationCards.filter { card in
            card.title.localizedCaseInsensitiveContains(searchText) ||
            card.summary.localizedCaseInsensitiveContains(searchText)
        }
    }
}

enum LibraryTab: String, CaseIterable, Identifiable {
    case exercises = "Exercises"
    case education = "Education"
    
    var id: String { rawValue }
}

struct ExerciseLibraryList: View {
    let exercises: [Exercise]
    
    var groupedExercises: [(String, [Exercise])] {
        Dictionary(grouping: exercises, by: { $0.category })
            .sorted { $0.key < $1.key }
    }
    
    var body: some View {
        List {
            ForEach(groupedExercises, id: \.0) { category, exercises in
                Section(header: Text(category.capitalized)) {
                    ForEach(exercises, id: \.slug) { exercise in
                        NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                            ExerciseRow(exercise: exercise)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack {
            // Placeholder icon
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 50, height: 50)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack {
                    Label(exercise.difficulty.capitalized, systemImage: "chart.bar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if !exercise.equipment.isEmpty && exercise.equipment != ["none"] {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(exercise.equipment.joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct EducationLibraryList: View {
    let cards: [EducationCard]
    
    var body: some View {
        List {
            ForEach(cards, id: \.cardId) { card in
                NavigationLink(destination: EducationDetailView(card: card)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(card.title)
                            .font(.headline)
                        
                        Text(card.summary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    LibraryView()
        .modelContainer(for: [Exercise.self, EducationCard.self], inMemory: true)
}
