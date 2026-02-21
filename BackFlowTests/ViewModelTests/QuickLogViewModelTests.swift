import Testing
import SwiftData
@testable import BackFlow

@Suite("Quick Log ViewModel Tests")
struct QuickLogViewModelTests {
    
    @Test("Initial state is correct")
    @MainActor
    func testInitialState() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SymptomLog.self, configurations: config)
        let context = container.mainContext
        
        let viewModel = QuickLogViewModel(modelContext: context)
        
        // Then
        #expect(viewModel.painNow == nil)
        #expect(viewModel.painAfterActivity == nil)
        #expect(viewModel.notes == "")
        #expect(viewModel.hasRedFlags == false)
        #expect(viewModel.canSave == false)
        #expect(viewModel.isSaving == false)
    }
    
    @Test("Can save when pain is set")
    @MainActor
    func testCanSaveWithPain() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SymptomLog.self, configurations: config)
        let context = container.mainContext
        
        let viewModel = QuickLogViewModel(modelContext: context)
        
        // When
        viewModel.painNow = 5
        
        // Then
        #expect(viewModel.canSave == true)
    }
    
    @Test("Red flags detection works")
    @MainActor
    func testRedFlagsDetection() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SymptomLog.self, configurations: config)
        let context = container.mainContext
        
        let viewModel = QuickLogViewModel(modelContext: context)
        
        // When - no red flags
        #expect(viewModel.hasRedFlags == false)
        
        // When - bowel/bladder change
        viewModel.bowelBladderChange = true
        #expect(viewModel.hasRedFlags == true)
        
        // When - clear flag
        viewModel.bowelBladderChange = false
        #expect(viewModel.hasRedFlags == false)
        
        // When - severe night pain
        viewModel.severeNightPain = true
        #expect(viewModel.hasRedFlags == true)
    }
    
    @Test("Save log creates symptom log entry")
    @MainActor
    func testSaveLog() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SymptomLog.self, configurations: config)
        let context = container.mainContext
        
        let viewModel = QuickLogViewModel(modelContext: context)
        viewModel.painNow = 7
        viewModel.painAfterActivity = 5
        viewModel.notes = "Test note"
        
        // When
        let result = await viewModel.saveLog()
        
        // Then
        #expect(result == .success)
        
        // Verify log was saved
        let descriptor = FetchDescriptor<SymptomLog>()
        let logs = try context.fetch(descriptor)
        #expect(logs.count == 1)
        #expect(logs.first?.painNow == 7)
        #expect(logs.first?.painAfterActivity == 5)
        #expect(logs.first?.notes == "Test note")
    }
}
