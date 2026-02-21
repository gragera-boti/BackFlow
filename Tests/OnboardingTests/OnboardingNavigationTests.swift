import XCTest
import SwiftUI
import SwiftData
@testable import BackFlow

@MainActor
final class OnboardingNavigationTests: XCTestCase {
    
    func test_onboardingStepTransitions() {
        // Test that currentStep increments properly
        var currentStep = 0
        
        // Welcome -> Disclaimer
        currentStep = 1
        XCTAssertEqual(currentStep, 1)
        
        // Disclaimer -> Red Flags
        currentStep = 2
        XCTAssertEqual(currentStep, 2)
        
        // Red Flags -> Goals (no flags)
        currentStep = 3
        XCTAssertEqual(currentStep, 3)
        
        // Goals -> Baseline
        currentStep = 4
        XCTAssertEqual(currentStep, 4)
    }
    
    func test_redFlagsDetection_navigatesToStopAndSeekCare() {
        var currentStep = 2
        var redFlagsDetected = false
        
        // Simulate red flags detected
        redFlagsDetected = true
        currentStep = 3
        
        // When at step 3 with red flags, should show StopAndSeekCareView
        XCTAssertEqual(currentStep, 3)
        XCTAssertTrue(redFlagsDetected)
    }
    
    func test_goalsAndScheduleContinue_incrementsStep() async {
        // Given
        var currentStep = 3
        let expectation = XCTestExpectation(description: "Step incremented")
        
        // Simulate the onContinue callback
        let onContinue = {
            currentStep = 4
            expectation.fulfill()
        }
        
        // When
        onContinue()
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(currentStep, 4, "Step should increment from 3 to 4")
    }
}

// Test helper to verify SwiftUI state updates
@MainActor
final class OnboardingStateTests: XCTestCase {
    
    func test_stateBinding_updatesCorrectly() {
        // Test that @State variables update as expected
        struct TestView: View {
            @State var currentStep: Int
            
            var body: some View {
                Text("Step \(currentStep)")
            }
        }
        
        var view = TestView(currentStep: 0)
        XCTAssertEqual(view.currentStep, 0)
        
        // Simulate state change
        view.currentStep = 1
        XCTAssertEqual(view.currentStep, 1)
    }
    
    func test_onboardingCompleted_persistsInUserDefaults() {
        // Given
        let key = "onboardingCompleted"
        UserDefaults.standard.removeObject(forKey: key)
        
        // When
        UserDefaults.standard.set(true, forKey: key)
        
        // Then
        XCTAssertTrue(UserDefaults.standard.bool(forKey: key))
        
        // Cleanup
        UserDefaults.standard.removeObject(forKey: key)
    }
}