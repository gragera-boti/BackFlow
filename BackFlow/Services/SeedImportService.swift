import Foundation
import SwiftData

class SeedImportService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func needsImport() -> Bool {
        // Check if already seeded
        let descriptor = FetchDescriptor<Exercise>()
        let count = try? modelContext.fetchCount(descriptor)
        return count == 0
    }
    
    func importAllData() async throws {
        print("Importing seed data...")
        
        // Import references
        try await importReferences()
        
        // Import exercises
        try await importExercises()
        
        // Import education cards
        try await importEducationCards()
        
        // Import program templates
        try await importProgramTemplates()
        
        try modelContext.save()
        print("Seed data import complete")
    }
    
    private func importReferences() async throws {
        guard let url = Bundle.main.url(forResource: "references", withExtension: "json"),
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
    
    private func importExercises() async throws {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json"),
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
    
    private func importEducationCards() async throws {
        guard let url = Bundle.main.url(forResource: "education_cards", withExtension: "json"),
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
    
    private func importProgramTemplates() async throws {
        guard let url = Bundle.main.url(forResource: "program_templates", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let template = try? JSONDecoder().decode(ProgramTemplateJSON.self, from: data) else {
            print("Failed to load program_templates.json")
            return
        }
        
        // Convert template back to JSON string for storage
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let templateData = try? encoder.encode(template),
              let templateJSON = String(data: templateData, encoding: .utf8) else {
            print("Failed to encode template")
            return
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
    
    enum CodingKeys: String, CodingKey {
        case slug, name, category, equipment, difficulty
        case regions = "region"
        case timePerSetSec = "time_per_set_sec"
        case setsDefault = "sets_default"
        case repsDefault = "reps_default"
        case holdSecDefault = "hold_sec_default"
        case restSecDefault = "rest_sec_default"
        case primaryCues = "primary_cues"
        case commonMistakes = "common_mistakes"
        case progressions, regressions
        case dosageNotes = "dosage_notes"
        case rangeOfMotionNotes = "range_of_motion_notes"
        case evidenceRefs = "evidence_refs"
        case illustrationAssetName = "illustration"
    }
}

struct EducationCardJSON: Codable {
    let id: String
    let title: String
    let summary: String
    let detailMarkdown: String
    let refs: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, title, summary, refs
        case detailMarkdown = "detail_md"
    }
}

struct ProgramTemplateJSON: Codable {
    let programId: String
    let name: String
    let targetCondition: String
    let phases: [PhaseJSON]
    let activityLadder: [ActivityLadderLevelJSON]?
    
    enum CodingKeys: String, CodingKey {
        case name, phases
        case programId = "program_id"
        case targetCondition = "target_condition"
        case activityLadder = "activity_ladder"
    }
}

struct PhaseJSON: Codable {
    let phaseId: String
    let name: String
    let durationWeeks: Int?
    let sessionTemplates: [SessionTemplateJSON]
    let goals: [String]?
    let exitCriteria: [String]?
    let sessionsPerWeek: Int?
    
    enum CodingKeys: String, CodingKey {
        case name, goals
        case phaseId = "phase_id"
        case durationWeeks = "duration_weeks"
        case sessionTemplates = "session_templates"
        case exitCriteria = "exit_criteria"
        case sessionsPerWeek = "sessions_per_week"
    }
}

struct SessionTemplateJSON: Codable {
    let templateId: String
    let name: String
    let exercises: [SessionExerciseJSON]
    
    enum CodingKeys: String, CodingKey {
        case name, exercises
        case templateId = "template_id"
    }
}

struct SessionExerciseJSON: Codable {
    let exerciseSlug: String
    let sets: Int
    let reps: Int?
    let holdSec: Int?
    let durationSec: Int?
    let restSec: Int?
    
    enum CodingKeys: String, CodingKey {
        case sets, reps
        case exerciseSlug = "slug"
        case holdSec = "hold_sec"
        case durationSec = "duration_sec"
        case restSec = "rest_sec"
    }
}

struct ActivityLadderLevelJSON: Codable {
    let level: Int
    let name: String
    let description: String
    let weeklyMinutes: Int
    
    enum CodingKeys: String, CodingKey {
        case level, name, description
        case weeklyMinutes = "weekly_minutes"
    }
}
