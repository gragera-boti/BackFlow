import XCTest

final class OnboardingUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        // Reset app state
        app.launchArguments = ["-UITestMode", "-ResetOnboarding"]
        app.launch()
    }
    
    override func tearDown() {
        app.terminate()
        super.tearDown()
    }
    
    func test_completeOnboardingFlow() {
        // Welcome Screen
        XCTAssertTrue(app.staticTexts["Welcome to BackFlow"].exists)
        app.buttons["Get Started"].tap()
        
        // Disclaimer Screen
        XCTAssertTrue(app.staticTexts["Important Medical Information"].exists)
        let acceptToggle = app.switches["I understand and accept"]
        acceptToggle.tap()
        app.buttons["Continue"].tap()
        
        // Red Flags Screen
        XCTAssertTrue(app.staticTexts["Safety Check"].exists)
        // Assuming no red flags
        app.buttons["Continue"].tap()
        
        // Goals & Schedule Screen
        XCTAssertTrue(app.staticTexts["Your Goals"].exists)
        
        // Select at least one goal
        let firstGoal = app.buttons["Reduce flare-ups"]
        XCTAssertTrue(firstGoal.exists)
        firstGoal.tap()
        
        // Verify button is enabled and tap it
        let createPlanButton = app.buttons["Create My Plan"]
        XCTAssertTrue(createPlanButton.exists)
        XCTAssertTrue(createPlanButton.isEnabled)
        createPlanButton.tap()
        
        // Baseline Assessment Screen should appear
        XCTAssertTrue(app.staticTexts["Baseline Assessment"].waitForExistence(timeout: 5))
        
        // Complete baseline assessment
        app.buttons["Complete Assessment"].tap()
        
        // Should now be at main app
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
    }
    
    func test_createMyPlanButton_disabledWithoutGoals() {
        // Navigate to Goals & Schedule
        navigateToGoalsAndSchedule()
        
        // Verify button is disabled initially
        let createPlanButton = app.buttons["Create My Plan"]
        XCTAssertTrue(createPlanButton.exists)
        XCTAssertFalse(createPlanButton.isEnabled)
        
        // Select a goal
        app.buttons["Reduce flare-ups"].tap()
        
        // Verify button is now enabled
        XCTAssertTrue(createPlanButton.isEnabled)
        
        // Deselect the goal
        app.buttons["Reduce flare-ups"].tap()
        
        // Verify button is disabled again
        XCTAssertFalse(createPlanButton.isEnabled)
    }
    
    func test_debugSkipButton_navigatesToBaseline() {
        // Navigate to Goals & Schedule
        navigateToGoalsAndSchedule()
        
        // Find and tap debug skip button
        let debugButton = app.buttons["DEBUG: Skip (Force Continue)"]
        XCTAssertTrue(debugButton.exists)
        debugButton.tap()
        
        // Should navigate to Baseline Assessment
        XCTAssertTrue(app.staticTexts["Baseline Assessment"].waitForExistence(timeout: 5))
    }
    
    // Helper Methods
    
    private func navigateToGoalsAndSchedule() {
        // Welcome
        app.buttons["Get Started"].tap()
        
        // Disclaimer
        app.switches["I understand and accept"].tap()
        app.buttons["Continue"].tap()
        
        // Red Flags (no flags)
        app.buttons["Continue"].tap()
        
        // Should now be at Goals & Schedule
        XCTAssertTrue(app.staticTexts["Your Goals"].waitForExistence(timeout: 3))
    }
}