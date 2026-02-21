# BackFlow - Low Back Pain Rehab Tracker

**Evidence-based rehab tracker for iOS**

## Overview

BackFlow is an iOS-only app designed to help people self-manage non-specific low back pain through:
- Progressive exercise therapy
- Evidence-based education
- Conservative symptom-guided progression
- Walking habit building

**Tech Stack:**
- SwiftUI (iOS 17+)
- SwiftData (local-first persistence)
- CloudKit (optional Premium iCloud sync)
- StoreKit 2 (subscriptions)
- No custom backend

## Features

### Free Tier
✅ Complete onboarding with safety screening  
✅ 10-week progressive rehab program  
✅ Daily session player with exercise library  
✅ Pain & symptom tracking  
✅ Walking target tracking  
✅ Education cards (evidence-based)  
✅ Progress charts  
✅ Local data persistence  
✅ Daily reminder notifications  

### Premium (Subscription)
⭐ iCloud sync across devices  
⭐ Advanced progression settings  
⭐ Data export (CSV/PDF)  
⭐ Custom schedule options  
⭐ Home screen widgets  
⭐ HealthKit integration (optional walking import)  

## Architecture

The app follows strict **MVVM + Services** architecture with protocol-based dependency injection:

```
BackFlow/
├── BackFlowApp.swift              # App entry point with DI setup
├── ContentView.swift              # Root navigation with TabView
│
├── Theme/
│   ├── Theme.swift                # Design tokens (colors, spacing, typography)
│   └── Components/                # Reusable UI components
│       ├── PrimaryButton.swift
│       └── CardView.swift
│
├── Models/
│   ├── UserProfile.swift          # Individual @Model classes
│   ├── Exercise.swift
│   ├── Session.swift
│   └── ... (other models)
│
├── Services/
│   ├── ServiceContainer.swift     # DI container
│   ├── Protocols/                 # Service protocols
│   │   ├── ProgramServiceProtocol.swift
│   │   ├── SessionServiceProtocol.swift
│   │   └── ... (other protocols)
│   └── Implementations/
│       ├── ProgramService.swift
│       ├── RevenueCatSubscriptionService.swift
│       └── ... (other implementations)
│
├── Features/                      # Feature-based organization
│   ├── Today/
│   │   ├── TodayView.swift
│   │   ├── TodayViewModel.swift
│   │   └── Components/
│   ├── Plan/
│   ├── Progress/
│   ├── Library/
│   └── Settings/
│
├── Navigation/
│   └── AppRouter.swift            # Centralized navigation
│
├── SeedData/                      # JSON content
│   ├── exercises.json
│   ├── program_templates.json
│   └── education_cards.json
│
└── Tests/
    ├── ViewModelTests/
    └── ServiceTests/
```

### Key Principles

- **ViewModels:** `@MainActor @Observable` classes managing state
- **Services:** Protocol-based with dependency injection
- **Views:** Pure presentation, no business logic
- **Navigation:** Centralized router pattern
- **Testing:** Protocol-based mocking for easy unit testing

## Core Logic: 24-Hour Response Progression

The `PlanEngine` uses a conservative, symptom-limited progression strategy:

1. **Red flags detected** → Pause plan, show Stop & Seek Care
2. **Next-day pain > threshold** → Regress volume OR switch to Phase 0
3. **Post-session pain > threshold** → Repeat session with reduced volume
4. **Stable response** → Progress (increase ONE variable: reps, sets, hold time, or walking minutes)

**Pain threshold:** Default 3/10 (editable in Premium)

## Data Model

### Core Entities
- `UserProfile` — goals, schedule, settings
- `Exercise` (seeded) — library with cues, dosage, evidence refs
- `EducationCard` (seeded) — markdown content + references
- `ProgramTemplate` (seeded) — 10-week progressive template
- `ProgramPlan` — user's active plan state
- `Session` — completed workout with set logs
- `SymptomLog` — pain + red flags
- `FunctionLog` — baseline functional tasks
- `WalkingLog` — walking minutes (manual or HealthKit)

## Safety Design

### Red Flag Screening
Onboarding includes a **blocking red flag questionnaire**:
- Bowel/bladder changes
- Saddle numbness
- Progressive weakness
- Fever with pain
- Major trauma
- Unexplained weight loss
- Severe night pain

If any are YES → **Stop & Seek Care** (plan remains paused)

### Medical Disclaimer
Must be shown and accepted during onboarding. No diagnostic claims.

### Content Accuracy
All exercises and education cards include `evidenceRefs` (links to published research). Content should be reviewed by a qualified clinician before release.

## Getting Started

### Prerequisites
- Xcode 15+
- iOS 17+ simulator or device
- Apple Developer account (for StoreKit testing)

### Setup

1. **Open in Xcode**
   ```bash
   open BackFlow.xcodeproj
   ```

2. **Add Seed Data**
   - Ensure `SeedData/` folder is in the project target
   - JSON files will auto-import on first launch

3. **Configure App ID**
   - Update bundle identifier in project settings
   - Enable:
     - iCloud (CloudKit)
     - Push Notifications
     - In-App Purchase

4. **StoreKit Configuration**
   - Create `.storekit` configuration file
   - Add products:
     - `com.backflow.premium.monthly`
     - `com.backflow.premium.yearly`

5. **Run**
   ```
   Cmd+R in Xcode
   ```

## Subscription Setup

### RevenueCat Integration
The app uses RevenueCat for subscription management with separate test/production environments:

- **Debug builds:** Use RevenueCat test store
- **Release builds:** Use real App Store

### App Store Connect
1. Create app record with bundle ID: `com.albgra.BackFlow`
2. Configure In-App Purchases:
   - Monthly: `com.albgra.BackFlow.premium.monthly` ($2.99)
   - Yearly: `com.albgra.BackFlow.premium.yearly` ($19.99)
3. Set up subscription group: "BackFlow Premium"
4. 7-day free trial enabled for both plans

### Testing
- StoreKit configuration file (`BackFlow.storekit`) included for local testing
- RevenueCat sandbox environment enabled for debug builds
- Test purchases without charging real money

See `ASC_REVENUECAT_SETUP.md` for complete setup instructions.

## CloudKit Sync Strategy

- **Local-first:** All data stored in local SwiftData store by default
- **Premium toggle:** Enables CloudKit private database sync
- **Migration:** When enabled, copies local data → cloud store
- **Conflict resolution:** Last-write-wins (via CloudKit automatic handling)

## Content Authoring

### Exercises (`SeedData/exercises.json`)
```json
{
  "slug": "cat-cow",
  "name": "Cat-Cow",
  "category": "mobility",
  "regions": ["lumbar"],
  "equipment": ["none"],
  "difficulty": "beginner",
  "setsDefault": 2,
  "repsDefault": 8,
  "primaryCues": ["Start on hands and knees", "Arch back", "Round back"],
  "commonMistakes": ["Moving too fast"],
  "progressions": ["Add holds at end range"],
  "regressions": ["Smaller range of motion"],
  "dosageNotes": "Slow and controlled",
  "evidenceRefs": ["mcgill2015"],
  "illustrationAssetName": "cat-cow.svg"
}
```

### Program Templates (`SeedData/program_templates.json`)
Defines phases, session templates, and activity ladder progression.

### Education Cards (`SeedData/education_cards.json`)
Markdown-based educational content with evidence references.

## Roadmap

### MVP (Current Build)
- [x] Full onboarding with safety
- [x] 10-week program with conservative progression
- [x] Session player
- [x] Pain & walking tracking
- [x] Progress charts
- [x] Education library
- [x] Local persistence
- [x] StoreKit 2 Premium
- [ ] CloudKit sync implementation
- [ ] Widgets
- [ ] Export (CSV/PDF)

### Post-MVP
- [ ] HealthKit step import
- [ ] Additional program templates (return to lifting, postpartum, etc.)
- [ ] Customizable exercise library
- [ ] Shareable session summaries
- [ ] Clinician review mode (export for PT)

## Clinical Content Review

**⚠️ IMPORTANT:** All exercise instructions, dosage recommendations, and educational content should be reviewed by a licensed physical therapist or sports medicine physician before public release.

Evidence references are provided for transparency but do not constitute medical advice.

## License

All rights reserved. (Update with appropriate license)

## Contact

- **Support:** support@backflow.app
- **Privacy:** privacy@backflow.app

---

Built with ❤️ for people managing low back pain.
