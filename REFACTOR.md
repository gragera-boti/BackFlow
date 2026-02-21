# BackFlow Architecture Refactor

**Date:** February 21, 2026  
**Status:** In Progress  
**Branch:** `refactor/mvvm-architecture`

## Overview

Complete architectural refactor of BackFlow to follow strict MVVM + Services pattern with protocol-based dependency injection, as specified in the iOS development guidelines.

---

## Architecture Changes

### Before: Mixed Concerns
- ❌ Views directly using `@Query` and `@Environment(\.modelContext)`
- ❌ Business logic scattered in views
- ❌ No ViewModels
- ❌ Services without protocols
- ❌ Direct `NavigationLink` usage
- ❌ No design token system
- ❌ Monolithic view files

### After: MVVM + Services
- ✅ **Views:** Pure presentation, no business logic
- ✅ **ViewModels:** `@MainActor @Observable`, manage state and logic
- ✅ **Services:** Protocol-based, dependency-injected via `ServiceContainer`
- ✅ **Navigation:** Centralized `AppRouter` with `NavigationPath`
- ✅ **Theme:** Design tokens and reusable components
- ✅ **Structure:** Feature-based folders with components

---

## New Folder Structure

```
BackFlow/
├── BackFlowApp.swift              # App entry point with DI setup
├── ContentView.swift              # Root navigation with TabView
│
├── Theme/
│   ├── Theme.swift                # Design tokens (colors, spacing, typography)
│   └── Components/
│       ├── PrimaryButton.swift
│       └── CardView.swift
│
├── Models/
│   └── (All @Model classes from Models.swift - to be split)
│
├── Services/
│   ├── ServiceContainer.swift     # DI container + Environment key
│   ├── Protocols/
│   │   ├── ProgramServiceProtocol.swift
│   │   ├── SessionServiceProtocol.swift
│   │   ├── ExerciseServiceProtocol.swift
│   │   ├── EducationServiceProtocol.swift
│   │   └── WalkingServiceProtocol.swift
│   └── Implementations/
│       ├── ProgramService.swift
│       ├── SessionService.swift
│       ├── ExerciseService.swift
│       ├── EducationService.swift
│       └── WalkingService.swift
│
├── Features/
│   └── Today/
│       ├── TodayView.swift
│       ├── TodayViewModel.swift
│       └── Components/
│           ├── TodaySessionCard.swift
│           ├── WalkingTargetCard.swift
│           ├── QuickLogCard.swift
│           └── EducationBiteCard.swift
│
└── Navigation/
    └── AppRouter.swift            # Centralized navigation state
```

---

## Dependency Injection Pattern

### Service Container
Services are initialized with `ModelContext` and registered in a `ServiceContainer`:

```swift
@MainActor
final class ServiceContainer {
    let programService: ProgramServiceProtocol
    let sessionService: SessionServiceProtocol
    // ...
    
    init(modelContext: ModelContext) {
        self.programService = ProgramService(modelContext: modelContext)
        // ...
    }
}
```

### Environment Injection
Container is injected via SwiftUI Environment:

```swift
// In App:
.serviceContainer(ServiceContainer(modelContext: modelContainer.mainContext))

// In View:
@Environment(\.services) private var services
```

### ViewModel Initialization
ViewModels receive protocol-based services:

```swift
@MainActor @Observable
final class TodayViewModel {
    private let programService: ProgramServiceProtocol
    private let sessionService: SessionServiceProtocol
    
    init(
        programService: ProgramServiceProtocol,
        sessionService: SessionServiceProtocol
    ) {
        self.programService = programService
        self.sessionService = sessionService
    }
}
```

---

## Navigation Pattern

### Centralized Router
All navigation goes through `AppRouter`:

```swift
@MainActor @Observable
final class AppRouter {
    var path = NavigationPath()
    
    func navigate(to destination: AppDestination) {
        path.append(destination)
    }
}
```

### Destination Enum
Type-safe navigation destinations:

```swift
enum AppDestination: Hashable {
    case exerciseDetail(exerciseSlug: String)
    case educationDetail(cardId: String)
    case sessionPlayer(sessionId: UUID)
    // ...
}
```

### Usage in Views
```swift
router.navigate(to: .sessionPlayer(sessionId: session.id))
```

---

## Completed Refactors

### ✅ Infrastructure
- [x] Theme system with design tokens
- [x] Reusable components (PrimaryButton, CardView)
- [x] Service protocols (5 protocols)
- [x] Service implementations (5 services)
- [x] ServiceContainer with Environment injection
- [x] AppRouter with navigation destinations
- [x] Updated BackFlowApp.swift with DI

### ✅ Features
- [x] Today screen (View + ViewModel + 4 Components)

---

## Remaining Work

### 🚧 Features to Refactor
- [ ] Plan screen
- [ ] Progress/Tracking screen
- [ ] Library screen
- [ ] Exercise Detail screen
- [ ] Education Detail screen
- [ ] Session Player screen
- [ ] Settings screen
- [ ] Onboarding flow
- [ ] Quick Log sheet
- [ ] Walking Log sheet

### 🚧 Models
- [ ] Split Models.swift into individual files
- [ ] Move to Models/ directory
- [ ] Group related enums

### 🚧 Services
- [ ] PlanEngine → refactor into ProgramService methods
- [ ] NotificationService (create protocol)
- [ ] SubscriptionService (create protocol)
- [ ] SeedImportService (create protocol)

### 🚧 Testing
- [ ] Unit tests for ViewModels
- [ ] Unit tests for Services (with mock protocols)
- [ ] Integration tests

### 🚧 Documentation
- [ ] Update README.md
- [ ] Add inline documentation
- [ ] Create API docs with DocC

---

## Migration Guide

### For Views

**Before:**
```swift
struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plans: [ProgramPlan]
    
    var body: some View {
        // Direct data access
    }
}
```

**After:**
```swift
struct TodayView: View {
    @Environment(\.services) private var services
    @State private var viewModel: TodayViewModel?
    
    var body: some View {
        // Use viewModel state
    }
}
```

### For Business Logic

**Before:**
```swift
// In View
let totalMinutes = walkingLogs
    .filter { Calendar.current.isDateInToday($0.date) }
    .reduce(0) { $0 + $1.durationMinutes }
```

**After:**
```swift
// In ViewModel
private(set) var todayWalkingMinutes: Int = 0

func loadData() async {
    todayWalkingMinutes = try await walkingService.fetchTodayTotal()
}
```

### For Navigation

**Before:**
```swift
NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
    Text("View Exercise")
}
```

**After:**
```swift
Button("View Exercise") {
    router.navigate(to: .exerciseDetail(exerciseSlug: exercise.slug))
}

// Destination mapping in ContentView:
.navigationDestination(for: AppDestination.self) { destination in
    // ...
}
```

---

## Benefits

1. **Testability:** Protocol-based services enable easy mocking
2. **Separation of Concerns:** Views, ViewModels, and Services have clear responsibilities
3. **Maintainability:** Feature-based folders keep related code together
4. **Type Safety:** Centralized navigation with enum destinations
5. **Consistency:** Theme system ensures design coherence
6. **Scalability:** Clean architecture supports feature growth

---

## Testing Strategy

### Unit Tests
```swift
@MainActor
final class TodayViewModelTests: XCTestCase {
    func test_loadData_populatesState() async {
        // Arrange
        let mockService = MockProgramService()
        mockService.stubbedPlan = ProgramPlan(...)
        let vm = TodayViewModel(programService: mockService, ...)
        
        // Act
        await vm.loadData()
        
        // Assert
        XCTAssertNotNil(vm.activePlan)
    }
}
```

---

## Next Steps

1. **Immediate:** Refactor remaining main screens (Plan, Progress, Library)
2. **Short-term:** Split Models.swift, refactor detail screens
3. **Mid-term:** Add comprehensive unit tests
4. **Long-term:** Extract shared components into a design system module

---

## Notes

- All service methods use typed `throws(ServiceError)` for explicit error handling
- ViewModels are `@MainActor @Observable` classes (never structs)
- Services never import SwiftUI
- Max file length: ~300 lines (extract when exceeded)
- Component subviews extracted when view body exceeds ~80 lines
