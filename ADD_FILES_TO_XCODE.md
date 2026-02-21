# Adding New Files to Xcode Project

## Problem
The following files were created but are not yet part of the Xcode project:

### ViewModels
- `BackFlow/Views/Onboarding/GoalAndScheduleViewModel.swift`

### Components
- `BackFlow/Views/Onboarding/Components/GoalToggle.swift`
- `BackFlow/Views/Onboarding/Components/EquipmentToggle.swift`
- `BackFlow/Views/Onboarding/Components/RedFlagQuestion.swift`
- `BackFlow/Views/Onboarding/Components/ReminderSettings.swift`
- `BackFlow/Views/Onboarding/Components/SessionsPerWeekPicker.swift`

## Solution

### Option 1: Add Files via Xcode GUI (Recommended)
1. Open Xcode:
   ```bash
   open BackFlow.xcodeproj
   ```

2. In the Project Navigator (left sidebar), right-click on `BackFlow/Views/Onboarding`

3. Select "Add Files to BackFlow..."

4. Navigate to the Components folder and select all the new component files

5. Make sure "Copy items if needed" is **unchecked** (files are already in the right place)

6. Make sure "BackFlow" target is **checked**

7. Click "Add"

8. Repeat for the ViewModel file

9. Build the project (Cmd+B)

### Option 2: Use Script (If you have xcodeproj gem)
```bash
gem install xcodeproj
ruby add_files_to_project.rb
```

### Option 3: Let Xcode Auto-Detect
Sometimes Xcode will auto-detect new files if you:
1. Close Xcode
2. Delete DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData/BackFlow-*`
3. Reopen the project
4. Clean build folder (Cmd+Shift+K)
5. Build (Cmd+B)

---

## What These Files Do

### GoalAndScheduleViewModel
- **Purpose**: Manages business logic for goal and schedule selection
- **Pattern**: `@MainActor @Observable final class` with protocol-based DI
- **Benefits**: 
  - Testable business logic
  - No SwiftUI in ViewModel
  - Proper error handling with OSLog

### Components
All components follow the pattern:
- Single responsibility
- Accessibility labels built-in
- Reusable across views
- Under 80 lines each

---

## After Adding Files

Once the files are added to the project, the build should succeed. You'll have:

✅ Phase 2 complete: All onboarding views refactored with proper MVVM
✅ All components extracted and accessible
✅ OSLog instead of print() throughout onboarding
✅ Proper error handling

Then you can proceed to Phase 3 (extract remaining large views) or Phase 4 (add tests).

---

## Verification

After adding files, verify:
```bash
xcodebuild -project BackFlow.xcodeproj -scheme BackFlow -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build
```

Should output: `** BUILD SUCCEEDED **`
