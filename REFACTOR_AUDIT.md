# BackFlow Refactor Audit
## Compliance with AGENTS.md Standards

### ✅ Already Compliant

1. **MVVM Architecture**
   - Features folder with ViewModels ✅
   - Services layer with protocols ✅
   - Separation of concerns mostly good ✅

2. **ViewModels**
   - `@MainActor @Observable final class` ✅
   - Protocol-based dependency injection ✅
   - No SwiftUI imports (checking...)

3. **Services**
   - Protocol-defined ✅
   - Typed errors (Swift 6.2 typed throws) ✅
   - OSLog logging ✅

4. **Project Structure**
   - Features/ folder ✅
   - Services/Protocols and Services/Implementations ✅
   - Models/ folder ✅
   - Theme/ folder ✅

### ❌ Needs Work

1. **Onboarding Views Missing ViewModels**
   - `BaselineAssessmentView` - has business logic inline
   - `GoalAndScheduleView` - has business logic inline
   - `RedFlagsView` - probably simple enough
   - `OnboardingFlow` - coordinator logic inline

2. **Missing Tests**
   - No Swift Testing tests yet
   - Need ViewModel tests
   - Need Service tests

3. **View Bodies > 80 Lines**
   - Need to audit all views and extract components

4. **Accessibility**
   - Need to add `.accessibilityLabel()` to all interactive elements
   - Need `.accessibilityHint()` where appropriate

5. **Error Handling**
   - Some views might have force-unwraps
   - Need to audit for `!` and `try!`

6. **Documentation**
   - Need DocC comments on public APIs
   - Need Documentation.md

7. **Navigation**
   - AppRouter exists but not fully centralized

### 📋 Audit Tasks

#### Phase 1: Code Audit
- [ ] Check all ViewModels for SwiftUI imports
- [ ] Find all view bodies > 80 lines
- [ ] Find all files > 300 lines
- [ ] Find all force-unwraps and force-tries
- [ ] Check all views for accessibility labels

#### Phase 2: Refactor Onboarding
- [ ] Create `BaselineAssessmentViewModel`
- [ ] Create `GoalAndScheduleViewModel`
- [ ] Create `OnboardingCoordinator` (ViewModel)
- [ ] Extract view components to meet 80-line rule

#### Phase 3: Testing
- [ ] Set up Swift Testing framework
- [ ] Write tests for `TodayViewModel`
- [ ] Write tests for `ProgramService`
- [ ] Write tests for `BaselineAssessmentViewModel`
- [ ] Write tests for onboarding flow

#### Phase 4: Accessibility
- [ ] Add labels to all buttons
- [ ] Add labels to all interactive elements
- [ ] Test with VoiceOver

#### Phase 5: Documentation
- [ ] Create Documentation.md
- [ ] Add DocC comments to service protocols
- [ ] Add file-level comments with MARK headers
- [ ] Update README if exists

#### Phase 6: Polish
- [ ] Remove all force-unwraps
- [ ] Add loading states where missing
- [ ] Add error states where missing
- [ ] Ensure all animations use modern SwiftUI APIs

---

## Execution Plan

Starting with Phase 1: Code Audit
