import Foundation
import SwiftData

@MainActor
class SeedImportService {
    static let shared = SeedImportService()
    
    private init() {}
    
    func importSeedDataIfNeeded(modelContext: ModelContext) async {
        // Check if already seeded
        let descriptor = FetchDescriptor<Exercise>()
        if (try? modelContext.fetchCount(descriptor)) ?? 0 > 0 {
            print("Seed data already imported")
            return
        }
        
        print("Importing seed data...")
        
        // Import references
        await importReferences(modelContext: modelContext)
        
        // Import exercises
        await importExercises(modelContext: modelContext)
        
        // Import education cards
        await importEducationCards(modelContext: modelContext)
        
        // Import program templates
        await importProgramTemplates(modelContext: modelContext)
        
        try? modelContext.save()
        print("Seed data import complete")
    }
    
    private func importReferences(modelContext: ModelContext) async {
        guard let url = Bundle.main.url(forResource: "references", withExtension: "json", subdirectory: "SeedData"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONDecoder().decode([ReferenceJSON].self, from: data) else {
            print("Failed to load references.json")
            return
        }
        
        for ref in json {
            let reference = Reference(
                key: ref.key,
                type: ref.type,
                title: ref.title,
                authors: ref.authors,
                year: ref.year,
                journal: ref.journal,
                doi: ref.doi,
                url: ref.url,
                notes: ref.notes
            )
            modelContext.insert(reference)
        }
    }
    
    private func importExercises(modelContext: ModelContext) async {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json", subdirectory: "SeedData"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONDecoder().decode([ExerciseJSON].self, from: data) else {
            print("Failed to load exercises.json")
            return
        }
        
        for ex in json {
            let exercise = Exercise(
                slug: ex.slug,
                name: ex.name,
                category: ex.category,
                regions: ex.regions,
                equipment: ex.equipment,
                difficulty: ex.difficulty,
                timePerSetSec: ex.timePerSetSec,
                setsDefault: ex.setsDefault,
                repsDefault: ex.repsDefault,
                holdSecDefault: ex.holdSecDefault,
                restSecDefault: ex.restSecDefault,
                primaryCues: ex.primaryCues,
                commonMistakes: ex.commonMistakes,
                progressions: ex.progressions,
                regressions: ex.regressions,
                dosageNotes: ex.dosageNotes,
                rangeOfMotionNotes: ex.rangeOfMotionNotes,
                evidenceRefs: ex.evidenceRefs,
                illustrationAssetName: ex.illustrationAssetName
            )
            modelContext.insert(exercise)
        }
    }
    
    private func importEducationCards(modelContext: ModelContext) async {
        guard let url = Bundle.main.url(forResource: "education_cards", withExtension: "json", subdirectory: "SeedData"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONDecoder().decode([EducationCardJSON].self, from: data) else {
            print("Failed to load education_cards.json")
            return
        }
        
        for card in json {
            let educationCard = EducationCard(
                cardId: card.id,
                title: card.title,
                summary: card.summary,
                detailMarkdown: card.detailMarkdown,
                refs: card.refs
            )
            modelContext.insert(educationCard)
        }
    }
    
    private func importProgramTemplates(modelContext: ModelContext) async {
        guard let url = Bundle.main.url(forResource: "program_templates", withExtension: "json", subdirectory: "SeedData"),
              let data = try? Data(contentsOf: url),
              let jsonString = String(data: data, encoding: .utf8),
              let json = try? JSONDecoder().decode([ProgramTemplateJSON].self, from: data) else {
            print("Failed to load program_templates.json")
            return
        }
        
        for template in json {
            // Convert template back to JSON string for storage
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            guard let templateData = try? encoder.encode(template),
                  let templateJSON = String(data: templateData, encoding: .utf8) else {
                continue
            }
            
            let programTemplate = ProgramTemplate(
                programId: template.programId,
                name: template.name,
                targetCondition: template.targetCondition,
                jsonPayload: templateJSON
            )
            modelContext.insert(programTemplate)
        }
    }
}

// MARK: - Decodable structs for JSON

struct ReferenceJSON: Codable {
    let key: String
    let type: String
    let title: String
    let authors: String
    let year: Int
    let journal: String
    let doi: String
    let url: String
    let notes: String
}

struct ExerciseJSON: Codable {
    let slug: String
    let name: String
    let category: String
    let regions: [String]
    let equipment: [String]
    let difficulty: String
    let timePerSetSec: Int?
    let setsDefault: Int
    let repsDefault: Int?
    let holdSecDefault: Int?
    let restSecDefault: Int?
    let primaryCues: [String]
    let commonMistakes: [String]
    let progressions: [String]
    let regressions: [String]
    let dosageNotes: String
    let rangeOfMotionNotes: String
    let evidenceRefs: [String]
    let illustrationAssetName: String
}

struct EducationCardJSON: Codable {
    let id: String
    let title: String
    let summary: String
    let detailMarkdown: String
    let refs: [String]
}

struct ProgramTemplateJSON: Codable {
    let programId: String
    let name: String
    let targetCondition: String
    let phases: [PhaseJSON]
    let activityLadder: [ActivityLadderLevelJSON]
}

struct PhaseJSON: Codable {
    let phaseId: String
    let name: String
    let durationWeeks: Int
    let sessionTemplates: [SessionTemplateJSON]
}

struct SessionTemplateJSON: Codable {
    let templateId: String
    let name: String
    let exercises: [SessionExerciseJSON]
}

struct SessionExerciseJSON: Codable {
    let exerciseSlug: String
    let sets: Int
    let reps: Int?
    let holdSec: Int?
    let restSec: Int?
}

struct ActivityLadderLevelJSON: Codable {
    let level: Int
    let name: String
    let description: String
    let weeklyMinutes: Int
}
