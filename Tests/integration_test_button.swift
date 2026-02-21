#!/usr/bin/env swift

import Foundation

// Simulate the GoalAndScheduleView state and behavior
class GoalAndScheduleViewSimulator {
    // State variables (mirroring SwiftUI @State)
    var selectedGoals: Set<String> = []
    var selectedEquipment: Set<String> = ["None"]
    var sessionsPerWeek = 3
    var reminderEnabled = false
    var reminderTime = Date()
    
    // Callback that should trigger navigation
    var onContinue: () -> Void = {}
    var onContinueCalled = false
    
    // Simulated database operations
    var savedUserProfile: UserProfile?
    var savedProgramPlan: ProgramPlan?
    var saveError: Error?
    
    // Debug tracking
    var debugLog: [String] = []
    
    init(onContinue: @escaping () -> Void) {
        self.onContinue = onContinue
    }
    
    // Simulate the button tap
    func tapCreateMyPlanButton() {
        // Check if button should be enabled (mirrors the SwiftUI disabled modifier)
        let isButtonEnabled = !selectedGoals.isEmpty
        
        if !isButtonEnabled {
            debugLog.append("Button tap ignored - button is disabled (no goals selected)")
            return
        }
        
        debugLog.append("Button action triggered")
        debugLog.append("Goals selected: \(selectedGoals)")
        saveAndContinue()
    }
    
    // The actual save function from the view
    func saveAndContinue() {
        debugLog.append("saveAndContinue called - selectedGoals: \(selectedGoals)")
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        
        // Create UserProfile
        let profile = UserProfile(
            goal: Array(selectedGoals).joined(separator: ", "),
            sessionsPerWeek: sessionsPerWeek,
            equipment: Array(selectedEquipment),
            reminderHour: reminderEnabled ? components.hour : nil,
            reminderMinute: reminderEnabled ? components.minute : nil
        )
        
        debugLog.append("UserProfile created and inserted")
        savedUserProfile = profile
        
        // Create ProgramPlan
        let weekdays = generateWeekdaySchedule(sessionsPerWeek: sessionsPerWeek)
        let programPlan = ProgramPlan(
            programId: "standard-rehab-program",
            currentPhaseId: "phase-1",
            weekdays: weekdays
        )
        
        debugLog.append("ProgramPlan created and inserted")
        savedProgramPlan = programPlan
        
        // Simulate save
        if saveError == nil {
            debugLog.append("Profile and program plan saved successfully")
            
            // Call navigation callback
            debugLog.append("About to call onContinue")
            onContinue()
            onContinueCalled = true
            debugLog.append("onContinue called")
        } else {
            debugLog.append("Save error: \(saveError!.localizedDescription)")
        }
    }
    
    func generateWeekdaySchedule(sessionsPerWeek: Int) -> [Int] {
        switch sessionsPerWeek {
        case 1: return [3]
        case 2: return [1, 4]
        case 3: return [1, 3, 5]
        case 4: return [1, 2, 4, 5]
        case 5: return [1, 2, 3, 4, 5]
        case 6: return [1, 2, 3, 4, 5, 6]
        case 7: return [0, 1, 2, 3, 4, 5, 6]
        default: return [1, 3, 5]
        }
    }
}

// Simplified data models for testing
struct UserProfile {
    let goal: String
    let sessionsPerWeek: Int
    let equipment: [String]
    let reminderHour: Int?
    let reminderMinute: Int?
}

struct ProgramPlan {
    let programId: String
    let currentPhaseId: String
    let weekdays: [Int]
}

// Test runner
func runIntegrationTest() {
    print("\n🧪 Running Integration Test: Create My Plan Button\n")
    
    var navigationTriggered = false
    let view = GoalAndScheduleViewSimulator(onContinue: {
        navigationTriggered = true
    })
    
    // Test 1: Button should not work without goals
    print("📋 Test 1: Button tap without goals selected")
    view.tapCreateMyPlanButton()
    
    if !navigationTriggered && view.savedUserProfile == nil {
        print("✅ Correctly prevented save with no goals")
    } else {
        print("❌ FAILED: Button should not work without goals")
    }
    
    // Test 2: Button should work with goals selected
    print("\n📋 Test 2: Button tap with goals selected")
    view.selectedGoals = ["Reduce flare-ups", "Move more comfortably"]
    view.tapCreateMyPlanButton()
    
    print("\n🔍 Debug Log:")
    for log in view.debugLog {
        print("  • \(log)")
    }
    
    print("\n📊 Results:")
    print("  • Goals selected: \(view.selectedGoals)")
    print("  • UserProfile saved: \(view.savedUserProfile != nil ? "✅" : "❌")")
    print("  • ProgramPlan saved: \(view.savedProgramPlan != nil ? "✅" : "❌")")
    print("  • onContinue called: \(view.onContinueCalled ? "✅" : "❌")")
    print("  • Navigation triggered: \(navigationTriggered ? "✅" : "❌")")
    
    if let profile = view.savedUserProfile {
        print("\n📝 Saved Profile:")
        print("  • Goals: \(profile.goal)")
        print("  • Sessions/week: \(profile.sessionsPerWeek)")
        print("  • Equipment: \(profile.equipment)")
    }
    
    if let plan = view.savedProgramPlan {
        print("\n📅 Saved Plan:")
        print("  • Program: \(plan.programId)")
        print("  • Phase: \(plan.currentPhaseId)")
        print("  • Weekdays: \(plan.weekdays)")
    }
    
    // Final verdict
    let testPassed = navigationTriggered && 
                    view.savedUserProfile != nil && 
                    view.savedProgramPlan != nil &&
                    view.onContinueCalled
    
    print("\n\(testPassed ? "✅ TEST PASSED" : "❌ TEST FAILED")")
    
    if !testPassed {
        print("\n🔴 Possible issues:")
        if !view.onContinueCalled {
            print("  • onContinue callback was never invoked")
        }
        if !navigationTriggered {
            print("  • Navigation callback didn't update parent state")
        }
        if view.savedUserProfile == nil {
            print("  • UserProfile was not created/saved")
        }
        if view.savedProgramPlan == nil {
            print("  • ProgramPlan was not created/saved")
        }
    }
}

// Run the test
runIntegrationTest()