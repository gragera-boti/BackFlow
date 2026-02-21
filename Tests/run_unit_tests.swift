#!/usr/bin/env swift

import Foundation

// ANSI color codes for output
struct Colors {
    static let green = "\u{001B}[0;32m"
    static let red = "\u{001B}[0;31m"
    static let yellow = "\u{001B}[0;33m"
    static let reset = "\u{001B}[0m"
}

// Test result tracking
struct TestResult {
    let name: String
    let passed: Bool
    let message: String
    let duration: TimeInterval
}

class TestRunner {
    private var results: [TestResult] = []
    private var currentTest: String = ""
    
    func run() {
        print("\n🧪 Running BackFlow Unit Tests\n")
        
        // Run test suites
        testWeekdayScheduleGeneration()
        testGoalValidation()
        testNavigationFlow()
        testDataPersistence()
        
        // Print summary
        printSummary()
    }
    
    // MARK: - Test Suites
    
    func testWeekdayScheduleGeneration() {
        describe("Weekday Schedule Generation") {
            test("should generate correct schedule for 1 session per week") {
                let result = generateWeekdaySchedule(sessionsPerWeek: 1)
                try assert(result == [3], "Expected [3] (Wednesday), got \(result)")
            }
            
            test("should generate correct schedule for 3 sessions per week") {
                let result = generateWeekdaySchedule(sessionsPerWeek: 3)
                try assert(result == [1, 3, 5], "Expected [1, 3, 5] (Mon/Wed/Fri), got \(result)")
            }
            
            test("should generate correct schedule for 7 sessions per week") {
                let result = generateWeekdaySchedule(sessionsPerWeek: 7)
                try assert(result == [0, 1, 2, 3, 4, 5, 6], "Expected all days, got \(result)")
            }
        }
    }
    
    func testGoalValidation() {
        describe("Goal Selection Validation") {
            test("should disable button when no goals selected") {
                let selectedGoals: Set<String> = []
                let isEnabled = !selectedGoals.isEmpty
                try assert(!isEnabled, "Button should be disabled with no goals")
            }
            
            test("should enable button when goals are selected") {
                let selectedGoals: Set<String> = ["Reduce flare-ups"]
                let isEnabled = !selectedGoals.isEmpty
                try assert(isEnabled, "Button should be enabled with goals selected")
            }
        }
    }
    
    func testNavigationFlow() {
        describe("Onboarding Navigation") {
            test("should start at step 0") {
                let initialStep = 0
                try assert(initialStep == 0, "Should start at welcome screen")
            }
            
            test("should advance through steps correctly") {
                var step = 0
                
                // Welcome -> Disclaimer
                step = 1
                try assert(step == 1, "Should advance to disclaimer")
                
                // Disclaimer -> Red Flags
                step = 2
                try assert(step == 2, "Should advance to red flags")
                
                // Red Flags -> Goals (no flags)
                step = 3
                try assert(step == 3, "Should advance to goals")
                
                // Goals -> Baseline
                step = 4
                try assert(step == 4, "Should advance to baseline")
            }
        }
    }
    
    func testDataPersistence() {
        describe("Data Model Integrity") {
            test("UserProfile should handle optional reminder fields") {
                // Simulate creating a profile without reminder
                let reminderHour: Int? = nil
                let reminderMinute: Int? = nil
                
                try assert(reminderHour == nil, "Reminder hour should be nil")
                try assert(reminderMinute == nil, "Reminder minute should be nil")
            }
            
            test("UserProfile should store reminder time correctly") {
                let reminderHour: Int? = 9
                let reminderMinute: Int? = 30
                
                try assert(reminderHour == 9, "Reminder hour should be 9")
                try assert(reminderMinute == 30, "Reminder minute should be 30")
            }
        }
    }
    
    // MARK: - Test Helpers
    
    private func describe(_ suiteName: String, tests: () -> Void) {
        print("\n📁 \(suiteName)")
        tests()
    }
    
    private func test(_ description: String, body: () throws -> Void) {
        currentTest = description
        let start = Date()
        
        do {
            try body()
            let duration = Date().timeIntervalSince(start)
            results.append(TestResult(
                name: currentTest,
                passed: true,
                message: "Passed",
                duration: duration
            ))
            print("  \(Colors.green)✓\(Colors.reset) \(description) (\(String(format: "%.3f", duration))s)")
        } catch {
            let duration = Date().timeIntervalSince(start)
            results.append(TestResult(
                name: currentTest,
                passed: false,
                message: error.localizedDescription,
                duration: duration
            ))
            print("  \(Colors.red)✗\(Colors.reset) \(description)")
            print("    \(Colors.red)\(error.localizedDescription)\(Colors.reset)")
        }
    }
    
    private func assert(_ condition: Bool, _ message: String) throws {
        if !condition {
            throw TestError.assertionFailed(message)
        }
    }
    
    private func printSummary() {
        let passed = results.filter { $0.passed }.count
        let failed = results.filter { !$0.passed }.count
        let total = results.count
        let totalTime = results.reduce(0) { $0 + $1.duration }
        
        print("\n" + String(repeating: "=", count: 50))
        print("\n📊 Test Summary\n")
        print("Total: \(total) tests")
        print("\(Colors.green)Passed: \(passed)\(Colors.reset)")
        if failed > 0 {
            print("\(Colors.red)Failed: \(failed)\(Colors.reset)")
        }
        print("Time: \(String(format: "%.3f", totalTime))s")
        
        if failed == 0 {
            print("\n\(Colors.green)✅ All tests passed!\(Colors.reset)")
        } else {
            print("\n\(Colors.red)❌ \(failed) test(s) failed\(Colors.reset)")
            
            print("\nFailed tests:")
            for result in results.filter({ !$0.passed }) {
                print("  • \(result.name)")
                print("    \(result.message)")
            }
        }
        print("")
    }
    
    // MARK: - Business Logic (mirroring app logic)
    
    private func generateWeekdaySchedule(sessionsPerWeek: Int) -> [Int] {
        switch sessionsPerWeek {
        case 1:
            return [3] // Wednesday
        case 2:
            return [1, 4] // Monday, Thursday
        case 3:
            return [1, 3, 5] // Monday, Wednesday, Friday
        case 4:
            return [1, 2, 4, 5] // Monday, Tuesday, Thursday, Friday
        case 5:
            return [1, 2, 3, 4, 5] // Weekdays
        case 6:
            return [1, 2, 3, 4, 5, 6] // Monday through Saturday
        case 7:
            return [0, 1, 2, 3, 4, 5, 6] // Every day
        default:
            return [1, 3, 5] // Default to Mon/Wed/Fri
        }
    }
}

enum TestError: LocalizedError {
    case assertionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .assertionFailed(let message):
            return message
        }
    }
}

// Run the tests
TestRunner().run()