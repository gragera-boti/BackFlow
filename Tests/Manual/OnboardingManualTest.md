# Manual Test: Onboarding Flow

This test verifies the "Create My Plan" button functionality in the onboarding flow.

## Test Steps

### Setup
1. Delete and reinstall the app (or use "Reset All Data" in Settings)
2. Open BackFlow app
3. Open Xcode → Window → Devices and Simulators → Select your device → Open Console
4. Filter console for "BackFlow" to see app logs

### Test Execution

#### Step 1: Welcome Screen
- [ ] Verify "Welcome to BackFlow" text appears
- [ ] Tap "Get Started" button
- Console should show: `OnboardingFlow - currentStep: 1`

#### Step 2: Disclaimer Screen  
- [ ] Verify "Important Medical Information" text appears
- [ ] Toggle "I understand and accept"
- [ ] Tap "Continue" button
- Console should show: `OnboardingFlow - currentStep: 2`

#### Step 3: Red Flags Screen
- [ ] Verify "Safety Check" text appears
- [ ] Select "No" for all red flags
- [ ] Tap "Continue" button
- Console should show: `OnboardingFlow - currentStep: 3`

#### Step 4: Goals & Schedule Screen
- [ ] Verify "Your Goals" text appears
- [ ] Verify "Create My Plan" button is disabled (gray)
- [ ] Select at least one goal (e.g., "Reduce flare-ups")
- [ ] Verify button becomes enabled (blue)
- [ ] Tap "Create My Plan" button

#### Expected Console Output:
```
Button action triggered
Goals selected: ["Reduce flare-ups"]
saveAndContinue called - selectedGoals: ["Reduce flare-ups"]
UserProfile created and inserted
ProgramPlan created and inserted
Profile and program plan saved successfully
About to call onContinue
OnboardingFlow: Advancing from GoalAndSchedule to BaselineAssessment
onContinue called
OnboardingFlow - currentStep: 4
BaselineAssessmentView rendered
```

#### Step 5: Baseline Assessment Screen
- [ ] Verify "Baseline Assessment" text appears
- [ ] Complete the assessment
- [ ] Tap "Complete Assessment"

### Test Results

**PASS Criteria:**
- All console logs appear in order
- Navigation progresses from step 3 to step 4
- Baseline Assessment screen appears after tapping "Create My Plan"

**FAIL Criteria:**
- Console logs stop at any point
- No navigation occurs after tapping button
- Error messages appear in console

## Debugging

If the test fails:

1. **Button doesn't become enabled:**
   - Check that goals are properly selected (should turn blue)
   - Console should show goal selection

2. **Button tap does nothing:**
   - Check console for "Button action triggered"
   - If missing, the button action isn't firing
   - Try the "DEBUG: Skip (Force Continue)" button

3. **Navigation doesn't occur:**
   - Check if "onContinue called" appears
   - Check if currentStep changes from 3 to 4
   - Look for any error messages

## Alternative Test

If the main button fails, test the debug button:
1. On Goals & Schedule screen, tap "DEBUG: Skip (Force Continue)"
2. Console should show: `DEBUG: Force continue tapped`
3. Should navigate directly to Baseline Assessment