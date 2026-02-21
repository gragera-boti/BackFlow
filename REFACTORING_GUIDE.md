# BackFlow Refactoring Guide

Quick reference for maintaining AGENTS.md compliance as you build new features.

---

## Creating a New Feature

### 1. Create the Folder Structure
```
Features/
└── MyFeature/
    ├── MyFeatureView.swift
    ├── MyFeatureViewModel.swift
    └── Components/
        ├── MySpecialWidget.swift
        └── MyListRow.swift
```

### 2. Create the ViewModel First
```swift
import Foundation
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "MyFeatureViewModel")

@MainActor @Observable
final class MyFeatureViewModel {
    // MARK: - Published State
    private(set) var items: [Item] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    private let myService: any MyServiceProtocol
    
    // MARK: - Initialization
    init(myService: some MyServiceProtocol) {
        self.myService = myService
    }
    
    // MARK: - Actions
    func loadData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            items = try await myService.fetchItems()
            logger.info("Loaded \(items.count) items")
        } catch let error as MyServiceError {
            logger.error("Service error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription)")
            errorMessage = "An unexpected error occurred"
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
```

**Rules:**
- ✅ Always `@MainActor @Observable final class`
- ✅ Never import SwiftUI (except value types like `SwiftUI.Image` if unavoidable)
- ✅ Use protocol-based dependency injection
- ✅ All state is `private(set)` or private
- ✅ Use OSLog, not `print()`

### 3. Create the View
```swift
import SwiftUI

struct MyFeatureView: View {
    @Environment(\.services) private var services
    @State private var viewModel: MyFeatureViewModel?
    
    var body: some View {
        Group {
            if let vm = viewModel {
                contentView(vm: vm)
            } else {
                ProgressView()
                    .task {
                        guard let services = services else { return }
                        viewModel = MyFeatureViewModel(
                            myService: services.myService
                        )
                        await viewModel?.loadData()
                    }
            }
        }
        .navigationTitle("My Feature")
    }
    
    @ViewBuilder
    private func contentView(vm: MyFeatureViewModel) -> some View {
        @Bindable var bindableVM = vm
        
        List {
            // Your UI here
        }
        .refreshable {
            await vm.loadData()
        }
        .alert("Error", isPresented: .init(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.clearError() } }
        )) {
            Button("OK") { vm.clearError() }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}

#Preview {
    MyFeatureView()
}
```

**Rules:**
- ✅ Keep `body` under 80 lines → extract to methods or components
- ✅ Use `@Bindable` when you need two-way bindings
- ✅ Initialize ViewModel in `.task` after getting services
- ✅ Always add accessibility labels to interactive elements
- ✅ Always include error handling UI

### 4. If Your View Body is > 80 Lines → Extract Components

```swift
// Before: Too big
var body: some View {
    VStack {
        // 100 lines of UI
    }
}

// After: Clean
var body: some View {
    VStack {
        headerSection
        contentSection(vm: vm)
        footerSection
    }
}

@ViewBuilder
private func contentSection(vm: MyFeatureViewModel) -> some View {
    ForEach(vm.items) { item in
        MyListRow(item: item)  // Extracted component
    }
}
```

---

## Creating a Service

### 1. Define the Protocol
```swift
// Services/Protocols/MyServiceProtocol.swift
import Foundation

enum MyServiceError: Error, LocalizedError {
    case notFound
    case saveFailed(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Item not found"
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        }
    }
}

protocol MyServiceProtocol {
    func fetchItems() async throws(MyServiceError) -> [Item]
    func saveItem(_ item: Item) async throws(MyServiceError)
}
```

### 2. Implement the Service
```swift
// Services/Implementations/MyService.swift
import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.backflow.app", category: "MyService")

@MainActor
final class MyService: MyServiceProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchItems() async throws(MyServiceError) -> [Item] {
        let descriptor = FetchDescriptor<Item>()
        
        do {
            let items = try modelContext.fetch(descriptor)
            return items
        } catch {
            logger.error("Failed to fetch items: \(error.localizedDescription)")
            throw .saveFailed(underlying: error)
        }
    }
    
    func saveItem(_ item: Item) async throws(MyServiceError) {
        modelContext.insert(item)
        
        do {
            try modelContext.save()
            logger.info("Saved item: \(item.id)")
        } catch {
            logger.error("Failed to save item: \(error.localizedDescription)")
            throw .saveFailed(underlying: error)
        }
    }
}
```

### 3. Register in ServiceContainer
```swift
// Services/ServiceContainer.swift
@MainActor
final class ServiceContainer {
    // ... existing services
    let myService: MyServiceProtocol
    
    init(modelContext: ModelContext) {
        // ... existing initialization
        self.myService = MyService(modelContext: modelContext)
    }
}
```

---

## Writing Tests

### 1. Create Test File
```swift
// Tests/ViewModelTests/MyFeatureViewModelTests.swift
import Testing
@testable import BackFlow

@Suite("MyFeature ViewModel Tests")
struct MyFeatureViewModelTests {
    
    @Test("Loads items successfully")
    @MainActor
    func testLoadItems() async throws {
        // Given
        let mockService = MockMyService()
        let viewModel = MyFeatureViewModel(myService: mockService)
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(viewModel.items.count == 3)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Handles errors correctly")
    @MainActor
    func testLoadItemsError() async throws {
        // Given
        let mockService = MockMyService(shouldFail: true)
        let viewModel = MyFeatureViewModel(myService: mockService)
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(viewModel.items.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }
}

// MARK: - Mocks

@MainActor
final class MockMyService: MyServiceProtocol {
    var shouldFail = false
    
    init(shouldFail: Bool = false) {
        self.shouldFail = shouldFail
    }
    
    func fetchItems() async throws(MyServiceError) -> [Item] {
        if shouldFail {
            throw .notFound
        }
        return [
            Item(id: UUID(), name: "Item 1"),
            Item(id: UUID(), name: "Item 2"),
            Item(id: UUID(), name: "Item 3")
        ]
    }
    
    func saveItem(_ item: Item) async throws(MyServiceError) {
        if shouldFail {
            throw .saveFailed(underlying: NSError(domain: "test", code: 1))
        }
    }
}
```

---

## Quick Checklist

Before committing:

- [ ] ViewModel is `@MainActor @Observable final class`
- [ ] ViewModel doesn't import SwiftUI
- [ ] View body is under 80 lines
- [ ] File is under 300 lines
- [ ] No force unwraps (`!`)
- [ ] No force try (`try!`)
- [ ] Accessibility labels on interactive elements
- [ ] Error handling UI present
- [ ] OSLog used for logging
- [ ] Tests written for new ViewModels
- [ ] `#Preview` added to new views
- [ ] MARK headers for organization

---

## Common Patterns

### Computed Property in ViewModel
```swift
// ✅ Good: Computed property in ViewModel
var displayText: String {
    items.isEmpty ? "No items" : "\(items.count) items"
}

// ❌ Bad: Computed logic in View
Text(vm.items.isEmpty ? "No items" : "\(vm.items.count) items")
```

### Bindings from @Observable
```swift
// ✅ Good: Use @Bindable wrapper
@ViewBuilder
private func contentView(vm: MyViewModel) -> some View {
    @Bindable var bindableVM = vm
    TextField("Name", text: $bindableVM.name)
}

// ❌ Bad: Manual Binding creation for every property
TextField("Name", text: Binding(
    get: { vm.name },
    set: { vm.name = $0 }
))
```

### Error Handling
```swift
// ✅ Good: Typed errors with localized descriptions
enum MyServiceError: LocalizedError {
    case notFound
    
    var errorDescription: String? {
        "Item not found"
    }
}

// ❌ Bad: Generic errors or string errors
throw NSError(domain: "MyService", code: 1, userInfo: nil)
```

---

## Resources

- **AGENTS.md**: Full iOS development guidelines
- **REFACTOR_AUDIT.md**: Current compliance status
- **REFACTOR_SUMMARY.md**: What we've done so far
- **Apple HIG**: https://developer.apple.com/design/human-interface-guidelines/
- **Swift Testing**: https://developer.apple.com/documentation/testing

---

Happy coding! 🚀
