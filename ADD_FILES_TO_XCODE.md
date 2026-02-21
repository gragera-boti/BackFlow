# Add These Files to Xcode

The build is failing because these new files need to be added to the Xcode project:

## Steps to Add Files:

1. **In Xcode**, right-click on the appropriate group in the project navigator
2. Choose **"Add Files to BackFlow..."**
3. Navigate to and select these files:
4. Make sure **"Copy items if needed"** is UNCHECKED (files already exist)
5. Make sure **"BackFlow"** target is checked

## Files to Add:

### Views/Sheets/
- `WalkingLogSheet.swift`

### Views/Detail/
- `ExerciseDetailContainer.swift`
- `EducationDetailContainer.swift`
- `ExerciseDetailViewModel.swift`
- `EducationDetailViewModel.swift`

### Views/Session/
- `SessionPlayerContainer.swift`
- `SessionPlayerViewModel.swift`

## Verify Files Were Added:
After adding, make sure each file appears in:
1. The project navigator (left sidebar)
2. The target's "Compile Sources" build phase

## Then Build:
Once added, run:
```bash
./deploy.sh
```

## Alternative: Delete build folder and rebuild
Sometimes Xcode picks up new files automatically:
```bash
rm -rf build
./deploy.sh
```